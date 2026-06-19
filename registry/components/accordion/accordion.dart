import 'package:flutter/material.dart';
import '../../tokens/kinetic_spacing.dart';
import '../../tokens/kinetic_typography.dart';
import '../../tokens/kinetic_enums.dart';
import '../../tokens/kinetic_theme.dart';
import '../divider/kinetic_divider.dart';

/// A single item in a [KineticAccordion].
class KineticAccordionItem {
  final String title;
  final Widget content;
  final Widget? leadingIcon;
  final bool isInitiallyOpen;

  const KineticAccordionItem({
    required this.title,
    required this.content,
    this.leadingIcon,
    this.isInitiallyOpen = false,
  });
}

/// A collapsible accordion widget following the Kinetic design system.
class KineticAccordion extends StatefulWidget {
  final List<KineticAccordionItem> items;
  final bool allowMultiple;
  final KineticColor color;

  const KineticAccordion({
    super.key,
    required this.items,
    this.allowMultiple = false,
    this.color = KineticColor.defaultColor,
  }) : assert(items.length > 0, 'KineticAccordion requires at least one item');

  @override
  State<KineticAccordion> createState() => _KineticAccordionState();
}

class _KineticAccordionState extends State<KineticAccordion> {
  late Set<int> _openIndices;

  @override
  void initState() {
    super.initState();
    _openIndices = {
      for (var i = 0; i < widget.items.length; i++)
        if (widget.items[i].isInitiallyOpen) i,
    };
    // If allowMultiple is false, keep only the last initially-open item.
    if (!widget.allowMultiple && _openIndices.length > 1) {
      _openIndices = {_openIndices.last};
    }
  }

  void _toggle(int index) {
    setState(() {
      if (_openIndices.contains(index)) {
        _openIndices.remove(index);
      } else {
        if (!widget.allowMultiple) {
          _openIndices.clear();
        }
        _openIndices.add(index);
      }
    });
  }

  Color _accentColor(KineticThemeData theme) {
    return switch (widget.color) {
      KineticColor.primary      => theme.primary,
      KineticColor.secondary    => theme.secondary,
      KineticColor.success      => theme.success,
      KineticColor.warning      => theme.warning,
      KineticColor.danger       => theme.danger,
      KineticColor.defaultColor => theme.foreground,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = KineticTheme.of(context);
    final accent = _accentColor(theme);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.items.length; i++) ...[
          _AccordionItemWidget(
            item: widget.items[i],
            isOpen: _openIndices.contains(i),
            accent: accent,
            theme: theme,
            onTap: () => _toggle(i),
          ),
          if (i < widget.items.length - 1)
            const KineticDivider(orientation: Axis.horizontal),
        ],
      ],
    );
  }
}

class _AccordionItemWidget extends StatelessWidget {
  final KineticAccordionItem item;
  final bool isOpen;
  final Color accent;
  final KineticThemeData theme;
  final VoidCallback onTap;

  const _AccordionItemWidget({
    required this.item,
    required this.isOpen,
    required this.accent,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KineticSpacing.lg,
              ),
              child: Row(
                children: [
                  if (item.leadingIcon != null) ...[
                    IconTheme(
                      data: IconThemeData(
                        color: isOpen ? accent : theme.mutedForeground,
                        size: 18,
                      ),
                      child: item.leadingIcon!,
                    ),
                    const SizedBox(width: KineticSpacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      item.title,
                      style: KineticTypography.labelMedium.copyWith(
                        color: isOpen ? accent : theme.foreground,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: isOpen ? accent : theme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Animated content
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: isOpen
              ? Container(
                  width: double.infinity,
                  color: theme.muted.withValues(alpha: 0.3),
                  padding: const EdgeInsets.all(KineticSpacing.lg),
                  child: item.content,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
