# flutter_kinetic_ui — CLI Infrastructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the CLI infrastructure for `flutter_kinetic_ui` — a copy-paste Flutter UI component library where developers run `dart run flutter_kinetic_ui add button` to copy components into their project.

**Architecture:** Single Dart CLI package with a `bin/` entry point and command classes under `lib/src/`. Components live in a `registry/` folder in the same repo. A `registry.json` manifest declares all 21 components with their files, dependency chains, and required pub packages. The CLI resolves dependency chains via topological sort, copies files to `lib/kinetic/` in the target project, merges pubspec entries, regenerates a barrel export, and maintains a `.kinetic/kinetic.json` state file.

**Tech Stack:** Dart CLI (no Flutter dependency in CLI itself), `args ^2.5.0`, `http ^1.2.0`, `path ^1.9.0`, `yaml ^3.1.2`, `test ^1.24.0`, `mocktail ^1.0.0`.

> **Scope note:** This plan covers CLI infrastructure + foundation tokens + button + overlay as smoke-test components. A separate Plan B covers the remaining 19 component implementations.

## Global Constraints

- Dart SDK: `^3.12.0`
- No Flutter dependency in the CLI package — registry files contain Flutter code but the CLI is pure Dart
- Component files are placed at `lib/kinetic/<registry-relative-path>` in the target project
- State file: `.kinetic/kinetic.json` at target project root
- Registry base URL: `https://raw.githubusercontent.com/flutter-kinetic/flutter_kinetic_ui/main/registry`
- Registry file paths in `registry.json` are relative to the `registry/` folder root
- Relative imports in registry component files must resolve correctly after copying to `lib/kinetic/`

---

### Task 1: Project Setup

**Files:**
- Modify: `pubspec.yaml`
- Create: `bin/flutter_kinetic_ui.dart`
- Create: `lib/flutter_kinetic_ui.dart` (library barrel — empty for now)
- Create: `analysis_options.yaml`

- [ ] **Step 1: Update pubspec.yaml**

```yaml
name: flutter_kinetic_ui
description: "Flutter Kinetic UI — copy-paste component library CLI"
version: 0.1.0
homepage: https://github.com/flutter-kinetic/flutter_kinetic_ui

environment:
  sdk: ^3.12.0

dependencies:
  args: ^2.5.0
  http: ^1.2.0
  path: ^1.9.0
  yaml: ^3.1.2

dev_dependencies:
  lints: ^4.0.0
  test: ^1.24.0
  mocktail: ^1.0.0
```

Note: Remove `flutter` SDK dependency and `flutter_lints` — this is a pure Dart CLI, not a Flutter package.

- [ ] **Step 2: Create bin/flutter_kinetic_ui.dart**

```dart
import 'package:flutter_kinetic_ui/src/cli_runner.dart';

Future<void> main(List<String> args) async {
  await CliRunner().run(args);
}
```

- [ ] **Step 3: Create lib/flutter_kinetic_ui.dart**

```dart
library flutter_kinetic_ui;
```

- [ ] **Step 4: Create directory structure**

Run:
```
mkdir lib\src\registry
mkdir lib\src\state
mkdir lib\src\generator
mkdir lib\src\commands
mkdir registry\tokens
mkdir registry\overlay
mkdir registry\components
mkdir test\registry
mkdir test\state
mkdir test\generator
mkdir test\commands
```

- [ ] **Step 5: Run pub get**

Run: `dart pub get`
Expected: Resolves dependencies without errors, creates `pubspec.lock`.

- [ ] **Step 6: Verify bin entry runs**

Run: `dart run flutter_kinetic_ui`
Expected: Error `Could not find command cli_runner` or similar (lib/src/cli_runner.dart does not exist yet) — this confirms the bin entry point is wired.

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml pubspec.lock bin/ lib/ analysis_options.yaml
git commit -m "feat: project setup for flutter_kinetic_ui CLI"
```

---

### Task 2: Token Files + Enums + KineticTheme

These are Flutter source files that live in `registry/` and get copied to users' projects. They use relative imports that resolve correctly after copying to `lib/kinetic/`.

**Files:**
- Create: `registry/tokens/kinetic_colors.dart`
- Create: `registry/tokens/kinetic_spacing.dart`
- Create: `registry/tokens/kinetic_radius.dart`
- Create: `registry/tokens/kinetic_typography.dart`
- Create: `registry/tokens/kinetic_shadows.dart`
- Create: `registry/tokens/kinetic_enums.dart`
- Create: `registry/tokens/kinetic_theme.dart`
- Test: `test/registry/token_files_test.dart`

**Interfaces:**
- Produces: `KineticColors`, `KineticSpacing`, `KineticRadius`, `KineticTypography`, `KineticShadows` (abstract classes with static constants); `KineticVariant`, `KineticColor`, `KineticSize` (enums); `KineticThemeData`, `KineticTheme`, `KineticApp` (theme system)

- [ ] **Step 1: Write the failing test**

```dart
// test/registry/token_files_test.dart
import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('Token files exist in registry', () {
    const expected = [
      'registry/tokens/kinetic_colors.dart',
      'registry/tokens/kinetic_spacing.dart',
      'registry/tokens/kinetic_radius.dart',
      'registry/tokens/kinetic_typography.dart',
      'registry/tokens/kinetic_shadows.dart',
      'registry/tokens/kinetic_enums.dart',
      'registry/tokens/kinetic_theme.dart',
    ];

    for (final path in expected) {
      test('$path exists and is non-empty', () {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: '$path missing');
        expect(file.readAsStringSync().trim(), isNotEmpty);
      });
    }
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/registry/token_files_test.dart`
Expected: FAIL — files do not exist yet.

- [ ] **Step 3: Create registry/tokens/kinetic_colors.dart**

```dart
import 'package:flutter/material.dart';

abstract class KineticColors {
  // Brand
  static const Color primary             = Color(0xFF7C3AED);
  static const Color primaryForeground   = Color(0xFFFFFFFF);
  static const Color secondary           = Color(0xFF6B7280);
  static const Color secondaryForeground = Color(0xFFFFFFFF);
  // Semantic
  static const Color success  = Color(0xFF22C55E);
  static const Color warning  = Color(0xFFF59E0B);
  static const Color danger   = Color(0xFFEF4444);
  static const Color info     = Color(0xFF3B82F6);
  // Surface
  static const Color background      = Color(0xFFFFFFFF);
  static const Color foreground      = Color(0xFF09090B);
  static const Color muted           = Color(0xFFF4F4F5);
  static const Color mutedForeground = Color(0xFF71717A);
  static const Color border          = Color(0xFFE4E4E7);
  static const Color ring            = Color(0xFF7C3AED);
}
```

- [ ] **Step 4: Create registry/tokens/kinetic_spacing.dart**

```dart
abstract class KineticSpacing {
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 16.0;
  static const double xl  = 24.0;
  static const double xxl = 32.0;
}
```

- [ ] **Step 5: Create registry/tokens/kinetic_radius.dart**

```dart
abstract class KineticRadius {
  static const double none = 0.0;
  static const double sm   = 4.0;
  static const double md   = 8.0;
  static const double lg   = 12.0;
  static const double xl   = 16.0;
  static const double full = 999.0;
}
```

- [ ] **Step 6: Create registry/tokens/kinetic_typography.dart**

```dart
import 'package:flutter/material.dart';

abstract class KineticTypography {
  static const String fontFamily = 'Inter';

  static const TextStyle bodySmall   = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle bodyMedium  = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle bodyLarge   = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle labelSmall  = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
  static const TextStyle labelMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  static const TextStyle labelLarge  = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  static const TextStyle heading4    = TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
  static const TextStyle heading3    = TextStyle(fontSize: 24, fontWeight: FontWeight.w700);
  static const TextStyle heading2    = TextStyle(fontSize: 30, fontWeight: FontWeight.w700);
  static const TextStyle heading1    = TextStyle(fontSize: 36, fontWeight: FontWeight.w800);
}
```

- [ ] **Step 7: Create registry/tokens/kinetic_shadows.dart**

```dart
import 'package:flutter/material.dart';

abstract class KineticShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8,  offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0D000000), blurRadius: 4,  offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0D000000), blurRadius: 6,  offset: Offset(0, 2)),
  ];
}
```

- [ ] **Step 8: Create registry/tokens/kinetic_enums.dart**

```dart
/// Semantic color slots used in component props.
/// Maps to actual colors via KineticTheme.
enum KineticColor {
  primary,
  secondary,
  success,
  warning,
  danger,
  defaultColor,
}

/// Visual style variants.
enum KineticVariant { solid, bordered, flat, faded, shadow, ghost }

/// Size tokens for component sizing.
enum KineticSize { sm, md, lg }
```

- [ ] **Step 9: Create registry/tokens/kinetic_theme.dart**

```dart
import 'package:flutter/material.dart';
import 'kinetic_colors.dart';

class KineticThemeData {
  final Color background;
  final Color foreground;
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color muted;
  final Color mutedForeground;
  final Color border;
  final Color success;
  final Color warning;
  final Color danger;

  const KineticThemeData({
    required this.background,
    required this.foreground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.border,
    required this.success,
    required this.warning,
    required this.danger,
  });

  factory KineticThemeData.light() => const KineticThemeData(
        background: KineticColors.background,
        foreground: KineticColors.foreground,
        primary: KineticColors.primary,
        primaryForeground: KineticColors.primaryForeground,
        secondary: KineticColors.secondary,
        secondaryForeground: KineticColors.secondaryForeground,
        muted: KineticColors.muted,
        mutedForeground: KineticColors.mutedForeground,
        border: KineticColors.border,
        success: KineticColors.success,
        warning: KineticColors.warning,
        danger: KineticColors.danger,
      );

  factory KineticThemeData.dark() => const KineticThemeData(
        background: Color(0xFF09090B),
        foreground: Color(0xFFFAFAFA),
        primary: Color(0xFF8B5CF6),
        primaryForeground: Color(0xFFFFFFFF),
        secondary: Color(0xFF27272A),
        secondaryForeground: Color(0xFFFAFAFA),
        muted: Color(0xFF27272A),
        mutedForeground: Color(0xFFA1A1AA),
        border: Color(0xFF27272A),
        success: Color(0xFF22C55E),
        warning: Color(0xFFF59E0B),
        danger: Color(0xFFEF4444),
      );

  KineticThemeData copyWith({
    Color? background, Color? foreground,
    Color? primary, Color? primaryForeground,
    Color? secondary, Color? secondaryForeground,
    Color? muted, Color? mutedForeground,
    Color? border, Color? success, Color? warning, Color? danger,
  }) => KineticThemeData(
        background: background ?? this.background,
        foreground: foreground ?? this.foreground,
        primary: primary ?? this.primary,
        primaryForeground: primaryForeground ?? this.primaryForeground,
        secondary: secondary ?? this.secondary,
        secondaryForeground: secondaryForeground ?? this.secondaryForeground,
        muted: muted ?? this.muted,
        mutedForeground: mutedForeground ?? this.mutedForeground,
        border: border ?? this.border,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        danger: danger ?? this.danger,
      );
}

class KineticTheme extends InheritedWidget {
  final KineticThemeData data;

  const KineticTheme({
    super.key,
    required this.data,
    required super.child,
  });

  static KineticThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<KineticTheme>();
    return theme?.data ?? KineticThemeData.light();
  }

  @override
  bool updateShouldNotify(KineticTheme oldWidget) => data != oldWidget.data;
}

class KineticApp extends StatelessWidget {
  final KineticThemeData theme;
  final KineticThemeData? darkTheme;
  final Widget child;

  const KineticApp({
    super.key,
    required this.theme,
    this.darkTheme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final brightness =
        MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.light;
    final activeTheme =
        (darkTheme != null && brightness == Brightness.dark) ? darkTheme! : theme;
    return KineticTheme(data: activeTheme, child: child);
  }
}
```

- [ ] **Step 10: Run test to verify it passes**

Run: `dart test test/registry/token_files_test.dart`
Expected: PASS — all 7 token files exist and are non-empty.

- [ ] **Step 11: Commit**

```bash
git add registry/tokens/
git commit -m "feat: add design token files and KineticTheme"
```

---

### Task 3: Registry Manifest Models + Dependency Resolver

**Files:**
- Create: `lib/src/registry/registry_manifest.dart`
- Create: `lib/src/registry/dependency_resolver.dart`
- Test: `test/registry/registry_manifest_test.dart`
- Test: `test/registry/dependency_resolver_test.dart`

**Interfaces:**
- Produces: `RegistryComponent({name, files, dependsOn, pubspecDependencies, version})`, `RegistryManifest({version, components, findByName})`, `DependencyResolver(components).resolve(names) → List<RegistryComponent>` in dependency order

- [ ] **Step 1: Write failing tests**

```dart
// test/registry/registry_manifest_test.dart
import 'package:test/test.dart';
import 'package:flutter_kinetic_ui/src/registry/registry_manifest.dart';

void main() {
  group('RegistryManifest.fromJson', () {
    test('parses version and component list', () {
      final manifest = RegistryManifest.fromJson({
        'version': '1.0.0',
        'components': [
          {'name': 'tokens', 'files': ['tokens/kinetic_colors.dart'], 'depends_on': [], 'pubspec_dependencies': {}},
          {'name': 'button', 'files': ['components/button/button.dart'], 'depends_on': ['tokens'], 'pubspec_dependencies': {}},
        ],
      });
      expect(manifest.version, '1.0.0');
      expect(manifest.components.length, 2);
      expect(manifest.components[1].dependsOn, ['tokens']);
    });

    test('findByName returns matching component', () {
      final manifest = RegistryManifest.fromJson({
        'version': '1.0.0',
        'components': [
          {'name': 'button', 'files': [], 'depends_on': [], 'pubspec_dependencies': {}},
        ],
      });
      expect(manifest.findByName('button')?.name, 'button');
      expect(manifest.findByName('unknown'), isNull);
    });

    test('missing depends_on defaults to empty list', () {
      final c = RegistryComponent.fromJson({'name': 'x', 'files': []});
      expect(c.dependsOn, isEmpty);
    });

    test('missing pubspec_dependencies defaults to empty map', () {
      final c = RegistryComponent.fromJson({'name': 'x', 'files': []});
      expect(c.pubspecDependencies, isEmpty);
    });

    test('missing version defaults to 1.0.0', () {
      final c = RegistryComponent.fromJson({'name': 'x', 'files': []});
      expect(c.version, '1.0.0');
    });
  });
}
```

```dart
// test/registry/dependency_resolver_test.dart
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
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `dart test test/registry/`
Expected: FAIL — source files do not exist yet.

- [ ] **Step 3: Create lib/src/registry/registry_manifest.dart**

```dart
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
    return RegistryComponent(
      name: json['name'] as String,
      files: List<String>.from(json['files'] as List? ?? const []),
      dependsOn: List<String>.from(json['depends_on'] as List? ?? const []),
      pubspecDependencies:
          (json['pubspec_dependencies'] as Map<String, dynamic>? ?? {})
              .map((k, v) => MapEntry(k, v as String)),
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
```

- [ ] **Step 4: Create lib/src/registry/dependency_resolver.dart**

```dart
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
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `dart test test/registry/`
Expected: PASS — all 10 tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/src/registry/ test/registry/
git commit -m "feat: add registry manifest models and dependency resolver"
```

---

### Task 4: Registry Client + Kinetic State

**Files:**
- Create: `lib/src/registry/registry_client.dart`
- Create: `lib/src/state/kinetic_state.dart`
- Test: `test/registry/registry_client_test.dart`
- Test: `test/state/kinetic_state_test.dart`

**Interfaces:**
- Consumes: `RegistryManifest` from Task 3
- Produces: `RegistryClient({httpClient?}).fetchManifest() → Future<RegistryManifest>`, `RegistryClient.fetchFile(path) → Future<String>`; `KineticState({projectRoot}).isInitialized`, `.installedComponents`, `.markInstalled(name, version)`, `.initialize()`

- [ ] **Step 1: Write failing tests**

```dart
// test/registry/registry_client_test.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:flutter_kinetic_ui/src/registry/registry_client.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockHttp;
  late RegistryClient client;

  setUp(() {
    mockHttp = MockHttpClient();
    client = RegistryClient(httpClient: mockHttp);
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  group('RegistryClient', () {
    test('fetchManifest parses 200 response into RegistryManifest', () async {
      when(() => mockHttp.get(any())).thenAnswer((_) async => http.Response(
            jsonEncode({
              'version': '1.0.0',
              'components': [
                {'name': 'tokens', 'files': [], 'depends_on': [], 'pubspec_dependencies': {}},
              ],
            }),
            200,
          ));

      final manifest = await client.fetchManifest();
      expect(manifest.version, '1.0.0');
      expect(manifest.components.length, 1);
    });

    test('fetchManifest throws on non-200', () async {
      when(() => mockHttp.get(any()))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(client.fetchManifest(), throwsException);
    });

    test('fetchFile returns body on 200', () async {
      when(() => mockHttp.get(any()))
          .thenAnswer((_) async => http.Response('// dart code', 200));

      final result = await client.fetchFile('tokens/kinetic_colors.dart');
      expect(result, '// dart code');
    });

    test('fetchFile throws on non-200', () async {
      when(() => mockHttp.get(any()))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(client.fetchFile('missing.dart'), throwsException);
    });

    test('fetchManifest calls correct URL', () async {
      Uri? calledUri;
      when(() => mockHttp.get(any())).thenAnswer((invocation) async {
        calledUri = invocation.positionalArguments.first as Uri;
        return http.Response(
            jsonEncode({'version': '1.0.0', 'components': []}), 200);
      });

      await client.fetchManifest();
      expect(calledUri?.path, contains('registry.json'));
    });
  });
}
```

```dart
// test/state/kinetic_state_test.dart
import 'dart:io';
import 'package:test/test.dart';
import 'package:flutter_kinetic_ui/src/state/kinetic_state.dart';

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
        'https://raw.githubusercontent.com/flutter-kinetic/flutter_kinetic_ui/main/registry',
      );
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `dart test test/registry/registry_client_test.dart test/state/`
Expected: FAIL — source files missing.

- [ ] **Step 3: Create lib/src/registry/registry_client.dart**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'registry_manifest.dart';

class RegistryClient {
  static const _baseUrl =
      'https://raw.githubusercontent.com/flutter-kinetic/flutter_kinetic_ui/main/registry';

  final http.Client _httpClient;

  RegistryClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Future<RegistryManifest> fetchManifest() async {
    final uri = Uri.parse('$_baseUrl/registry.json');
    final response = await _httpClient.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch manifest (HTTP ${response.statusCode})');
    }
    return RegistryManifest.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<String> fetchFile(String registryPath) async {
    final uri = Uri.parse('$_baseUrl/$registryPath');
    final response = await _httpClient.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to fetch $registryPath (HTTP ${response.statusCode})');
    }
    return response.body;
  }
}
```

- [ ] **Step 4: Create lib/src/state/kinetic_state.dart**

```dart
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
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `dart test test/registry/registry_client_test.dart test/state/`
Expected: PASS — all 9 tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/src/registry/registry_client.dart lib/src/state/ test/
git commit -m "feat: add registry client and kinetic state"
```

---

### Task 5: File Generators (Barrel Export + Pubspec Merger)

**Files:**
- Create: `lib/src/generator/barrel_generator.dart`
- Create: `lib/src/generator/pubspec_merger.dart`
- Test: `test/generator/barrel_generator_test.dart`
- Test: `test/generator/pubspec_merger_test.dart`

**Interfaces:**
- Consumes: `RegistryManifest` from Task 3
- Produces: `BarrelGenerator({projectRoot}).regenerate(manifest, installedNames)` — writes `lib/kinetic/kinetic_ui.dart`; `PubspecMerger({projectRoot}).merge(Map<String, String>)` — idempotently adds deps to `pubspec.yaml`

- [ ] **Step 1: Write failing tests**

```dart
// test/generator/barrel_generator_test.dart
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:flutter_kinetic_ui/src/generator/barrel_generator.dart';
import 'package:flutter_kinetic_ui/src/registry/registry_manifest.dart';

RegistryComponent comp(String name, List<String> files,
        [List<String> deps = const []]) =>
    RegistryComponent(
        name: name,
        files: files,
        dependsOn: deps,
        pubspecDependencies: {},
        version: '1.0.0');

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('barrel_test_');
    Directory(p.join(tempDir.path, 'lib', 'kinetic')).createSync(recursive: true);
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  group('BarrelGenerator', () {
    test('generates AUTO-GENERATED header', () {
      final manifest = RegistryManifest(version: '1.0.0', components: [
        comp('tokens', ['tokens/kinetic_colors.dart']),
      ]);
      BarrelGenerator(projectRoot: tempDir.path)
          .regenerate(manifest, ['tokens']);
      final content = File(p.join(tempDir.path, 'lib', 'kinetic', 'kinetic_ui.dart'))
          .readAsStringSync();
      expect(content, startsWith('// AUTO-GENERATED'));
    });

    test('exports all files for installed components', () {
      final manifest = RegistryManifest(version: '1.0.0', components: [
        comp('tokens', ['tokens/kinetic_colors.dart', 'tokens/kinetic_spacing.dart']),
        comp('button', ['components/button/button.dart'], ['tokens']),
      ]);
      BarrelGenerator(projectRoot: tempDir.path)
          .regenerate(manifest, ['tokens', 'button']);
      final content = File(p.join(tempDir.path, 'lib', 'kinetic', 'kinetic_ui.dart'))
          .readAsStringSync();
      expect(content, contains("export 'tokens/kinetic_colors.dart';"));
      expect(content, contains("export 'tokens/kinetic_spacing.dart';"));
      expect(content, contains("export 'components/button/button.dart';"));
    });

    test('omits files for non-installed components', () {
      final manifest = RegistryManifest(version: '1.0.0', components: [
        comp('tokens', ['tokens/kinetic_colors.dart']),
        comp('button', ['components/button/button.dart'], ['tokens']),
      ]);
      BarrelGenerator(projectRoot: tempDir.path)
          .regenerate(manifest, ['tokens']); // button NOT installed
      final content = File(p.join(tempDir.path, 'lib', 'kinetic', 'kinetic_ui.dart'))
          .readAsStringSync();
      expect(content, isNot(contains('button.dart')));
    });

    test('overwrites existing barrel on regenerate', () {
      final manifest = RegistryManifest(version: '1.0.0', components: [
        comp('tokens', ['tokens/kinetic_colors.dart']),
      ]);
      final gen = BarrelGenerator(projectRoot: tempDir.path);
      gen.regenerate(manifest, ['tokens']);
      gen.regenerate(manifest, ['tokens']); // call twice
      final lines = File(p.join(tempDir.path, 'lib', 'kinetic', 'kinetic_ui.dart'))
          .readAsStringSync()
          .split('\n')
          .where((l) => l.contains('export'))
          .toList();
      expect(lines.length, 1); // no duplicates
    });
  });
}
```

```dart
// test/generator/pubspec_merger_test.dart
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:flutter_kinetic_ui/src/generator/pubspec_merger.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('pubspec_test_');
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  void write(String content) =>
      File(p.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync(content);

  String read() =>
      File(p.join(tempDir.path, 'pubspec.yaml')).readAsStringSync();

  group('PubspecMerger', () {
    test('adds new dependency under dependencies section', () {
      write('name: my_app\ndependencies:\n  flutter:\n    sdk: flutter\n');
      PubspecMerger(projectRoot: tempDir.path)
          .merge({'cached_network_image': '^3.3.0'});
      expect(read(), contains('cached_network_image: ^3.3.0'));
    });

    test('does not duplicate an already-present dependency', () {
      write('name: my_app\ndependencies:\n  cached_network_image: ^3.3.0\n');
      PubspecMerger(projectRoot: tempDir.path)
          .merge({'cached_network_image': '^3.3.0'});
      expect(
          'cached_network_image'.allMatches(read()).length, 1);
    });

    test('does nothing when deps map is empty', () {
      const original = 'name: my_app\ndependencies:\n  flutter:\n    sdk: flutter\n';
      write(original);
      PubspecMerger(projectRoot: tempDir.path).merge({});
      expect(read(), original);
    });

    test('throws if pubspec.yaml missing', () {
      expect(
        () => PubspecMerger(projectRoot: tempDir.path)
            .merge({'some_pkg': '^1.0.0'}),
        throwsException,
      );
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `dart test test/generator/`
Expected: FAIL — source files missing.

- [ ] **Step 3: Create lib/src/generator/barrel_generator.dart**

```dart
import 'dart:io';
import 'package:path/path.dart' as p;
import '../registry/registry_manifest.dart';

class BarrelGenerator {
  final String projectRoot;

  BarrelGenerator({required this.projectRoot});

  void regenerate(RegistryManifest manifest, List<String> installedNames) {
    final lines = <String>[
      '// AUTO-GENERATED by flutter_kinetic_ui — do not edit manually',
    ];

    for (final component in manifest.components) {
      if (!installedNames.contains(component.name)) continue;
      for (final file in component.files) {
        lines.add("export '$file';");
      }
    }

    final barrelPath =
        p.join(projectRoot, 'lib', 'kinetic', 'kinetic_ui.dart');
    File(barrelPath).parent.createSync(recursive: true);
    File(barrelPath).writeAsStringSync('${lines.join('\n')}\n');
  }
}
```

- [ ] **Step 4: Create lib/src/generator/pubspec_merger.dart**

```dart
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class PubspecMerger {
  final String projectRoot;

  PubspecMerger({required this.projectRoot});

  void merge(Map<String, String> dependencies) {
    if (dependencies.isEmpty) return;

    final pubspecPath = p.join(projectRoot, 'pubspec.yaml');
    final file = File(pubspecPath);
    if (!file.existsSync()) {
      throw Exception('pubspec.yaml not found at $pubspecPath');
    }

    final content = file.readAsStringSync();
    final yaml = loadYaml(content) as YamlMap;
    final existingDeps = (yaml['dependencies'] as YamlMap?)?.keys.toSet() ?? {};

    var updated = content;
    for (final entry in dependencies.entries) {
      if (existingDeps.contains(entry.key)) continue;
      updated = _insertDependency(updated, entry.key, entry.value);
    }

    file.writeAsStringSync(updated);
  }

  String _insertDependency(String content, String name, String version) {
    final lines = content.split('\n');
    final idx = lines.indexWhere((l) => l.trimRight() == 'dependencies:');
    if (idx == -1) return '$content\ndependencies:\n  $name: $version\n';
    lines.insert(idx + 1, '  $name: $version');
    return lines.join('\n');
  }
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `dart test test/generator/`
Expected: PASS — all 8 tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/src/generator/ test/generator/
git commit -m "feat: add barrel generator and pubspec merger"
```

---

### Task 6: CLI Runner + init + list Commands

**Files:**
- Create: `lib/src/cli_runner.dart`
- Create: `lib/src/commands/init_command.dart`
- Create: `lib/src/commands/list_command.dart`
- Test: `test/commands/init_command_test.dart`

**Interfaces:**
- Consumes: `RegistryClient`, `DependencyResolver`, `KineticState`, `BarrelGenerator` from Tasks 3–5
- Produces: `CliRunner().run(args)` routes to commands; `init` creates `lib/kinetic/tokens/` + `.kinetic/kinetic.json`; `list` prints available components

- [ ] **Step 1: Write failing test for init**

```dart
// test/commands/init_command_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:flutter_kinetic_ui/src/commands/init_command.dart';

class MockHttpClient extends Mock implements http.Client {}

final _sampleManifest = jsonEncode({
  'version': '1.0.0',
  'components': [
    {
      'name': 'tokens',
      'files': ['tokens/kinetic_colors.dart'],
      'depends_on': [],
      'pubspec_dependencies': {},
    },
  ],
});

void main() {
  late Directory projectDir;
  late MockHttpClient mockHttp;

  setUp(() {
    projectDir = Directory.systemTemp.createTempSync('init_test_');
    mockHttp = MockHttpClient();
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  tearDown(() => projectDir.deleteSync(recursive: true));

  test('init creates .kinetic/kinetic.json', () async {
    when(() => mockHttp.get(any())).thenAnswer((_) async {
      final uri = (_.positionalArguments.first as Uri).toString();
      if (uri.contains('registry.json')) {
        return http.Response(_sampleManifest, 200);
      }
      return http.Response('// file content', 200);
    });

    await runInit(projectRoot: projectDir.path, httpClient: mockHttp);

    expect(File(p.join(projectDir.path, '.kinetic', 'kinetic.json')).existsSync(), isTrue);
  });

  test('init marks tokens as installed', () async {
    when(() => mockHttp.get(any())).thenAnswer((_) async {
      final uri = (_.positionalArguments.first as Uri).toString();
      if (uri.contains('registry.json')) {
        return http.Response(_sampleManifest, 200);
      }
      return http.Response('// file content', 200);
    });

    await runInit(projectRoot: projectDir.path, httpClient: mockHttp);

    final stateFile = File(p.join(projectDir.path, '.kinetic', 'kinetic.json'));
    final state = jsonDecode(stateFile.readAsStringSync()) as Map<String, dynamic>;
    expect((state['components'] as Map).containsKey('tokens'), isTrue);
  });
}
```

Note: `runInit` is a testable function extracted from `InitCommand` — see implementation step.

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/commands/init_command_test.dart`
Expected: FAIL.

- [ ] **Step 3: Create lib/src/cli_runner.dart**

```dart
import 'package:args/command_runner.dart';
import 'commands/init_command.dart';
import 'commands/list_command.dart';
import 'commands/add_command.dart';
import 'commands/status_command.dart';
import 'commands/update_command.dart';
import 'commands/diff_command.dart';

class CliRunner {
  Future<void> run(List<String> args) async {
    final runner = CommandRunner<void>(
      'flutter_kinetic_ui',
      'Flutter Kinetic UI — copy-paste component library',
    )
      ..addCommand(InitCommand())
      ..addCommand(ListCommand())
      ..addCommand(AddCommand())
      ..addCommand(StatusCommand())
      ..addCommand(UpdateCommand())
      ..addCommand(DiffCommand());

    try {
      await runner.run(args);
    } on UsageException catch (e) {
      print(e.message);
      print(e.usage);
    }
  }
}
```

- [ ] **Step 4: Create lib/src/commands/init_command.dart**

```dart
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
```

- [ ] **Step 5: Create lib/src/commands/list_command.dart**

```dart
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
    final manifest = await RegistryClient().fetchManifest();

    print('\nAvailable components:\n');
    for (final component in manifest.components) {
      final mark = installed.containsKey(component.name) ? '✓' : ' ';
      final deps = component.dependsOn.isEmpty
          ? ''
          : '  (needs: ${component.dependsOn.join(', ')})';
      print('  [$mark] ${component.name.padRight(16)}$deps');
    }
    print('\n  ✓ = installed\n');
  }
}
```

- [ ] **Step 6: Run test to verify it passes**

Run: `dart test test/commands/init_command_test.dart`
Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/src/cli_runner.dart lib/src/commands/init_command.dart lib/src/commands/list_command.dart test/commands/
git commit -m "feat: add CLI runner, init and list commands"
```

---

### Task 7: add Command (with --all and --force)

**Files:**
- Create: `lib/src/commands/add_command.dart`
- Test: `test/commands/add_command_test.dart`

**Interfaces:**
- Consumes: `RegistryClient`, `DependencyResolver`, `KineticState`, `BarrelGenerator`, `PubspecMerger`
- Produces: `AddCommand` — `add <names...>`, `add --all`, `add <name> --force`

- [ ] **Step 1: Write failing test**

```dart
// test/commands/add_command_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:flutter_kinetic_ui/src/commands/add_command.dart';

class MockHttpClient extends Mock implements http.Client {}

String _manifest(List<Map<String, dynamic>> components) => jsonEncode({
      'version': '1.0.0',
      'components': components,
    });

void main() {
  late Directory projectDir;
  late MockHttpClient mockHttp;

  setUp(() {
    projectDir = Directory.systemTemp.createTempSync('add_test_');
    // Create pubspec.yaml so PubspecMerger doesn't throw
    File(p.join(projectDir.path, 'pubspec.yaml'))
        .writeAsStringSync('name: my_app\ndependencies:\n  flutter:\n    sdk: flutter\n');
    mockHttp = MockHttpClient();
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  tearDown(() => projectDir.deleteSync(recursive: true));

  void stubHttp(String manifestJson) {
    when(() => mockHttp.get(any())).thenAnswer((inv) async {
      final uri = (inv.positionalArguments.first as Uri).toString();
      if (uri.contains('registry.json')) return http.Response(manifestJson, 200);
      return http.Response('// component code', 200);
    });
  }

  test('add button copies button.dart to lib/kinetic/components/button/', () async {
    stubHttp(_manifest([
      {'name': 'tokens', 'files': ['tokens/kinetic_colors.dart'], 'depends_on': [], 'pubspec_dependencies': {}},
      {'name': 'button', 'files': ['components/button/button.dart'], 'depends_on': ['tokens'], 'pubspec_dependencies': {}},
    ]));

    await runAdd(
      names: ['button'],
      addAll: false,
      force: false,
      projectRoot: projectDir.path,
      httpClient: mockHttp,
    );

    expect(
      File(p.join(projectDir.path, 'lib', 'kinetic', 'components', 'button', 'button.dart')).existsSync(),
      isTrue,
    );
  });

  test('add dialog auto-installs tokens and overlay as dependencies', () async {
    stubHttp(_manifest([
      {'name': 'tokens',  'files': ['tokens/kinetic_colors.dart'], 'depends_on': [], 'pubspec_dependencies': {}},
      {'name': 'overlay', 'files': ['overlay/kinetic_overlay.dart'], 'depends_on': ['tokens'], 'pubspec_dependencies': {}},
      {'name': 'button',  'files': ['components/button/button.dart'], 'depends_on': ['tokens'], 'pubspec_dependencies': {}},
      {'name': 'dialog',  'files': ['components/dialog/dialog.dart'], 'depends_on': ['tokens', 'overlay', 'button'], 'pubspec_dependencies': {}},
    ]));

    await runAdd(
      names: ['dialog'],
      addAll: false,
      force: false,
      projectRoot: projectDir.path,
      httpClient: mockHttp,
    );

    for (final path in [
      'lib/kinetic/tokens/kinetic_colors.dart',
      'lib/kinetic/overlay/kinetic_overlay.dart',
      'lib/kinetic/components/button/button.dart',
      'lib/kinetic/components/dialog/dialog.dart',
    ]) {
      expect(File(p.join(projectDir.path, path)).existsSync(), isTrue, reason: '$path missing');
    }
  });

  test('add merges pubspec_dependencies into pubspec.yaml', () async {
    stubHttp(_manifest([
      {'name': 'tokens', 'files': ['tokens/kinetic_colors.dart'], 'depends_on': [], 'pubspec_dependencies': {}},
      {'name': 'avatar', 'files': ['components/avatar/avatar.dart'], 'depends_on': ['tokens'],
        'pubspec_dependencies': {'cached_network_image': '^3.3.0'}},
    ]));

    await runAdd(
      names: ['avatar'],
      addAll: false,
      force: false,
      projectRoot: projectDir.path,
      httpClient: mockHttp,
    );

    final pubspec = File(p.join(projectDir.path, 'pubspec.yaml')).readAsStringSync();
    expect(pubspec, contains('cached_network_image: ^3.3.0'));
  });

  test('add --all installs every component', () async {
    stubHttp(_manifest([
      {'name': 'tokens', 'files': ['tokens/kinetic_colors.dart'], 'depends_on': [], 'pubspec_dependencies': {}},
      {'name': 'button', 'files': ['components/button/button.dart'], 'depends_on': ['tokens'], 'pubspec_dependencies': {}},
    ]));

    await runAdd(
      names: [],
      addAll: true,
      force: false,
      projectRoot: projectDir.path,
      httpClient: mockHttp,
    );

    expect(
      File(p.join(projectDir.path, 'lib', 'kinetic', 'components', 'button', 'button.dart')).existsSync(),
      isTrue,
    );
  });

  test('add skips already-installed component without --force', () async {
    // Pre-install tokens
    final tokensFile = File(p.join(projectDir.path, 'lib', 'kinetic', 'tokens', 'kinetic_colors.dart'));
    tokensFile.parent.createSync(recursive: true);
    tokensFile.writeAsStringSync('// original');

    // Write state showing tokens installed
    final stateFile = File(p.join(projectDir.path, '.kinetic', 'kinetic.json'));
    stateFile.parent.createSync(recursive: true);
    stateFile.writeAsStringSync(jsonEncode({
      'registry': 'https://example.com',
      'components': {'tokens': '1.0.0'},
    }));

    stubHttp(_manifest([
      {'name': 'tokens', 'files': ['tokens/kinetic_colors.dart'], 'depends_on': [], 'pubspec_dependencies': {}},
    ]));

    await runAdd(
      names: ['tokens'],
      addAll: false,
      force: false,
      projectRoot: projectDir.path,
      httpClient: mockHttp,
    );

    // File should still have original content
    expect(tokensFile.readAsStringSync(), '// original');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/commands/add_command_test.dart`
Expected: FAIL.

- [ ] **Step 3: Create lib/src/commands/add_command.dart**

```dart
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import '../registry/registry_client.dart';
import '../registry/registry_manifest.dart';
import '../registry/dependency_resolver.dart';
import '../state/kinetic_state.dart';
import '../generator/barrel_generator.dart';
import '../generator/pubspec_merger.dart';

Future<void> runAdd({
  required List<String> names,
  required bool addAll,
  required bool force,
  required String projectRoot,
  http.Client? httpClient,
}) async {
  if (!addAll && names.isEmpty) {
    print('Usage: dart run flutter_kinetic_ui add <component> [--all] [--force]');
    return;
  }

  final state = KineticState(projectRoot: projectRoot);
  final client = RegistryClient(httpClient: httpClient);

  print('Fetching registry...');
  final manifest = await client.fetchManifest();

  final targetNames = addAll
      ? manifest.components.map((c) => c.name).toList()
      : names.toList();

  final resolver = DependencyResolver(manifest.components);
  final resolved = resolver.resolve(targetNames);
  final installed = state.installedComponents;

  final toInstall = <RegistryComponent>[];
  final alreadyExisting = <RegistryComponent>[];

  for (final c in resolved) {
    if (installed.containsKey(c.name)) {
      alreadyExisting.add(c);
    } else {
      toInstall.add(c);
    }
  }

  if (force && alreadyExisting.isNotEmpty) {
    final existingNames = alreadyExisting.map((c) => c.name).join(', ');
    stdout.write(
        '⚠ $existingNames already exist. --force will overwrite local changes. Continue? (y/N) ');
    final input = stdin.readLineSync()?.toLowerCase();
    if (input != 'y') {
      print('Aborted.');
      return;
    }
    toInstall.addAll(alreadyExisting);
  } else if (alreadyExisting.isNotEmpty) {
    final existingNames = alreadyExisting.map((c) => c.name).join(', ');
    print('Skipping already installed: $existingNames (use --force to overwrite)');
  }

  if (toInstall.isEmpty) {
    print('Nothing new to install.');
    return;
  }

  final merger = PubspecMerger(projectRoot: projectRoot);
  for (final component in toInstall) {
    print('Adding ${component.name}...');
    for (final file in component.files) {
      final content = await client.fetchFile(file);
      final destPath = p.join(projectRoot, 'lib', 'kinetic', file);
      File(destPath).parent.createSync(recursive: true);
      File(destPath).writeAsStringSync(content);
    }
    if (component.pubspecDependencies.isNotEmpty) {
      merger.merge(component.pubspecDependencies);
    }
    state.markInstalled(component.name, manifest.version);
  }

  BarrelGenerator(projectRoot: projectRoot)
      .regenerate(manifest, state.installedComponents.keys.toList());

  print('\n✓ Done! Run `flutter pub get` to install new dependencies.');
}

class AddCommand extends Command<void> {
  @override
  String get name => 'add';

  @override
  String get description => 'Add component(s) to your project';

  AddCommand() {
    argParser
      ..addFlag('all',
          help: 'Add all available components', negatable: false)
      ..addFlag('force',
          abbr: 'f',
          help: 'Overwrite existing components',
          negatable: false);
  }

  @override
  Future<void> run() => runAdd(
        names: argResults!.rest,
        addAll: argResults!['all'] as bool,
        force: argResults!['force'] as bool,
        projectRoot: Directory.current.path,
      );
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `dart test test/commands/add_command_test.dart`
Expected: PASS — all 5 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/commands/add_command.dart test/commands/add_command_test.dart
git commit -m "feat: add command with --all and --force flags"
```

---

### Task 8: status + update Commands

**Files:**
- Create: `lib/src/commands/status_command.dart`
- Create: `lib/src/commands/update_command.dart`
- Test: `test/commands/status_command_test.dart`

**Interfaces:**
- Consumes: `KineticState`, `RegistryClient`, `BarrelGenerator`, `PubspecMerger`
- Produces: `StatusCommand` — prints installed component table; `UpdateCommand` — re-fetches and overwrites components

- [ ] **Step 1: Write failing test**

```dart
// test/commands/status_command_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:flutter_kinetic_ui/src/commands/status_command.dart';

void main() {
  late Directory projectDir;

  setUp(() {
    projectDir = Directory.systemTemp.createTempSync('status_test_');
  });

  tearDown(() => projectDir.deleteSync(recursive: true));

  test('getInstalledSummary returns empty list when not initialized', () {
    final summary = getInstalledSummary(projectRoot: projectDir.path);
    expect(summary, isEmpty);
  });

  test('getInstalledSummary returns installed components', () {
    final stateFile = File(p.join(projectDir.path, '.kinetic', 'kinetic.json'));
    stateFile.parent.createSync(recursive: true);
    stateFile.writeAsStringSync(jsonEncode({
      'registry': 'https://example.com',
      'components': {'tokens': '1.0.0', 'button': '1.0.0'},
    }));

    final summary = getInstalledSummary(projectRoot: projectDir.path);
    expect(summary.length, 2);
    expect(summary.any((e) => e.name == 'button'), isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/commands/status_command_test.dart`
Expected: FAIL.

- [ ] **Step 3: Create lib/src/commands/status_command.dart**

```dart
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
```

- [ ] **Step 4: Create lib/src/commands/update_command.dart**

```dart
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import '../registry/registry_client.dart';
import '../state/kinetic_state.dart';
import '../generator/barrel_generator.dart';
import '../generator/pubspec_merger.dart';

class UpdateCommand extends Command<void> {
  @override
  String get name => 'update';

  @override
  String get description => 'Update component(s) to the latest registry version';

  UpdateCommand() {
    argParser.addFlag('all',
        help: 'Update all installed components', negatable: false);
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
    final client = RegistryClient();

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
        final destPath = p.join(projectRoot, 'lib', 'kinetic', file);
        File(destPath).parent.createSync(recursive: true);
        File(destPath).writeAsStringSync(content);
      }
      if (component.pubspecDependencies.isNotEmpty) {
        merger.merge(component.pubspecDependencies);
      }
      state.markInstalled(name, manifest.version);
    }

    BarrelGenerator(projectRoot: projectRoot)
        .regenerate(manifest, state.installedComponents.keys.toList());

    print('\n✓ Updated! Run `flutter pub get` if new dependencies were added.');
  }
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `dart test test/commands/status_command_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/src/commands/status_command.dart lib/src/commands/update_command.dart test/commands/status_command_test.dart
git commit -m "feat: add status and update commands"
```

---

### Task 9: diff Command

**Files:**
- Create: `lib/src/commands/diff_command.dart`
- Test: `test/commands/diff_command_test.dart`

**Interfaces:**
- Consumes: `RegistryClient`, `KineticState`
- Produces: `DiffCommand` — `diff <name>`, `diff --all`. Prints unified-style diff of local vs registry file. `computeDiff(local, remote) → List<DiffLine>` is the testable pure function.

- [ ] **Step 1: Write failing test**

```dart
// test/commands/diff_command_test.dart
import 'package:test/test.dart';
import 'package:flutter_kinetic_ui/src/commands/diff_command.dart';

void main() {
  group('computeDiff', () {
    test('returns empty list for identical content', () {
      const src = 'line1\nline2\nline3';
      expect(computeDiff(src, src), isEmpty);
    });

    test('detects added lines', () {
      const local  = 'line1\nline2';
      const remote = 'line1\nline2\nline3';
      final diff = computeDiff(local, remote);
      expect(diff.any((d) => d.type == DiffType.added && d.content == 'line3'), isTrue);
    });

    test('detects removed lines', () {
      const local  = 'line1\nline2\nline3';
      const remote = 'line1\nline3';
      final diff = computeDiff(local, remote);
      expect(diff.any((d) => d.type == DiffType.removed && d.content == 'line2'), isTrue);
    });

    test('empty local vs non-empty remote shows all as added', () {
      const remote = 'a\nb\nc';
      final diff = computeDiff('', remote);
      expect(diff.every((d) => d.type == DiffType.added), isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/commands/diff_command_test.dart`
Expected: FAIL.

- [ ] **Step 3: Create lib/src/commands/diff_command.dart**

```dart
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import '../registry/registry_client.dart';
import '../state/kinetic_state.dart';

enum DiffType { added, removed }

class DiffLine {
  final DiffType type;
  final String content;
  DiffLine(this.type, this.content);
}

/// Pure function — computes line-level diff using LCS.
List<DiffLine> computeDiff(String local, String remote) {
  if (local == remote) return const [];

  final localLines  = local.isEmpty  ? <String>[] : local.split('\n');
  final remoteLines = remote.isEmpty ? <String>[] : remote.split('\n');

  final lcs = _lcs(localLines, remoteLines);
  final result = <DiffLine>[];
  int i = 0, j = 0, k = 0;

  while (i < localLines.length || j < remoteLines.length) {
    final inLcs = k < lcs.length;
    final localMatches  = inLcs && i < localLines.length  && localLines[i]  == lcs[k];
    final remoteMatches = inLcs && j < remoteLines.length && remoteLines[j] == lcs[k];

    if (localMatches && remoteMatches) {
      i++; j++; k++;
    } else if (!remoteMatches && j < remoteLines.length &&
        (k >= lcs.length || !localMatches)) {
      result.add(DiffLine(DiffType.added, remoteLines[j++]));
    } else if (i < localLines.length) {
      result.add(DiffLine(DiffType.removed, localLines[i++]));
    } else {
      result.add(DiffLine(DiffType.added, remoteLines[j++]));
    }
  }
  return result;
}

List<String> _lcs(List<String> a, List<String> b) {
  final m = a.length, n = b.length;
  if (m == 0 || n == 0 || m * n > 500000) return [];

  final dp = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));
  for (var i = 1; i <= m; i++) {
    for (var j = 1; j <= n; j++) {
      dp[i][j] = a[i - 1] == b[j - 1]
          ? dp[i - 1][j - 1] + 1
          : (dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1]);
    }
  }

  final result = <String>[];
  var i = m, j = n;
  while (i > 0 && j > 0) {
    if (a[i - 1] == b[j - 1]) {
      result.insert(0, a[i - 1]);
      i--; j--;
    } else if (dp[i - 1][j] > dp[i][j - 1]) {
      i--;
    } else {
      j--;
    }
  }
  return result;
}

class DiffCommand extends Command<void> {
  @override
  String get name => 'diff';

  @override
  String get description =>
      'Show differences between local and registry versions';

  DiffCommand() {
    argParser.addFlag('all',
        help: 'Diff all installed components', negatable: false);
  }

  @override
  Future<void> run() async {
    final diffAll = argResults!['all'] as bool;
    final names = argResults!.rest;

    if (!diffAll && names.isEmpty) {
      print('Usage: dart run flutter_kinetic_ui diff <component> [--all]');
      printUsage();
      return;
    }

    final projectRoot = Directory.current.path;
    final state = KineticState(projectRoot: projectRoot);
    final client = RegistryClient();

    print('Fetching registry...');
    final manifest = await client.fetchManifest();
    final installed = state.installedComponents;
    final targets = diffAll ? installed.keys.toList() : names.toList();

    var anyDiff = false;
    for (final name in targets) {
      final component = manifest.findByName(name);
      if (component == null) {
        print('⚠ Unknown component: $name');
        continue;
      }

      for (final file in component.files) {
        final localPath = p.join(projectRoot, 'lib', 'kinetic', file);
        final localFile = File(localPath);

        if (!localFile.existsSync()) {
          print('$file: not installed locally');
          anyDiff = true;
          continue;
        }

        final localContent = localFile.readAsStringSync();
        final remoteContent = await client.fetchFile(file);
        final diff = computeDiff(localContent, remoteContent);

        if (diff.isEmpty) {
          print('$file: no changes');
        } else {
          anyDiff = true;
          print('\n--- local/$file');
          print('+++ registry@${manifest.version}/$file');
          for (final line in diff) {
            final prefix = line.type == DiffType.added ? '+' : '-';
            print('$prefix ${line.content}');
          }
        }
      }
    }

    if (!anyDiff) print('\nAll components are up to date.');
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `dart test test/commands/diff_command_test.dart`
Expected: PASS — all 4 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/commands/diff_command.dart test/commands/diff_command_test.dart
git commit -m "feat: add diff command with LCS-based line comparison"
```

---

### Task 10: registry.json + button + overlay (Smoke Test)

Write the complete registry manifest and implement the two smoke-test components. Verify the full pipeline end-to-end in a temp Flutter project.

**Files:**
- Create: `registry/registry.json`
- Create: `registry/components/button/button.dart`
- Create: `registry/components/button/button_theme.dart`
- Create: `registry/overlay/kinetic_overlay.dart`
- Test: `test/smoke_test.dart`

**Interfaces:**
- Consumes: all previous tasks
- Produces: complete manifest declaring all 21 components; working `button` and `overlay` implementations

- [ ] **Step 1: Write failing smoke test**

```dart
// test/smoke_test.dart
import 'dart:io';
import 'package:test/test.dart';

void main() {
  test('registry/registry.json is valid JSON with 21 components', () {
    final content = File('registry/registry.json').readAsStringSync();
    final json = jsonDecode(content) as Map<String, dynamic>;
    final components = json['components'] as List;
    // 2 primitives + 13 level-1 + 6 level-2 = 21
    expect(components.length, 21);
    // Every component has required fields
    for (final c in components) {
      final comp = c as Map<String, dynamic>;
      expect(comp['name'], isA<String>());
      expect(comp['files'], isA<List>());
      expect(comp['depends_on'], isA<List>());
      expect(comp['pubspec_dependencies'], isA<Map>());
    }
  });

  test('registry/components/button/button.dart exists and contains KineticButton', () {
    final content = File('registry/components/button/button.dart').readAsStringSync();
    expect(content, contains('class KineticButton'));
  });

  test('registry/overlay/kinetic_overlay.dart exists and contains KineticOverlay', () {
    final content = File('registry/overlay/kinetic_overlay.dart').readAsStringSync();
    expect(content, contains('class KineticOverlay'));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/smoke_test.dart`
Expected: FAIL — files missing.

- [ ] **Step 3: Create registry/registry.json**

```json
{
  "version": "1.0.0",
  "components": [
    {
      "name": "tokens",
      "files": [
        "tokens/kinetic_colors.dart",
        "tokens/kinetic_spacing.dart",
        "tokens/kinetic_radius.dart",
        "tokens/kinetic_typography.dart",
        "tokens/kinetic_shadows.dart",
        "tokens/kinetic_enums.dart",
        "tokens/kinetic_theme.dart"
      ],
      "depends_on": [],
      "pubspec_dependencies": {}
    },
    {
      "name": "overlay",
      "files": ["overlay/kinetic_overlay.dart"],
      "depends_on": ["tokens"],
      "pubspec_dependencies": {}
    },
    {
      "name": "button",
      "files": [
        "components/button/button.dart",
        "components/button/button_theme.dart"
      ],
      "depends_on": ["tokens"],
      "pubspec_dependencies": {}
    },
    {
      "name": "input",
      "files": ["components/input/input.dart"],
      "depends_on": ["tokens"],
      "pubspec_dependencies": {}
    },
    {
      "name": "checkbox",
      "files": ["components/checkbox/checkbox.dart"],
      "depends_on": ["tokens"],
      "pubspec_dependencies": {}
    },
    {
      "name": "switch",
      "files": ["components/switch/kinetic_switch.dart"],
      "depends_on": ["tokens"],
      "pubspec_dependencies": {}
    },
    {
      "name": "badge",
      "files": ["components/badge/badge.dart"],
      "depends_on": ["tokens"],
      "pubspec_dependencies": {}
    },
    {
      "name": "chip",
      "files": ["components/chip/chip.dart"],
      "depends_on": ["tokens"],
      "pubspec_dependencies": {}
    },
    {
      "name": "card",
      "files": ["components/card/card.dart"],
      "depends_on": ["tokens"],
      "pubspec_dependencies": {}
    },
    {
      "name": "slider",
      "files": ["components/slider/kinetic_slider.dart"],
      "depends_on": ["tokens"],
      "pubspec_dependencies": {}
    },
    {
      "name": "progress",
      "files": ["components/progress/progress.dart"],
      "depends_on": ["tokens"],
      "pubspec_dependencies": {}
    },
    {
      "name": "divider",
      "files": ["components/divider/kinetic_divider.dart"],
      "depends_on": ["tokens"],
      "pubspec_dependencies": {}
    },
    {
      "name": "skeleton",
      "files": ["components/skeleton/skeleton.dart"],
      "depends_on": ["tokens"],
      "pubspec_dependencies": {}
    },
    {
      "name": "avatar",
      "files": ["components/avatar/avatar.dart"],
      "depends_on": ["tokens"],
      "pubspec_dependencies": {
        "cached_network_image": "^3.3.0"
      }
    },
    {
      "name": "table",
      "files": ["components/table/kinetic_table.dart"],
      "depends_on": ["tokens"],
      "pubspec_dependencies": {}
    },
    {
      "name": "tooltip",
      "files": ["components/tooltip/tooltip.dart"],
      "depends_on": ["tokens", "overlay"],
      "pubspec_dependencies": {}
    },
    {
      "name": "toast",
      "files": ["components/toast/toast.dart"],
      "depends_on": ["tokens", "overlay"],
      "pubspec_dependencies": {}
    },
    {
      "name": "dialog",
      "files": [
        "components/dialog/dialog.dart",
        "components/dialog/dialog_theme.dart"
      ],
      "depends_on": ["tokens", "overlay", "button"],
      "pubspec_dependencies": {}
    },
    {
      "name": "select",
      "files": ["components/select/select.dart"],
      "depends_on": ["tokens", "overlay", "input"],
      "pubspec_dependencies": {}
    },
    {
      "name": "tabs",
      "files": ["components/tabs/tabs.dart"],
      "depends_on": ["tokens", "button"],
      "pubspec_dependencies": {}
    },
    {
      "name": "accordion",
      "files": ["components/accordion/accordion.dart"],
      "depends_on": ["tokens", "divider"],
      "pubspec_dependencies": {}
    }
  ]
}
```

- [ ] **Step 4: Create registry/components/button/button.dart**

```dart
import 'package:flutter/material.dart';
import '../../tokens/kinetic_colors.dart';
import '../../tokens/kinetic_spacing.dart';
import '../../tokens/kinetic_radius.dart';
import '../../tokens/kinetic_typography.dart';
import '../../tokens/kinetic_shadows.dart';
import '../../tokens/kinetic_enums.dart';
import '../../tokens/kinetic_theme.dart';

class KineticButton extends StatefulWidget {
  final String? label;
  final Widget? child;
  final VoidCallback? onPressed;
  final KineticVariant variant;
  final KineticColor color;
  final KineticSize size;
  final double? radius;
  final bool isDisabled;
  final bool isAnimated;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  const KineticButton({
    super.key,
    this.label,
    this.child,
    this.onPressed,
    this.variant = KineticVariant.solid,
    this.color = KineticColor.primary,
    this.size = KineticSize.md,
    this.radius,
    this.isDisabled = false,
    this.isAnimated = false,
    this.leadingIcon,
    this.trailingIcon,
  }) : assert(label != null || child != null, 'Provide label or child');

  @override
  State<KineticButton> createState() => _KineticButtonState();
}

class _KineticButtonState extends State<KineticButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = KineticTheme.of(context);
    final colors = _resolveColors(theme);
    final effectiveRadius = widget.radius ?? KineticRadius.md;

    Widget content = Padding(
      padding: _resolvePadding(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.leadingIcon != null) ...[
            widget.leadingIcon!,
            const SizedBox(width: KineticSpacing.xs),
          ],
          widget.child ??
              Text(widget.label!,
                  style: _resolveTextStyle()
                      .copyWith(color: colors.foreground)),
          if (widget.trailingIcon != null) ...[
            const SizedBox(width: KineticSpacing.xs),
            widget.trailingIcon!,
          ],
        ],
      ),
    );

    Widget button = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: colors.border != null
            ? Border.all(color: colors.border!, width: 1.5)
            : null,
        boxShadow: widget.variant == KineticVariant.shadow
            ? KineticShadows.md
            : null,
      ),
      child: content,
    );

    if (widget.isAnimated) {
      button = ScaleTransition(scale: _scale, child: button);
    }

    return Opacity(
      opacity: widget.isDisabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTapDown: widget.isAnimated && !widget.isDisabled
            ? (_) => _ctrl.forward()
            : null,
        onTapUp: widget.isAnimated ? (_) => _ctrl.reverse() : null,
        onTapCancel: widget.isAnimated ? () => _ctrl.reverse() : null,
        onTap: widget.isDisabled ? null : widget.onPressed,
        child: button,
      ),
    );
  }

  EdgeInsetsGeometry _resolvePadding() {
    return switch (widget.size) {
      KineticSize.sm => const EdgeInsets.symmetric(
          horizontal: KineticSpacing.md, vertical: KineticSpacing.xs),
      KineticSize.md => const EdgeInsets.symmetric(
          horizontal: KineticSpacing.lg, vertical: KineticSpacing.sm),
      KineticSize.lg => const EdgeInsets.symmetric(
          horizontal: KineticSpacing.xl, vertical: KineticSpacing.md),
    };
  }

  TextStyle _resolveTextStyle() {
    return switch (widget.size) {
      KineticSize.sm => KineticTypography.labelSmall,
      KineticSize.md => KineticTypography.labelMedium,
      KineticSize.lg => KineticTypography.labelLarge,
    };
  }

  ({Color background, Color foreground, Color? border}) _resolveColors(
      KineticThemeData theme) {
    final base = _baseColor(theme);
    return switch (widget.variant) {
      KineticVariant.solid   => (background: base, foreground: _fgColor(theme), border: null),
      KineticVariant.bordered => (background: Colors.transparent, foreground: base, border: base),
      KineticVariant.flat    => (background: base.withOpacity(0.1), foreground: base, border: null),
      KineticVariant.faded   => (background: base.withOpacity(0.15), foreground: base, border: base.withOpacity(0.3)),
      KineticVariant.shadow  => (background: base, foreground: _fgColor(theme), border: null),
      KineticVariant.ghost   => (background: Colors.transparent, foreground: base, border: null),
    };
  }

  Color _baseColor(KineticThemeData theme) => switch (widget.color) {
        KineticColor.primary      => theme.primary,
        KineticColor.secondary    => theme.secondary,
        KineticColor.success      => theme.success,
        KineticColor.warning      => theme.warning,
        KineticColor.danger       => theme.danger,
        KineticColor.defaultColor => theme.foreground,
      };

  Color _fgColor(KineticThemeData theme) => switch (widget.color) {
        KineticColor.primary   => theme.primaryForeground,
        KineticColor.secondary => theme.secondaryForeground,
        _                      => theme.foreground,
      };
}
```

- [ ] **Step 5: Create registry/components/button/button_theme.dart**

```dart
import '../../tokens/kinetic_enums.dart';
import '../../tokens/kinetic_radius.dart';

class KineticButtonTheme {
  final KineticVariant defaultVariant;
  final KineticColor defaultColor;
  final KineticSize defaultSize;
  final double defaultRadius;

  const KineticButtonTheme({
    this.defaultVariant = KineticVariant.solid,
    this.defaultColor = KineticColor.primary,
    this.defaultSize = KineticSize.md,
    this.defaultRadius = KineticRadius.md,
  });
}
```

- [ ] **Step 6: Create registry/overlay/kinetic_overlay.dart**

```dart
import 'package:flutter/material.dart';

class KineticOverlay {
  static OverlayEntry? _currentEntry;

  static void show({
    required BuildContext context,
    required Widget child,
    bool dismissOnTap = true,
  }) {
    hide();
    final overlay = Overlay.of(context);
    _currentEntry = OverlayEntry(
      builder: (_) => _OverlayScaffold(
        dismissOnTap: dismissOnTap,
        onDismiss: hide,
        child: child,
      ),
    );
    overlay.insert(_currentEntry!);
  }

  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _OverlayScaffold extends StatelessWidget {
  final Widget child;
  final bool dismissOnTap;
  final VoidCallback onDismiss;

  const _OverlayScaffold({
    required this.child,
    required this.dismissOnTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (dismissOnTap)
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              child: const ColoredBox(color: Color(0x66000000)),
            ),
          ),
        child,
      ],
    );
  }
}
```

- [ ] **Step 7: Run smoke test to verify it passes**

Run: `dart test test/smoke_test.dart`
Expected: PASS — all 3 tests pass.

- [ ] **Step 8: Run full test suite**

Run: `dart test`
Expected: All tests pass. Note final count.

- [ ] **Step 9: Verify CLI entry point runs**

Run: `dart run flutter_kinetic_ui --help`
Expected: Prints help listing all 6 commands: init, list, add, status, update, diff.

- [ ] **Step 10: Commit**

```bash
git add registry/ test/smoke_test.dart
git commit -m "feat: add registry.json, button, and overlay — CLI infrastructure complete"
```

---

## Self-Review

**Spec coverage check:**

| Spec requirement | Covered by |
|---|---|
| Copy-paste model | add command (Task 7) |
| `dart run flutter_kinetic_ui init` | Task 6 |
| `dart run flutter_kinetic_ui add <name>` | Task 7 |
| `dart run flutter_kinetic_ui add --all` | Task 7 |
| `dart run flutter_kinetic_ui add --force` | Task 7 |
| `dart run flutter_kinetic_ui list` | Task 6 |
| `dart run flutter_kinetic_ui update [--all]` | Task 8 |
| `dart run flutter_kinetic_ui diff [--all]` | Task 9 |
| `dart run flutter_kinetic_ui status` | Task 8 |
| Dependency resolution (topo-sort) | Task 3 |
| registry.json manifest | Task 10 |
| Token files (5 + enums + theme) | Task 2 |
| KineticTheme InheritedWidget + dark mode | Task 2 |
| barrel export auto-generated | Task 5 |
| pubspec.yaml merger | Task 5 |
| .kinetic/kinetic.json state | Task 4 |
| GitHub raw URL fetch | Task 4 |
| button component | Task 10 |
| overlay primitive | Task 10 |
| 21 components declared in registry.json | Task 10 |

**Out of scope for this plan (covered in Plan B):** 19 remaining component implementations (input, checkbox, switch, badge, chip, card, slider, progress, divider, skeleton, avatar, table, tooltip, toast, dialog, select, tabs, accordion + overlay full usage).

**Type consistency check:** `RegistryComponent` defined in Task 3, consumed in Tasks 4, 5, 6, 7, 8, 9 — names and types consistent. `KineticState.installedComponents` returns `Map<String, String>` — used correctly in all commands.
