import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:flutter_kinetic_ui/src/commands/init_command.dart';

class MockHttpClient extends Mock implements http.Client {}

final _sampleManifest = jsonEncode({
  'version': '1.0.0',
  'components': [
    {
      'name': 'tokens',
      'files': ['tokens/kinetic_colors.dart'],
      'depends_on': [],
      'pubspec_dependencies': {},
    },
    {
      'name': 'overlay',
      'files': ['overlay/kinetic_overlay.dart'],
      'depends_on': ['tokens'],
      'pubspec_dependencies': {},
    },
  ],
});

void main() {
  late Directory projectDir;
  late MockHttpClient mockHttp;

  setUp(() {
    projectDir = Directory.systemTemp.createTempSync('init_test_');
    mockHttp = MockHttpClient();
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  tearDown(() => projectDir.deleteSync(recursive: true));

  test('init creates .kinetic/kinetic.json', () async {
    when(() => mockHttp.get(any())).thenAnswer((invocation) async {
      final uri = (invocation.positionalArguments.first as Uri).toString();
      if (uri.contains('registry.json')) {
        return http.Response(_sampleManifest, 200);
      }
      return http.Response('// file content', 200);
    });

    await runInit(projectRoot: projectDir.path, httpClient: mockHttp);

    expect(File(p.join(projectDir.path, '.kinetic', 'kinetic.json')).existsSync(), isTrue);
  });

  test('init marks tokens as installed', () async {
    when(() => mockHttp.get(any())).thenAnswer((invocation) async {
      final uri = (invocation.positionalArguments.first as Uri).toString();
      if (uri.contains('registry.json')) {
        return http.Response(_sampleManifest, 200);
      }
      return http.Response('// file content', 200);
    });

    await runInit(projectRoot: projectDir.path, httpClient: mockHttp);

    final stateFile = File(p.join(projectDir.path, '.kinetic', 'kinetic.json'));
    final state = jsonDecode(stateFile.readAsStringSync()) as Map<String, dynamic>;
    expect((state['components'] as Map).containsKey('tokens'), isTrue);
  });
}
