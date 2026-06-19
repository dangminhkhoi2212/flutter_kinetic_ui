import 'package:flutter/material.dart';
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
      KineticVariant.flat    => (background: base.withValues(alpha: 0.1), foreground: base, border: null),
      KineticVariant.faded   => (background: base.withValues(alpha: 0.15), foreground: base, border: base.withValues(alpha: 0.3)),
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
