import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:flutter_kinetic_ui/src/commands/add_command.dart';

class MockHttpClient extends Mock implements http.Client {}

String _manifest(List<Map<String, dynamic>> components) => jsonEncode({
      'version': '1.0.0',
      'components': components,
    });

void main() {
  late Directory projectDir;
  late MockHttpClient mockHttp;

  setUp(() {
    projectDir = Directory.systemTemp.createTempSync('add_test_');
    // Create pubspec.yaml so PubspecMerger doesn't throw
    File(p.join(projectDir.path, 'pubspec.yaml'))
        .writeAsStringSync('name: my_app\ndependencies:\n  flutter:\n    sdk: flutter\n');
    mockHttp = MockHttpClient();
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  tearDown(() => projectDir.deleteSync(recursive: true));

  void stubHttp(String manifestJson) {
    when(() => mockHttp.get(any())).thenAnswer((inv) async {
      final uri = (inv.positionalArguments.first as Uri).toString();
      if (uri.contains('registry.json')) return http.Response(manifestJson, 200);
      return http.Response('// component code', 200);
    });
  }

  test('add button copies button.dart to lib/kinetic/components/button/', () async {
    stubHttp(_manifest([
      {'name': 'tokens', 'files': ['tokens/kinetic_colors.dart'], 'depends_on': [], 'pubspec_dependencies': {}},
      {'name': 'button', 'files': ['components/button/button.dart'], 'depends_on': ['tokens'], 'pubspec_dependencies': {}},
    ]));

    await runAdd(
      names: ['button'],
      addAll: false,
      force: false,
      projectRoot: projectDir.path,
      httpClient: mockHttp,
    );

    expect(
      File(p.join(projectDir.path, 'lib', 'kinetic', 'components', 'button', 'button.dart')).existsSync(),
      isTrue,
    );
  });

  test('add dialog auto-installs tokens and overlay as dependencies', () async {
    stubHttp(_manifest([
      {'name': 'tokens',  'files': ['tokens/kinetic_colors.dart'], 'depends_on': [], 'pubspec_dependencies': {}},
      {'name': 'overlay', 'files': ['overlay/kinetic_overlay.dart'], 'depends_on': ['tokens'], 'pubspec_dependencies': {}},
      {'name': 'button',  'files': ['components/button/button.dart'], 'depends_on': ['tokens'], 'pubspec_dependencies': {}},
      {'name': 'dialog',  'files': ['components/dialog/dialog.dart'], 'depends_on': ['tokens', 'overlay', 'button'], 'pubspec_dependencies': {}},
    ]));

    await runAdd(
      names: ['dialog'],
      addAll: false,
      force: false,
      projectRoot: projectDir.path,
      httpClient: mockHttp,
    );

    for (final path in [
      'lib/kinetic/tokens/kinetic_colors.dart',
      'lib/kinetic/overlay/kinetic_overlay.dart',
      'lib/kinetic/components/button/button.dart',
      'lib/kinetic/components/dialog/dialog.dart',
    ]) {
      expect(File(p.join(projectDir.path, path)).existsSync(), isTrue, reason: '$path missing');
    }
  });

  test('add calls flutter pub add for pubspec_dependencies', () async {
    stubHttp(_manifest([
      {'name': 'tokens', 'files': ['tokens/kinetic_colors.dart'], 'depends_on': [], 'pubspec_dependencies': {}},
      {'name': 'avatar', 'files': ['components/avatar/avatar.dart'], 'depends_on': ['tokens'],
        'pubspec_dependencies': {'cached_network_image': '^3.3.0'}},
    ]));

    final capturedArgs = <String>[];
    await runAdd(
      names: ['avatar'],
      addAll: false,
      force: false,
      projectRoot: projectDir.path,
      httpClient: mockHttp,
      processRunner: (exe, args, {workingDirectory}) async {
        capturedArgs..add(exe)..addAll(args);
        return ProcessResult(0, 0, '', '');
      },
    );

    expect(capturedArgs, containsAll(['flutter', 'pub', 'add']));
    expect(capturedArgs, contains('cached_network_image:^3.3.0'));
  });

  test('add --all installs every component', () async {
    stubHttp(_manifest([
      {'name': 'tokens', 'files': ['tokens/kinetic_colors.dart'], 'depends_on': [], 'pubspec_dependencies': {}},
      {'name': 'button', 'files': ['components/button/button.dart'], 'depends_on': ['tokens'], 'pubspec_dependencies': {}},
    ]));

    await runAdd(
      names: [],
      addAll: true,
      force: false,
      projectRoot: projectDir.path,
      httpClient: mockHttp,
    );

    expect(
      File(p.join(projectDir.path, 'lib', 'kinetic', 'components', 'button', 'button.dart')).existsSync(),
      isTrue,
    );
  });

  test('add skips already-installed component without --force', () async {
    // Pre-install tokens
    final tokensFile = File(p.join(projectDir.path, 'lib', 'kinetic', 'tokens', 'kinetic_colors.dart'));
    tokensFile.parent.createSync(recursive: true);
    tokensFile.writeAsStringSync('// original');

    // Write state showing tokens installed
    final stateFile = File(p.join(projectDir.path, '.kinetic', 'kinetic.json'));
    stateFile.parent.createSync(recursive: true);
    stateFile.writeAsStringSync(jsonEncode({
      'registry': 'https://example.com',
      'components': {'tokens': '1.0.0'},
    }));

    stubHttp(_manifest([
      {'name': 'tokens', 'files': ['tokens/kinetic_colors.dart'], 'depends_on': [], 'pubspec_dependencies': {}},
    ]));

    await runAdd(
      names: ['tokens'],
      addAll: false,
      force: false,
      projectRoot: projectDir.path,
      httpClient: mockHttp,
    );

    // File should still have original content
    expect(tokensFile.readAsStringSync(), '// original');
  });
}
