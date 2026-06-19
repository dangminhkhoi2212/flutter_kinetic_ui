import 'package:flutter/material.dart';
import '../../tokens/kinetic_spacing.dart';
import '../../tokens/kinetic_typography.dart';
import '../../tokens/kinetic_enums.dart';
import '../../tokens/kinetic_theme.dart';

class _TrackDimensions {
  final double width;
  final double height;
  final double thumbSize;

  const _TrackDimensions({
    required this.width,
    required this.height,
    required this.thumbSize,
  });
}

class KineticSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final KineticColor color;
  final KineticSize size;
  final bool isDisabled;
  final String? label;

  const KineticSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.color = KineticColor.primary,
    this.size = KineticSize.md,
    this.isDisabled = false,
    this.label,
  });

  @override
  State<KineticSwitch> createState() => _KineticSwitchState();
}

class _KineticSwitchState extends State<KineticSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _thumbPosition;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.value ? 1.0 : 0.0,
    );
    _thumbPosition = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(KineticSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  _TrackDimensions _resolveDimensions() => switch (widget.size) {
        KineticSize.sm =>
          const _TrackDimensions(width: 36, height: 20, thumbSize: 14),
        KineticSize.md =>
          const _TrackDimensions(width: 44, height: 24, thumbSize: 18),
        KineticSize.lg =>
          const _TrackDimensions(width: 52, height: 28, thumbSize: 22),
      };

  Color _resolveColor(KineticThemeData theme) => switch (widget.color) {
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
    final dims = _resolveDimensions();
    final semanticColor = _resolveColor(theme);

    final track = GestureDetector(
      onTap: widget.isDisabled
          ? null
          : () => widget.onChanged?.call(!widget.value),
      child: AnimatedBuilder(
        animation: _thumbPosition,
        builder: (context, _) {
          final trackColor =
              Color.lerp(theme.border, semanticColor, _thumbPosition.value)!;
          final thumbOffset = (dims.width - dims.thumbSize - 4) * _thumbPosition.value;

          return Container(
            width: dims.width,
            height: dims.height,
            decoration: BoxDecoration(
              color: trackColor,
              borderRadius: BorderRadius.circular(dims.height / 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Transform.translate(
                  offset: Offset(thumbOffset, 0),
                  child: Container(
                    width: dims.thumbSize,
                    height: dims.thumbSize,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    if (widget.label != null) {
      return Opacity(
        opacity: widget.isDisabled ? 0.5 : 1.0,
        child: GestureDetector(
          onTap: widget.isDisabled
              ? null
              : () => widget.onChanged?.call(!widget.value),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              track,
              const SizedBox(width: KineticSpacing.sm),
              Text(
                widget.label!,
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
      opacity: widget.isDisabled ? 0.5 : 1.0,
      child: track,
    );
  }
}
