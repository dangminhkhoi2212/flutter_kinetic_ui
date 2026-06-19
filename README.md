# flutter_kinetic_ui

A Flutter UI component library inspired by [shadcn/ui](https://ui.shadcn.com/) — copy-paste components you **own and customize directly**, with a token-based design system and opt-in animations.

```bash
dart run flutter_kinetic_ui add button
```

---

## Philosophy

- **You own the code.** Components are copied into your project, not imported as a black-box dependency.
- **Token-first design.** Edit one file to update colors, spacing, or radius across your entire app.
- **Opt-in animation.** Every interactive component works without animation by default. Add `isAnimated: true` to enable spring press feedback.
- **shadcn-inspired.** Consistent `variant`, `color`, and `size` props across all components.

---

## Installation

This package is distributed via a **private GitHub repository**. You need a GitHub Personal Access Token (PAT) with `repo` scope to access it.

### Step 1 — Add git dependency

In your Flutter project's `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_kinetic_ui:
    git:
      url: git@github.com:flutter-kinetic/flutter_kinetic_ui.git
      ref: main
```

> **SSH (recommended for local dev):** make sure your SSH key is added to GitHub.  
> **HTTPS with PAT:** replace the URL with `https://github.com/flutter-kinetic/flutter_kinetic_ui.git` and configure git credentials (see CI section below).

### Step 2 — Install

```bash
flutter pub get
```

> `flutter_kinetic_ui` is a **pure Dart CLI tool** — it has no Flutter SDK dependency itself. Components are copied as source files into your project; you own and compile them there.

---

## Quick Start

### 1. Initialize with your token

```bash
dart run flutter_kinetic_ui init --token ghp_yourPersonalAccessToken
```

The token is saved to `.kinetic/kinetic.json` and used for all subsequent `add`, `update`, `diff`, and `list` commands. You only need to pass it once.

**Alternative — environment variable (recommended for CI):**

```bash
export KINETIC_GITHUB_TOKEN=ghp_yourPersonalAccessToken
dart run flutter_kinetic_ui init
```

The env var always takes priority over the stored token, so CI pipelines can override without editing any file.

> Add `.kinetic/kinetic.json` to `.gitignore` if your token is stored there, or use the env var approach exclusively in shared environments.

### 2. Initialize (if token already set via env)

```bash
dart run flutter_kinetic_ui init
```

Creates `lib/kinetic/` with all design token files and a barrel export at `lib/kinetic/kinetic_ui.dart`.

### 2. Add components

```bash
dart run flutter_kinetic_ui add button
dart run flutter_kinetic_ui add dialog        # auto-installs overlay + button
dart run flutter_kinetic_ui add button input  # multiple at once
dart run flutter_kinetic_ui add --all         # all 21 components
```

### 3. Import and use

```dart
import 'package:my_app/kinetic/kinetic_ui.dart';

KineticButton(
  label: 'Submit',
  color: KineticColor.primary,
  variant: KineticVariant.solid,
  onPressed: () {},
)
```

---

## CLI Reference

| Command | Description |
|---|---|
| `init` | Initialize — copy token files to `lib/kinetic/` |
| `list` | List all available components (✓ = installed) |
| `add <name...>` | Add component(s) with auto-resolved dependencies |
| `add --all` | Add all 21 components |
| `add <name> --force` | Overwrite existing component without confirmation |
| `update <name>` | Update component to latest registry version |
| `update --all` | Update all installed components |
| `diff <name>` | Show diff between local and registry version |
| `diff --all` | Diff all installed components |
| `status` | Show installed components and their versions |

---

## Design Token System

After `init`, token files are copied to `lib/kinetic/tokens/`. Edit them to customize your design system — no config files, no theme objects.

### Colors — `kinetic_colors.dart`

```dart
abstract class KineticColors {
  static const Color primary   = Color(0xFF7C3AED); // violet
  static const Color success   = Color(0xFF22C55E);
  static const Color warning   = Color(0xFFF59E0B);
  static const Color danger    = Color(0xFFEF4444);
  static const Color info      = Color(0xFF3B82F6);
  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF09090B);
  // ...
}
```

### Spacing — `kinetic_spacing.dart`

```dart
abstract class KineticSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}
```

### Radius — `kinetic_radius.dart`

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

Also: `kinetic_typography.dart` (TextStyle constants), `kinetic_shadows.dart` (BoxShadow presets), `kinetic_enums.dart` (shared enums), `kinetic_theme.dart` (KineticApp InheritedWidget).

---

## Dark Mode

Wrap your app with `KineticApp` for runtime dark/light switching:

```dart
KineticApp(
  theme: KineticThemeData.light(),
  darkTheme: KineticThemeData.dark(),
  child: MaterialApp(home: MyHomePage()),
)
```

Components call `KineticTheme.of(context)` to resolve colors at runtime. Without `KineticApp`, they fall back to the static `KineticColors` constants.

---

## Component Props

All interactive components share a consistent prop API:

| Prop | Type | Default | Description |
|---|---|---|---|
| `variant` | `KineticVariant` | `solid` | `solid`, `bordered`, `flat`, `faded`, `shadow`, `ghost` |
| `color` | `KineticColor` | `primary` | `primary`, `secondary`, `success`, `warning`, `danger`, `defaultColor` |
| `size` | `KineticSize` | `md` | `sm`, `md`, `lg` |
| `isDisabled` | `bool` | `false` | Renders at 50% opacity, blocks interaction |
| `isAnimated` | `bool` | `false` | Enables scale press feedback (0.97) and entrance animation |

---

## Component Library

### Foundation
| Component | Description |
|---|---|
| `tokens` | Design token files (colors, spacing, radius, typography, shadows, enums, theme) |
| `overlay` | Shared overlay primitive used by dialog, toast, tooltip, and select |

### Level 1 — depends on tokens only
| Component | Description |
|---|---|
| `button` | 6 variants · 3 sizes · icon support · animated press |
| `input` | text/password/search · label, hint, error state · variant styling |
| `checkbox` | checked/indeterminate · custom-drawn animated box |
| `switch` | animated thumb slide · on/off toggle |
| `badge` | dot mode and pill mode |
| `chip` | closable, selectable · leading icon support |
| `card` | header/body/footer slots · shadow/bordered/flat variants |
| `slider` | step support · SliderTheme override |
| `progress` | linear & circular · indeterminate · TweenAnimationBuilder |
| `divider` | horizontal/vertical · optional centered label |
| `skeleton` | shimmer animation · `KineticSkeletonText` for multi-line |
| `avatar` | image/initials/icon · `KineticAvatarGroup` with +N overflow |
| `table` | generic `KineticTable<T>` · sortable columns · striped rows |

> `avatar` adds `cached_network_image: ^3.3.0` to your `pubspec.yaml` automatically.

### Level 2 — depends on other components
| Component | Depends on | Description |
|---|---|---|
| `tooltip` | tokens, overlay | Hover/long-press tooltip with custom decoration |
| `toast` | tokens, overlay | Auto-dismiss notification · slide+fade animation |
| `dialog` | tokens, overlay, button | Modal dialog · `KineticDialog.show<T>()` static helper |
| `select` | tokens, overlay, input | Generic `KineticSelect<T>` with OverlayEntry dropdown |
| `tabs` | tokens, button | underline/solid/bordered tab variants · AnimatedSwitcher content |
| `accordion` | tokens, divider | Collapsible sections · `AnimatedSize` expand/collapse |

---

## Dependency Resolution

The CLI automatically installs transitive dependencies in topological order. For example, `add dialog` installs:

```
tokens → overlay → button → dialog
```

Existing components are skipped unless you pass `--force`.

---

## Staying in Sync

After adding a component, you own the file and can edit it freely. To check what changed upstream before updating:

```bash
dart run flutter_kinetic_ui diff button
dart run flutter_kinetic_ui diff --all
```

To pull in upstream changes:

```bash
dart run flutter_kinetic_ui update button
```

---

## File Structure

```
your_flutter_app/
├── pubspec.yaml                         ← add flutter_kinetic_ui to dev_dependencies
├── .kinetic/
│   └── kinetic.json                     ← installed component versions (auto-managed)
└── lib/
    └── kinetic/
        ├── kinetic_ui.dart              ← auto-generated barrel export
        ├── tokens/
        │   ├── kinetic_colors.dart      ← edit to customize colors
        │   ├── kinetic_spacing.dart     ← edit to customize spacing
        │   ├── kinetic_radius.dart
        │   ├── kinetic_typography.dart
        │   ├── kinetic_shadows.dart
        │   ├── kinetic_enums.dart
        │   └── kinetic_theme.dart
        ├── overlay/
        │   └── kinetic_overlay.dart
        └── components/
            ├── button/button.dart
            ├── input/input.dart
            └── ...
```

---

## License

MIT
