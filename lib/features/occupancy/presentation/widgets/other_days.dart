import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:occupancy_frontend/core/functions/uk_datetime.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/occupancy_entity.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/widgets/occupancy_graph.dart';

class OtherDays extends StatelessWidget {
  const OtherDays({super.key, required this.dataName});
  final String dataName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            SizedBox(
                height: constraints.maxHeight * 0.3,
                child: MyDatePicker(dataName: dataName)),
            SizedBox(
              child: OccupancyGraph(
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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Showing Data for:"),
        Text(
          widget.formatter.format(showingDate),
          style: Theme.of(context).textTheme.headlineSmall,
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
                ref
                    .read(
                      otherDayOccupancyEntityProvider(
                        widget.dataName,
                      ).notifier,
                    )
                    .getOtherDayData(value);
                setState(() {
                  showingDate = value;
                });
              }
            });
          },
          child: const Text("Change Date"),
        )
      ],
    );
  }
}
