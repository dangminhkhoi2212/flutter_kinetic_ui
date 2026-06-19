import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import '../registry/registry_client.dart';
import '../state/kinetic_state.dart';

enum DiffType { added, removed }

class DiffLine {
  final DiffType type;
  final String content;
  DiffLine(this.type, this.content);
}

/// Pure function — computes line-level diff using LCS.
List<DiffLine> computeDiff(String local, String remote) {
  if (local == remote) return const [];

  final localLines  = local.isEmpty  ? <String>[] : local.split('\n');
  final remoteLines = remote.isEmpty ? <String>[] : remote.split('\n');

  final lcs = _lcs(localLines, remoteLines);
  final result = <DiffLine>[];
  int i = 0, j = 0, k = 0;

  while (i < localLines.length || j < remoteLines.length) {
    final inLcs = k < lcs.length;
    final localMatches  = inLcs && i < localLines.length  && localLines[i]  == lcs[k];
    final remoteMatches = inLcs && j < remoteLines.length && remoteLines[j] == lcs[k];

    if (localMatches && remoteMatches) {
      i++; j++; k++;
    } else if (!remoteMatches && j < remoteLines.length &&
        (k >= lcs.length || !localMatches)) {
      result.add(DiffLine(DiffType.added, remoteLines[j++]));
    } else if (i < localLines.length) {
      result.add(DiffLine(DiffType.removed, localLines[i++]));
    } else {
      result.add(DiffLine(DiffType.added, remoteLines[j++]));
    }
  }
  return result;
}

List<String> _lcs(List<String> a, List<String> b) {
  final m = a.length, n = b.length;
  if (m == 0 || n == 0 || m * n > 500000) return [];

  final dp = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));
  for (var i = 1; i <= m; i++) {
    for (var j = 1; j <= n; j++) {
      dp[i][j] = a[i - 1] == b[j - 1]
          ? dp[i - 1][j - 1] + 1
          : (dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1]);
    }
  }

  final result = <String>[];
  var i = m, j = n;
  while (i > 0 && j > 0) {
    if (a[i - 1] == b[j - 1]) {
      result.insert(0, a[i - 1]);
      i--; j--;
    } else if (dp[i - 1][j] > dp[i][j - 1]) {
      i--;
    } else {
      j--;
    }
  }
  return result;
}

class DiffCommand extends Command<void> {
  @override
  String get name => 'diff';

  @override
  String get description =>
      'Show differences between local and registry versions';

  DiffCommand() {
    argParser.addFlag('all',
        help: 'Diff all installed components', negatable: false);
  }

  @override
  Future<void> run() async {
    final diffAll = argResults!['all'] as bool;
    final names = argResults!.rest;

    if (!diffAll && names.isEmpty) {
      print('Usage: dart run flutter_kinetic_ui diff <component> [--all]');
      printUsage();
      return;
    }

    final projectRoot = Directory.current.path;
    final state = KineticState(projectRoot: projectRoot);
    final client = RegistryClient();

    print('Fetching registry...');
    final manifest = await client.fetchManifest();
    final installed = state.installedComponents;
    final targets = diffAll ? installed.keys.toList() : names.toList();

    var anyDiff = false;
    for (final name in targets) {
      final component = manifest.findByName(name);
      if (component == null) {
        print('⚠ Unknown component: $name');
        continue;
      }

      for (final file in component.files) {
        final localPath = p.join(projectRoot, 'lib', 'kinetic', file);
        final localFile = File(localPath);

        if (!localFile.existsSync()) {
          print('$file: not installed locally');
          anyDiff = true;
          continue;
        }

        final localContent = localFile.readAsStringSync();
        final remoteContent = await client.fetchFile(file);
        final diff = computeDiff(localContent, remoteContent);

        if (diff.isEmpty) {
          print('$file: no changes');
        } else {
          anyDiff = true;
          print('\n--- local/$file');
          print('+++ registry@${manifest.version}/$file');
          for (final line in diff) {
            final prefix = line.type == DiffType.added ? '+' : '-';
            print('$prefix ${line.content}');
          }
        }
      }
    }

    if (!anyDiff) print('\nAll components are up to date.');
  }
}
