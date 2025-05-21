import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mob_lab_manger/app/bloc/theme_bloc.dart'; // Ensure this path is correct

class ThemeToggleButton extends StatelessWidget {
  final double iconSize;
  final EdgeInsetsGeometry buttonPadding; // Padding for the IconButton itself
  final EdgeInsetsGeometry
      containerPadding; // Padding for the Container around the button
  final double borderRadius;

  const ThemeToggleButton({
    super.key,
    this.iconSize = 26.0,
    this.buttonPadding =
        EdgeInsets.zero, // IconButton often has its own default padding
    this.containerPadding = const EdgeInsets.all(
        3.0), // Default padding around the button inside the container (changed from .only())
    this.borderRadius = 30.0, // Default border radius (as you had it)
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDarkMode = state.themeMode == ThemeMode.dark;
        Color iconColor;

        // Determine icon color based on theme for good contrast against the white container
        if (isDarkMode) {
          // For dark mode, a light icon for the sun
          iconColor = Colors.orangeAccent; // Brighter sun
        } else {
          // For light mode, a darker icon for the moon
          iconColor = Colors.blueGrey.shade700; // Deep blue/grey moon
        }

        return Container(
          padding: containerPadding,
          decoration: BoxDecoration(
            color: Colors.white, // White background for the container
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              // Optional: add a subtle shadow for depth
              BoxShadow(
                color: Colors.black
                    .withAlpha((0.1 * 255).round()), // Use withAlpha
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            padding: buttonPadding, // Apply padding to the IconButton itself
            constraints:
                const BoxConstraints(), // Remove IconButton's default min size if padding is small
            icon: Icon(
              isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded, // Using rounded icons
              color: iconColor,
              size: iconSize,
            ),
            onPressed: () {
              context.read<ThemeBloc>().add(ThemeToggled());
            },
            tooltip:
                isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        );
      },
    );
  }
}
