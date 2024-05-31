import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:occupancy_frontend/core/widgets/custom_progress_indicator.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/occupancy_entity.dart';

class OccupancyDetailsScreen extends ConsumerWidget {
  const OccupancyDetailsScreen(
      {super.key,
      required this.displayName,
      required this.dataName,
      required this.mainColor,
      required this.textColor,
      required this.progressColor,
      required this.emptyColor});
  final String displayName;
  final String dataName;
  final Color? mainColor;
  final Color textColor;
  final Color? progressColor;
  final Color? emptyColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occupancyProvider = ref.watch(occupancyEntityProvider(dataName));
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text(
          displayName,
        ),
      ),
      body: occupancyProvider.when(
        data: (data) {
          final int occupancy = data.data.last.$2;
          final DateTime lastUpdated = data.data.last.$1;
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 10,
            ),
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.width * 0.7,
                    child: CustomPaint(
                      painter: CustomProgressIndicator(
                          progress: (occupancy).toDouble() / 100,
                          startAngle: -30,
                          progressColor: progressColor,
                          emptyColor: emptyColor),
                      child: Center(
                        child: Text(
                          "$occupancy%",
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: textColor),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        loading: () {
          return const Placeholder();
        },
        error: (err, stack) {
          return const Placeholder();
        },
      ),
    );
  }
}
