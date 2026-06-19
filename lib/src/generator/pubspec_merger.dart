import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class PubspecMerger {
  final String projectRoot;

  PubspecMerger({required this.projectRoot});

  void merge(Map<String, String> dependencies) {
    if (dependencies.isEmpty) return;

    final pubspecPath = p.join(projectRoot, 'pubspec.yaml');
    final file = File(pubspecPath);
    if (!file.existsSync()) {
      throw Exception('pubspec.yaml not found at $pubspecPath');
    }

    // Normalize to LF so split/join is consistent on Windows (CRLF) and Unix.
    final content = file.readAsStringSync().replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final yaml = loadYaml(content) as YamlMap;
    final existingDeps = (yaml['dependencies'] as YamlMap?)?.keys.toSet() ?? {};

    var updated = content;
    for (final entry in dependencies.entries) {
      if (existingDeps.contains(entry.key)) continue;
      updated = _insertDependency(updated, entry.key, entry.value);
    }

    file.writeAsStringSync(updated);
  }

  String _insertDependency(String content, String name, String version) {
    final lines = content.split('\n');
    final idx = lines.indexWhere((l) => l.trimRight() == 'dependencies:');
    if (idx == -1) return '$content\ndependencies:\n  $name: $version\n';
    lines.insert(idx + 1, '  $name: $version');
    return lines.join('\n');
  }
}
