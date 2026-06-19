class RegistryComponent {
  final String name;
  final List<String> files;
  final List<String> dependsOn;
  final Map<String, String> pubspecDependencies;
  final String version;

  const RegistryComponent({
    required this.name,
    required this.files,
    required this.dependsOn,
    required this.pubspecDependencies,
    required this.version,
  });

  factory RegistryComponent.fromJson(Map<String, dynamic> json) {
    final pubspecDepsRaw = json['pubspec_dependencies'] as Map? ?? {};
    final pubspecDeps = <String, String>{};
    pubspecDepsRaw.forEach((k, v) {
      pubspecDeps[k as String] = v as String;
    });

    return RegistryComponent(
      name: json['name'] as String,
      files: List<String>.from(json['files'] as List? ?? const []),
      dependsOn: List<String>.from(json['depends_on'] as List? ?? const []),
      pubspecDependencies: pubspecDeps,
      version: json['version'] as String? ?? '1.0.0',
    );
  }
}

class RegistryManifest {
  final String version;
  final List<RegistryComponent> components;

  const RegistryManifest({required this.version, required this.components});

  factory RegistryManifest.fromJson(Map<String, dynamic> json) {
    return RegistryManifest(
      version: json['version'] as String,
      components: (json['components'] as List)
          .map((c) => RegistryComponent.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  RegistryComponent? findByName(String name) {
    for (final c in components) {
      if (c.name == name) return c;
    }
    return null;
  }
}
