import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../generator/barrel_generator.dart';
import '../generator/pubspec_merger.dart';
import '../registry/dependency_resolver.dart';
import '../registry/registry_client.dart';
import '../registry/registry_manifest.dart';
import '../state/kinetic_state.dart';

String _safeDestPath(String projectRoot, String file) {
  final boundary = p.normalize(p.join(projectRoot, 'lib', 'kinetic'));
  final dest = p.normalize(p.join(projectRoot, 'lib', 'kinetic', file));
  if (!dest.startsWith(boundary)) {
    throw ArgumentError('Unsafe registry file path: $file');
  }
  return dest;
}

Future<void> runAdd({
  required List<String> names,
  required bool addAll,
  required bool force,
  required String projectRoot,
  http.Client? httpClient,
  ProcessRunner? processRunner,
}) async {
  if (!addAll && names.isEmpty) {
    print(
      'Usage: dart run flutter_kinetic_ui add <component> [--all] [--force]',
    );
    return;
  }

  final state = KineticState(projectRoot: projectRoot);
  final client = RegistryClient(httpClient: httpClient, token: state.token);

  try {
    print('Fetching registry...');
    final manifest = await client.fetchManifest();

    final targetNames = addAll
        ? manifest.components.map((c) => c.name).toList()
        : names.toList();

    final resolver = DependencyResolver(manifest.components);
    final resolved = resolver.resolve(targetNames);
    final installed = state.installedComponents;

    final toInstall = <RegistryComponent>[];
    final alreadyExisting = <RegistryComponent>[];

    for (final c in resolved) {
      if (installed.containsKey(c.name)) {
        alreadyExisting.add(c);
      } else {
        toInstall.add(c);
      }
    }

    if (force && alreadyExisting.isNotEmpty) {
      final existingNames = alreadyExisting.map((c) => c.name).join(', ');
      stdout.write(
        '⚠ $existingNames already exist. --force will overwrite local changes. Continue? (y/N) ',
      );
      final input = stdin.readLineSync()?.toLowerCase();
      if (input != 'y') {
        print('Aborted.');
        return;
      }
      toInstall.addAll(alreadyExisting);
    } else if (alreadyExisting.isNotEmpty) {
      final existingNames = alreadyExisting.map((c) => c.name).join(', ');
      print(
        'Skipping already installed: $existingNames (use --force to overwrite)',
      );
    }

    if (toInstall.isEmpty) {
      print('Nothing new to install.');
      return;
    }

    final merger = PubspecMerger(projectRoot: projectRoot, processRunner: processRunner);
    for (final component in toInstall) {
      print('Adding ${component.name}...');
      for (final file in component.files) {
        final content = await client.fetchFile(file);
        final destPath = _safeDestPath(projectRoot, file);
        File(destPath).parent.createSync(recursive: true);
        File(destPath).writeAsStringSync(content);
      }
      if (component.pubspecDependencies.isNotEmpty) {
        await merger.merge(component.pubspecDependencies);
      }
      state.markInstalled(component.name, manifest.version);
    }

    BarrelGenerator(
      projectRoot: projectRoot,
    ).regenerate(manifest, state.installedComponents.keys.toList());

    print('\n✓ Done!');
  } finally {
    client.close();
  }
}

class AddCommand extends Command<void> {
  @override
  String get name => 'add';

  @override
  String get description => 'Add component(s) to your project';

  AddCommand() {
    argParser
      ..addFlag('all', help: 'Add all available components', negatable: false)
      ..addFlag(
        'force',
        abbr: 'f',
        help: 'Overwrite existing components',
        negatable: false,
      );
  }

  @override
  Future<void> run() => runAdd(
    names: argResults!.rest,
    addAll: argResults!['all'] as bool,
    force: argResults!['force'] as bool,
    projectRoot: Directory.current.path,
  );
}
