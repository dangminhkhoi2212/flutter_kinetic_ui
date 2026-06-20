import 'dart:io';
import 'package:args/command_runner.dart';
import '../registry/registry_client.dart';
import '../state/kinetic_state.dart';

class ListCommand extends Command<void> {
  @override
  String get name => 'list';

  @override
  String get description => 'List all available components';

  @override
  Future<void> run() async {
    final state = KineticState(projectRoot: Directory.current.path);
    final installed = state.installedComponents;

    print('Fetching registry...');
    final client = RegistryClient(token: state.token);
    try {
      final manifest = await client.fetchManifest();

      print('\nAvailable components:\n');
      for (final component in manifest.components) {
        final mark = installed.containsKey(component.name) ? '✓' : ' ';
        final deps = component.dependsOn.isEmpty
            ? ''
            : '  (needs: ${component.dependsOn.join(', ')})';
        print('  [$mark] ${component.name.padRight(16)}$deps');
      }
      print('\n  ✓ = installed\n');
    } finally {
      client.close();
    }
  }
}
