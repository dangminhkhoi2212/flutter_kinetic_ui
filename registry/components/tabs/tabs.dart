import 'package:flutter/material.dart';
import '../../tokens/kinetic_spacing.dart';
import '../../tokens/kinetic_radius.dart';
import '../../tokens/kinetic_typography.dart';
import '../../tokens/kinetic_enums.dart';
import '../../tokens/kinetic_theme.dart';

/// Visual style variant for [KineticTabs].
enum KineticTabVariant {
  /// Selected tab shows a bottom border in the semantic color.
  underline,

  /// Selected tab has a filled pill/capsule shape with the semantic color.
  solid,

  /// Selected tab has a border and semantic-colored text.
  bordered,
}

/// Describes a single tab in a [KineticTabs] widget.
class KineticTab {
  final String label;
  final Widget? icon;
  final Widget content;

  const KineticTab({
    required this.label,
    required this.content,
    this.icon,
  });
}

/// A tab bar + content widget following the Kinetic design system.
class KineticTabs extends StatefulWidget {
  final List<KineticTab> tabs;
  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final KineticColor color;
  final KineticTabVariant variant;

  const KineticTabs({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onChanged,
    this.color = KineticColor.primary,
    this.variant = KineticTabVariant.underline,
  }) : assert(tabs.length > 0, 'KineticTabs requires at least one tab');

  @override
  State<KineticTabs> createState() => _KineticTabsState();
}

class _KineticTabsState extends State<KineticTabs> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.tabs.length - 1);
  }

  void _selectTab(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    widget.onChanged?.call(index);
  }

  Color _semanticColor(KineticThemeData theme) {
    return switch (widget.color) {
      KineticColor.primary      => theme.primary,
      KineticColor.secondary    => theme.secondary,
      KineticColor.success      => theme.success,
      KineticColor.warning      => theme.warning,
      KineticColor.danger       => theme.danger,
      KineticColor.defaultColor => theme.foreground,
    };
  }

  Color _semanticForeground(KineticThemeData theme) {
    return switch (widget.color) {
      KineticColor.primary   => theme.primaryForeground,
      KineticColor.secondary => theme.secondaryForeground,
      _                      => theme.background,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = KineticTheme.of(context);
    final accent = _semanticColor(theme);
    final accentFg = _semanticForeground(theme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTabBar(theme, accent, accentFg),
        _buildContent(),
      ],
    );
  }

  Widget _buildTabBar(
      KineticThemeData theme, Color accent, Color accentFg) {
    switch (widget.variant) {
      case KineticTabVariant.underline:
        return _UnderlineTabBar(
          tabs: widget.tabs,
          currentIndex: _currentIndex,
          accent: accent,
          theme: theme,
          onTap: _selectTab,
        );
      case KineticTabVariant.solid:
        return _SolidTabBar(
          tabs: widget.tabs,
          currentIndex: _currentIndex,
          accent: accent,
          accentFg: accentFg,
          theme: theme,
          onTap: _selectTab,
        );
      case KineticTabVariant.bordered:
        return _BorderedTabBar(
          tabs: widget.tabs,
          currentIndex: _currentIndex,
          accent: accent,
          theme: theme,
          onTap: _selectTab,
        );
    }
  }

  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: KeyedSubtree(
        key: ValueKey(_currentIndex),
        child: widget.tabs[_currentIndex].content,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Underline variant
// ---------------------------------------------------------------------------

class _UnderlineTabBar extends StatelessWidget {
  final List<KineticTab> tabs;
  final int currentIndex;
  final Color accent;
  final KineticThemeData theme;
  final ValueChanged<int> onTap;

  const _UnderlineTabBar({
    required this.tabs,
    required this.currentIndex,
    required this.accent,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.border, width: 1),
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: KineticSpacing.lg,
                vertical: KineticSpacing.sm,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? accent : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: _TabLabel(
                tab: tabs[i],
                isSelected: isSelected,
                selectedColor: accent,
                unselectedColor: theme.mutedForeground,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Solid variant
// ---------------------------------------------------------------------------

class _SolidTabBar extends StatelessWidget {
  final List<KineticTab> tabs;
  final int currentIndex;
  final Color accent;
  final Color accentFg;
  final KineticThemeData theme;
  final ValueChanged<int> onTap;

  const _SolidTabBar({
    required this.tabs,
    required this.currentIndex,
    required this.accent,
    required this.accentFg,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KineticSpacing.xs),
      decoration: BoxDecoration(
        color: theme.muted,
        borderRadius: BorderRadius.circular(KineticRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(tabs.length, (i) {
          final isSelected = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                horizontal: KineticSpacing.lg,
                vertical: KineticSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected ? accent : Colors.transparent,
                borderRadius: BorderRadius.circular(KineticRadius.md),
              ),
              child: _TabLabel(
                tab: tabs[i],
                isSelected: isSelected,
                selectedColor: accentFg,
                unselectedColor: theme.mutedForeground,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bordered variant
// ---------------------------------------------------------------------------

class _BorderedTabBar extends StatelessWidget {
  final List<KineticTab> tabs;
  final int currentIndex;
  final Color accent;
  final KineticThemeData theme;
  final ValueChanged<int> onTap;

  const _BorderedTabBar({
    required this.tabs,
    required this.currentIndex,
    required this.accent,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(tabs.length, (i) {
        final isSelected = i == currentIndex;
        final isFirst = i == 0;
        final isLast = i == tabs.length - 1;

        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: KineticSpacing.lg,
              vertical: KineticSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? accent.withValues(alpha: 0.08)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? accent : theme.border,
                width: 1.5,
              ),
              borderRadius: BorderRadius.horizontal(
                left: isFirst
                    ? const Radius.circular(KineticRadius.md)
                    : Radius.zero,
                right: isLast
                    ? const Radius.circular(KineticRadius.md)
                    : Radius.zero,
              ),
            ),
            child: _TabLabel(
              tab: tabs[i],
              isSelected: isSelected,
              selectedColor: accent,
              unselectedColor: theme.mutedForeground,
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared tab label helper
// ---------------------------------------------------------------------------

class _TabLabel extends StatelessWidget {
  final KineticTab tab;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;

  const _TabLabel({
    required this.tab,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : unselectedColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tab.icon != null) ...[
          IconTheme(
            data: IconThemeData(color: color, size: 16),
            child: tab.icon!,
          ),
          const SizedBox(width: KineticSpacing.xs),
        ],
        Text(
          tab.label,
          style: KineticTypography.labelMedium.copyWith(color: color),
        ),
      ],
    );
  }
}
