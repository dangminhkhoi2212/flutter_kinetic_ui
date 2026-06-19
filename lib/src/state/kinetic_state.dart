import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../registry/registry_client.dart' show kDefaultRegistryUrl;

class KineticState {
  static const _stateFile = '.kinetic/kinetic.json';
  static const _envKey = 'KINETIC_GITHUB_TOKEN';
  static const _defaultRegistry = kDefaultRegistryUrl;

  final String projectRoot;

  KineticState({required this.projectRoot});

  String get _statePath => p.join(projectRoot, _stateFile);

  bool get isInitialized => File(_statePath).existsSync();

  Map<String, dynamic> _read() {
    final file = File(_statePath);
    if (!file.existsSync()) {
      return {'registry': _defaultRegistry, 'components': <String, String>{}};
    }
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  void _write(Map<String, dynamic> data) {
    final file = File(_statePath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  }

  Map<String, String> get installedComponents {
    final data = _read();
    final raw = data['components'] as Map? ?? {};
    return raw.map((k, v) => MapEntry(k as String, v as String));
  }

  String get registryUrl =>
      (_read()['registry'] as String?) ?? _defaultRegistry;

  /// Reads from OS env var first, then .env file as a local-dev convenience.
  /// The user is responsible for setting KINETIC_GITHUB_TOKEN — the CLI never
  /// writes it.
  String? get token {
    final env = Platform.environment[_envKey];
    if (env != null && env.isNotEmpty) return env;
    return _readDotEnv();
  }

  String? _readDotEnv() {
    final file = File(p.join(projectRoot, '.env'));
    if (!file.existsSync()) return null;
    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('$_envKey=')) {
        return trimmed.substring('$_envKey='.length);
      }
    }
    return null;
  }

  void markInstalled(String name, String version) {
    final data = _read();
    (data['components'] as Map)[name] = version;
    _write(data);
  }

  void initialize() {
    _write({'registry': _defaultRegistry, 'components': <String, String>{}});
  }
}
