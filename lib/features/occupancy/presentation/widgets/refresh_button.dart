import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/last_updated_entity.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/occupancy_entity.dart';

class RefreshButton extends ConsumerStatefulWidget {
  const RefreshButton({
    super.key,
    required this.dataName,
    this.delay,
    this.color,
    this.lastFetched,
  });
  final Duration? delay;
  final Color? color;
  final String dataName;
  final DateTime? lastFetched;

  @override
  ConsumerState<RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends ConsumerState<RefreshButton> {
  Timer? timer;
  bool isEnabled = false;

  void refreshData() {
    String from = widget.lastFetched!.toIso8601String();
    ref.read(lastUpdatedProvider)[widget.dataName] = DateTime.now();
    ref.read(occupancyEntityProvider(widget.dataName).notifier).refreshData(from);
    setState(() {
      isEnabled = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void sendSnackBar(BuildContext context, int seconds) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text("Please wait $seconds second(s) before refreshing"),
          duration: const Duration(milliseconds: 800),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    // Cancel previous timer!
    timer?.cancel();
    final lastUpdated = ref.read(lastUpdatedProvider)[widget.dataName];
    final delay = widget.delay ?? const Duration(minutes: 1);
    int seconds = 0;
    VoidCallback? onPressed;

    if (lastUpdated == null) {
      if (widget.lastFetched != null) {
        onPressed = refreshData;
        isEnabled = true;
      }
    } else {
      Duration diff = DateTime.now().difference(lastUpdated);
      if (diff > delay) {
        isEnabled = true;
        onPressed = refreshData;
      } else {
        seconds = delay.inSeconds - diff.inSeconds;
        onPressed = () => sendSnackBar(context, seconds);
        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          seconds--;
          if (seconds <= 0) {
            timer.cancel();
            setState(() {
              isEnabled = true;
            });
          }
        });
      }
    }

    return IconButton(
        icon: Icon(
          Icons.refresh,
          color: isEnabled ? widget.color : widget.color!.withAlpha(128),
        ),
        onPressed: onPressed);
  }
}
