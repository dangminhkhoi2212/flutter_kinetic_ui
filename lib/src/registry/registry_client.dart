import 'dart:convert';
import 'package:http/http.dart' as http;
import 'registry_manifest.dart';

class RegistryClient {
  static const _baseUrl =
      'https://raw.githubusercontent.com/flutter-kinetic/flutter_kinetic_ui/main/registry';

  final http.Client _httpClient;

  RegistryClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Future<RegistryManifest> fetchManifest() async {
    final uri = Uri.parse('$_baseUrl/registry.json');
    final response = await _httpClient.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch manifest (HTTP ${response.statusCode})');
    }
    return RegistryManifest.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<String> fetchFile(String registryPath) async {
    final uri = Uri.parse('$_baseUrl/$registryPath');
    final response = await _httpClient.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to fetch $registryPath (HTTP ${response.statusCode})');
    }
    return response.body;
  }
}
