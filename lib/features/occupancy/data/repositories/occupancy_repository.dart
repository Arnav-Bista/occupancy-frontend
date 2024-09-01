import 'package:either_dart/either.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/occupancy_entity.dart';

abstract class OccupancyRepository {
  Future<Either<int, OccupancyEntity>> getDayData(String name);

  Future<Either<int, OccupancyEntity>> getFromData(String name, String from);

  Future<Either<int, OccupancyEntity>> getOtherDayData(String name, String date);
}
