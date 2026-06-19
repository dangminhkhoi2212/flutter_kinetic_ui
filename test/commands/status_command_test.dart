import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:flutter_kinetic_ui/src/commands/status_command.dart';

void main() {
  late Directory projectDir;

  setUp(() {
    projectDir = Directory.systemTemp.createTempSync('status_test_');
  });

  tearDown(() => projectDir.deleteSync(recursive: true));

  test('getInstalledSummary returns empty list when not initialized', () {
    final summary = getInstalledSummary(projectRoot: projectDir.path);
    expect(summary, isEmpty);
  });

  test('getInstalledSummary returns installed components', () {
    final stateFile = File(p.join(projectDir.path, '.kinetic', 'kinetic.json'));
    stateFile.parent.createSync(recursive: true);
    stateFile.writeAsStringSync(jsonEncode({
      'registry': 'https://example.com',
      'components': {'tokens': '1.0.0', 'button': '1.0.0'},
    }));

    final summary = getInstalledSummary(projectRoot: projectDir.path);
    expect(summary.length, 2);
    expect(summary.any((e) => e.name == 'button'), isTrue);
  });
}
