import 'package:flutter/material.dart';
import '../../tokens/kinetic_spacing.dart';
import '../../tokens/kinetic_radius.dart';
import '../../tokens/kinetic_typography.dart';
import '../../tokens/kinetic_enums.dart';
import '../../tokens/kinetic_theme.dart';

/// A single item in a [KineticSelect] dropdown.
class KineticSelectItem<T> {
  final T value;
  final String label;
  final Widget? leadingIcon;
  final bool isDisabled;

  const KineticSelectItem({
    required this.value,
    required this.label,
    this.leadingIcon,
    this.isDisabled = false,
  });
}

/// A dropdown select widget that follows the Kinetic design system.
class KineticSelect<T> extends StatefulWidget {
  final List<KineticSelectItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String placeholder;
  final String? label;
  final KineticVariant variant;
  final KineticSize size;
  final bool isDisabled;

  const KineticSelect({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.placeholder = 'Select...',
    this.label,
    this.variant = KineticVariant.bordered,
    this.size = KineticSize.md,
    this.isDisabled = false,
  });

  @override
  State<KineticSelect<T>> createState() => _KineticSelectState<T>();
}

class _KineticSelectState<T> extends State<KineticSelect<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (ctx) => _SelectDropdown<T>(
        layerLink: _layerLink,
        triggerSize: size,
        items: widget.items,
        selectedValue: widget.value,
        onSelected: (value) {
          _closeDropdown();
          widget.onChanged?.call(value);
        },
        onDismiss: _closeDropdown,
        theme: KineticTheme.of(context),
      ),
    );

    overlay.insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  KineticSelectItem<T>? get _selectedItem {
    if (widget.value == null) return null;
    try {
      return widget.items.firstWhere((item) => item.value == widget.value);
    } catch (_) {
      return null;
    }
  }

  EdgeInsetsGeometry _resolvePadding() {
    return switch (widget.size) {
      KineticSize.sm => const EdgeInsets.symmetric(
          horizontal: KineticSpacing.md, vertical: KineticSpacing.xs),
      KineticSize.md => const EdgeInsets.symmetric(
          horizontal: KineticSpacing.lg, vertical: KineticSpacing.sm),
      KineticSize.lg => const EdgeInsets.symmetric(
          horizontal: KineticSpacing.xl, vertical: KineticSpacing.md),
    };
  }

  double _resolveIconSize() {
    return switch (widget.size) {
      KineticSize.sm => 14.0,
      KineticSize.md => 16.0,
      KineticSize.lg => 18.0,
    };
  }

  TextStyle _resolveTextStyle() {
    return switch (widget.size) {
      KineticSize.sm => KineticTypography.labelSmall,
      KineticSize.md => KineticTypography.labelMedium,
      KineticSize.lg => KineticTypography.labelLarge,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = KineticTheme.of(context);
    final selectedItem = _selectedItem;
    final hasValue = selectedItem != null;

    Color borderColor;
    Color bgColor;
    Color textColor;

    switch (widget.variant) {
      case KineticVariant.bordered:
        borderColor = _isOpen ? theme.primary : theme.border;
        bgColor = theme.background;
        textColor = hasValue ? theme.foreground : theme.mutedForeground;
        break;
      case KineticVariant.flat:
        borderColor = Colors.transparent;
        bgColor = theme.muted;
        textColor = hasValue ? theme.foreground : theme.mutedForeground;
        break;
      case KineticVariant.faded:
        borderColor = theme.border.withValues(alpha: 0.5);
        bgColor = theme.muted.withValues(alpha: 0.5);
        textColor = hasValue ? theme.foreground : theme.mutedForeground;
        break;
      default:
        borderColor = _isOpen ? theme.primary : theme.border;
        bgColor = theme.background;
        textColor = hasValue ? theme.foreground : theme.mutedForeground;
    }

    Widget trigger = CompositedTransformTarget(
      link: _layerLink,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(KineticRadius.md),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Padding(
          padding: _resolvePadding(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (selectedItem != null && selectedItem.leadingIcon != null) ...[
                      selectedItem.leadingIcon!,
                      const SizedBox(width: KineticSpacing.sm),
                    ],
                    Expanded(
                      child: Text(
                        hasValue ? selectedItem!.label : widget.placeholder,
                        style: _resolveTextStyle().copyWith(color: textColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: _isOpen ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: _resolveIconSize() + 2,
                  color: theme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Opacity(
      opacity: widget.isDisabled ? 0.5 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: KineticTypography.labelSmall.copyWith(
                color: theme.foreground,
              ),
            ),
            const SizedBox(height: KineticSpacing.xs),
          ],
          GestureDetector(
            onTap: widget.isDisabled ? null : _toggleDropdown,
            child: trigger,
          ),
        ],
      ),
    );
  }
}

class _SelectDropdown<T> extends StatelessWidget {
  final LayerLink layerLink;
  final Size triggerSize;
  final List<KineticSelectItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T?> onSelected;
  final VoidCallback onDismiss;
  final KineticThemeData theme;

  const _SelectDropdown({
    required this.layerLink,
    required this.triggerSize,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    required this.onDismiss,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.translucent,
            child: const SizedBox.expand(),
          ),
        ),
        CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, triggerSize.height + KineticSpacing.xs),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: triggerSize.width,
              constraints: const BoxConstraints(maxHeight: 240),
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(KineticRadius.md),
                border: Border.all(color: theme.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(KineticRadius.md),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: KineticSpacing.xs,
                  ),
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item.value == selectedValue;

                    return _SelectItemTile<T>(
                      item: item,
                      isSelected: isSelected,
                      theme: theme,
                      onTap: item.isDisabled ? null : () => onSelected(item.value),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectItemTile<T> extends StatefulWidget {
  final KineticSelectItem<T> item;
  final bool isSelected;
  final KineticThemeData theme;
  final VoidCallback? onTap;

  const _SelectItemTile({
    required this.item,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  State<_SelectItemTile<T>> createState() => _SelectItemTileState<T>();
}

class _SelectItemTileState<T> extends State<_SelectItemTile<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.item.isDisabled;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          onEnter: isDisabled ? null : (_) => setState(() => _isHovered = true),
          onExit: isDisabled ? null : (_) => setState(() => _isHovered = false),
          child: Container(
            color: widget.isSelected
                ? widget.theme.primary.withValues(alpha: 0.08)
                : _isHovered
                    ? widget.theme.muted
                    : Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: KineticSpacing.lg,
              vertical: KineticSpacing.sm,
            ),
            child: Row(
              children: [
                if (widget.item.leadingIcon != null) ...[
                  widget.item.leadingIcon!,
                  const SizedBox(width: KineticSpacing.sm),
                ],
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: KineticTypography.bodyMedium.copyWith(
                      color: widget.isSelected
                          ? widget.theme.primary
                          : widget.theme.foreground,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                if (widget.isSelected)
                  Icon(
                    Icons.check,
                    size: 16,
                    color: widget.theme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
