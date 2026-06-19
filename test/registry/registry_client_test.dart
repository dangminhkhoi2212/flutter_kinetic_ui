import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:flutter_kinetic_ui/src/registry/registry_client.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockHttp;
  late RegistryClient client;

  setUp(() {
    mockHttp = MockHttpClient();
    client = RegistryClient(httpClient: mockHttp);
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  group('RegistryClient', () {
    test('fetchManifest parses 200 response into RegistryManifest', () async {
      when(() => mockHttp.get(any())).thenAnswer((_) async => http.Response(
            jsonEncode({
              'version': '1.0.0',
              'components': [
                {'name': 'tokens', 'files': [], 'depends_on': [], 'pubspec_dependencies': {}},
              ],
            }),
            200,
          ));

      final manifest = await client.fetchManifest();
      expect(manifest.version, '1.0.0');
      expect(manifest.components.length, 1);
    });

    test('fetchManifest throws on non-200', () async {
      when(() => mockHttp.get(any()))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(client.fetchManifest(), throwsException);
    });

    test('fetchFile returns body on 200', () async {
      when(() => mockHttp.get(any()))
          .thenAnswer((_) async => http.Response('// dart code', 200));

      final result = await client.fetchFile('tokens/kinetic_colors.dart');
      expect(result, '// dart code');
    });

    test('fetchFile throws on non-200', () async {
      when(() => mockHttp.get(any()))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(client.fetchFile('missing.dart'), throwsException);
    });

    test('fetchManifest calls correct URL', () async {
      Uri? calledUri;
      when(() => mockHttp.get(any())).thenAnswer((invocation) async {
        calledUri = invocation.positionalArguments.first as Uri;
        return http.Response(
            jsonEncode({'version': '1.0.0', 'components': []}), 200);
      });

      await client.fetchManifest();
      expect(calledUri?.path, contains('registry.json'));
    });
  });
}
