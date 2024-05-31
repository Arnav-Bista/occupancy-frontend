import 'dart:async';

import 'package:flutter/material.dart';
import 'package:occupancy_frontend/core/functions/uk_datetime.dart';

class CurrentTime extends StatelessWidget {
  const CurrentTime({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "It's Currently",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const CurrentTimeTimer(),
        Text(
          "In St Andrews",
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class CurrentTimeTimer extends StatefulWidget {
  const CurrentTimeTimer({super.key});

  @override
  State<CurrentTimeTimer> createState() => _CurrentTimeTimerState();
}

class _CurrentTimeTimerState extends State<CurrentTimeTimer> {
  Timer? secondsTimer;
  Timer? minuteTimer;

  int seconds = 0;
  int minutes = 0;
  int hours = 0;

  void startTimer() {
    secondsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds += 1;
      if (seconds == 60) {
        seconds = 0;
        if (minutes == 59) {
          setState(() {
            minutes = 0;
            hours = (hours + 1) % 24;
          });
        } else {
          setState(() {
            minutes += 1;
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final now = ukDateTimeNow();
    seconds = now.second;
    minutes = now.minute;
    hours = now.hour;
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final String minuteString = minutes < 10 ? "0$minutes" : "$minutes";
    return Text(
      "$hours:$minuteString",
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}
