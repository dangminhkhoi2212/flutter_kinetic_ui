import 'package:flutter/material.dart';
import '../../tokens/kinetic_spacing.dart';
import '../../tokens/kinetic_radius.dart';
import '../../tokens/kinetic_typography.dart';
import '../../tokens/kinetic_enums.dart';
import '../../tokens/kinetic_theme.dart';

class KineticCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final KineticColor color;
  final KineticSize size;
  final bool isDisabled;
  final bool isIndeterminate;

  const KineticCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.color = KineticColor.primary,
    this.size = KineticSize.md,
    this.isDisabled = false,
    this.isIndeterminate = false,
  });

  double _resolveSize() => switch (size) {
        KineticSize.sm => 16.0,
        KineticSize.md => 20.0,
        KineticSize.lg => 24.0,
      };

  Color _resolveColor(KineticThemeData theme) => switch (color) {
        KineticColor.primary => theme.primary,
        KineticColor.secondary => theme.secondary,
        KineticColor.success => theme.success,
        KineticColor.warning => theme.warning,
        KineticColor.danger => theme.danger,
        KineticColor.defaultColor => theme.foreground,
      };

  @override
  Widget build(BuildContext context) {
    final theme = KineticTheme.of(context);
    final boxSize = _resolveSize();
    final semanticColor = _resolveColor(theme);
    final isCheckedOrIndeterminate = value || isIndeterminate;

    final box = GestureDetector(
      onTap: isDisabled ? null : () => onChanged?.call(isIndeterminate ? false : !value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: boxSize,
        height: boxSize,
        decoration: BoxDecoration(
          color: isCheckedOrIndeterminate ? semanticColor : Colors.transparent,
          borderRadius: BorderRadius.circular(KineticRadius.sm),
          border: Border.all(
            color: isCheckedOrIndeterminate ? semanticColor : theme.border,
            width: 1.5,
          ),
        ),
        child: isCheckedOrIndeterminate
            ? Center(
                child: Icon(
                  isIndeterminate ? Icons.remove : Icons.check,
                  color: Colors.white,
                  size: boxSize * 0.65,
                ),
              )
            : null,
      ),
    );

    if (label != null) {
      return Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: GestureDetector(
          onTap: isDisabled
              ? null
              : () => onChanged?.call(isIndeterminate ? false : !value),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              box,
              const SizedBox(width: KineticSpacing.sm),
              Text(
                label!,
                style: KineticTypography.bodyMedium.copyWith(
                  color: theme.foreground,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: box,
    );
  }
}
