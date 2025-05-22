import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AuthBottomActionLink extends StatelessWidget {
  final String leadingText;
  final String actionText;
  final VoidCallback onActionPressed;

  const AuthBottomActionLink({
    super.key,
    required this.leadingText,
    required this.actionText,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
          ),
          children: [
            TextSpan(text: '$leadingText '),
            TextSpan(
              text: actionText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
                decorationColor: theme.colorScheme.primary,
              ),
              recognizer: TapGestureRecognizer()..onTap = onActionPressed,
            ),
          ],
        ),
      ),
    );
  }
}
