import 'dart:io';
import 'package:test/test.dart';
import 'package:flutter_kinetic_ui/src/state/kinetic_state.dart';
import 'package:flutter_kinetic_ui/src/registry/registry_client.dart' show kDefaultRegistryUrl;

void main() {
  late Directory tempDir;
  late KineticState state;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('kinetic_state_test_');
    state = KineticState(projectRoot: tempDir.path);
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  group('KineticState', () {
    test('isInitialized returns false before init', () {
      expect(state.isInitialized, isFalse);
    });

    test('initialize creates .kinetic/kinetic.json', () {
      state.initialize();
      expect(state.isInitialized, isTrue);
    });

    test('installedComponents is empty before any markInstalled', () {
      expect(state.installedComponents, isEmpty);
    });

    test('markInstalled persists across re-reads', () {
      state.initialize();
      state.markInstalled('button', '1.0.0');

      final fresh = KineticState(projectRoot: tempDir.path);
      expect(fresh.installedComponents['button'], '1.0.0');
    });

    test('markInstalled accumulates multiple components', () {
      state.initialize();
      state.markInstalled('tokens', '1.0.0');
      state.markInstalled('button', '1.0.0');
      expect(state.installedComponents.length, 2);
    });

    test('registryUrl returns default when not set', () {
      expect(
        state.registryUrl,
        kDefaultRegistryUrl,
      );
    });
  });
}
