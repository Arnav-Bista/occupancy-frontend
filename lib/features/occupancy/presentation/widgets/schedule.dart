import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:occupancy_frontend/core/functions/text_size.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/occupancy_entity.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/timing_entity.dart';

class Schedule extends ConsumerWidget {
  const Schedule(
      {super.key, required this.dataName, this.color, this.textColor});

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
    return "$hour:${minute >= 10 ? minute : "0$minute"}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occupancyProvider = ref.watch(occupancyEntityProvider(dataName));
    final textStyle =
        Theme.of(context).textTheme.bodyMedium!.copyWith(color: textColor);

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
            child: Text("Error: $error"),
          ),
        );
      },
      data: (data) {
        int weekDay = 0;
        List<Widget> days = [];
        List<Widget> opening = [];
        List<Widget> closing = [];

        days.add(Text(
          "Day",
          style: textStyle.copyWith(fontWeight: FontWeight.bold),
        ));
        opening.add(Text(
          "Opening",
          style: textStyle.copyWith(fontWeight: FontWeight.bold),
        ));
        closing.add(Text(
          "Closing",
          style: textStyle.copyWith(fontWeight: FontWeight.bold),
        ));

        for (Timing timing in data.scheduleEntity.timings) {
          days.add(Text(
            getDayName(++weekDay),
            style: textStyle,
          ));
          opening.add(Text(
            getTimingString(timing.opening),
            style: textStyle,
          ));
          closing.add(Text(
            getTimingString(timing.closing),
            style: textStyle,
          ));
        }

        childWidget = SizedBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              // vertical: 10,
              horizontal: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: days,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: opening,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: closing,
                ),
              ],
            ),
          ),
        );
      },
    );

    return Center(
      child: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight * 0.7,
          width: constraints.maxWidth * 0.8,
          child: Card(
            color: color,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: childWidget,
            ),
          ),
        );
      }),
    );
  }
}
