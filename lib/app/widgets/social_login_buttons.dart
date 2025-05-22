import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onGoogleLogin;
  final VoidCallback onFacebookLogin;

  const SocialLoginButtons({
    super.key,
    required this.onGoogleLogin,
    required this.onFacebookLogin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // Define button styles based on theme
    Color googleButtonColor =
        isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
    Color googleForegroundColor = isDarkMode ? Colors.white : Colors.black54;
    Color facebookButtonColor = const Color(0xFF1877F2); // Facebook blue
    Color facebookForegroundColor = Colors.white;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Image.asset(
              'assets/icons/google_logo.png', // PROVIDE THIS ASSET
              height: 20,
              width: 20,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.android, size: 20), // Fallback
            ),
            label: const Text('Google'),
            onPressed: onGoogleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: googleButtonColor,
              foregroundColor: googleForegroundColor,
              elevation: 1,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                      color: Colors.grey.shade300, width: isDarkMode ? 0 : 1)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: Image.asset(
              'assets/icons/facebook_logo.png', // PROVIDE THIS ASSET
              height: 20,
              width: 20,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.facebook, size: 20), // Fallback
            ),
            label: const Text('Facebook'),
            onPressed: onFacebookLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: facebookButtonColor,
              foregroundColor: facebookForegroundColor,
              elevation: 1,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
