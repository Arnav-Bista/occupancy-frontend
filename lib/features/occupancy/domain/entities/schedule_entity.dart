import 'package:flutter/material.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/timing_entity.dart';

@immutable
class ScheduleEntity {
  const ScheduleEntity({required this.timings});

  factory ScheduleEntity.fromJson(Map<String, dynamic> json) {
    final timings = json['schedule']['timings'] as List;
    final List<Timing> data = timings.map((timing) => Timing.fromJson(timing)).toList();
    return ScheduleEntity(timings: data);
  }

  factory ScheduleEntity.empty() {
    return const ScheduleEntity(timings: []);
  }

  final List<Timing> timings;

  @override
  operator ==(Object other) {
    if (other is ScheduleEntity) {
      bool dataEqual = true;
      if (timings.length != other.timings.length) {
        dataEqual = false;
      } else {
        for (int i = 0; i < timings.length; i++) {
          if (timings[i] != other.timings[i]) {
            dataEqual = false;
            break;
          }
        }
      }
      return dataEqual;
    }
    return false;
  }

  @override
  int get hashCode {
    return timings.fold<int>(0, (previousValue, element) => previousValue ^ element.hashCode);
  }
}
