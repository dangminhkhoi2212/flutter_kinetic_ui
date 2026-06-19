import 'package:flutter/material.dart';
import '../../tokens/kinetic_enums.dart';
import '../../tokens/kinetic_theme.dart';

/// A kinetic-styled slider built on top of Flutter's [Slider] widget.
///
/// Supports semantic colors via [KineticColor], three track/thumb sizes via
/// [KineticSize], optional step divisions, an accessible tooltip label, and a
/// disabled state that renders the control at half opacity and ignores input.
class KineticSlider extends StatelessWidget {
  const KineticSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.color = KineticColor.primary,
    this.size = KineticSize.md,
    this.isDisabled = false,
    this.label,
  }) : assert(
         min <= max,
         'KineticSlider: min ($min) must be less than or equal to max ($max).',
       ),
       assert(
         value >= min && value <= max,
         'KineticSlider: value ($value) must be between min ($min) and max ($max).',
       );

  /// Current value of the slider. Must be within [[min], [max]].
  final double value;

  /// Called whenever the user moves the thumb. Set to `null` (or use
  /// [isDisabled]) to make the slider read-only.
  final ValueChanged<double>? onChanged;

  /// Minimum value of the slider range. Defaults to `0.0`.
  final double min;

  /// Maximum value of the slider range. Defaults to `1.0`.
  final double max;

  /// Number of discrete steps. When non-null the slider snaps and the value
  /// indicator is shown for discrete positions.
  final int? divisions;

  /// Semantic color variant. Defaults to [KineticColor.primary].
  final KineticColor color;

  /// Controls track height and thumb radius. Defaults to [KineticSize.md].
  final KineticSize size;

  /// When `true` the slider renders at 50 % opacity and ignores user input
  /// even if [onChanged] is provided.
  final bool isDisabled;

  /// Text shown inside the tooltip bubble while dragging.
  ///
  /// - If [divisions] is non-null, the indicator is shown only for discrete
  ///   positions (Flutter default behaviour).
  /// - If [divisions] is null but [label] is provided, the indicator is always
  ///   shown while dragging.
  /// - If neither is set, no indicator is shown.
  final String? label;

  // ---------------------------------------------------------------------------
  // Size constants
  // ---------------------------------------------------------------------------

  double get _trackHeight => switch (size) {
    KineticSize.sm => 2.0,
    KineticSize.md => 4.0,
    KineticSize.lg => 6.0,
  };

  double get _thumbDiameter => switch (size) {
    KineticSize.sm => 12.0,
    KineticSize.md => 16.0,
    KineticSize.lg => 20.0,
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
  // Value indicator visibility
  // ---------------------------------------------------------------------------

  ShowValueIndicator get _showValueIndicator {
    if (divisions != null) {
      return ShowValueIndicator.onlyForDiscrete;
    }
    if (label != null) {
      return ShowValueIndicator.onDrag;
    }
    return ShowValueIndicator.never;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = KineticTheme.of(context);
    final resolvedColor = _resolveColor(theme);
    final thumbRadius = _thumbDiameter / 2;

    final slider = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: _trackHeight,
        activeTrackColor: resolvedColor,
        inactiveTrackColor: theme.muted,
        thumbColor: resolvedColor,
        overlayColor: resolvedColor.withValues(alpha: 0.2),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: thumbRadius),
        overlayShape: RoundSliderOverlayShape(
          overlayRadius: _thumbDiameter * 0.75,
        ),
        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
        valueIndicatorColor: resolvedColor,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
        showValueIndicator: _showValueIndicator,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        onChanged: isDisabled ? null : onChanged,
      ),
    );

    if (isDisabled) {
      return Opacity(opacity: 0.5, child: slider);
    }

    return slider;
  }
}
