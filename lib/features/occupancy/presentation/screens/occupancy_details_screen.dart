import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:occupancy_frontend/core/widgets/custom_progress_indicator.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/occupancy_entity.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/widgets/occupancy_card.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/widgets/occupancy_graph.dart';

class OccupancyDetailsScreen extends StatelessWidget {
  const OccupancyDetailsScreen({
    super.key,
    required this.displayName,
    required this.dataName,
    required this.mainColor,
    required this.textColor,
    required this.progressColor,
    required this.emptyColor,
  });
  final String displayName;
  final String dataName;
  final Color? mainColor;
  final Color textColor;
  final Color? progressColor;
  final Color? emptyColor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          displayName,
          style: Theme.of(context).textTheme.headlineMedium!,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OccupancyCard(
              displayName: displayName,
              dataName: dataName,
              width: size.width * 0.7,
              progressHeight: size.width * 0.7,
              disableTap: true,
              cardColor: mainColor,
              progressColor: progressColor,
              emptyColor: emptyColor,
            ),
            OccupancyGraph(
              color: mainColor,
              dataName: dataName,
              width: size.width * 0.8,
              height: size.width * 0.6,
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            label: "Today",
            icon: const Icon(Icons.today),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month),
            label: "Schedule",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.data_exploration),
            label: "Other days",
          ),
        ],
      ),
    );
  }
}
