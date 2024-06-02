import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:occupancy_frontend/core/functions/uk_datetime.dart';
import 'package:occupancy_frontend/core/widgets/custom_shimmer.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/occupancy_entity.dart';

class OccupancyGraph extends ConsumerWidget {
  const OccupancyGraph({
    super.key,
    required this.width,
    required this.height,
    required this.dataName,
    this.color,
  });

  final double width;
  final double height;
  final String dataName;
  final Color? color;

  Widget getLineGraph(BuildContext context, OccupancyEntity data) {
    final weekDay = DateTime.now().weekday - 1;
    final relevantTimings = data.scheduleEntity.timings[weekDay];
    if (!relevantTimings.isOpen) {
      return Center(
        child: Text(
          "Closed",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      );
    }
    final today = ukDateTimeNow();
    final startHour = relevantTimings.opening! ~/ 100;
    final startMinute = relevantTimings.opening! % 100;
    final startEpochs = DateTime(
      today.year,
      today.month,
      today.day,
      relevantTimings.opening! ~/ 100,
      relevantTimings.opening! % 100,
    ).millisecondsSinceEpoch;
    final endEpochs = DateTime(
      today.year,
      today.month,
      today.day,
      relevantTimings.closing! ~/ 100,
      relevantTimings.closing! % 100,
    ).millisecondsSinceEpoch;
    return LineChart(
      LineChartData(
        minX: startEpochs.toDouble(),
        maxX: endEpochs.toDouble(),
        minY: 0,
        maxY: 100,
        titlesData: FlTitlesData(
          topTitles: AxisTitles(
            axisNameWidget: Text(
              "Occupancy% vs Time",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            sideTitles: const SideTitles(
              showTitles: false,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Container();
                }),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (120 + 30) * 60 * 1000,
              getTitlesWidget: (value, meta) {
                if (value == meta.min || value == meta.max) {
                  return Container();
                }
                // 0 Should be the opening time. Add the opening time
                // This is in minutes
                final timeDiff = (value - startEpochs) ~/ 60000 +
                    startHour * 60 +
                    startMinute;
                final hour = timeDiff ~/ 60;
                final minute = timeDiff % 60;
                final String time =
                    "$hour:${minute < 10 ? "0$minute" : minute}";
                return SideTitleWidget(
                  // angle: pi / 6,
                  axisSide: AxisSide.bottom,
                  child: Text(
                    time,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
              spots: data.data.map((e) {
                final time = e.$1.millisecondsSinceEpoch;
                return FlSpot(time.toDouble(), e.$2.toDouble());
              }).toList(),
              isCurved: false,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              color: color),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occupancyProvider = ref.watch(occupancyEntityProvider(dataName));
    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: occupancyProvider.when(
            data: (data) => getLineGraph(context, data),
            loading: () {
              return CustomShimmer(
                width: width,
                height: height,
              );
            },
            error: (err, stack) {
              return const Center(
                child: Icon(Icons.error),
              );
            },
          ),
        ),
      ),
    );
  }
}