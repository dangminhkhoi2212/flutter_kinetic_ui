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

  PubspecMerger merger({
    required List<String> capturedArgs,
    int exitCode = 0,
  }) =>
      PubspecMerger(
        projectRoot: tempDir.path,
        processRunner: (exe, args, {workingDirectory}) async {
          capturedArgs
            ..add(exe)
            ..addAll(args);
          return ProcessResult(0, exitCode, '', 'error output');
        },
      );

  group('PubspecMerger', () {
    test('calls flutter pub add with package and version', () async {
      write('name: my_app\ndependencies:\n  flutter:\n    sdk: flutter\n');
      final args = <String>[];
      await merger(capturedArgs: args).merge({'cached_network_image': '^3.3.0'});
      expect(args, containsAll(['flutter', 'pub', 'add']));
      expect(args, contains('cached_network_image:^3.3.0'));
    });

    test('passes all dependencies in a single pub add call', () async {
      write('name: my_app\ndependencies:\n  flutter:\n    sdk: flutter\n');
      final args = <String>[];
      await merger(capturedArgs: args).merge({
        'pkg_a': '^1.0.0',
        'pkg_b': '^2.0.0',
      });
      expect(args, contains('pkg_a:^1.0.0'));
      expect(args, contains('pkg_b:^2.0.0'));
      // Only one process invocation for both packages
      expect(args.where((a) => a == 'flutter').length, 1);
    });

    test('does nothing when deps map is empty', () async {
      write('name: my_app\ndependencies:\n  flutter:\n    sdk: flutter\n');
      final args = <String>[];
      await merger(capturedArgs: args).merge({});
      expect(args, isEmpty);
    });

    test('throws if pubspec.yaml missing', () async {
      expect(
        () => PubspecMerger(projectRoot: tempDir.path)
            .merge({'some_pkg': '^1.0.0'}),
        throwsException,
      );
    });

    test('throws if flutter pub add exits with non-zero code', () async {
      write('name: my_app\ndependencies:\n  flutter:\n    sdk: flutter\n');
      final args = <String>[];
      expect(
        () => merger(capturedArgs: args, exitCode: 1)
            .merge({'bad_pkg': '^1.0.0'}),
        throwsException,
      );
    });
  });
}
