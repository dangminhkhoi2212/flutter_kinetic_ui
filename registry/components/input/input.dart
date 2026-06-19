import 'package:flutter/material.dart';
import '../../tokens/kinetic_spacing.dart';
import '../../tokens/kinetic_radius.dart';
import '../../tokens/kinetic_typography.dart';
import '../../tokens/kinetic_enums.dart';
import '../../tokens/kinetic_theme.dart';

class KineticInput extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final KineticVariant variant;
  final KineticSize size;
  final bool isDisabled;
  final int maxLines;
  final TextInputType? keyboardType;

  const KineticInput({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.variant = KineticVariant.bordered,
    this.size = KineticSize.md,
    this.isDisabled = false,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  State<KineticInput> createState() => _KineticInputState();
}

class _KineticInputState extends State<KineticInput> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  EdgeInsets _resolvePadding() {
    return switch (widget.size) {
      KineticSize.sm => const EdgeInsets.symmetric(
          horizontal: KineticSpacing.xs, vertical: KineticSpacing.xs),
      KineticSize.md => const EdgeInsets.symmetric(
          horizontal: KineticSpacing.sm, vertical: KineticSpacing.sm),
      KineticSize.lg => const EdgeInsets.symmetric(
          horizontal: KineticSpacing.md, vertical: KineticSpacing.sm),
    };
  }

  TextStyle _resolveTextStyle() {
    return switch (widget.size) {
      KineticSize.sm => KineticTypography.bodySmall,
      KineticSize.md => KineticTypography.bodyMedium,
      KineticSize.lg => KineticTypography.bodyLarge,
    };
  }

  InputDecoration _resolveDecoration(KineticThemeData theme) {
    final isFocused = _focusNode.hasFocus;
    final hasError = widget.errorText != null;

    final borderColor = hasError
        ? theme.danger
        : isFocused
            ? theme.primary
            : theme.border;

    final InputBorder border;
    final Color? fillColor;
    bool filled;

    switch (widget.variant) {
      case KineticVariant.bordered:
        fillColor = Colors.transparent;
        filled = true;
        border = OutlineInputBorder(
          borderRadius: BorderRadius.circular(KineticRadius.md),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        );
        break;
      case KineticVariant.flat:
        fillColor = theme.muted;
        filled = true;
        border = OutlineInputBorder(
          borderRadius: BorderRadius.circular(KineticRadius.md),
          borderSide: BorderSide.none,
        );
        break;
      case KineticVariant.faded:
        fillColor = theme.muted.withValues(alpha: 0.5);
        filled = true;
        border = OutlineInputBorder(
          borderRadius: BorderRadius.circular(KineticRadius.md),
          borderSide: BorderSide(
            color: hasError ? theme.danger : theme.border,
            width: 1.0,
          ),
        );
        break;
      default:
        fillColor = Colors.transparent;
        filled = true;
        border = OutlineInputBorder(
          borderRadius: BorderRadius.circular(KineticRadius.md),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        );
    }

    final focusedBorder = switch (widget.variant) {
      KineticVariant.flat => OutlineInputBorder(
          borderRadius: BorderRadius.circular(KineticRadius.md),
          borderSide: BorderSide.none,
        ),
      _ => OutlineInputBorder(
          borderRadius: BorderRadius.circular(KineticRadius.md),
          borderSide: BorderSide(
            color: hasError ? theme.danger : theme.primary,
            width: 1.5,
          ),
        ),
    };

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(KineticRadius.md),
      borderSide: BorderSide(color: theme.danger, width: 1.5),
    );

    final contentPadding = _resolvePadding();

    return InputDecoration(
      hintText: widget.hint,
      hintStyle: _resolveTextStyle().copyWith(color: theme.mutedForeground),
      prefixIcon: widget.prefixIcon != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: KineticSpacing.sm),
              child: widget.prefixIcon,
            )
          : null,
      prefixIconConstraints: widget.prefixIcon != null
          ? const BoxConstraints(minWidth: 0, minHeight: 0)
          : null,
      suffixIcon: widget.suffixIcon != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: KineticSpacing.sm),
              child: widget.suffixIcon,
            )
          : null,
      suffixIconConstraints: widget.suffixIcon != null
          ? const BoxConstraints(minWidth: 0, minHeight: 0)
          : null,
      filled: filled,
      fillColor: fillColor,
      contentPadding: contentPadding,
      border: border,
      enabledBorder: border,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      disabledBorder: border,
      errorText: widget.errorText,
      errorStyle: KineticTypography.bodySmall.copyWith(color: theme.danger),
      helperText: widget.helperText,
      helperStyle:
          KineticTypography.bodySmall.copyWith(color: theme.mutedForeground),
      isDense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = KineticTheme.of(context);
    final textStyle = _resolveTextStyle().copyWith(color: theme.foreground);

    Widget field = TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      obscureText: widget.obscureText,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      keyboardType: widget.keyboardType,
      enabled: !widget.isDisabled,
      style: textStyle,
      cursorColor: theme.primary,
      decoration: _resolveDecoration(theme),
    );

    if (widget.label != null) {
      field = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label!,
            style: KineticTypography.labelMedium.copyWith(
              color: theme.foreground,
            ),
          ),
          const SizedBox(height: KineticSpacing.xs),
          field,
        ],
      );
    }

    return Opacity(
      opacity: widget.isDisabled ? 0.5 : 1.0,
      child: field,
    );
  }
}
