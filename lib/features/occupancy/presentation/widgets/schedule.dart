import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:occupancy_frontend/core/functions/text_size.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/occupancy_entity.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/timing_entity.dart';

class Schedule extends ConsumerWidget {
  const Schedule({super.key, required this.dataName, this.color, this.textColor});

  final String dataName;
  final Color? color;
  final Color? textColor;

  String getDayName(int day) {
    switch (day) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
      default:
        return "How did this happen?";
    }
  }

  String getTimingString(int? time) {
    if (time == null) {
      return "-";
    }
    int hour = time ~/ 100;
    int minute = time % 100;
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occupancyProvider = ref.watch(occupancyEntityProvider(dataName));

    late Widget childWidget;
    occupancyProvider.when(
      loading: () {
        childWidget = const Expanded(
          child: Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        childWidget = Expanded(
          child: Center(
            child: Text("Error: ${error.toString()}"),
          ),
        );
      },
      data: (data) {
        final List<Widget> entries = [];
        for (int i = 0; i < data.scheduleEntity.timings.length; i++) {
          final Timing timing = data.scheduleEntity.timings[i];
          entries.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getDayName(i + 1),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Text(
                          "${getTimingString(timing.opening)} - ${getTimingString(timing.closing)}",
                          style:
                              TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                    Card(
                    elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        child: Text(
                          timing.isOpen ? "Open" : "Closed",
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ));
        }

        childWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: entries
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: childWidget,
        ),
      ),
    );
  }
}
