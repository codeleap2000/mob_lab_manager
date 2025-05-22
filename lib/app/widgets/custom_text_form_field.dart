import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIconWidget;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool isDense;
  final EdgeInsetsGeometry contentPadding;
  final bool enforceGmail;
  final bool isFocused;
  final int maxLines; // New parameter

  const CustomTextFormField({
    super.key,
    this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIconWidget,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.isDense = true,
    this.contentPadding =
        const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
    this.enforceGmail = false,
    this.isFocused = false,
    this.maxLines = 1, // Default to a single line
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputDecorationTheme = theme.inputDecorationTheme;
    final colorScheme = theme.colorScheme;

    String? combinedValidator(String? value) {
      if (validator != null) {
        final externalError = validator!(value);
        if (externalError != null) {
          debugPrint(
              "[CustomTextFormField] External validator error: '$externalError' for value: '$value'");
          return externalError;
        }
      }
      if (enforceGmail) {
        if (value != null &&
            value.isNotEmpty &&
            !value.toLowerCase().endsWith('@gmail.com')) {
          debugPrint(
              "[CustomTextFormField] Gmail enforcement error for value: '$value'");
          return 'Only @gmail.com addresses are allowed.';
        }
      }
      debugPrint("[CustomTextFormField] Validation passed for value: '$value'");
      return null;
    }

    final defaultBorder = inputDecorationTheme.border ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        );
    final enabledBorder = inputDecorationTheme.enabledBorder ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
              color: isFocused
                  ? colorScheme.primary.withAlpha(100)
                  : Colors.transparent,
              width: 1.0),
        );
    final focusedBorder = inputDecorationTheme.focusedBorder ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        );

    final effectiveFocusedBorder = isFocused
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
                color: colorScheme.primary.withAlpha((0.7 * 255).round()),
                width: 2.5),
          )
        : focusedBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: colorScheme.primary.withAlpha((0.3 * 255).round()),
                  blurRadius: 6.0,
                  spreadRadius: 1.0,
                )
              ]
            : [],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: combinedValidator,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        maxLines: obscureText
            ? 1
            : maxLines, // Password fields should always be single line
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: inputDecorationTheme.hintStyle,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon,
                  color: (isFocused
                      ? colorScheme.primary
                      : colorScheme.primary.withAlpha(200)),
                  size: 20)
              : null,
          suffixIcon: suffixIconWidget,
          filled: true,
          fillColor: theme.canvasColor.withAlpha((0.8 * 255).round()),
          border: defaultBorder,
          enabledBorder: enabledBorder,
          focusedBorder: effectiveFocusedBorder,
          errorBorder: inputDecorationTheme.errorBorder ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide:
                    BorderSide(color: theme.colorScheme.error, width: 1.5),
              ),
          focusedErrorBorder: inputDecorationTheme.focusedErrorBorder ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide:
                    BorderSide(color: theme.colorScheme.error, width: 1.5),
              ),
          isDense: isDense,
          contentPadding: contentPadding,
        ),
      ),
    );
  }
}
