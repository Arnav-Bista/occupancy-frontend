import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:occupancy_frontend/constants.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/screens/occupancy_screen.dart';
import 'package:timezone/data/latest.dart' as tzl;

void main() {
  tzl.initializeTimeZones();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(ConstantColors.burgundy),
          // brightness: Brightness.dark
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.latoTextTheme().copyWith(
          headlineLarge: GoogleFonts.lato(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: GoogleFonts.lato(
            fontSize: 16,
          ),
        ),
      ),
      home: OccupancyScreen(),
    );
  }
}
