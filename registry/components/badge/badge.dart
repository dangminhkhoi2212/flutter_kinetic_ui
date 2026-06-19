import 'package:flutter/material.dart';
import '../../tokens/kinetic_radius.dart';
import '../../tokens/kinetic_spacing.dart';
import '../../tokens/kinetic_typography.dart';
import '../../tokens/kinetic_enums.dart';
import '../../tokens/kinetic_theme.dart';

class KineticBadge extends StatelessWidget {
  final String? label;
  final KineticColor color;
  final KineticVariant variant;
  final KineticSize size;

  const KineticBadge({
    super.key,
    this.label,
    this.color = KineticColor.primary,
    this.variant = KineticVariant.solid,
    this.size = KineticSize.md,
  });

  Color _resolveColor(KineticThemeData theme) => switch (color) {
        KineticColor.primary => theme.primary,
        KineticColor.secondary => theme.secondary,
        KineticColor.success => theme.success,
        KineticColor.warning => theme.warning,
        KineticColor.danger => theme.danger,
        KineticColor.defaultColor => theme.foreground,
      };

  TextStyle _resolveTextStyle() => switch (size) {
        KineticSize.sm => KineticTypography.bodySmall,
        KineticSize.md => KineticTypography.bodySmall,
        KineticSize.lg => KineticTypography.bodyMedium,
      };

  ({Color background, Color foreground, Color? borderColor}) _resolveVariantColors(
      KineticThemeData theme) {
    final base = _resolveColor(theme);
    return switch (variant) {
      KineticVariant.solid => (
          background: base,
          foreground: Colors.white,
          borderColor: null,
        ),
      KineticVariant.flat => (
          background: base.withValues(alpha: 0.1),
          foreground: base,
          borderColor: null,
        ),
      KineticVariant.bordered => (
          background: Colors.transparent,
          foreground: base,
          borderColor: base,
        ),
      _ => (
          background: base,
          foreground: Colors.white,
          borderColor: null,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = KineticTheme.of(context);

    // Dot badge (no label)
    if (label == null) {
      final base = _resolveColor(theme);
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: base,
          shape: BoxShape.circle,
        ),
      );
    }

    final colors = _resolveVariantColors(theme);
    final textStyle = _resolveTextStyle().copyWith(
      color: colors.foreground,
      fontWeight: FontWeight.w500,
    );

    EdgeInsets padding;
    switch (size) {
      case KineticSize.sm:
        padding = const EdgeInsets.symmetric(
          horizontal: KineticSpacing.xs,
          vertical: 2.0,
        );
        break;
      case KineticSize.md:
        padding = const EdgeInsets.symmetric(
          horizontal: KineticSpacing.sm,
          vertical: 2.0,
        );
        break;
      case KineticSize.lg:
        padding = const EdgeInsets.symmetric(
          horizontal: KineticSpacing.sm,
          vertical: KineticSpacing.xs,
        );
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(KineticRadius.full),
        border: colors.borderColor != null
            ? Border.all(color: colors.borderColor!, width: 1.5)
            : null,
      ),
      child: Text(label!, style: textStyle),
    );
  }
}
