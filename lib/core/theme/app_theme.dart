import 'package:flutter/material.dart';

class AppTheme {
  // Light Mode 
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
  );

  // Dark Mode 
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFF121212),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
  );
}