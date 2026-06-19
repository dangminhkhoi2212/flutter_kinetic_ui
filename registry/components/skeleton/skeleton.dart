import 'package:flutter/material.dart';
import '../../tokens/kinetic_spacing.dart';
import '../../tokens/kinetic_radius.dart';
import '../../tokens/kinetic_theme.dart';

/// A shimmer loading placeholder widget.
///
/// Animates a gradient sweep from left to right to indicate loading state.
///
/// Example:
/// ```dart
/// KineticSkeleton(width: 200, height: 20)
/// KineticSkeleton(isCircle: true, width: 48, height: 48)
/// ```
class KineticSkeleton extends StatefulWidget {
  /// Optional fixed width. If null, fills available width.
  final double? width;

  /// Height of the skeleton placeholder. Defaults to 16.0.
  final double height;

  /// Border radius of the skeleton. Defaults to [KineticRadius.md].
  final double borderRadius;

  /// When true, renders as a circle (ignores [borderRadius]). Defaults to false.
  final bool isCircle;

  const KineticSkeleton({
    super.key,
    this.width,
    this.height = 16.0,
    this.borderRadius = KineticRadius.md,
    this.isCircle = false,
  });

  @override
  State<KineticSkeleton> createState() => _KineticSkeletonState();
}

class _KineticSkeletonState extends State<KineticSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = KineticTheme.of(context);
    final effectiveRadius = widget.isCircle
        ? BorderRadius.circular(KineticRadius.full)
        : BorderRadius.circular(widget.borderRadius);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Sweep the gradient from left-to-right by offsetting alignment with
        // the animation value. The highlight travels from -1 → 1 on the x-axis.
        final double offset = _controller.value * 2 - 1; // -1.0 to 1.0

        return SizedBox(
          width: widget.isCircle ? widget.height : widget.width,
          height: widget.height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: effectiveRadius,
              gradient: LinearGradient(
                begin: Alignment(offset - 1.0, 0),
                end: Alignment(offset + 1.0, 0),
                colors: [
                  theme.muted,
                  theme.border,
                  theme.muted,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A convenience widget that renders several lines of [KineticSkeleton]
/// placeholders to represent a block of loading text.
///
/// The last line is narrower than the rest to mimic natural text layout.
///
/// Example:
/// ```dart
/// KineticSkeletonText(lines: 4, lastLineWidth: 0.5)
/// ```
class KineticSkeletonText extends StatelessWidget {
  /// Number of skeleton lines to render. Defaults to 3.
  final int lines;

  /// Fractional width (0.0–1.0) of the last line relative to available width.
  /// Defaults to 0.7.
  final double lastLineWidth;

  const KineticSkeletonText({
    super.key,
    this.lines = 3,
    this.lastLineWidth = 0.7,
  }) : assert(lines > 0, 'lines must be greater than 0'),
       assert(
         lastLineWidth > 0.0 && lastLineWidth <= 1.0,
         'lastLineWidth must be between 0.0 (exclusive) and 1.0 (inclusive)',
       );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(lines, (index) {
            final isLast = index == lines - 1;
            final width = isLast
                ? availableWidth * lastLineWidth
                : availableWidth;

            return Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0.0 : KineticSpacing.xs,
              ),
              child: KineticSkeleton(
                width: width,
                height: 12.0,
              ),
            );
          }),
        );
      },
    );
  }
}
