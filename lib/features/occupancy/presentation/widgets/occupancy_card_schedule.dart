import 'package:flutter/material.dart';

class OccupancyCardSchedule extends StatelessWidget {
  const OccupancyCardSchedule(
      {super.key,
      required this.textColor,
      required this.width,
      required this.opening,
      required this.closing});

  final Color textColor;
  final double width;
  final int? opening;
  final int? closing;

  @override
  Widget build(BuildContext context) {
    // Should probably look into this
    // TODO: make it pretty >:(
    final openingString =
        "${(opening ?? 0) ~/ 100}:${((opening ?? 0) % 100) == 0 ? "00" : (opening ?? 0) % 100}";
    final closingString =
        "${(closing ?? 0) ~/ 100}:${((closing ?? 0) % 100) == 0 ? "00" : (closing ?? 0) % 100}";

    return opening == null
        ? Row(
            children: [
              Text("Closed", style: TextStyle(fontSize: 16, color: textColor)),
            ],
          )
        : Row(
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
                  Text(
                    openingString,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: textColor,
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
                  Text(
                    closingString,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: textColor,
                        ),
                  ),
                ],
              ),
            ],
          );
  }
}
