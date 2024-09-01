import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:occupancy_frontend/features/occupancy/data/repositories/occupancy_repository.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/occupancy_entity.dart';
import 'package:http/http.dart' as http;

final remoteSourceProvider = Provider<RemoteSource>((ref) {
  return RemoteSource();
});

class RemoteSource extends OccupancyRepository {
  final apiHost = "arnavbista.com";

  @override
  Future<Either<int, OccupancyEntity>> getDayData(String name) async {
    final uri = Uri.https(apiHost, "api/day", {"name": name});
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      return Left(response.statusCode);
    }
    final body = json.decode(response.body);
    return Right(OccupancyEntity.fromJson(body));
  }

  @override
  Future<Either<int, OccupancyEntity>> getOtherDayData(String name, String date) async {
    final uri = Uri.https(apiHost, "api/day", {"name": name, "date": date});
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      return Left(response.statusCode);
    }
    final body = json.decode(response.body);
    return Right(OccupancyEntity.fromJson(body));
  }

  @override
  Future<Either<int, OccupancyEntity>> getFromData(String name, String from) async {
    final uri = Uri.https(apiHost, "api/from", {"name": name, "from": from});
    final response = await http.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return Left(response.statusCode);
    }

    // Handle 204
    if (response.statusCode == 204) {
      return Right(OccupancyEntity.empty());
    }
    final body = json.decode(response.body);
    return Right(OccupancyEntity.fromJson(body));
  }
}
