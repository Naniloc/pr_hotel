import 'package:dio/dio.dart';

import '../models/floor.dart';
import '../core/api_client.dart';
import 'floor_repository.dart';

class PocketBaseFloorRepository implements FloorRepository {
  final Dio _dio;

  PocketBaseFloorRepository(this._dio);

  @override
  List<Floor> getAll({bool includeDeleted = false}) {
    return [];
  }

  Future<List<Floor>> getAllAsync({bool includeDeleted = false}) =>
      guard(() async {
        final response = await _dio.get(
          '/collections/floors/records',
          queryParameters: {'perPage': 200, 'sort': 'number'},
        );

        final data = response.data as Map<String, dynamic>;
        return (data['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Floor.fromJson)
            .toList();
      });

  @override
  Floor? getById(String id) {
    return null;
  }

  Future<Floor?> getByIdAsync(String id) => guard(() async {
    try {
      final response = await _dio.get('/collections/floors/records/$id');
      return Floor.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  });

  @override
  Floor create(Floor floor) {
    throw UnimplementedError('Используйте createAsync');
  }

  Future<Floor> createAsync(Floor floor) => guard(() async {
    final response = await _dio.post(
      '/collections/floors/records',
      data: {'number': floor.number, 'roomCount': floor.roomCount},
    );
    return Floor.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Floor update(Floor floor) {
    throw UnimplementedError('Используйте updateAsync');
  }

  Future<Floor> updateAsync(Floor floor) => guard(() async {
    final response = await _dio.patch(
      '/collections/floors/records/${floor.id}',
      data: {'number': floor.number, 'roomCount': floor.roomCount},
    );
    return Floor.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  void delete(String id, {bool soft = true}) {
    throw UnimplementedError('Используйте deleteAsync');
  }

  Future<void> deleteAsync(String id) => guard(() async {
    await _dio.delete('/collections/floors/records/$id');
  });

  @override
  void restore(String id) {
    throw UnimplementedError('PocketBase не поддерживает восстановление');
  }

  @override
  int countRoomsByFloorId(String floorId) {
    return 0;
  }

  Future<int> countRoomsByFloorIdAsync(String floorId) => guard(() async {
    final response = await _dio.get(
      '/collections/rooms/records',
      queryParameters: {'filter': 'floorId="$floorId"', 'perPage': 1},
    );
    final data = response.data as Map<String, dynamic>;
    return data['totalItems'] as int? ?? 0;
  });
}
