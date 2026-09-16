import 'package:dio/dio.dart';

import '../models/room_type.dart';
import '../core/api_client.dart';
import 'room_type_repository.dart';

class PocketBaseRoomTypeRepository implements RoomTypeRepository {
  final Dio _dio;

  PocketBaseRoomTypeRepository(this._dio);

  @override
  List<RoomType> getAll({bool includeDeleted = false}) {
    //
    return [];
  }

  @override
  RoomType? getById(String id) {
    //
    return null;
  }

  Future<List<RoomType>> getAllAsync({bool includeDeleted = false}) =>
      guard(() async {
        final response = await _dio.get(
          '/collections/room_types/records',
          queryParameters: {'perPage': 200, 'sort': 'name'},
        );

        final data = response.data as Map<String, dynamic>;
        return (data['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(RoomType.fromJson)
            .toList();
      });

  @override
  RoomType create(RoomType roomType) {
    throw UnimplementedError('Используйте createAsync');
  }

  Future<RoomType> createAsync(RoomType roomType) => guard(() async {
    final response = await _dio.post(
      '/collections/room_types/records',
      data: {'name': roomType.name, 'description': roomType.description},
    );
    return RoomType.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  RoomType update(RoomType roomType) {
    throw UnimplementedError('Используйте updateAsync');
  }

  Future<RoomType> updateAsync(RoomType roomType) => guard(() async {
    final response = await _dio.patch(
      '/collections/room_types/records/${roomType.id}',
      data: {'name': roomType.name, 'description': roomType.description},
    );
    return RoomType.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  void delete(String id, {bool soft = true}) {
    throw UnimplementedError('Используйте deleteAsync');
  }

  Future<void> deleteAsync(String id) => guard(() async {
    await _dio.delete('/collections/room_types/records/$id');
  });

  @override
  void restore(String id) {
    throw UnimplementedError('PocketBase не поддерживает восстановление');
  }

  @override
  int countRoomsByTypeId(String typeId) {
    //
    return 0;
  }
}
