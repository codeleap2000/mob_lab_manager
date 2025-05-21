import 'package:flutter/material.dart';

enum CustomButtonType { primary, secondary, text }

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? iconData;
  final CustomButtonType type;
  final Color? backgroundColor; // Overrides theme if provided
  final Color? foregroundColor; // Overrides theme if provided
  final double elevation;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final TextStyle? textStyle;
  final bool isLoading; // To show a loading indicator

  const CustomElevatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.iconData,
    this.type = CustomButtonType.primary,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 2.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.borderRadius = 12.0,
    this.textStyle,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color effectiveBackgroundColor;
    Color effectiveForegroundColor;
    Color? overlayColor; // For splash effect
    BorderSide? side;

    switch (type) {
      case CustomButtonType.secondary:
        effectiveBackgroundColor = backgroundColor ?? colorScheme.secondary;
        effectiveForegroundColor = foregroundColor ?? colorScheme.onSecondary;
        overlayColor =
            colorScheme.onSecondary.withAlpha((0.1 * 255).round()); // Corrected
        break;
      case CustomButtonType.text:
        effectiveBackgroundColor = backgroundColor ?? Colors.transparent;
        effectiveForegroundColor = foregroundColor ?? colorScheme.primary;
        overlayColor =
            colorScheme.primary.withAlpha((0.1 * 255).round()); // Corrected
        side = BorderSide.none;
        break;
      case CustomButtonType.primary: // Made primary explicit, removed default
        effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;
        effectiveForegroundColor = foregroundColor ?? colorScheme.onPrimary;
        overlayColor =
            colorScheme.onPrimary.withAlpha((0.1 * 255).round()); // Corrected
        break;
      // No default needed as all enum values are covered.
    }

    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: type == CustomButtonType.text ? 0 : elevation,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: side ?? BorderSide.none,
      ),
      textStyle:
          textStyle ?? theme.elevatedButtonTheme.style?.textStyle?.resolve({}),
      shadowColor: type == CustomButtonType.text
          ? Colors.transparent
          : theme.shadowColor,
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        // Corrected
        (Set<WidgetState> states) {
          // Corrected
          if (states.contains(WidgetState.pressed)) {
            // Corrected
            return overlayColor;
          }
          return null; // Defer to the default
        },
      ),
    );

    Widget buttonChild = isLoading
        ? SizedBox(
            width: (textStyle?.fontSize ?? 16) *
                1.25, // Dynamic size based on text style
            height: (textStyle?.fontSize ?? 16) * 1.25,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor:
                  AlwaysStoppedAnimation<Color>(effectiveForegroundColor),
            ),
          )
        : Text(text);

    if (iconData != null && !isLoading) {
      return ElevatedButton.icon(
        style: style,
        onPressed: onPressed,
        icon: Icon(iconData,
            size: (textStyle?.fontSize ?? 16) * 1.3), // Slightly larger icon
        label: Text(text),
      );
    } else {
      return ElevatedButton(
        style: style,
        onPressed: onPressed,
        child: buttonChild,
      );
    }
  }
}
