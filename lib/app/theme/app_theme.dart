import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color _lightPrimaryColor = Color(0xFF008080); // Teal
  static const Color _lightAccentColor = Color(0xFFFF9800); // Orange accent
  static const Color _lightScaffoldBackgroundColor = Color(0xFFF5F5F5);
  static const Color _lightSurfaceColor = Colors.white;
  static const Color _lightOnSurfaceColor = Colors.black87;
  static const Color _lightTextColor = Colors.black87;
  static const Color _lightSubtleTextColor = Colors.black54;

  // Dark Theme Colors
  static const Color _darkPrimaryColor =
      Color(0xFF009688); // Slightly brighter Teal for dark
  static const Color _darkAccentColor =
      Color(0xFFFFAB40); // Slightly brighter Orange for dark
  static const Color _darkScaffoldBackgroundColor =
      Color(0xFF121212); // Standard dark bg
  static const Color _darkSurfaceColor =
      Color(0xFF1E1E1E); // Slightly lighter than scaffold for cards etc.
  static const Color _darkOnSurfaceColor = Colors.white;
  static const Color _darkTextColor = Colors.white;
  static const Color _darkSubtleTextColor = Colors.white70;

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: _lightPrimaryColor,
    scaffoldBackgroundColor: _lightScaffoldBackgroundColor,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      elevation: 1,
      backgroundColor: _lightPrimaryColor,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    colorScheme: const ColorScheme.light(
      primary: _lightPrimaryColor,
      secondary: _lightAccentColor,
      surface: _lightSurfaceColor,
      error: Colors.redAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: _lightOnSurfaceColor,
      onError: Colors.white,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 5,
      backgroundColor: _lightSurfaceColor,
      titleTextStyle: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: _lightTextColor),
      contentTextStyle: TextStyle(fontSize: 16, color: _lightSubtleTextColor),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      modalBackgroundColor: _lightSurfaceColor,
      elevation: 5,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: _lightPrimaryColor, width: 2.0),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade600),
      hintStyle: TextStyle(color: Colors.grey.shade400),
    ),
    textTheme: const TextTheme(
      // Define some default text styles for light theme
      headlineSmall:
          TextStyle(color: _lightTextColor, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: _lightSubtleTextColor),
      bodyMedium: TextStyle(color: _lightTextColor),
    ).apply(bodyColor: _lightTextColor, displayColor: _lightTextColor),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _darkPrimaryColor,
    scaffoldBackgroundColor: _darkScaffoldBackgroundColor,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      elevation: 1,
      backgroundColor:
          _darkPrimaryColor, // Or a darker shade like Colors.grey[850]
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimaryColor,
      secondary: _darkAccentColor,
      surface: _darkSurfaceColor,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary:
          Colors.black, // Or Colors.white depending on accent brightness
      onSurface: _darkOnSurfaceColor,
      onError: Colors.black, // Or Colors.white
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 5,
      backgroundColor: _darkSurfaceColor,
      titleTextStyle: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: _darkTextColor),
      contentTextStyle: TextStyle(fontSize: 16, color: _darkSubtleTextColor),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      modalBackgroundColor: _darkSurfaceColor,
      elevation: 5,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: _darkPrimaryColor, width: 2.0),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade400),
      hintStyle: TextStyle(color: Colors.grey.shade600),
    ),
    textTheme: const TextTheme(
      // Define some default text styles for dark theme
      headlineSmall:
          TextStyle(color: _darkTextColor, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: _darkSubtleTextColor),
      bodyMedium: TextStyle(color: _darkTextColor),
    ).apply(bodyColor: _darkTextColor, displayColor: _darkTextColor),
  );
}
