import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:occupancy_frontend/core/functions/text_size.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/occupancy_entity.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/timing_entity.dart';

class Schedule extends ConsumerWidget {
  const Schedule({super.key, required this.dataName});

  final String dataName;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occupancyProvider = ref.watch(occupancyEntityProvider(dataName));
    final textSize = getTextSize("X", Theme.of(context).textTheme.bodyMedium!);

    late Widget childWidget;
    occupancyProvider.when(
      loading: () {
        childWidget = const Expanded(
          child: Center(
            child: CircularProgressIndicator(),
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

        days.add(SizedBox(height: textSize.height));
        opening.add(SizedBox(height: textSize.height));
        closing.add(SizedBox(height: textSize.height));

        days.add(Text(
          "Day",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ));
        opening.add(Text(
          "Opening",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ));
        closing.add(Text(
          "Closing",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ));

        for (Timing timing in data.scheduleEntity.timings) {
          days.add(Text(
            getDayName(++weekDay),
            style: Theme.of(context).textTheme.bodyMedium,
          ));
          opening.add(Text(
            (timing.opening ?? 0).toString(),
            style: Theme.of(context).textTheme.bodyMedium,
          ));
          closing.add(Text(
            (timing.closing ?? 0).toString(),
            style: Theme.of(context).textTheme.bodyMedium,
          ));
        }

        days.add(SizedBox(height: textSize.height));
        opening.add(SizedBox(height: textSize.height));
        closing.add(SizedBox(height: textSize.height));

        childWidget = Row(
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
        );
        // childWidget.add(Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     children: [
        //       Text(
        //         "Day",
        //         style: Theme.of(context).textTheme.bodyMedium,
        //       ),
        //       Text(
        //         "Opening",
        //         style: Theme.of(context).textTheme.bodyMedium,
        //       ),
        //       Text(
        //         "Closing",
        //         style: Theme.of(context).textTheme.bodyMedium,
        //       ),
        //     ],
        //   ),
        // ));
        // childWidget.addAll(data.scheduleEntity.timings.map((timing) {
        //   return Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //       children: [
        //         Text(
        //           getDayName(++weekDay),
        //           style: Theme.of(context).textTheme.bodyMedium,
        //         ),
        //         Text(
        //           (timing.opening ?? 0).toString(),
        //           style: Theme.of(context).textTheme.bodyMedium,
        //         ),
        //         Text(
        //           (timing.closing ?? 0).toString(),
        //           style: Theme.of(context).textTheme.bodyMedium,
        //         ),
        //       ],
        //     ),
        //   );
        // }));
        // childWidget.add(Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Container(height: textSize.height),
        // ));
      },
    );

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: childWidget),
        ],
      ),
    );
  }
}
