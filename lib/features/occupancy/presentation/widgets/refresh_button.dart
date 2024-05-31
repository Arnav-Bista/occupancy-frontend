import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/occupancy_entity.dart';

class RefreshButton extends ConsumerStatefulWidget {
  const RefreshButton(
      {super.key,
      this.delay,
      this.color,
      required this.dataName,
      this.lastUpdated});
  final Duration? delay;
  final Color? color;
  final String dataName;
  final DateTime? lastUpdated;

  @override
  ConsumerState<RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends ConsumerState<RefreshButton> {
  Timer? timer;
  bool isEnabled = false;

  void refreshData() {
    String from = widget.lastUpdated!.toIso8601String();
    ref
        .read(occupancyEntityProvider(widget.dataName).notifier)
        .refreshData(from);
    setState(() {
      isEnabled = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cancel previous timer!
    timer?.cancel();
    final duration = widget.delay ?? const Duration(minutes: 1);
    int seconds = 0;
    if (widget.lastUpdated != null) {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        seconds += 1;
        if (seconds == duration.inSeconds) {
          setState(() {
            isEnabled = true;
          });
          timer.cancel();
        }
      });
    }

    return IconButton(
      icon: Icon(
        Icons.refresh,
        color: isEnabled ? widget.color : widget.color!.withAlpha(128),
      ),
      onPressed: isEnabled
          ? refreshData
          : () {
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(SnackBar(
                    content: Text(
                        "Please wait ${duration.inSeconds - seconds} second(s) before refreshing"),
                    duration: const Duration(milliseconds: 800)));
            },
      // onPressed: lastUpdated == null ? null : refreshData,
    );
  }
}
