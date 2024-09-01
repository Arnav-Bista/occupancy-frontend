import 'dart:async';
import 'dart:collection';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:occupancy_frontend/core/functions/uk_datetime.dart';
import 'package:occupancy_frontend/features/occupancy/data/data_sources/remote_source.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/schedule_entity.dart';

@immutable
class OccupancyEntity {
  const OccupancyEntity({
    required this.data,
    required this.knnPrediction,
    required this.lstmPrediction,
    required this.scheduleEntity,
  });

  final List<(DateTime, int)> data;
  final List<(DateTime, int)> knnPrediction;
  final List<(DateTime, int)> lstmPrediction;
  final ScheduleEntity scheduleEntity;

  factory OccupancyEntity.fromJson(Map<String, dynamic> json) {
    final List<(DateTime, int)> data = [];
    final List<(DateTime, int)> knnPrediction = [];
    final List<(DateTime, int)> lstmPrediction = [];
    final dataList = json['data'] as List;
    for (final item in dataList) {
      data.add((DateTime.parse(item[0] as String), item[1] as int));
    }
    final knnList = json['prediction_knn'] as List;
    for (final item in knnList) {
      knnPrediction.add((DateTime.parse(item[0] as String), item[1] as int));
    }
    final lstmList = json['prediction_lstm'] as List;
    for (final item in lstmList) {
      lstmPrediction.add((DateTime.parse(item[0] as String), item[1] as int));
    }
    final scheduleEntity = ScheduleEntity.fromJson(json);
    return OccupancyEntity(
      data: data,
      knnPrediction: knnPrediction,
      lstmPrediction: lstmPrediction,
      scheduleEntity: scheduleEntity,
    );
  }

  factory OccupancyEntity.empty() {
    return OccupancyEntity(
      data: [],
      knnPrediction: [],
      lstmPrediction: [],
      scheduleEntity: ScheduleEntity.empty(),
    );
  }

  DateTime? getLastDate() {
    if (data.isEmpty) {
      return null;
    }
    return data.last.$1;
  }

  OccupancyEntity copyWith({
    List<(DateTime, int)>? data,
    List<(DateTime, int)>? knnPrediction,
    List<(DateTime, int)>? lstmPrediction,
    ScheduleEntity? scheduleEntity,
  }) {
    return OccupancyEntity(
      data: data ?? this.data,
      knnPrediction: knnPrediction ?? this.knnPrediction,
      lstmPrediction: lstmPrediction ?? this.lstmPrediction,
      scheduleEntity: scheduleEntity ?? this.scheduleEntity,
    );
  }

  OccupancyEntity extendData(OccupancyEntity other) {
    ScheduleEntity schedule = scheduleEntity;
    if (scheduleEntity != other.scheduleEntity && other.scheduleEntity.timings.isNotEmpty) {
      schedule = other.scheduleEntity;
    }
    return OccupancyEntity(
        data: [...data, ...other.data],
        knnPrediction: knnPrediction,
        lstmPrediction: lstmPrediction,
        scheduleEntity: schedule);
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
    final int dataHash = data.fold<int>(0, (previousValue, element) => previousValue ^ element.hashCode);
    final int scheduleHash = scheduleEntity.hashCode;
    return dataHash ^ scheduleHash;
  }
}

class OccupancyEntitiyNotifier extends FamilyAsyncNotifier<OccupancyEntity, String> {
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
    final fetchedData = await ref.read(remoteSourceProvider).getFromData(_name, from);
    if (fetchedData is Left) {
      // print(fetchedData.left);
      // print("Error :(");
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

class OtherDayOccupancyEntityNotifier extends FamilyAsyncNotifier<OccupancyEntity, String> {
  final HashMap map = HashMap<String, OccupancyEntity>();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  late String _name;
  late DateTime _currentDate;

  @override
  FutureOr<OccupancyEntity> build(String arg) async {
    _name = arg;
    final yesterdayDateTime = ukDateTimeNow().subtract(const Duration(days: 1));
    _currentDate = yesterdayDateTime;
    if (map.containsKey(yesterdayDateTime)) {
      return map[yesterdayDateTime];
    }
    final String yesterday = formatter.format(yesterdayDateTime);
    final data = await ref.read(remoteSourceProvider).getOtherDayData(arg, yesterday);
    return data.right;
  }

  Future<void> getOtherDayData(DateTime date) async {
    _currentDate = date;
    final String dateString = formatter.format(date);
    state = const AsyncValue.loading();
    if (map.containsKey(dateString)) {
      state = AsyncValue.data(map[dateString]);
      return;
    }
    final fetchedData = await ref.read(remoteSourceProvider).getOtherDayData(_name, dateString);
    if (fetchedData is Left) {
      // print(fetchedData.left);
      // print("Error :(");
      state = AsyncValue.error(fetchedData.left, StackTrace.current);
      return;
    }
    final data = fetchedData.right;
    map[dateString] = data;
    state = AsyncValue.data(data);
  }

  DateTime getCurrentDate() {
    return _currentDate;
  }
}

final occupancyEntityProvider =
    AsyncNotifierProvider.family<OccupancyEntitiyNotifier, OccupancyEntity, String>(OccupancyEntitiyNotifier.new);

final otherDayOccupancyEntityProvider =
    AsyncNotifierProvider.family<OtherDayOccupancyEntityNotifier, OccupancyEntity, String>(
        OtherDayOccupancyEntityNotifier.new);
