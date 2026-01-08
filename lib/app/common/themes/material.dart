import 'package:flutter/material.dart';

ThemeData lightTheme(ColorScheme? lightDynamic) => ThemeData(
  useMaterial3: true,
  colorScheme:
      lightDynamic ??
      ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 245, 244, 244),
        brightness: Brightness.light,
      ),
);

ThemeData darkTheme(ColorScheme? darkDynamic) => ThemeData(
  useMaterial3: true,
  colorScheme:
      darkDynamic ??
      ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 71, 69, 66),
        brightness: Brightness.dark,
      ),
);

ThemeData superDarkTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF00E5FF),
    onPrimary: Colors.black,
    primaryContainer: Color(0xFF004D40),
    onPrimaryContainer: Color(0xFF64FFDA),
    secondary: Color(0xFF03DAC6),
    onSecondary: Colors.black,
    secondaryContainer: Color(0xFF1A237E),
    onSecondaryContainer: Color(0xFFBB86FC),
    tertiary: Color(0xFFBB86FC),
    onTertiary: Colors.black,
    surface: Color(0xFF121212),
    onSurface: Color(0xFFE0E0E0),
    surfaceContainerHighest: Color(0xFF1E1E1E),
    onSurfaceVariant: Color(0xFFB0B0B0),
    error: Color(0xFFCF6679),
    onError: Colors.black,
  ),
  scaffoldBackgroundColor: const Color(0xFF0A0A0A),
  cardColor: const Color(0xFF1E1E1E),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFF121212),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF121212),
    foregroundColor: Color(0xFFE0E0E0),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF121212),
    selectedItemColor: Color(0xFF00E5FF),
    unselectedItemColor: Color(0xFFB0B0B0),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
    bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
    titleLarge: TextStyle(color: Color(0xFFE0E0E0)),
    titleMedium: TextStyle(color: Color(0xFFE0E0E0)),
    labelLarge: TextStyle(color: Color(0xFFE0E0E0)),
  ),
);
