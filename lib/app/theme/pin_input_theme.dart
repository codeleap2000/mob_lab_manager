import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class PinInputThemes {
  static PinTheme getPinTheme({
    required BuildContext context,
    required bool isDarkMode,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return PinTheme(
      width: 50,
      height: 56,
      textStyle: textTheme.headlineSmall?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
      decoration: BoxDecoration(
        // Corrected: Replaced withOpacity with withAlpha
        color: isDarkMode
            ? Colors.grey.shade800.withAlpha((0.7 * 255).round())
            : Colors.grey.shade200.withAlpha((0.8 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
    );
  }

  static PinTheme getFocusedPinTheme({
    required BuildContext context,
    required bool isDarkMode,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final defaultTheme = getPinTheme(
        context: context,
        isDarkMode: isDarkMode,
        colorScheme: colorScheme,
        textTheme: textTheme);
    return defaultTheme.copyWith(
      decoration: defaultTheme.decoration!.copyWith(
          border: Border.all(color: colorScheme.primary, width: 2),
          boxShadow: [
            BoxShadow(
              // Corrected: Replaced withOpacity with withAlpha
              color: colorScheme.primary.withAlpha((0.3 * 255).round()),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ]),
    );
  }

  static PinTheme getSubmittedPinTheme({
    required BuildContext context,
    required bool isDarkMode,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final defaultTheme = getPinTheme(
        context: context,
        isDarkMode: isDarkMode,
        colorScheme: colorScheme,
        textTheme: textTheme);
    return defaultTheme.copyWith(
      decoration: defaultTheme.decoration!.copyWith(
        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
      ),
    );
  }

  static PinTheme getErrorPinTheme({
    required BuildContext context,
    required bool isDarkMode,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return PinTheme(
        width: 50,
        height: 56,
        textStyle: textTheme.headlineSmall?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.error,
        ),
        decoration: BoxDecoration(
          // Corrected: Replaced withOpacity with withAlpha
          color: colorScheme.error.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.error, width: 1.5),
        ));
  }
}
