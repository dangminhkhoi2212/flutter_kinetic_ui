import 'package:test/test.dart';
import 'package:flutter_kinetic_ui/src/registry/registry_manifest.dart';
import 'package:flutter_kinetic_ui/src/registry/dependency_resolver.dart';

RegistryComponent c(String name, List<String> deps) => RegistryComponent(
    name: name, files: [], dependsOn: deps,
    pubspecDependencies: {}, version: '1.0.0');

void main() {
  group('DependencyResolver', () {
    test('single component with no deps returns just that component', () {
      final r = DependencyResolver([c('tokens', [])]);
      expect(r.resolve(['tokens']).map((x) => x.name), ['tokens']);
    });

    test('resolves single level dependency', () {
      final r = DependencyResolver([c('tokens', []), c('button', ['tokens'])]);
      final names = r.resolve(['button']).map((x) => x.name).toList();
      expect(names, ['tokens', 'button']);
    });

    test('resolves deep chain in correct order', () {
      final r = DependencyResolver([
        c('tokens', []),
        c('overlay', ['tokens']),
        c('button', ['tokens']),
        c('dialog', ['tokens', 'overlay', 'button']),
      ]);
      final names = r.resolve(['dialog']).map((x) => x.name).toList();
      expect(names.indexOf('tokens'), lessThan(names.indexOf('overlay')));
      expect(names.indexOf('tokens'), lessThan(names.indexOf('button')));
      expect(names.indexOf('overlay'), lessThan(names.indexOf('dialog')));
      expect(names.indexOf('button'), lessThan(names.indexOf('dialog')));
    });

    test('deduplicates shared deps when resolving multiple targets', () {
      final r = DependencyResolver([
        c('tokens', []),
        c('button', ['tokens']),
        c('input',  ['tokens']),
      ]);
      final result = r.resolve(['button', 'input']);
      expect(result.where((x) => x.name == 'tokens').length, 1);
    });

    test('throws ArgumentError on unknown component', () {
      final r = DependencyResolver([c('tokens', [])]);
      expect(() => r.resolve(['unknown']), throwsArgumentError);
    });

    test('throws StateError on circular dependency', () {
      final r = DependencyResolver([c('a', ['b']), c('b', ['a'])]);
      expect(() => r.resolve(['a']), throwsStateError);
    });
  });
}
