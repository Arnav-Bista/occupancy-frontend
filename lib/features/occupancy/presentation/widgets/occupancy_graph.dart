import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:occupancy_frontend/core/functions/uk_datetime.dart';
import 'package:occupancy_frontend/core/widgets/custom_shimmer.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/models.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/occupancy_entity.dart';

class OccupancyGraph extends ConsumerWidget {
  const OccupancyGraph({
    super.key,
    required this.width,
    required this.height,
    required this.dataName,
    this.isOther = false,
    this.color,
  });

  final double width;
  final double height;
  final Color? color;
  final String dataName;
  final bool isOther;

  Widget getLineGraph(BuildContext context, OccupancyEntity data, Models models, [DateTime? providedDate]) {
    late DateTime date;
    if (providedDate == null) {
      date = ukDateTimeNow();
    } else {
      date = providedDate;
    }
    final weekDay = date.weekday - 1;
    final relevantTimings = data.scheduleEntity.timings[weekDay];
    if (!relevantTimings.isOpen) {
      return Center(
        child: Text(
          "Closed",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      );
    }
    final startEpochs = DateTime(
      date.year,
      date.month,
      date.day,
      relevantTimings.opening! ~/ 100,
      relevantTimings.opening! % 100,
    ).millisecondsSinceEpoch;
    final endEpochs = DateTime(
      date.year,
      date.month,
      date.day,
      relevantTimings.closing! ~/ 100,
      relevantTimings.closing! % 100,
    ).millisecondsSinceEpoch;
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Theme.of(context).cardColor,
            tooltipBorder: BorderSide(
              color: Colors.black,
              width: 1,
            ),
            getTooltipItems: (barData) => barData.map((barData) {
              return LineTooltipItem(
                "${barData.y.toInt()}%",
                TextStyle(
                  color: barData.bar.color,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
          ),
          enabled: true,
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes.map((spotIndex) {
              return TouchedSpotIndicatorData(
                FlLine(
                  color: Colors.black,
                  strokeWidth: 1,
                ),
                FlDotData(
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: barData.color ?? Colors.black,
                      strokeWidth: 1,
                      strokeColor: Colors.black,
                    );
                  },
                ),
              );
            }).toList();
          },
        ),
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
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
            showTitles: true,
              maxIncluded: false,
              minIncluded: false,
            getTitlesWidget: (value, meta) {
              final time = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              final hour = time.hour;
              final minute = time.minute;
              return Text(
                "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}",
                style: Theme.of(context).textTheme.bodySmall,
              );
            },
          )),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Container();
                }),
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
            color: color,
          ),
          if (models == Models.both || models == Models.knn)
            LineChartBarData(
              spots: data.knnPrediction.map((e) {
                final time = e.$1.millisecondsSinceEpoch;
                return FlSpot(time.toDouble(), e.$2.toDouble());
              }).toList(),
              dashArray: [2, 3],
              isCurved: true,
              barWidth: 1.25,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              color: Colors.blue,
            ),
          if (models == Models.both || models == Models.gb)
            LineChartBarData(
              spots: data.gbPrediction.where((e) {
                return e.$1.millisecondsSinceEpoch >= startEpochs && e.$1.millisecondsSinceEpoch <= endEpochs;
              }).map((e) {
                final time = e.$1.millisecondsSinceEpoch;
                return FlSpot(time.toDouble(), e.$2.toDouble());
              }).toList(),
              dashArray: [2, 3],
              isCurved: true,
              barWidth: 1.25,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              color: Colors.purple,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late AsyncValue<OccupancyEntity> occupancyProvider;
    if (isOther) {
      occupancyProvider = ref.watch(otherDayOccupancyEntityProvider(dataName));
    } else {
      occupancyProvider = ref.watch(occupancyEntityProvider(dataName));
    }
    final model = ref.watch(modelsProvider);
    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: occupancyProvider.when(
            data: (data) {
              if (isOther) {
                return getLineGraph(
                  context,
                  data,
                  model,
                  ref.read(otherDayOccupancyEntityProvider(dataName).notifier).getCurrentDate(),
                );
              }
              return getLineGraph(context, data, model);
            },
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
