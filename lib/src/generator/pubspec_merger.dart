import 'dart:io';
import 'package:path/path.dart' as p;

typedef ProcessRunner = Future<ProcessResult> Function(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
});

class PubspecMerger {
  final String projectRoot;
  final ProcessRunner _run;

  PubspecMerger({required this.projectRoot, ProcessRunner? processRunner})
      : _run = processRunner ?? _defaultRunner;

  static Future<ProcessResult> _defaultRunner(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) =>
      Process.run(executable, arguments, workingDirectory: workingDirectory);

  Future<void> merge(Map<String, String> dependencies) async {
    if (dependencies.isEmpty) return;

    final pubspecPath = p.join(projectRoot, 'pubspec.yaml');
    if (!File(pubspecPath).existsSync()) {
      throw Exception('pubspec.yaml not found at $pubspecPath');
    }

    final args = ['pub', 'add'];
    for (final entry in dependencies.entries) {
      args.add('${entry.key}:${entry.value}');
    }

    final result = await _run('flutter', args, workingDirectory: projectRoot);
    if (result.exitCode != 0) {
      throw Exception('flutter pub add failed:\n${result.stderr}');
    }
  }
}
