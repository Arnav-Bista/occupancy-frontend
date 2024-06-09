import 'package:flutter/material.dart';
import 'package:occupancy_frontend/core/entities/status.dart';
import 'package:occupancy_frontend/core/functions/text_size.dart';
import 'package:occupancy_frontend/core/widgets/custom_shimmer.dart';

class OccupancyCardSchedule extends StatelessWidget {
  const OccupancyCardSchedule({
    super.key,
    required this.textColor,
    required this.width,
    required this.opening,
    required this.closing,
    required this.status,
  });

  final Color textColor;
  final double width;
  final int? opening;
  final int? closing;
  final Status status;

  String convertToTime(int? time) {
    if (status != Status.success) {
      return "...";
    }
    if (time == null) {
      return "Closed";
    }
    final hour = time ~/ 100;
    final minute = time % 100;
    return "$hour:${minute < 10 ? "0$minute" : minute}";
  }

  @override
  Widget build(BuildContext context) {
    final Size textSize =
        getTextSize("XX:XX", Theme.of(context).textTheme.bodyMedium!);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text(
              "Opens",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: textColor,
                  ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: status == Status.loading
                  ? CustomShimmer(
                      height: textSize.height,
                      width: textSize.width,
                    )
                  : Text(
                      convertToTime(opening),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: textColor,
                          ),
                    ),
            ),
          ],
        ),
        SizedBox(
          width: width * 0.2,
          child: Divider(
            color: textColor,
            thickness: 2,
          ),
        ),
        Column(
          children: [
            Text(
              "Closes",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: textColor,
                  ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: status == Status.loading
                  ? CustomShimmer(
                      height: textSize.height,
                      width: textSize.width,
                    )
                  : Text(
                      convertToTime(closing),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: textColor,
                          ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
