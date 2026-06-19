import 'registry_manifest.dart';

class DependencyResolver {
  final List<RegistryComponent> components;

  DependencyResolver(this.components);

  /// Returns [names] and all transitive dependencies in install order (deps first).
  List<RegistryComponent> resolve(List<String> names) {
    final result = <RegistryComponent>[];
    final visited = <String>{};
    final visiting = <String>{};

    void visit(String name) {
      if (visited.contains(name)) return;
      if (visiting.contains(name)) {
        throw StateError('Circular dependency detected: $name');
      }

      final component = components.cast<RegistryComponent?>().firstWhere(
            (c) => c?.name == name,
            orElse: () => null,
          );
      if (component == null) throw ArgumentError('Unknown component: $name');

      visiting.add(name);
      for (final dep in component.dependsOn) {
        visit(dep);
      }
      visiting.remove(name);
      visited.add(name);
      result.add(component);
    }

    for (final name in names) {
      visit(name);
    }
    return result;
  }
}
