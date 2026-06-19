import 'package:flutter/material.dart';
import '../../tokens/kinetic_spacing.dart';
import '../../tokens/kinetic_radius.dart';
import '../../tokens/kinetic_typography.dart';
import '../../tokens/kinetic_shadows.dart';
import '../../tokens/kinetic_theme.dart';

export 'dialog_theme.dart';

/// A modal dialog widget that follows Kinetic design tokens.
///
/// Use the static [KineticDialog.show] helper to present the dialog via
/// Flutter's routing system (handles scrim, barrier colour, and back-button
/// dismissal automatically).
///
/// Example:
/// ```dart
/// KineticDialog.show(
///   context,
///   child: KineticDialog(
///     title: 'Delete item',
///     body: Text('This action cannot be undone.'),
///     actions: [
///       KineticButton(label: 'Cancel', variant: KineticVariant.bordered, onPressed: () => Navigator.pop(context)),
///       KineticButton(label: 'Delete',  color: KineticColor.danger,      onPressed: _delete),
///     ],
///   ),
/// );
/// ```
class KineticDialog extends StatelessWidget {
  /// Optional dialog heading rendered in [KineticTypography.heading4].
  final String? title;

  /// Optional body widget placed below [title].
  ///
  /// Use [body] for plain text content; use [content] for fully custom layout.
  final Widget? body;

  /// Alternative to [body] — provides a fully custom content area with no
  /// extra wrapping padding applied by the dialog.
  final Widget? content;

  /// Row of action widgets (typically [KineticButton]s) rendered at the
  /// bottom of the dialog, right-aligned.
  final List<Widget>? actions;

  /// Whether tapping the backdrop closes the dialog.
  ///
  /// Passed through to [showDialog]'s `barrierDismissible` when using the
  /// [KineticDialog.show] static helper.
  final bool isDismissable;

  /// Maximum width of the dialog container. Defaults to 480 logical pixels.
  final double? maxWidth;

  const KineticDialog({
    super.key,
    this.title,
    this.body,
    this.content,
    this.actions,
    this.isDismissable = true,
    this.maxWidth,
  });

  // ---------------------------------------------------------------------------
  // Static helper
  // ---------------------------------------------------------------------------

  /// Presents a [KineticDialog] (or any widget) using Flutter's [showDialog],
  /// which handles the modal route, scrim, and system back-button.
  ///
  /// Returns a [Future] that resolves to the value passed to [Navigator.pop].
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissable = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissable,
      barrierColor: const Color(0x80000000),
      builder: (_) => child,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = KineticTheme.of(context);
    final effectiveMaxWidth = maxWidth ?? 480.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: KineticSpacing.xl,
        vertical: KineticSpacing.xxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
          child: Container(
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: BorderRadius.circular(KineticRadius.xl),
              boxShadow: KineticShadows.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      KineticSpacing.xl,
                      KineticSpacing.xl,
                      KineticSpacing.xl,
                      KineticSpacing.md,
                    ),
                    child: Text(
                      title!,
                      style: KineticTypography.heading4
                          .copyWith(color: theme.foreground),
                    ),
                  ),

                // Divider between title and body (when title is present)
                if (title != null && (body != null || content != null))
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.border,
                  ),

                // Body / custom content
                if (content != null)
                  content!
                else if (body != null)
                  Padding(
                    padding: const EdgeInsets.all(KineticSpacing.xl),
                    child: DefaultTextStyle(
                      style: KineticTypography.bodyMedium
                          .copyWith(color: theme.mutedForeground),
                      child: body!,
                    ),
                  ),

                // Actions
                if (actions != null && actions!.isNotEmpty) ...[
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.border,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(KineticSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: _intersperse(
                        actions!,
                        const SizedBox(width: KineticSpacing.sm),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Inserts [separator] between each element of [widgets].
  List<Widget> _intersperse(List<Widget> widgets, Widget separator) {
    if (widgets.isEmpty) return widgets;
    final result = <Widget>[widgets.first];
    for (var i = 1; i < widgets.length; i++) {
      result
        ..add(separator)
        ..add(widgets[i]);
    }
    return result;
  }
}
