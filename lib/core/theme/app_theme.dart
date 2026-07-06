import 'package:flutter/material.dart';

class AppTheme {
  // --- WARNA IDENTITAS APLIKASI KITA ---
  // Kita jadikan warna ungu/biru ini sebagai DNA utama aplikasi
  static const Color primaryColor = Color(0xFF4B39EF);
  
  // ==========================================
  // 1. LIGHT MODE (Tampilan Terang Modern)
  // ==========================================
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Warna abu-abu sangat terang (bersih)
    useMaterial3: true,
    
    // Konfigurasi Material 3 Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),

    // Konfigurasi otomatis untuk semua AppBar di aplikasi
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0, 
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
    ),

    // Konfigurasi otomatis untuk semua ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Ujung agak membulat
        ),
      ),
    ),

    // Konfigurasi otomatis untuk Card (Kartu)
    // Konfigurasi otomatis untuk Card (Kartu)
    cardTheme: const CardThemeData( // <-- Tambahkan kata 'Data' di sini
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: Color(0xFFEEEEEE)), // Garis pinggir tipis
      ),
    ),

    // Konfigurasi otomatis untuk Kolom Input (TextField / TextFormField)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2), // Warna primary saat diklik
      ),
    ),
  );


  // ==========================================
  // 2. DARK MODE (Tampilan Gelap Elegan)
  // ==========================================
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212), // Hitam pekat modern
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E), // Abu-abu sangat gelap
      elevation: 0, 
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    cardTheme: const CardThemeData( // <-- Tambahkan kata 'Data' di sini juga
      color: Color(0xFF1E1E1E),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: Color(0xFF333333)), // Garis pinggir agak redup
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF333333)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF333333)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),
  );
}