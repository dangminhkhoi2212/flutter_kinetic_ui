import 'package:test/test.dart';
import 'package:flutter_kinetic_ui/src/commands/diff_command.dart';

void main() {
  group('computeDiff', () {
    test('returns empty list for identical content', () {
      const src = 'line1\nline2\nline3';
      expect(computeDiff(src, src), isEmpty);
    });

    test('detects added lines', () {
      const local  = 'line1\nline2';
      const remote = 'line1\nline2\nline3';
      final diff = computeDiff(local, remote);
      expect(diff.any((d) => d.type == DiffType.added && d.content == 'line3'), isTrue);
    });

    test('detects removed lines', () {
      const local  = 'line1\nline2\nline3';
      const remote = 'line1\nline3';
      final diff = computeDiff(local, remote);
      expect(diff.any((d) => d.type == DiffType.removed && d.content == 'line2'), isTrue);
    });

    test('empty local vs non-empty remote shows all as added', () {
      const remote = 'a\nb\nc';
      final diff = computeDiff('', remote);
      expect(diff.every((d) => d.type == DiffType.added), isTrue);
    });
  });
}
