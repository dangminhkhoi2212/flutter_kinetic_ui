import 'dart:convert';
import 'package:http/http.dart' as http;
import 'registry_manifest.dart';

const kDefaultRegistryUrl =
    'https://raw.githubusercontent.com/dangminhkhoi2212/flutter_kinetic_ui/main/registry';

class RegistryClient {
  static const _baseUrl = kDefaultRegistryUrl;

  final http.Client _httpClient;
  final String? _token;

  RegistryClient({http.Client? httpClient, this._token})
      : _httpClient = httpClient ?? http.Client();

  Future<http.Response> _get(Uri uri) {
    if (_token != null) {
      return _httpClient.get(uri, headers: {'Authorization': 'token $_token'});
    }
    return _httpClient.get(uri);
  }

  // GitHub returns 404 (not 401) for private repos accessed without a token.
  void _checkStatus(http.Response response, String label) {
    final status = response.statusCode;
    if (status == 401 || status == 403) {
      throw Exception(
        'Registry access denied (HTTP $status). '
        'Run: dart run flutter_kinetic_ui init --token <PAT>',
      );
    }
    if (status == 404) {
      final hint = _token == null
          ? 'No token configured — if this is a private repository, '
              'run: dart run flutter_kinetic_ui init --token <PAT>'
          : 'File not found: $label';
      throw Exception('$hint (HTTP 404)');
    }
    if (status != 200) {
      throw Exception('Failed to fetch $label (HTTP $status)');
    }
  }

  Future<RegistryManifest> fetchManifest() async {
    final uri = Uri.parse('$_baseUrl/registry.json');
    final response = await _get(uri);
    _checkStatus(response, 'registry manifest');
    return RegistryManifest.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<String> fetchFile(String registryPath) async {
    final uri = Uri.parse('$_baseUrl/$registryPath');
    final response = await _get(uri);
    _checkStatus(response, registryPath);
    return response.body;
  }

  void close() => _httpClient.close();
}
