import 'dart:async';

import 'package:flutter/material.dart';
import 'package:occupancy_frontend/core/functions/uk_datetime.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget(
      {super.key, required this.dateTime, required this.textColor});

  final DateTime dateTime;
  final Color textColor;

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? secondsTimer;
  Timer? minuteTimer;

  String text = "";
  int seconds = 0;
  int minutes = 0;
  int hours = 0;

  void startSecondsTimer() {
    secondsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        seconds += 1;
      });
      if (seconds == 60) {
        seconds = 0;
        minutes += 1;
        if (minutes == 60) {
          hours += 1;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final now = ukDateTimeNow();
    final difference = now.difference(ukDateTimeParse(widget.dateTime));
    hours = difference.inHours;
    minutes = difference.inMinutes % 60;
    seconds = difference.inSeconds % 60;
    if (seconds < 0) {
      minutes -= 1;
      seconds += 60;
    }
    startSecondsTimer();
  }

  @override
  void dispose() {
    super.dispose();
    secondsTimer?.cancel();
    minuteTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: widget.textColor.withAlpha(128),
      fontSize: 14,
    );

    if (hours == 0) {
      if (minutes == 0) {
        return Text("$seconds second${seconds == 1 ? "" : "s"} ago",
            style: textStyle);
      }
      return Text(
          "$minutes minute${minutes == 1 ? "" : "s"} and $seconds second${seconds == 1 ? "" : "s"} ago",
          style: textStyle);
    }
    return Text(
        "$hours hour${hours == 1 ? "" : "s"} and $minutes minute${minutes == 1 ? "" : "s"} ago",
        style: textStyle);
  }
}
