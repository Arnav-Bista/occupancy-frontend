import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:occupancy_frontend/features/occupancy/data/data_sources/remote_source.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/schedule_entity.dart';

@immutable
class OccupancyEntity {
  const OccupancyEntity({required this.data, required this.scheduleEntity});

  final List<(DateTime, int)> data;
  final ScheduleEntity scheduleEntity;

  factory OccupancyEntity.fromJson(Map<String, dynamic> json) {
    final List<(DateTime, int)> data = [];
    final dataList = json['data'] as List;
    for (final item in dataList) {
      data.add((DateTime.parse(item[0] as String), item[1] as int));
    }
    final scheduleEntity = ScheduleEntity.fromJson(json);
    return OccupancyEntity(data: data, scheduleEntity: scheduleEntity);
  }

  DateTime? getLastDate() {
    if (data.isEmpty) {
      return null;
    }
    return data.last.$1;
  }

  OccupancyEntity copyWith(
      {List<(DateTime, int)>? data, ScheduleEntity? scheduleEntity}) {
    return OccupancyEntity(
        data: data ?? this.data,
        scheduleEntity: scheduleEntity ?? this.scheduleEntity);
  }

  OccupancyEntity extendData(OccupancyEntity other) {
    ScheduleEntity schedule = scheduleEntity;
    if (scheduleEntity != other.scheduleEntity) {
      schedule = other.scheduleEntity;
    }
    return OccupancyEntity(
        data: [...data, ...other.data], scheduleEntity: schedule);
  }

  @override
  operator ==(Object other) {
    if (other is OccupancyEntity) {
      bool dataEqual = true;
      if (data.length != other.data.length) {
        dataEqual = false;
      } else {
        for (int i = 0; i < data.length; i++) {
          if (data[i] != other.data[i]) {
            dataEqual = false;
            break;
          }
        }
      }
      return dataEqual && scheduleEntity == other.scheduleEntity;
    }
    return false;
  }

  @override
  int get hashCode {
    final int dataHash = data.fold<int>(
        0, (previousValue, element) => previousValue ^ element.hashCode);
    final int scheduleHash = scheduleEntity.hashCode;
    return dataHash ^ scheduleHash;
  }
}

class OccupancyEntitiyNotifier
    extends FamilyAsyncNotifier<OccupancyEntity, String> {
  late String _name;

  @override
  Future<OccupancyEntity> build(String arg) async {
    _name = arg;
    final data = await ref.read(remoteSourceProvider).getDayData(arg);
    return data.right;
  }

  Future<void> refreshData(String from) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(seconds: 1));
    final fetchedData =
        await ref.read(remoteSourceProvider).getFromData(_name, from);
    if (fetchedData is Left) {
      print(fetchedData.left);
      print("Error :(");
      state = AsyncValue.error(fetchedData.left, StackTrace.current);
      return;
    }
    // state = AsyncValue.error(500, StackTrace.current);
    // return;
    final data = fetchedData.right;
    // Protection: This function should only be called when we already have some data.
    // This function should never be called without already having a SUCCESSFUL GET.
    final occupancyEntity = state.value!;
    state = AsyncValue.data(occupancyEntity.extendData(data));
  }
}

final occupancyEntityProvider = AsyncNotifierProvider.family<
    OccupancyEntitiyNotifier,
    OccupancyEntity,
    String>(OccupancyEntitiyNotifier.new);
