import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('Token files exist in registry', () {
    const expected = [
      'registry/tokens/kinetic_colors.dart',
      'registry/tokens/kinetic_spacing.dart',
      'registry/tokens/kinetic_radius.dart',
      'registry/tokens/kinetic_typography.dart',
      'registry/tokens/kinetic_shadows.dart',
      'registry/tokens/kinetic_enums.dart',
      'registry/tokens/kinetic_theme.dart',
    ];

    for (final path in expected) {
      test('$path exists and is non-empty', () {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: '$path missing');
        expect(file.readAsStringSync().trim(), isNotEmpty);
      });
    }
  });
}
