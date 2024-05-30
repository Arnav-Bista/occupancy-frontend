import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:occupancy_frontend/constants.dart';
import 'package:occupancy_frontend/core/functions/uk_datetime.dart';
import 'package:occupancy_frontend/core/widgets/custom_progress_indicator.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/occupancy_entity.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/widgets/occupancy_card_schedule.dart';

class OccupancyCard extends ConsumerWidget {
  const OccupancyCard(
      {super.key,
      required this.displayName,
      required this.dataName,
      required this.width,
      required this.progressHeight,
      this.cardColor,
      this.progressColor,
      this.emptyColor});

  final String displayName;
  final String dataName;

  final Color? cardColor;
  final double width;
  final double progressHeight;
  final Color? progressColor;
  final Color? emptyColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekday = ukDateTimeNow().weekday - 1;
    final occupancyProvider = ref.watch(occupancyEntityProvider(dataName));
    Color textColor;
    if (cardColor != null && cardColor!.computeLuminance() < 0.5) {
      textColor = const Color(ConstantColors.lavenderBush);
    } else {
      textColor = const Color(ConstantColors.black);
    }

    return occupancyProvider.when(
      data: (data) {
        final int occupancy = data.data.last.$2;
        return Card(
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: SizedBox(
            width: width,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: progressHeight * 0.7,
                    height: progressHeight * 0.7,
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
                  ),
                  Text(
                    displayName,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                  ),
                  OccupancyCardSchedule(
                    opening: data.scheduleEntity.timings[weekday].opening, 
                    closing: data.scheduleEntity.timings[weekday].closing,
                    textColor: textColor, 
                    width: width
                  )
                ],
              ),
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
    );

    // return Card(
    //   color: cardColor,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(30),
    //   ),
    //   child: SizedBox(
    //     width: width,
    //     child: Padding(
    //       padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 8),
    //       child: Column(
    //         mainAxisSize: MainAxisSize.max,
    //         children: [
    //           SizedBox(
    //             width: progressHeight * 0.7,
    //             height: progressHeight * 0.7,
    //             child: CustomPaint(
    //               painter: CustomProgressIndicator(
    //                   progress: (occupancy ?? 0).toDouble() / 100,
    //                   startAngle: -30,
    //                   progressColor: progressColor,
    //                   emptyColor: emptyColor),
    //               child: Center(
    //                 child: Text(
    //                   "$occupancy%",
    //                   style: TextStyle(
    //                       fontSize: 40,
    //                       fontWeight: FontWeight.bold,
    //                       color: textColor),
    //                 ),
    //               ),
    //             ),
    //           ),
    //           Text(
    //             name ?? "",
    //             style: TextStyle(
    //                 fontSize: 20,
    //                 fontWeight: FontWeight.bold,
    //                 color: textColor),
    //           ),
    //           OccupancyCardSchedule(textColor: textColor, width: width)
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
