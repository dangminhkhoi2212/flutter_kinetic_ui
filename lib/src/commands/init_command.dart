import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import '../registry/registry_client.dart';
import '../registry/dependency_resolver.dart';
import '../state/kinetic_state.dart';
import '../generator/barrel_generator.dart';

/// Testable core extracted from InitCommand.
Future<void> runInit({
  required String projectRoot,
  http.Client? httpClient,
}) async {
  final state = KineticState(projectRoot: projectRoot);

  if (state.isInitialized) {
    print('Already initialized. Use "add" to add more components.');
    return;
  }

  state.initialize();

  print('Fetching registry...');
  final client = RegistryClient(httpClient: httpClient);
  final manifest = await client.fetchManifest();

  final resolver = DependencyResolver(manifest.components);
  final toInstall = resolver.resolve(['tokens']);

  for (final component in toInstall) {
    print('Installing ${component.name}...');
    for (final file in component.files) {
      final content = await client.fetchFile(file);
      final destPath = p.join(projectRoot, 'lib', 'kinetic', file);
      File(destPath).parent.createSync(recursive: true);
      File(destPath).writeAsStringSync(content);
    }
    state.markInstalled(component.name, manifest.version);
  }

  BarrelGenerator(projectRoot: projectRoot)
      .regenerate(manifest, state.installedComponents.keys.toList());

  print('✓ Initialized! Token files copied to lib/kinetic/tokens/');
  print('  Next: dart run flutter_kinetic_ui add <component>');
}

class InitCommand extends Command<void> {
  @override
  String get name => 'init';

  @override
  String get description => 'Initialize flutter_kinetic_ui in this project';

  @override
  Future<void> run() => runInit(projectRoot: Directory.current.path);
}
