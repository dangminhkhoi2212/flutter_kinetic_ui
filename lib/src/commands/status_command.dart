import 'dart:io';
import 'package:args/command_runner.dart';
import '../state/kinetic_state.dart';

class InstalledEntry {
  final String name;
  final String version;
  InstalledEntry(this.name, this.version);
}

List<InstalledEntry> getInstalledSummary({required String projectRoot}) {
  final state = KineticState(projectRoot: projectRoot);
  return state.installedComponents.entries
      .map((e) => InstalledEntry(e.key, e.value))
      .toList();
}

class StatusCommand extends Command<void> {
  @override
  String get name => 'status';

  @override
  String get description => 'Show installed components and their versions';

  @override
  Future<void> run() async {
    final projectRoot = Directory.current.path;
    final state = KineticState(projectRoot: projectRoot);

    if (!state.isInitialized) {
      print('Not initialized. Run: dart run flutter_kinetic_ui init');
      return;
    }

    final installed = state.installedComponents;
    if (installed.isEmpty) {
      print('No components installed.');
      return;
    }

    print('\nInstalled components:\n');
    for (final entry in installed.entries) {
      print('  ${entry.key.padRight(20)} v${entry.value}');
    }
    print('\nTotal: ${installed.length} component(s)');
  }
}
