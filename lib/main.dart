import 'package:flutter/material.dart';
import 'screens/auth/landing_page.dart';

import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Wisata Lokal',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF3F51B5), // Deep Indigo
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5),
          secondary: const Color(0xFFFFC107), // Amber Accent
          surface: const Color(
            0xFFF5F5F7,
          ), // Off-white, replaced background with surface
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
            .copyWith(
              displayLarge: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3142),
              ),
              titleLarge: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3142),
              ),
            ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3142),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF2D3142)),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const LandingPage(),
    );
  }
}
