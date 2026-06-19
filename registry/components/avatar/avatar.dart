import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../tokens/kinetic_enums.dart';
import '../../tokens/kinetic_theme.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

double _diameterForSize(KineticSize size) {
  switch (size) {
    case KineticSize.sm:
      return 32;
    case KineticSize.md:
      return 40;
    case KineticSize.lg:
      return 48;
  }
}

/// Resolves the background color for a given [KineticColor] from the theme.
Color _bgColor(KineticColor color, KineticThemeData theme) {
  switch (color) {
    case KineticColor.primary:
      return theme.primary;
    case KineticColor.secondary:
      return theme.secondary;
    case KineticColor.success:
      return theme.success;
    case KineticColor.warning:
      return theme.warning;
    case KineticColor.danger:
      return theme.danger;
    case KineticColor.defaultColor:
      return theme.muted;
  }
}

/// Resolves the foreground (text/icon) color that contrasts with [_bgColor].
Color _fgColor(KineticColor color, KineticThemeData theme) {
  switch (color) {
    case KineticColor.primary:
      return theme.primaryForeground;
    case KineticColor.secondary:
      return theme.secondaryForeground;
    case KineticColor.success:
    case KineticColor.warning:
    case KineticColor.danger:
      return theme.background;
    case KineticColor.defaultColor:
      return theme.mutedForeground;
  }
}

// ---------------------------------------------------------------------------
// KineticAvatar
// ---------------------------------------------------------------------------

/// A circular (or custom-radius) avatar widget.
///
/// Displays content in priority order:
///   [imageUrl] > [initials] > [icon] > default person icon (Icons.person).
///
/// When [imageUrl] is loading a muted placeholder is shown; on error the
/// initials/icon fallback is used.
class KineticAvatar extends StatelessWidget {
  const KineticAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.icon,
    this.size = KineticSize.md,
    this.color = KineticColor.primary,
    this.radius,
    this.onTap,
  });

  /// Remote image URL loaded via CachedNetworkImage.
  final String? imageUrl;

  /// 1–2 letter initials shown when no image is available.
  final String? initials;

  /// Fallback icon shown when neither [imageUrl] nor [initials] is provided.
  final Widget? icon;

  /// Controls the avatar diameter: sm=32, md=40, lg=48.
  final KineticSize size;

  /// Background color used for the initials/icon surface.
  final KineticColor color;

  /// Border radius. Defaults to a full circle (diameter / 2) when null.
  final double? radius;

  /// Optional tap handler; wraps the avatar in an [InkWell] when set.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = KineticTheme.of(context);
    final diameter = _diameterForSize(size);
    final effectiveRadius = radius ?? diameter / 2;
    final borderRadius = BorderRadius.circular(effectiveRadius);

    Widget content;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      content = _buildImageContent(
        context,
        theme: theme,
        diameter: diameter,
        bgColor: _bgColor(color, theme),
      );
    } else {
      content = _buildFallbackContent(
        theme: theme,
        diameter: diameter,
        bgColor: _bgColor(color, theme),
        fgColor: _fgColor(color, theme),
      );
    }

    Widget avatar = ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(width: diameter, height: diameter, child: content),
    );

    if (onTap != null) {
      avatar = InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildImageContent(
    BuildContext context, {
    required KineticThemeData theme,
    required double diameter,
    required Color bgColor,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: diameter,
      height: diameter,
      fit: BoxFit.cover,
      // Loading placeholder: muted container mimicking a shimmer.
      placeholder: (context, url) => Container(
        width: diameter,
        height: diameter,
        color: theme.muted,
      ),
      // On error: fall back to initials/icon.
      errorWidget: (context, url, error) => _buildFallbackContent(
        theme: theme,
        diameter: diameter,
        bgColor: bgColor,
        fgColor: _fgColor(color, theme),
      ),
    );
  }

  Widget _buildFallbackContent({
    required KineticThemeData theme,
    required double diameter,
    required Color bgColor,
    required Color fgColor,
  }) {
    Widget child;

    if (initials != null && initials!.isNotEmpty) {
      final text =
          initials!.length > 2 ? initials!.substring(0, 2) : initials!;
      child = Center(
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: fgColor,
            fontSize: diameter * 0.35,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      );
    } else if (icon != null) {
      child = Center(child: icon!);
    } else {
      child = Center(
        child: Icon(
          Icons.person,
          color: fgColor.withValues(alpha: 0.8),
          size: diameter * 0.55,
        ),
      );
    }

    return Container(
      width: diameter,
      height: diameter,
      color: bgColor,
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// KineticAvatarGroup
// ---------------------------------------------------------------------------

/// Displays a row of overlapping [KineticAvatar] widgets.
///
/// When the number of avatars exceeds [max], the overflow is collapsed into
/// a "+N" badge rendered as an additional avatar at the end.
class KineticAvatarGroup extends StatelessWidget {
  const KineticAvatarGroup({
    super.key,
    required this.avatars,
    this.max = 3,
    this.size = KineticSize.md,
  });

  /// List of [KineticAvatar] (or any Widget) instances to display.
  final List<Widget> avatars;

  /// Maximum visible avatars before collapsing the rest into "+N".
  final int max;

  /// Controls the avatar diameter and overlap spacing.
  final KineticSize size;

  @override
  Widget build(BuildContext context) {
    final theme = KineticTheme.of(context);
    final diameter = _diameterForSize(size);
    // Each subsequent avatar is shifted by half its diameter.
    final step = diameter * 0.5;
    const borderWidth = 2.0;

    final visibleCount = avatars.length > max ? max : avatars.length;
    final overflowCount = avatars.length - visibleCount;
    final hasOverflow = overflowCount > 0;

    final itemCount = visibleCount + (hasOverflow ? 1 : 0);

    // First item occupies full diameter; each additional item adds `step`.
    final totalWidth =
        itemCount == 0 ? 0.0 : diameter + (itemCount - 1) * step;

    return SizedBox(
      width: totalWidth,
      height: diameter,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < visibleCount; i++)
            Positioned(
              left: i * step,
              child: _BorderedAvatar(
                borderWidth: borderWidth,
                borderColor: theme.background,
                diameter: diameter,
                child: avatars[i],
              ),
            ),
          if (hasOverflow)
            Positioned(
              left: visibleCount * step,
              child: _BorderedAvatar(
                borderWidth: borderWidth,
                borderColor: theme.background,
                diameter: diameter,
                child: _OverflowBadge(
                  count: overflowCount,
                  diameter: diameter,
                  theme: theme,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers for KineticAvatarGroup
// ---------------------------------------------------------------------------

/// Wraps a child in a circular border so overlapping avatars appear separated.
class _BorderedAvatar extends StatelessWidget {
  const _BorderedAvatar({
    required this.borderWidth,
    required this.borderColor,
    required this.diameter,
    required this.child,
  });

  final double borderWidth;
  final Color borderColor;
  final double diameter;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter + borderWidth * 2,
      height: diameter + borderWidth * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: borderColor,
      ),
      padding: EdgeInsets.all(borderWidth),
      child: ClipOval(
        child: SizedBox(width: diameter, height: diameter, child: child),
      ),
    );
  }
}

/// The "+N" overflow badge at the end of a [KineticAvatarGroup].
class _OverflowBadge extends StatelessWidget {
  const _OverflowBadge({
    required this.count,
    required this.diameter,
    required this.theme,
  });

  final int count;
  final double diameter;
  final KineticThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.muted,
      ),
      child: Center(
        child: Text(
          '+$count',
          style: TextStyle(
            color: theme.mutedForeground,
            fontSize: diameter * 0.30,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ),
    );
  }
}
