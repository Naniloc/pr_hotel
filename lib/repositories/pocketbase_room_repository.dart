import 'package:dio/dio.dart';

import '../models/room.dart';
import '../models/room_query.dart';
import '../models/page_result.dart';
import '../core/api_client.dart';
import 'room_repository.dart';

class PocketBaseRoomRepository implements RoomRepository {
  final Dio _dio;

  PocketBaseRoomRepository(this._dio);

  @override
  Future<PageResult<Room>> find(RoomQuery q) => guard(() async {
    final response = await _dio.get(
      '/collections/rooms/records',
      queryParameters: {
        'page': q.page,
        'perPage': q.size,
        'expand': 'floorId,roomTypeId',
        if (q.search.trim().isNotEmpty) 'filter': 'number~"${q.search.trim()}"',
        if (q.roomTypeId != null) 'filter': 'roomTypeId="${q.roomTypeId}"',
        'sort': q.sortAscending ? q.sortField : '-${q.sortField}',
      },
    );

    final data = response.data as Map<String, dynamic>;

    return PageResult(
      items: (data['items'] as List)
          .map((e) => Room.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: data['page'] as int,
      size: data['perPage'] as int,
      total: data['totalItems'] as int,
    );
  });

  @override
  Future<Room?> findById(String id) => guard(() async {
    try {
      final response = await _dio.get(
        '/collections/rooms/records/$id',
        queryParameters: {'expand': 'floorId,roomTypeId'},
      );
      return Room.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  });

  @override
  Future<Room> create(Room room) => guard(() async {
    final response = await _dio.post(
      '/collections/rooms/records',
      data: {
        'number': room.number,
        'floorId': room.floorId,
        'roomTypeId': room.roomTypeId,
        'capacity': room.capacity,
        'pricePerNight': room.pricePerNight,
        'isAvailable': room.isAvailable,
      },
    );
    return Room.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<Room> update(Room room) => guard(() async {
    final response = await _dio.patch(
      '/collections/rooms/records/${room.id}',
      data: {
        'number': room.number,
        'floorId': room.floorId,
        'roomTypeId': room.roomTypeId,
        'capacity': room.capacity,
        'pricePerNight': room.pricePerNight,
        'isAvailable': room.isAvailable,
      },
    );
    return Room.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> softDelete(String id) => guard(() async {
    await _dio.delete('/collections/rooms/records/$id');
  });

  @override
  Future<void> hardDelete(String id) => guard(() async {
    await _dio.delete('/collections/rooms/records/$id');
  });

  @override
  Future<void> restore(String id) => guard(() async {
    throw UnimplementedError('Восстановление не поддерживается PocketBase');
  });

  @override
  Future<int> deleteMany(List<String> ids) => guard(() async {
    var count = 0;
    for (final id in ids) {
      try {
        await _dio.delete('/collections/rooms/records/$id');
        count++;
      } catch (e) {
        //
      }
    }
    return count;
  });

  @override
  bool isRoomNumberUnique(String number, {String? excludeId}) {
    // ← String?
    return true;
  }
}
