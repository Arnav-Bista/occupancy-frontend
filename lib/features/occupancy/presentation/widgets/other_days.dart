import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:occupancy_frontend/core/functions/uk_datetime.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/occupancy_entity.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/widgets/occupancy_graph.dart';

class OtherDays extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            SizedBox(
              height: constraints.maxHeight * 0.3,
              child: MyDatePicker(dataName: dataName),
            ),
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

  DateTime maxDate = ukDateTimeNow().subtract(const Duration(days: 1));
  DateTime minDate = ukDateTimeNow().subtract(const Duration(days: 7 * 3));

  void updateProvider() {
    ref
        .read(otherDayOccupancyEntityProvider(widget.dataName).notifier)
        .getOtherDayData(showingDate);
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
                        showingDate =
                            showingDate.subtract(const Duration(days: 1));
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
