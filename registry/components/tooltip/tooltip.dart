import 'package:flutter/material.dart';
import '../../tokens/kinetic_spacing.dart';
import '../../tokens/kinetic_radius.dart';
import '../../tokens/kinetic_typography.dart';
import '../../tokens/kinetic_enums.dart';
import '../../tokens/kinetic_theme.dart';

/// Preferred placement of the tooltip relative to its child.
enum TooltipPlacement { top, bottom, left, right }

/// A tooltip that shows a short message on long-press or hover.
///
/// Uses Flutter's built-in [Tooltip] widget with Kinetic design tokens
/// applied via [decoration] and [textStyle].
///
/// Example:
/// ```dart
/// KineticTooltip(
///   message: 'Save file',
///   child: IconButton(icon: Icon(Icons.save), onPressed: _save),
/// )
/// ```
class KineticTooltip extends StatelessWidget {
  /// The message displayed inside the tooltip bubble.
  final String message;

  /// The widget that triggers the tooltip on long-press or hover.
  final Widget child;

  /// Where the tooltip bubble appears relative to [child].
  final TooltipPlacement placement;

  /// Semantic color slot for the tooltip background.
  /// Defaults to [KineticColor.defaultColor] (theme foreground).
  final KineticColor color;

  const KineticTooltip({
    super.key,
    required this.message,
    required this.child,
    this.placement = TooltipPlacement.top,
    this.color = KineticColor.defaultColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KineticTheme.of(context);
    final bg = _resolveBackground(theme);
    final fg = _resolveForeground(theme);

    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(KineticRadius.sm),
      ),
      textStyle: KineticTypography.bodySmall.copyWith(color: fg),
      padding: const EdgeInsets.symmetric(
        horizontal: KineticSpacing.sm,
        vertical: KineticSpacing.xs,
      ),
      preferBelow: placement == TooltipPlacement.bottom,
      verticalOffset: _resolveVerticalOffset(),
      child: child,
    );
  }

  Color _resolveBackground(KineticThemeData theme) => switch (color) {
        KineticColor.primary => theme.primary,
        KineticColor.secondary => theme.secondary,
        KineticColor.success => theme.success,
        KineticColor.warning => theme.warning,
        KineticColor.danger => theme.danger,
        KineticColor.defaultColor => theme.foreground,
      };

  Color _resolveForeground(KineticThemeData theme) => switch (color) {
        KineticColor.primary => theme.primaryForeground,
        KineticColor.secondary => theme.secondaryForeground,
        _ => theme.background,
      };

  double _resolveVerticalOffset() => switch (placement) {
        TooltipPlacement.top || TooltipPlacement.bottom => 16.0,
        TooltipPlacement.left || TooltipPlacement.right => 0.0,
      };
}
