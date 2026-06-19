import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../generator/barrel_generator.dart';
import '../generator/pubspec_merger.dart';
import '../registry/registry_client.dart';
import '../state/kinetic_state.dart';

String _safeDestPath(String projectRoot, String file) {
  final boundary = p.normalize(p.join(projectRoot, 'lib', 'kinetic'));
  final dest = p.normalize(p.join(projectRoot, 'lib', 'kinetic', file));
  if (!dest.startsWith(boundary)) {
    throw ArgumentError('Unsafe registry file path: $file');
  }
  return dest;
}

class UpdateCommand extends Command<void> {
  @override
  String get name => 'update';

  @override
  String get description =>
      'Update component(s) to the latest registry version';

  UpdateCommand() {
    argParser.addFlag(
      'all',
      help: 'Update all installed components',
      negatable: false,
    );
  }

  @override
  Future<void> run() async {
    final updateAll = argResults!['all'] as bool;
    final names = argResults!.rest;

    if (!updateAll && names.isEmpty) {
      print('Usage: dart run flutter_kinetic_ui update <component> [--all]');
      printUsage();
      return;
    }

    final projectRoot = Directory.current.path;
    final state = KineticState(projectRoot: projectRoot);
    final client = RegistryClient(token: state.token);

    print('Fetching registry...');
    final manifest = await client.fetchManifest();
    final installed = state.installedComponents;
    final targets = updateAll ? installed.keys.toList() : names.toList();

    if (targets.isEmpty) {
      print('No components installed.');
      return;
    }

    final merger = PubspecMerger(projectRoot: projectRoot);
    for (final name in targets) {
      final component = manifest.findByName(name);
      if (component == null) {
        print('⚠ Unknown component: $name, skipping.');
        continue;
      }
      print('Updating $name...');
      for (final file in component.files) {
        final content = await client.fetchFile(file);
        final destPath = _safeDestPath(projectRoot, file);
        File(destPath).parent.createSync(recursive: true);
        File(destPath).writeAsStringSync(content);
      }
      if (component.pubspecDependencies.isNotEmpty) {
        merger.merge(component.pubspecDependencies);
      }
      state.markInstalled(name, manifest.version);
    }

    BarrelGenerator(
      projectRoot: projectRoot,
    ).regenerate(manifest, state.installedComponents.keys.toList());

    print('\n✓ Updated! Run `flutter pub get` if new dependencies were added.');
  }
}
