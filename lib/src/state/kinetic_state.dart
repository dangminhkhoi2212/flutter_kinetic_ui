import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

class KineticState {
  static const _stateFile = '.kinetic/kinetic.json';
  static const _defaultRegistry =
      'https://raw.githubusercontent.com/flutter-kinetic/flutter_kinetic_ui/main/registry';

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

  void markInstalled(String name, String version) {
    final data = _read();
    (data['components'] as Map)[name] = version;
    _write(data);
  }

  void initialize() {
    _write({'registry': _defaultRegistry, 'components': <String, String>{}});
  }
}
