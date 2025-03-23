import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:occupancy_frontend/core/functions/uk_datetime.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/occupancy_entity.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/widgets/occupancy_graph.dart';

class OtherDays extends ConsumerWidget {
  const OtherDays({
    super.key,
    required this.dataName,
    this.mainColor,
    this.textColor,
  });

  final String dataName;
  final Color? mainColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occupancyData = ref.watch(otherDayOccupancyEntityProvider(dataName));

    int counter = 0;
    final totalGb = occupancyData.whenData((value) {
      final gb = value.gbPrediction.where((e) {
        if (e.$1.hour >= 8 && e.$1.hour <= 21) {
          counter++;
          return true;
        } else {
          return false;
        }
      }).fold<double>(0.0, (previousValue, element) => previousValue + element.$2);
      return gb;
    });

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            SizedBox(
              height: constraints.maxHeight * 0.22,
              child: MyDatePicker(dataName: dataName),
            ),
            SizedBox(
              height: constraints.maxHeight * 0.15,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOccupancyCard(
                      context,
                      "Peak Occupancy",
                      occupancyData.whenData(
                          (value) => value.gbPrediction.map((e) => e.$2).reduce((a, b) => a > b ? a : b).toDouble())),
                  _buildOccupancyCard(
                      context, "Average Occupancy", totalGb.whenData((value) => counter > 0 ? value / counter : 0.0)),
                ],
              ),
            ),
            SizedBox(height: 40),
            SizedBox(
              child: OccupancyGraph(
                color: mainColor,
                isOther: true,
                dataName: dataName,
                width: constraints.maxWidth * 0.8,
                height: constraints.maxHeight * 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupancyCard(BuildContext context, String title, AsyncValue<double> occupancyValue) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            occupancyValue.when(
              data: (value) => Text("${value.toStringAsFixed(1)}%", style: Theme.of(context).textTheme.headlineMedium),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyDatePicker extends ConsumerStatefulWidget {
  MyDatePicker({super.key, required this.dataName});

  final String dataName;
  final DateFormat formatter = DateFormat("dd MMMM yyyy");
  final DateFormat dataFormatter = DateFormat("yyyy-MM-dd");

  @override
  ConsumerState<MyDatePicker> createState() => _MyDatePickerState();
}

class _MyDatePickerState extends ConsumerState<MyDatePicker> {
  DateTime ukNow = ukDateTimeNow();
  DateTime showingDate = ukDateTimeNow().subtract(const Duration(days: 1));

  DateTime maxDate = ukDateTimeNow().add(const Duration(days: 7));
  DateTime minDate = ukDateTimeNow().subtract(const Duration(days: 7 * 3));

  void updateProvider() {
    ref.read(otherDayOccupancyEntityProvider(widget.dataName).notifier).getOtherDayData(showingDate);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_left_rounded,
                size: 50,
              ),
              onPressed: showingDate.compareTo(minDate) >= 0
                  ? () {
                      setState(() {
                        showingDate = showingDate.subtract(const Duration(days: 1));
                      });
                      updateProvider();
                    }
                  : null,
            ),
            Text(
              widget.formatter.format(showingDate),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            IconButton(
              icon: const Icon(
                Icons.arrow_right_rounded,
                size: 50,
              ),
              onPressed: showingDate.compareTo(maxDate) <= 0
                  ? () {
                      setState(() {
                        showingDate = showingDate.add(const Duration(days: 1));
                      });
                      updateProvider();
                    }
                  : null,
            )
          ],
        ),
        ElevatedButton(
          onPressed: () {
            showDatePicker(
              context: context,
              initialDate: showingDate,
              firstDate: ukNow.subtract(const Duration(days: 7 * 3)),
              lastDate: ukNow.subtract(const Duration(days: 1)),
            ).then((value) {
              if (value != null) {
                setState(() {
                  showingDate = value;
                  updateProvider();
                });
              }
            });
          },
          child: const Icon(Icons.edit_calendar),
        )
      ],
    );
  }
}
