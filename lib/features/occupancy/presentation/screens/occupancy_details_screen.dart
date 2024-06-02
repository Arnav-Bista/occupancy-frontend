import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/widgets/occupancy_card.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/widgets/occupancy_graph.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/widgets/schedule.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/widgets/today_details.dart';

class OccupancyDetailsScreen extends StatefulWidget {
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
  State<OccupancyDetailsScreen> createState() => _OccupancyDetailsScreenState();
}

class _OccupancyDetailsScreenState extends State<OccupancyDetailsScreen> {
  int _selectedIndex = 0;

  void _onTapIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final List<Widget> widgetOptions = [
      Center(child: TodayDetails(widget: widget, size: size)),
      Schedule(
        dataName: widget.dataName,
        color: widget.mainColor,
        textColor: widget.textColor,
      ),
      Placeholder(),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.displayName,
          style: Theme.of(context).textTheme.headlineMedium!,
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTapIndex,
        currentIndex: _selectedIndex,
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
