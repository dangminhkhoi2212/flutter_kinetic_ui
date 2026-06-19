import 'package:flutter/material.dart';
import '../../tokens/kinetic_spacing.dart';
import '../../tokens/kinetic_radius.dart';
import '../../tokens/kinetic_shadows.dart';
import '../../tokens/kinetic_enums.dart';
import '../../tokens/kinetic_theme.dart';

/// A versatile card component that supports multiple visual variants and
/// flexible content slots for structured layouts.
class KineticCard extends StatelessWidget {
  /// Simple content slot. Used when [header], [body], and [footer] are not
  /// provided. If any slot is provided, slots take priority over [child].
  final Widget? child;

  /// Top content slot. When all three slots ([header], [body], [footer]) are
  /// provided, thin dividers are drawn between them.
  final Widget? header;

  /// Middle content slot.
  final Widget? body;

  /// Bottom content slot.
  final Widget? footer;

  /// Visual style variant. Defaults to [KineticVariant.shadow].
  final KineticVariant variant;

  /// Padding applied around each slot or around [child].
  /// Defaults to [EdgeInsets.all(KineticSpacing.lg)].
  final EdgeInsetsGeometry? padding;

  const KineticCard({
    super.key,
    this.child,
    this.header,
    this.body,
    this.footer,
    this.variant = KineticVariant.shadow,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KineticTheme.of(context);
    final effectivePadding = padding ?? EdgeInsets.all(KineticSpacing.lg);

    final decoration = _buildDecoration(theme);

    return ClipRRect(
      borderRadius: BorderRadius.circular(KineticRadius.lg),
      child: DecoratedBox(
        decoration: decoration,
        child: _buildContent(effectivePadding, theme),
      ),
    );
  }

  BoxDecoration _buildDecoration(KineticThemeData theme) {
    switch (variant) {
      case KineticVariant.shadow:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(KineticRadius.lg),
          boxShadow: KineticShadows.sm,
        );
      case KineticVariant.bordered:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(KineticRadius.lg),
          border: Border.all(color: theme.border, width: 1),
        );
      case KineticVariant.flat:
        return BoxDecoration(
          color: theme.muted,
          borderRadius: BorderRadius.circular(KineticRadius.lg),
        );
      default:
        // Fallback to shadow style for other variants not explicitly handled.
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(KineticRadius.lg),
          boxShadow: KineticShadows.sm,
        );
    }
  }

  Widget _buildContent(EdgeInsetsGeometry effectivePadding, KineticThemeData theme) {
    final hasHeader = header != null;
    final hasBody = body != null;
    final hasFooter = footer != null;
    final hasAnySlot = hasHeader || hasBody || hasFooter;
    final hasAllSlots = hasHeader && hasBody && hasFooter;

    // Slots take priority over child.
    if (!hasAnySlot) {
      // Only child (or nothing).
      return Padding(
        padding: effectivePadding,
        child: child,
      );
    }

    if (hasAllSlots) {
      // All three slots: render with dividers between them.
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: effectivePadding,
            child: header,
          ),
          Container(height: 1, color: theme.border),
          Padding(
            padding: effectivePadding,
            child: body,
          ),
          Container(height: 1, color: theme.border),
          Padding(
            padding: effectivePadding,
            child: footer,
          ),
        ],
      );
    }

    // Some (but not all) slots provided: render in a Column without dividers.
    final slots = <Widget>[
      if (hasHeader)
        Padding(
          padding: effectivePadding,
          child: header,
        ),
      if (hasBody)
        Padding(
          padding: effectivePadding,
          child: body,
        ),
      if (hasFooter)
        Padding(
          padding: effectivePadding,
          child: footer,
        ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: slots,
    );
  }
}
