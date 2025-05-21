import 'package:flutter/material.dart';
import 'package:mob_lab_manger/app/widgets/theme_toggle_button.dart'; // For theme consistency

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // No AppBar, but include theme toggle for consistency if desired
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image (consistent with RoleSelectionScreen)
          Image.asset(
            isDarkMode
                ? 'assets/splash/dark_mode_wave_bg.png'
                : 'assets/splash/light_mode_wave_bg.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                  color: isDarkMode ? Colors.black : Colors.grey[300]);
            },
          ),
          const Positioned(
            // Theme toggle
            top: 40, // Adjust based on SafeArea
            right: 16,
            child: ThemeToggleButton(),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.engineering_outlined,
                    size: 80,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Login Screen',
                    style: textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This section is currently under maintenance.',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    label: const Text('Go Back'),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
