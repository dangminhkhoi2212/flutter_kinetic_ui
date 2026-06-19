import 'package:flutter/material.dart';

class KineticOverlay {
  static OverlayEntry? _currentEntry;

  static void show({
    required BuildContext context,
    required Widget child,
    bool dismissOnTap = true,
  }) {
    hide();
    final overlay = Overlay.of(context);
    _currentEntry = OverlayEntry(
      builder: (_) => _OverlayScaffold(
        dismissOnTap: dismissOnTap,
        onDismiss: hide,
        child: child,
      ),
    );
    overlay.insert(_currentEntry!);
  }

  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _OverlayScaffold extends StatelessWidget {
  final Widget child;
  final bool dismissOnTap;
  final VoidCallback onDismiss;

  const _OverlayScaffold({
    required this.child,
    required this.dismissOnTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (dismissOnTap)
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              child: const ColoredBox(color: Color(0x66000000)),
            ),
          ),
        child,
      ],
    );
  }
}
