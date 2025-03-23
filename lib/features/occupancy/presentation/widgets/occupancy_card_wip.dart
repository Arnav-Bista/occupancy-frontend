import 'package:flutter/material.dart';
import 'package:occupancy_frontend/constants.dart';

class OccupancyCardWIP extends StatelessWidget {
  const OccupancyCardWIP({
    super.key,
    required this.displayName,
    required this.width,
    required this.progressHeight,
    this.cardColor,
    this.textColor,
  });

  final String displayName;
  final double width;
  final double progressHeight;
  final Color? cardColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(30);
    final Color actualTextColor = textColor ?? 
      (cardColor != null && cardColor!.computeLuminance() < 0.5
        ? const Color(ConstantColors.lavenderBush)
        : const Color(ConstantColors.black));

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: progressHeight * 0.7,
                height: progressHeight * 0.7,
                child: Icon(
                  Icons.construction,
                  size: progressHeight * 0.5,
                  color: actualTextColor,
                ),
              ),
              // const SizedBox(height: 10), 
              Text(
                displayName,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: actualTextColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5), 
              Text(
                "Coming Soon",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: actualTextColor),
              ),
              const SizedBox(height: 5),
              Text(
                "Stay tuned for updates!",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: actualTextColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

