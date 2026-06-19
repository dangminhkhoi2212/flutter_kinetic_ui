import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:flutter_kinetic_ui/src/generator/pubspec_merger.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('pubspec_test_');
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  void write(String content) =>
      File(p.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync(content);

  String read() =>
      File(p.join(tempDir.path, 'pubspec.yaml')).readAsStringSync();

  group('PubspecMerger', () {
    test('adds new dependency under dependencies section', () {
      write('name: my_app\ndependencies:\n  flutter:\n    sdk: flutter\n');
      PubspecMerger(projectRoot: tempDir.path)
          .merge({'cached_network_image': '^3.3.0'});
      expect(read(), contains('cached_network_image: ^3.3.0'));
    });

    test('does not duplicate an already-present dependency', () {
      write('name: my_app\ndependencies:\n  cached_network_image: ^3.3.0\n');
      PubspecMerger(projectRoot: tempDir.path)
          .merge({'cached_network_image': '^3.3.0'});
      expect(
          'cached_network_image'.allMatches(read()).length, 1);
    });

    test('does nothing when deps map is empty', () {
      const original = 'name: my_app\ndependencies:\n  flutter:\n    sdk: flutter\n';
      write(original);
      PubspecMerger(projectRoot: tempDir.path).merge({});
      expect(read(), original);
    });

    test('throws if pubspec.yaml missing', () {
      expect(
        () => PubspecMerger(projectRoot: tempDir.path)
            .merge({'some_pkg': '^1.0.0'}),
        throwsException,
      );
    });

    test('handles CRLF line endings without corrupting the file', () {
      // Simulate a Windows-style pubspec.yaml with CRLF endings.
      write('name: my_app\r\ndependencies:\r\n  flutter:\r\n    sdk: flutter\r\n');
      PubspecMerger(projectRoot: tempDir.path)
          .merge({'cached_network_image': '^3.3.0'});
      final result = read();
      expect(result, contains('cached_network_image: ^3.3.0'));
      // Resulting file must be valid YAML — no mixed-ending corruption.
      expect(result, contains('flutter:'));
      expect(result.indexOf('cached_network_image'), lessThan(result.indexOf('flutter:')));
    });
  });
}
