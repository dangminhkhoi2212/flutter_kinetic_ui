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
  String? token,
}) async {
  final state = KineticState(projectRoot: projectRoot);

  if (state.isInitialized) {
    print('Already initialized. Use "add" to add more components.');
    return;
  }

  // Resolve: explicit arg > env var. Pass to initialize() so it's persisted.
  final resolvedToken = token ?? Platform.environment['KINETIC_GITHUB_TOKEN'];
  state.initialize(token: resolvedToken);

  print('Fetching registry...');
  final client = RegistryClient(httpClient: httpClient, token: resolvedToken);
  final manifest = await client.fetchManifest();

  // Install tokens + overlay — the foundation every component depends on.
  final resolver = DependencyResolver(manifest.components);
  final toInstall = resolver.resolve(['tokens', 'overlay']);

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

  print('✓ Initialized! Design system files copied to lib/kinetic/');
  print('  tokens/  → colors, spacing, radius, typography, shadows');
  print('  overlay/ → shared overlay primitive');
  print('  Next: dart run flutter_kinetic_ui add <component>');
}

class InitCommand extends Command<void> {
  @override
  String get name => 'init';

  @override
  String get description => 'Initialize flutter_kinetic_ui in this project';

  InitCommand() {
    argParser.addOption(
      'token',
      abbr: 't',
      help: 'GitHub Personal Access Token for private registry access',
      valueHelp: 'ghp_xxx',
    );
  }

  @override
  Future<void> run() => runInit(
        projectRoot: Directory.current.path,
        token: argResults!['token'] as String?,
      );
}
