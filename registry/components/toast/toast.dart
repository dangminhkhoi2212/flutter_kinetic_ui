import 'package:flutter/material.dart';
import '../../tokens/kinetic_spacing.dart';
import '../../tokens/kinetic_radius.dart';
import '../../tokens/kinetic_typography.dart';
import '../../tokens/kinetic_shadows.dart';
import '../../tokens/kinetic_enums.dart';
import '../../tokens/kinetic_theme.dart';

/// Displays transient toast notifications anchored to the bottom-center of
/// the screen. Toasts slide in from below, linger for [duration], then slide
/// back out.
///
/// Example:
/// ```dart
/// KineticToast.show(
///   context,
///   message: 'File saved successfully',
///   color: KineticColor.success,
/// );
/// ```
class KineticToast {
  KineticToast._();

  /// Shows a toast notification.
  ///
  /// Each call inserts an independent [OverlayEntry] so multiple toasts can
  /// coexist on screen simultaneously.
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    KineticColor color = KineticColor.defaultColor,
    KineticVariant variant = KineticVariant.solid,
    Duration duration = const Duration(seconds: 3),
    Widget? action,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _KineticToastWidget(
        message: message,
        title: title,
        color: color,
        variant: variant,
        duration: duration,
        action: action,
        themeData: KineticTheme.of(context),
        onDismiss: () {
          entry.remove();
        },
      ),
    );

    overlay.insert(entry);
  }
}

// ---------------------------------------------------------------------------
// Internal animated toast widget
// ---------------------------------------------------------------------------

class _KineticToastWidget extends StatefulWidget {
  final String message;
  final String? title;
  final KineticColor color;
  final KineticVariant variant;
  final Duration duration;
  final Widget? action;
  final KineticThemeData themeData;
  final VoidCallback onDismiss;

  const _KineticToastWidget({
    required this.message,
    required this.title,
    required this.color,
    required this.variant,
    required this.duration,
    required this.action,
    required this.themeData,
    required this.onDismiss,
  });

  @override
  State<_KineticToastWidget> createState() => _KineticToastWidgetState();
}

class _KineticToastWidgetState extends State<_KineticToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _ctrl.forward();

    Future.delayed(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors();

    return Positioned(
      bottom: KineticSpacing.xxl,
      left: KineticSpacing.xl,
      right: KineticSpacing.xl,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.symmetric(
                  horizontal: KineticSpacing.lg,
                  vertical: KineticSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(KineticRadius.lg),
                  border: colors.border != null
                      ? Border.all(color: colors.border!, width: 1.0)
                      : null,
                  boxShadow: KineticShadows.lg,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Color accent strip on the left for non-solid variants
                    if (widget.variant != KineticVariant.solid) ...[
                      Container(
                        width: 3,
                        height: widget.title != null ? 36 : 18,
                        decoration: BoxDecoration(
                          color: _baseColor(),
                          borderRadius: BorderRadius.circular(KineticRadius.sm),
                        ),
                      ),
                      const SizedBox(width: KineticSpacing.sm),
                    ],
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.title != null) ...[
                            Text(
                              widget.title!,
                              style: KineticTypography.labelMedium
                                  .copyWith(color: colors.foreground),
                            ),
                            const SizedBox(height: KineticSpacing.xs),
                          ],
                          Text(
                            widget.message,
                            style: KineticTypography.bodySmall
                                .copyWith(color: colors.foreground),
                          ),
                          if (widget.action != null) ...[
                            const SizedBox(height: KineticSpacing.sm),
                            widget.action!,
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _baseColor() {
    final theme = widget.themeData;
    return switch (widget.color) {
      KineticColor.primary => theme.primary,
      KineticColor.secondary => theme.secondary,
      KineticColor.success => theme.success,
      KineticColor.warning => theme.warning,
      KineticColor.danger => theme.danger,
      KineticColor.defaultColor => theme.foreground,
    };
  }

  Color _baseForeground() {
    final theme = widget.themeData;
    return switch (widget.color) {
      KineticColor.primary => theme.primaryForeground,
      KineticColor.secondary => theme.secondaryForeground,
      _ => theme.foreground,
    };
  }

  ({Color background, Color foreground, Color? border}) _resolveColors() {
    final theme = widget.themeData;
    final base = _baseColor();
    return switch (widget.variant) {
      KineticVariant.solid => (
          background: base,
          foreground: _baseForeground(),
          border: null,
        ),
      KineticVariant.bordered => (
          background: theme.background,
          foreground: base,
          border: base,
        ),
      KineticVariant.flat => (
          background: base.withValues(alpha: 0.1),
          foreground: base,
          border: null,
        ),
      KineticVariant.faded => (
          background: base.withValues(alpha: 0.15),
          foreground: base,
          border: base.withValues(alpha: 0.3),
        ),
      KineticVariant.shadow => (
          background: base,
          foreground: _baseForeground(),
          border: null,
        ),
      KineticVariant.ghost => (
          background: theme.background,
          foreground: base,
          border: null,
        ),
    };
  }
}
