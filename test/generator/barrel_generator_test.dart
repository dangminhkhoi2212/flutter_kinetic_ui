import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:flutter_kinetic_ui/src/generator/barrel_generator.dart';
import 'package:flutter_kinetic_ui/src/registry/registry_manifest.dart';

RegistryComponent comp(String name, List<String> files,
        [List<String> deps = const []]) =>
    RegistryComponent(
        name: name,
        files: files,
        dependsOn: deps,
        pubspecDependencies: {},
        version: '1.0.0');

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('barrel_test_');
    Directory(p.join(tempDir.path, 'lib', 'kinetic')).createSync(recursive: true);
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  group('BarrelGenerator', () {
    test('generates AUTO-GENERATED header', () {
      final manifest = RegistryManifest(version: '1.0.0', components: [
        comp('tokens', ['tokens/kinetic_colors.dart']),
      ]);
      BarrelGenerator(projectRoot: tempDir.path)
          .regenerate(manifest, ['tokens']);
      final content = File(p.join(tempDir.path, 'lib', 'kinetic', 'kinetic_ui.dart'))
          .readAsStringSync();
      expect(content, startsWith('// AUTO-GENERATED'));
    });

    test('exports all files for installed components', () {
      final manifest = RegistryManifest(version: '1.0.0', components: [
        comp('tokens', ['tokens/kinetic_colors.dart', 'tokens/kinetic_spacing.dart']),
        comp('button', ['components/button/button.dart'], ['tokens']),
      ]);
      BarrelGenerator(projectRoot: tempDir.path)
          .regenerate(manifest, ['tokens', 'button']);
      final content = File(p.join(tempDir.path, 'lib', 'kinetic', 'kinetic_ui.dart'))
          .readAsStringSync();
      expect(content, contains("export 'tokens/kinetic_colors.dart';"));
      expect(content, contains("export 'tokens/kinetic_spacing.dart';"));
      expect(content, contains("export 'components/button/button.dart';"));
    });

    test('omits files for non-installed components', () {
      final manifest = RegistryManifest(version: '1.0.0', components: [
        comp('tokens', ['tokens/kinetic_colors.dart']),
        comp('button', ['components/button/button.dart'], ['tokens']),
      ]);
      BarrelGenerator(projectRoot: tempDir.path)
          .regenerate(manifest, ['tokens']); // button NOT installed
      final content = File(p.join(tempDir.path, 'lib', 'kinetic', 'kinetic_ui.dart'))
          .readAsStringSync();
      expect(content, isNot(contains('button.dart')));
    });

    test('overwrites existing barrel on regenerate', () {
      final manifest = RegistryManifest(version: '1.0.0', components: [
        comp('tokens', ['tokens/kinetic_colors.dart']),
      ]);
      final gen = BarrelGenerator(projectRoot: tempDir.path);
      gen.regenerate(manifest, ['tokens']);
      gen.regenerate(manifest, ['tokens']); // call twice
      final lines = File(p.join(tempDir.path, 'lib', 'kinetic', 'kinetic_ui.dart'))
          .readAsStringSync()
          .split('\n')
          .where((l) => l.contains('export'))
          .toList();
      expect(lines.length, 1); // no duplicates
    });
  });
}
