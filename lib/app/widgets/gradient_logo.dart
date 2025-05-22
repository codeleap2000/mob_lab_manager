import 'package:flutter/material.dart';

class GradientLogo extends StatelessWidget {
  final double height;
  final double width;
  final String logoAssetPath; // To make it reusable if you have other logos

  const GradientLogo({
    super.key,
    this.height = 60.0, // Default height, same as last LoginScreen
    this.width = 60.0, // Default width
    required this.logoAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    // Define light gradient colors
    // These can be adjusted to better match your theme or desired effect
    final List<Color> lightGradientColors = [
      Colors.deepPurple,
      Colors.red,
      Colors.teal,
    ];

    // For dark mode, you might want a different gradient or to adjust opacity
    // For now, we'll use the same light gradient but it might look different on dark bg
    // final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // final List<Color> gradientColors = isDarkMode
    //   ? [Colors.teal.shade300, Colors.cyan.shade300]
    //   : lightGradientColors;

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: lightGradientColors, // Using the defined light gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          tileMode: TileMode.clamp,
        ).createShader(bounds);
      },
      blendMode: BlendMode
          .srcIn, // This applies the gradient to the opaque parts of the image
      child: Image.asset(
        logoAssetPath,
        height: height,
        width: width,
        fit: BoxFit.contain,
        // Add an error builder for the image itself
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          // Fallback if the logo asset fails to load
          return Icon(
            Icons.handyman_rounded, // Or your preferred fallback icon
            size: height,
            color: Theme.of(context).colorScheme.primary, // Fallback color
          );
        },
      ),
    );
  }
}
