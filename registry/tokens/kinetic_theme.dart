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
