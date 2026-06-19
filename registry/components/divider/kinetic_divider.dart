import 'package:flutter/material.dart';
import '../../tokens/kinetic_spacing.dart';
import '../../tokens/kinetic_typography.dart';
import '../../tokens/kinetic_theme.dart';

/// A divider line widget that supports horizontal and vertical orientations,
/// optional centered label text, and full theming via [KineticTheme].
class KineticDivider extends StatelessWidget {
  const KineticDivider({
    super.key,
    this.orientation = Axis.horizontal,
    this.label,
    this.thickness = 1.0,
    this.color,
    this.indent = 0,
    this.endIndent = 0,
  });

  /// The axis along which the divider is drawn.
  final Axis orientation;

  /// Optional label text centered on the divider line.
  final String? label;

  /// Thickness of the divider line in logical pixels.
  final double thickness;

  /// Color of the divider line. Defaults to [KineticThemeData.border].
  final Color? color;

  /// Empty space leading the divider line.
  final double indent;

  /// Empty space trailing the divider line.
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    final theme = KineticTheme.of(context);
    final effectiveColor = color ?? theme.border;

    if (orientation == Axis.vertical) {
      return _buildVerticalDivider(effectiveColor);
    }

    if (label != null && label!.isNotEmpty) {
      return _buildHorizontalDividerWithLabel(context, theme, effectiveColor);
    }

    return _buildHorizontalDivider(effectiveColor);
  }

  Widget _buildHorizontalDivider(Color effectiveColor) {
    return Padding(
      padding: EdgeInsets.only(left: indent, right: endIndent),
      child: Container(
        height: thickness,
        color: effectiveColor,
      ),
    );
  }

  Widget _buildHorizontalDividerWithLabel(
    BuildContext context,
    KineticThemeData theme,
    Color effectiveColor,
  ) {
    return Padding(
      padding: EdgeInsets.only(left: indent, right: endIndent),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: thickness,
              color: effectiveColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KineticSpacing.sm,
            ),
            child: Text(
              label!,
              style: KineticTypography.bodySmall.copyWith(
                color: theme.mutedForeground,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: thickness,
              color: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(Color effectiveColor) {
    return Padding(
      padding: EdgeInsets.only(top: indent, bottom: endIndent),
      child: Container(
        width: thickness,
        color: effectiveColor,
      ),
    );
  }
}
