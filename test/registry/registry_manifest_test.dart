import 'package:test/test.dart';
import 'package:flutter_kinetic_ui/src/registry/registry_manifest.dart';

void main() {
  group('RegistryManifest.fromJson', () {
    test('parses version and component list', () {
      final manifest = RegistryManifest.fromJson({
        'version': '1.0.0',
        'components': [
          {'name': 'tokens', 'files': ['tokens/kinetic_colors.dart'], 'depends_on': [], 'pubspec_dependencies': {}},
          {'name': 'button', 'files': ['components/button/button.dart'], 'depends_on': ['tokens'], 'pubspec_dependencies': {}},
        ],
      });
      expect(manifest.version, '1.0.0');
      expect(manifest.components.length, 2);
      expect(manifest.components[1].dependsOn, ['tokens']);
    });

    test('findByName returns matching component', () {
      final manifest = RegistryManifest.fromJson({
        'version': '1.0.0',
        'components': [
          {'name': 'button', 'files': [], 'depends_on': [], 'pubspec_dependencies': {}},
        ],
      });
      expect(manifest.findByName('button')?.name, 'button');
      expect(manifest.findByName('unknown'), isNull);
    });

    test('missing depends_on defaults to empty list', () {
      final c = RegistryComponent.fromJson({'name': 'x', 'files': []});
      expect(c.dependsOn, isEmpty);
    });

    test('missing pubspec_dependencies defaults to empty map', () {
      final c = RegistryComponent.fromJson({'name': 'x', 'files': []});
      expect(c.pubspecDependencies, isEmpty);
    });

    test('missing version defaults to 1.0.0', () {
      final c = RegistryComponent.fromJson({'name': 'x', 'files': []});
      expect(c.version, '1.0.0');
    });
  });
}
