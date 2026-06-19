import 'dart:convert';
import 'package:http/http.dart' as http;
import 'registry_manifest.dart';

class RegistryClient {
  static const _baseUrl =
      'https://raw.githubusercontent.com/dangminhkhoi2212/flutter_kinetic_ui/main/registry';

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

  void _checkAuth(http.Response response, String context) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception(
        'Registry access denied (HTTP ${response.statusCode}). '
        'Run: dart run flutter_kinetic_ui init --token <PAT>',
      );
    }
  }

  Future<RegistryManifest> fetchManifest() async {
    final uri = Uri.parse('$_baseUrl/registry.json');
    final response = await _get(uri);
    _checkAuth(response, 'manifest');
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch manifest (HTTP ${response.statusCode})');
    }
    return RegistryManifest.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<String> fetchFile(String registryPath) async {
    final uri = Uri.parse('$_baseUrl/$registryPath');
    final response = await _get(uri);
    _checkAuth(response, registryPath);
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to fetch $registryPath (HTTP ${response.statusCode})');
    }
    return response.body;
  }
}
