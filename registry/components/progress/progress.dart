import 'package:flutter/material.dart';
import '../../tokens/kinetic_spacing.dart';
import '../../tokens/kinetic_radius.dart';
import '../../tokens/kinetic_typography.dart';
import '../../tokens/kinetic_enums.dart';
import '../../tokens/kinetic_theme.dart';

/// A kinetic progress indicator supporting both linear and circular modes,
/// determinate and indeterminate states, and optional label/value display.
class KineticProgress extends StatelessWidget {
  /// Progress value from 0.0 to 1.0. Null means indeterminate.
  final double? value;

  /// Semantic color slot for the progress track fill.
  final KineticColor color;

  /// Size token controlling track height (linear) or diameter/strokeWidth (circular).
  final KineticSize size;

  /// When true, renders a circular indicator; otherwise renders a linear bar.
  final bool isCircular;

  /// Optional label shown below the indicator.
  final String? label;

  /// When true and [value] is non-null, displays the percentage text.
  /// For linear: shown right-aligned below the track.
  /// For circular: overlaid at the center of the indicator.
  final bool showValue;

  const KineticProgress({
    super.key,
    this.value,
    this.color = KineticColor.primary,
    this.size = KineticSize.md,
    this.isCircular = false,
    this.label,
    this.showValue = false,
  }) : assert(
          value == null || (value >= 0.0 && value <= 1.0),
          'value must be between 0.0 and 1.0, or null for indeterminate.',
        );

  // ---------------------------------------------------------------------------
  // Size helpers
  // ---------------------------------------------------------------------------

  double get _trackHeight => switch (size) {
        KineticSize.sm => 4.0,
        KineticSize.md => 6.0,
        KineticSize.lg => 8.0,
      };

  double get _diameter => switch (size) {
        KineticSize.sm => 32.0,
        KineticSize.md => 48.0,
        KineticSize.lg => 64.0,
      };

  double get _strokeWidth => switch (size) {
        KineticSize.sm => 3.0,
        KineticSize.md => 4.0,
        KineticSize.lg => 5.0,
      };

  // ---------------------------------------------------------------------------
  // Color resolver
  // ---------------------------------------------------------------------------

  Color _resolveColor(KineticThemeData theme) => switch (color) {
        KineticColor.primary => theme.primary,
        KineticColor.secondary => theme.secondary,
        KineticColor.success => theme.success,
        KineticColor.warning => theme.warning,
        KineticColor.danger => theme.danger,
        KineticColor.defaultColor => theme.foreground,
      };

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = KineticTheme.of(context);
    return isCircular
        ? _buildCircular(context, theme)
        : _buildLinear(context, theme);
  }

  // ---------------------------------------------------------------------------
  // Linear
  // ---------------------------------------------------------------------------

  Widget _buildLinear(BuildContext context, KineticThemeData theme) {
    final resolvedColor = _resolveColor(theme);
    final bool hasFooter = label != null || (showValue && value != null);

    Widget track;
    if (value == null) {
      // Indeterminate – no animation builder needed; Flutter handles it.
      track = LinearProgressIndicator(
        value: null,
        backgroundColor: theme.muted,
        valueColor: AlwaysStoppedAnimation<Color>(resolvedColor),
      );
    } else {
      // Determinate – animate from 0.0 to current value (and between value changes).
      track = TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: value!),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        builder: (context, animated, _) {
          return LinearProgressIndicator(
            value: animated,
            backgroundColor: theme.muted,
            valueColor: AlwaysStoppedAnimation<Color>(resolvedColor),
          );
        },
      );
    }

    final clippedTrack = SizedBox(
      height: _trackHeight,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(KineticRadius.full),
        child: track,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        clippedTrack,
        if (hasFooter) ...[
          const SizedBox(height: KineticSpacing.xs),
          Row(
            children: [
              if (label != null)
                Flexible(
                  child: Text(
                    label!,
                    style: KineticTypography.labelSmall.copyWith(
                      color: theme.mutedForeground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const Spacer(),
              if (showValue && value != null)
                Text(
                  '${(value! * 100).round()}%',
                  style: KineticTypography.labelSmall.copyWith(
                    color: theme.mutedForeground,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Circular
  // ---------------------------------------------------------------------------

  Widget _buildCircular(BuildContext context, KineticThemeData theme) {
    final resolvedColor = _resolveColor(theme);
    final double diameter = _diameter;
    final double strokeWidth = _strokeWidth;
    final bool hasLabel = label != null;
    final bool hasPercentage = showValue && value != null;

    Widget indicator;
    if (value == null) {
      // Indeterminate circular.
      indicator = SizedBox(
        width: diameter,
        height: diameter,
        child: CircularProgressIndicator(
          value: null,
          strokeWidth: strokeWidth,
          backgroundColor: theme.muted,
          valueColor: AlwaysStoppedAnimation<Color>(resolvedColor),
        ),
      );
    } else {
      // Determinate circular – animate value changes.
      indicator = TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: value!),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        builder: (context, animated, _) {
          return SizedBox(
            width: diameter,
            height: diameter,
            child: CircularProgressIndicator(
              value: animated,
              strokeWidth: strokeWidth,
              backgroundColor: theme.muted,
              valueColor: AlwaysStoppedAnimation<Color>(resolvedColor),
            ),
          );
        },
      );
    }

    // Overlay percentage text in the center when determinate.
    Widget circleWidget;
    if (hasPercentage) {
      final percentageFontSize = switch (size) {
        KineticSize.sm => 9.0,
        KineticSize.md => 12.0,
        KineticSize.lg => 14.0,
      };
      circleWidget = Stack(
        alignment: Alignment.center,
        children: [
          indicator,
          Text(
            '${(value! * 100).round()}%',
            style: KineticTypography.labelSmall.copyWith(
              fontSize: percentageFontSize,
              color: theme.foreground,
            ),
          ),
        ],
      );
    } else {
      circleWidget = indicator;
    }

    if (!hasLabel) {
      return circleWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        circleWidget,
        const SizedBox(height: KineticSpacing.sm),
        Text(
          label!,
          style: KineticTypography.labelSmall.copyWith(
            color: theme.mutedForeground,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
