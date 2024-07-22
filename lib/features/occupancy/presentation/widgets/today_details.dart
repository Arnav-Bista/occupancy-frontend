import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/occupancy_entity.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/screens/occupancy_details_screen.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/widgets/model_selector.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/widgets/occupancy_card.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/widgets/occupancy_graph.dart';

class TodayDetails extends ConsumerWidget {
  const TodayDetails({
    super.key,
    required this.widget,
    required this.size,
  });

  final OccupancyDetailsScreen widget;
  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OccupancyCard(
          displayName: widget.displayName,
          dataName: widget.dataName,
          width: size.width * 0.7,
          progressHeight: size.width * 0.7,
          disableTap: true,
          cardColor: widget.mainColor,
          progressColor: widget.progressColor,
          emptyColor: widget.emptyColor,
        ),
        ModelSelector(),
        OccupancyGraph(
          dataName: widget.dataName,
          color: widget.mainColor,
          width: size.width * 0.8,
          height: size.width * 0.6,
        )
      ],
    );
  }
}
