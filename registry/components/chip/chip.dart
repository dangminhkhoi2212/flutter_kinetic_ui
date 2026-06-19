import 'package:flutter/material.dart';
import '../../tokens/kinetic_spacing.dart';
import '../../tokens/kinetic_radius.dart';
import '../../tokens/kinetic_typography.dart';
import '../../tokens/kinetic_enums.dart';
import '../../tokens/kinetic_theme.dart';

class KineticChip extends StatelessWidget {
  final String label;
  final KineticColor color;
  final KineticVariant variant;
  final KineticSize size;
  final bool isDisabled;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onClose;
  final Widget? leadingIcon;

  const KineticChip({
    super.key,
    required this.label,
    this.color = KineticColor.primary,
    this.variant = KineticVariant.flat,
    this.size = KineticSize.md,
    this.isDisabled = false,
    this.isSelected = false,
    this.onTap,
    this.onClose,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KineticTheme.of(context);
    final colors = _resolveColors(theme);

    final Widget chipContent = Container(
      height: _resolveHeight(),
      padding: EdgeInsets.symmetric(
        horizontal: _resolveHorizontalPadding(),
        vertical: _resolveVerticalPadding(),
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(KineticRadius.full),
        border: colors.border != null
            ? Border.all(color: colors.border!, width: 1.5)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[
            leadingIcon!,
            const SizedBox(width: KineticSpacing.xs),
          ],
          Text(
            label,
            style: _resolveTextStyle().copyWith(color: colors.foreground),
          ),
          if (onClose != null) ...[
            const SizedBox(width: KineticSpacing.xs),
            GestureDetector(
              onTap: isDisabled ? null : onClose,
              child: Icon(
                Icons.close,
                size: 14,
                color: colors.foreground,
              ),
            ),
          ],
        ],
      ),
    );

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: chipContent,
      ),
    );
  }

  double _resolveHeight() => switch (size) {
        KineticSize.sm => 24,
        KineticSize.md => 28,
        KineticSize.lg => 32,
      };

  double _resolveHorizontalPadding() => switch (size) {
        KineticSize.sm => KineticSpacing.sm,
        KineticSize.md => KineticSpacing.md,
        KineticSize.lg => KineticSpacing.lg,
      };

  double _resolveVerticalPadding() => switch (size) {
        KineticSize.sm => KineticSpacing.xs,
        KineticSize.md => KineticSpacing.xs,
        KineticSize.lg => 6,
      };

  TextStyle _resolveTextStyle() => switch (size) {
        KineticSize.sm => KineticTypography.labelSmall,
        KineticSize.md => KineticTypography.labelSmall,
        KineticSize.lg => KineticTypography.labelMedium,
      };

  ({Color background, Color foreground, Color? border}) _resolveColors(
      KineticThemeData theme) {
    if (isSelected) {
      final base = _resolveBaseColor(theme);
      final fg = _resolveFgColor(theme);
      return (background: base, foreground: fg, border: null);
    }
    final base = _resolveBaseColor(theme);
    return switch (variant) {
      KineticVariant.solid => (
          background: base,
          foreground: _resolveFgColor(theme),
          border: null
        ),
      KineticVariant.flat => (
          background: base.withValues(alpha: 0.1),
          foreground: base,
          border: null
        ),
      KineticVariant.bordered => (
          background: Colors.transparent,
          foreground: base,
          border: base
        ),
      KineticVariant.faded => (
          background: base.withValues(alpha: 0.15),
          foreground: base,
          border: base.withValues(alpha: 0.3)
        ),
      KineticVariant.ghost => (
          background: Colors.transparent,
          foreground: base,
          border: null
        ),
      KineticVariant.shadow => (
          background: base,
          foreground: _resolveFgColor(theme),
          border: null
        ),
    };
  }

  Color _resolveBaseColor(KineticThemeData theme) => switch (color) {
        KineticColor.primary => theme.primary,
        KineticColor.secondary => theme.secondary,
        KineticColor.success => theme.success,
        KineticColor.warning => theme.warning,
        KineticColor.danger => theme.danger,
        KineticColor.defaultColor => theme.foreground,
      };

  Color _resolveFgColor(KineticThemeData theme) => switch (color) {
        KineticColor.primary => theme.primaryForeground,
        KineticColor.secondary => theme.secondaryForeground,
        _ => theme.foreground,
      };
}
