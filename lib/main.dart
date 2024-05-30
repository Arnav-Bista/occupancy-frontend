import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:occupancy_frontend/constants.dart';
import 'package:occupancy_frontend/features/occupancy/data/data_sources/remote_source.dart';
import 'package:occupancy_frontend/features/occupancy/data/repositories/occupancy_repository.dart';
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
    final OccupancyRepository repository = RemoteSource();
    // repository.getDayData();
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(ConstantColors.burgundy)),
          useMaterial3: true,
          textTheme: GoogleFonts.latoTextTheme(),
        ),
        home: OccupancyScreen());
  }
}
