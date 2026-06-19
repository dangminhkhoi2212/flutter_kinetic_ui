import '../../tokens/kinetic_radius.dart';

/// Theme configuration for [KineticDialog].
///
/// Pass an instance of this class to customise dialog-wide defaults without
/// having to set properties on every individual dialog widget.
class KineticDialogTheme {
  /// Maximum width of the dialog container in logical pixels.
  final double maxWidth;

  /// Corner radius applied to the dialog container.
  final double borderRadius;

  /// Whether tapping the backdrop dismisses the dialog.
  final bool isDismissable;

  const KineticDialogTheme({
    this.maxWidth = 480,
    this.borderRadius = KineticRadius.xl,
    this.isDismissable = true,
  });
}
