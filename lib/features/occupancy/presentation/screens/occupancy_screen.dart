import 'package:flutter/material.dart';
import 'package:occupancy_frontend/constants.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/widgets/current_time.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/widgets/occupancy_card.dart';
import 'package:occupancy_frontend/features/occupancy/presentation/widgets/occupancy_card_wip.dart';

class OccupancyScreen extends StatelessWidget {
  const OccupancyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("MyOccupancy"),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const CurrentTime(),
                OccupancyCard(
                  width: constraints.maxWidth * 0.7,
                  progressHeight: constraints.maxHeight * 0.3,
                  cardColor: const Color(ConstantColors.prussianBlue),
                  displayName: "The Gym",
                  dataName: "gym",
                ),
                OccupancyCardWIP(
                  width: constraints.maxWidth * 0.7,
                  progressHeight: constraints.maxHeight * 0.3,
                  cardColor: const Color(ConstantColors.burgundy),
                  displayName: "The Labs",
                )
                // OccupancyCard(
                //   width: constraints.maxWidth * 0.7,
                //   progressHeight: constraints.maxHeight * 0.3,
                //   cardColor: const Color(ConstantColors.burgundy),
                //   progressColor: const Color(0XFFFFD6BA),
                //   emptyColor: Colors.grey[500]!,
                //   displayName: "Main Library",
                //   dataName: "main_library",
                // ),
              ],
            ),
          );
        },
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.fitness_center_rounded),
      //       label: "Gym",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.book),
      //       label: "Main Library",
      //     ),
      //   ],
      //   currentIndex: 0,
      //   selectedItemColor: const Color(ConstantColors.burgundy),
      //   onTap: null,
      // ),
    );
  }
}
