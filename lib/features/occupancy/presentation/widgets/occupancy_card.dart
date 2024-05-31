import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:occupancy_frontend/constants.dart';
import 'package:occupancy_frontend/core/entities/status.dart';
import 'package:occupancy_frontend/core/functions/text_size.dart';
import 'package:occupancy_frontend/core/functions/uk_datetime.dart';
import 'package:occupancy_frontend/core/widgets/custom_progress_indicator.dart';
import 'package:occupancy_frontend/core/widgets/custom_shimmer.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/occupancy_entity.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/screens/occupancy_details_screen.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/widgets/occupancy_card_schedule.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/widgets/refresh_button.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/widgets/timer.dart';

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

  final Duration refreshDelay = const Duration(seconds: 2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderRadius = BorderRadius.circular(30);
    final weekday = ukDateTimeNow().weekday - 1;
    final occupancyProvider = ref.watch(occupancyEntityProvider(dataName));
    Color textColor;

    if (cardColor != null && cardColor!.computeLuminance() < 0.5) {
      textColor = const Color(ConstantColors.lavenderBush);
    } else {
      textColor = const Color(ConstantColors.black);
    }

    OccupancyEntity? occupancyData;
    int? occupancy;
    DateTime? lastUpdated;
    int errorCode = 0;
    Size textSize = getTextSize(
        "XX minutes and XX seconds ago", const TextStyle(fontSize: 14));
    Size occupancyNumberTextSize =
        getTextSize("100%", Theme.of(context).textTheme.headlineLarge!);
    Status status = Status.loading;

    occupancyProvider.when(
      data: (data) {
        occupancyData = data;
        occupancy = data.data.last.$2;
        lastUpdated = data.data.last.$1;
        status = Status.success;
      },
      loading: () {
        status = Status.loading;
      },
      error: (err, stack) {
        errorCode = err as int;
        status = Status.error;
      },
    );
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Card(
          color: cardColor,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: status == Status.success
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return OccupancyDetailsScreen(
                              displayName: displayName,
                              dataName: dataName,
                              mainColor: cardColor,
                              textColor: textColor,
                              progressColor: progressColor,
                              emptyColor: emptyColor,
                            );
                          },
                        ),
                      );
                    }
                  : null,
              borderRadius: borderRadius,
              child: SizedBox(
                width: width,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: progressHeight * 0.7,
                        height: progressHeight * 0.7,
                        child: CustomPaint(
                          painter: CustomProgressIndicator(
                            progress: (occupancy ?? 0) / 100,
                            startAngle: -30,
                            progressColor: progressColor,
                            emptyColor: emptyColor,
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: switch (status) {
                                Status.success => Text(
                                    "${occupancy!}%",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge!
                                        .copyWith(color: textColor),
                                  ),
                                Status.loading => CustomShimmer(
                                    height: occupancyNumberTextSize.height,
                                    width: occupancyNumberTextSize.width,
                                  ),
                                Status.error => Text(
                                    "?",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge!
                                        .copyWith(color: textColor),
                                  ),
                              },
                            ),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -10),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: switch (status) {
                            Status.success => TimerWidget(
                                dateTime: lastUpdated!,
                                textColor: textColor,
                              ),
                            Status.loading => Padding(
                              // Size didnt match...
                              padding: const EdgeInsets.all(1.3),
                              child: CustomShimmer(
                                  height: textSize.height,
                                  width: textSize.width,
                                ),
                            ),
                            Status.error => Text(
                                "Error: $errorCode",
                                style: TextStyle(fontSize: 14, color: textColor),
                              )
                          },
                        ),
                      ),
                      Text(
                        displayName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: textColor),
                      ),
                      OccupancyCardSchedule(
                        opening: occupancyData
                            ?.scheduleEntity.timings[weekday].opening,
                        closing: occupancyData
                            ?.scheduleEntity.timings[weekday].closing,
                        textColor: textColor,
                        width: width,
                        status: status,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10, top: 10),
          child: RefreshButton(
            lastUpdated: lastUpdated,
            dataName: dataName,
            delay: refreshDelay,
            color: textColor,
          ),
        )
      ],
    );
  }
}
