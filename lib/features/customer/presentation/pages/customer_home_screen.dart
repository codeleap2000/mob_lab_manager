import 'package:flutter/material.dart';
import 'package:mob_lab_manger/app/widgets/theme_toggle_button.dart'; // For theme consistency

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            isDarkMode
                ? 'assets/splash/dark_mode_wave_bg.png' // Assuming this is also png now
                : 'assets/splash/light_mode_wave_bg.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                  color: isDarkMode ? Colors.black : Colors.grey[300]);
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.topRight,
                    child: ThemeToggleButton(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Find Your Job / Service', // Updated title
                    style: textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      hintText:
                          'Search for services, job ID...', // Updated hint text
                      prefixIcon:
                          Icon(Icons.search, color: colorScheme.primary),
                      filled: true,
                      // Corrected: Replaced withOpacity with withAlpha
                      fillColor: Theme.of(context)
                          .canvasColor
                          .withAlpha((0.8 * 255).round()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 20.0),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    label: const Text('Go Back to Role Selection'),
                    onPressed: () {
                      // GoRouter is recommended for navigation if already setup
                      // For simplicity, using Navigator.pop if this screen is pushed.
                      // If using GoRouter, context.pop() or context.go(AppRoutes.roleSelection)
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  )
                  // Further UI for customer job listings etc. will go here
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
