import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';

void main() {
  test('registry/registry.json is valid JSON with 21 components', () {
    final content = File('registry/registry.json').readAsStringSync();
    final json = jsonDecode(content) as Map<String, dynamic>;
    final components = json['components'] as List;
    // 2 primitives + 13 level-1 + 6 level-2 = 21
    expect(components.length, 21);
    // Every component has required fields
    for (final c in components) {
      final comp = c as Map<String, dynamic>;
      expect(comp['name'], isA<String>());
      expect(comp['files'], isA<List>());
      expect(comp['depends_on'], isA<List>());
      expect(comp['pubspec_dependencies'], isA<Map>());
    }
  });

  test('registry/components/button/button.dart exists and contains KineticButton', () {
    final content = File('registry/components/button/button.dart').readAsStringSync();
    expect(content, contains('class KineticButton'));
  });

  test('registry/overlay/kinetic_overlay.dart exists and contains KineticOverlay', () {
    final content = File('registry/overlay/kinetic_overlay.dart').readAsStringSync();
    expect(content, contains('class KineticOverlay'));
  });
}
