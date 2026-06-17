# flutter_kinetic_ui — Design Spec

**Date:** 2026-06-17  
**Status:** Approved

---

## Overview

`flutter_kinetic_ui` là một Flutter UI component library theo mô hình **copy-paste** (giống shadcn UI). Dev không import components như một dependency — thay vào đó dùng CLI để copy từng component vào project của mình và "sở hữu" code hoàn toàn.

**Triết lý cốt lõi:**
- Dev sở hữu code, không bị lock vào library version
- Customize bằng cách edit trực tiếp file đã copy
- Token-based design system: thay đổi một file, toàn bộ app cập nhật
- Animation là opt-in, không bắt buộc
- Inspired by HeroUI's visual design system

---

## Repository Structure

Một repo duy nhất (`flutter-kinetic/flutter_kinetic_ui`) chứa cả CLI lẫn component registry.

```
flutter_kinetic_ui/
  bin/
    flutter_kinetic_ui.dart      # dart run entry point
  lib/
    src/
      commands/
        add_command.dart
        init_command.dart
        list_command.dart
        update_command.dart
        status_command.dart
      cli_runner.dart
  registry/
    registry.json                # component manifest
    tokens/
      kinetic_colors.dart
      kinetic_spacing.dart
      kinetic_radius.dart
      kinetic_typography.dart
      kinetic_shadows.dart
    components/
      button/
        button.dart
        button_theme.dart
      input/
        input.dart
      checkbox/
        checkbox.dart
      switch/
        kinetic_switch.dart
      badge/
        badge.dart
      chip/
        chip.dart
      card/
        card.dart
      slider/
        kinetic_slider.dart
      progress/
        progress.dart
      divider/
        kinetic_divider.dart
      skeleton/
        skeleton.dart
      avatar/
        avatar.dart
      table/
        kinetic_table.dart
      tooltip/
        tooltip.dart
      toast/
        toast.dart
      dialog/
        dialog.dart
        dialog_theme.dart
      select/
        select.dart
      tabs/
        tabs.dart
      accordion/
        accordion.dart
    overlay/
      kinetic_overlay.dart
  pubspec.yaml
  README.md
```

CLI fetch component qua GitHub raw URL trỏ vào chính repo này:
```
https://raw.githubusercontent.com/flutter-kinetic/flutter_kinetic_ui/main/registry/registry.json
https://raw.githubusercontent.com/flutter-kinetic/flutter_kinetic_ui/main/registry/components/button/button.dart
```

---

## Design Token System

Token là **static constants** trong các file riêng. Dev chỉnh trực tiếp file để customize toàn app — giống CSS custom properties.

### `kinetic_colors.dart`
```dart
abstract class KineticColors {
  // Brand
  static const Color primary            = Color(0xFF7C3AED);
  static const Color primaryForeground  = Color(0xFFFFFFFF);
  static const Color secondary          = Color(0xFF6B7280);
  static const Color secondaryForeground= Color(0xFFFFFFFF);
  // Semantic
  static const Color success   = Color(0xFF22C55E);
  static const Color warning   = Color(0xFFF59E0B);
  static const Color danger    = Color(0xFFEF4444);
  static const Color info      = Color(0xFF3B82F6);
  // Surface
  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF09090B);
  static const Color muted      = Color(0xFFF4F4F5);
  static const Color mutedForeground = Color(0xFF71717A);
  static const Color border     = Color(0xFFE4E4E7);
  static const Color ring       = Color(0xFF7C3AED);
}
```

### `kinetic_spacing.dart`
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

### `kinetic_radius.dart`
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

### `kinetic_typography.dart`
```dart
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

### `kinetic_shadows.dart`
```dart
abstract class KineticShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0D000000), blurRadius: 6,  offset: Offset(0, 2)),
  ];
}
```

---

## Component Architecture

### Props chuẩn (HeroUI-inspired)

Tất cả interactive components đều support các props sau:

| Prop | Type | Values |
|---|---|---|
| `variant` | `KineticVariant` | `solid`, `bordered`, `flat`, `faded`, `shadow`, `ghost` |
| `color` | `KineticColor` | `primary`, `secondary`, `success`, `warning`, `danger`, `default` |
| `size` | `KineticSize` | `sm`, `md`, `lg` |
| `radius` | `KineticRadius` | `none`, `sm`, `md`, `lg`, `full` |
| `isDisabled` | `bool` | — |
| `isAnimated` | `bool` | opt-in, mặc định `false` |

### Animation System (opt-in)

Khi `isAnimated: true`:
- **Press feedback**: scale down 0.97 với spring physics
- **Hover glow**: subtle glow on web/desktop
- **Entrance**: fade + slide in lần đầu render

Chỉ dùng Flutter built-in `AnimationController` + `Curves.easeOutCubic`. Không có external animation dependency.

### Component dùng tokens

```dart
// button.dart (sau khi copy vào project)
Container(
  padding: EdgeInsets.symmetric(
    horizontal: KineticSpacing.lg,
    vertical: KineticSpacing.sm,
  ),
  decoration: BoxDecoration(
    color: KineticColors.primary,
    borderRadius: BorderRadius.circular(KineticRadius.md),
    boxShadow: KineticShadows.sm,
  ),
  child: Text('Button', style: KineticTypography.labelMedium),
)
```

---

## Component List & Dependency Graph

### Primitives
| Component | Description | depends_on | pub deps |
|---|---|---|---|
| `tokens` | Static token files | — | — |
| `overlay` | Shared overlay primitive cho dialog/tooltip/toast/select | tokens | — |

### Level 1 — depends_on: [tokens]
| Component | Notes | pub deps |
|---|---|---|
| `button` | solid/bordered/flat/faded/shadow/ghost · icon support | — |
| `input` | text/password/search · label, hint, error state | — |
| `checkbox` | checked/indeterminate · label | — |
| `switch` | on/off · animated thumb | — |
| `badge` | solid/flat/dot · semantic colors | — |
| `chip` | closable, selectable | — |
| `card` | header/body/footer slots · shadow/bordered/flat | — |
| `slider` | single & range · step support | — |
| `progress` | linear & circular · indeterminate | — |
| `divider` | horizontal/vertical · label support | — |
| `skeleton` | block & text · shimmer animation | — |
| `avatar` | image/initials/icon · group stack | `cached_network_image: ^3.3.0` |
| `table` | sortable columns · custom cell builder | — |

### Level 2 — depends_on: [tokens + other components]
| Component | depends_on | pub deps |
|---|---|---|
| `tooltip` | tokens, overlay | — |
| `toast` | tokens, overlay | — |
| `dialog` | tokens, overlay, button | — |
| `select` | tokens, overlay, input | — |
| `tabs` | tokens, button | — |
| `accordion` | tokens, divider | — |

**Tổng: 2 primitives + 13 Level-1 + 6 Level-2 = 21 components**

---

## Registry Manifest

`registry/registry.json` khai báo metadata cho từng component:

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
        "tokens/kinetic_shadows.dart"
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
      "name": "avatar",
      "files": ["components/avatar/avatar.dart"],
      "depends_on": ["tokens"],
      "pubspec_dependencies": {
        "cached_network_image": "^3.3.0"
      }
    },
    {
      "name": "dialog",
      "files": [
        "components/dialog/dialog.dart",
        "components/dialog/dialog_theme.dart"
      ],
      "depends_on": ["tokens", "overlay", "button"],
      "pubspec_dependencies": {}
    }
  ]
}
```

---

## CLI Design

### Cài đặt

```yaml
dev_dependencies:
  flutter_kinetic_ui: ^1.0.0
```

### Commands

```bash
# Khởi tạo — tạo lib/kinetic/ + copy tokens
dart run flutter_kinetic_ui init

# Xem tất cả components có sẵn
dart run flutter_kinetic_ui list

# Add component (tự resolve dependencies)
dart run flutter_kinetic_ui add button
dart run flutter_kinetic_ui add dialog        # kéo theo overlay + button
dart run flutter_kinetic_ui add button input  # add nhiều cùng lúc

# Update component
dart run flutter_kinetic_ui update button
dart run flutter_kinetic_ui update --all

# Xem trạng thái components đã cài
dart run flutter_kinetic_ui status
```

### Dependency Resolution Flow (`add dialog`)

```
1. Fetch registry.json từ GitHub raw URL
2. dialog → depends_on: [tokens, overlay, button]
3. button → depends_on: [tokens]
4. overlay → depends_on: [tokens]
5. Topo-sort: tokens → overlay → button → dialog
6. Skip components đã tồn tại trong project
7. Copy files vào lib/kinetic/ theo thứ tự đã sort
8. Merge pubspec_dependencies vào pubspec.yaml
9. Regenerate lib/kinetic/kinetic_ui.dart (barrel export)
10. In hướng dẫn: "Run flutter pub get"
```

### File Placement trong project của user

```
lib/
  kinetic/                         # tạo bởi `init`
    tokens/
      kinetic_colors.dart
      kinetic_spacing.dart
      kinetic_radius.dart
      kinetic_typography.dart
      kinetic_shadows.dart
    overlay/
      kinetic_overlay.dart
    components/
      button/
        button.dart
        button_theme.dart
      dialog/
        dialog.dart
        dialog_theme.dart
    kinetic_ui.dart                # barrel export, auto-generated
  .kinetic/
    kinetic.json                   # track installed versions
```

### `.kinetic/kinetic.json`

```json
{
  "registry": "https://raw.githubusercontent.com/flutter-kinetic/flutter_kinetic_ui/main/registry",
  "components": {
    "tokens": "1.0.0",
    "overlay": "1.0.0",
    "button": "1.0.0",
    "dialog": "1.0.0"
  }
}
```

### `kinetic_ui.dart` — auto-generated barrel export

```dart
// AUTO-GENERATED by flutter_kinetic_ui — do not edit manually
export 'tokens/kinetic_colors.dart';
export 'tokens/kinetic_spacing.dart';
export 'tokens/kinetic_radius.dart';
export 'tokens/kinetic_typography.dart';
export 'tokens/kinetic_shadows.dart';
export 'overlay/kinetic_overlay.dart';
export 'components/button/button.dart';
export 'components/dialog/dialog.dart';
```

User chỉ cần:
```dart
import 'package:my_app/kinetic/kinetic_ui.dart';

// Dùng tokens
SizedBox(height: KineticSpacing.md)
Text('Hello', style: KineticTypography.bodyMedium)

// Dùng components
KineticButton(
  label: 'Submit',
  color: KineticColor.primary,
  variant: KineticVariant.solid,
  onPressed: () {},
)
```

---

## Dark Mode

Dùng `KineticTheme` InheritedWidget làm cơ chế chính:

```dart
KineticApp(
  theme: KineticThemeData.light(),
  darkTheme: KineticThemeData.dark(),
  child: MyApp(),
)
```

`KineticThemeData.light()` và `.dark()` là factory constructors với token defaults đã tính sẵn. Components check `KineticTheme.of(context)` để lấy màu đúng theo mode, fallback về static tokens trong `KineticColors` nếu không có `KineticApp` ở ancestor.

**Phân biệt rõ hai khái niệm:**
- `KineticColors` — abstract class, static constants, dùng khi không cần runtime theming
- `KineticColor` — enum (`primary`, `secondary`, `success`, `warning`, `danger`, `default`), dùng trong props của component để chỉ semantic color slot

---

## Out of Scope (v1)

- DatePicker / TimePicker
- DataGrid với pagination
- Rich text editor
- Chart components
- Web-specific components
- Auto-update notifications
