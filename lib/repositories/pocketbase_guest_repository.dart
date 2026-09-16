import 'package:dio/dio.dart';

import '../models/guest.dart';
import '../core/api_client.dart';
import 'guest_repository.dart';

class PocketBaseGuestRepository implements GuestRepository {
  final Dio _dio;

  PocketBaseGuestRepository(this._dio);

  @override
  List<Guest> getAll({bool includeDeleted = false}) {
    //
    return [];
  }

  Future<List<Guest>> getAllAsync({bool includeDeleted = false}) =>
      guard(() async {
        final response = await _dio.get(
          '/collections/guests/records',
          queryParameters: {'perPage': 200, 'sort': 'name'},
        );

        final data = response.data as Map<String, dynamic>;
        return (data['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Guest.fromJson)
            .toList();
      });

  @override
  Guest? getById(String id) {
    //
    return null;
  }

  Future<Guest?> getByIdAsync(String id) => guard(() async {
    try {
      final response = await _dio.get('/collections/guests/records/$id');
      return Guest.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  });

  @override
  Guest create(Guest guest) {
    throw UnimplementedError('Используйте createAsync');
  }

  Future<Guest> createAsync(Guest guest) => guard(() async {
    final response = await _dio.post(
      '/collections/guests/records',
      data: {'name': guest.name, 'email': guest.email, 'phone': guest.phone},
    );
    return Guest.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Guest update(Guest guest) {
    throw UnimplementedError('Используйте updateAsync');
  }

  Future<Guest> updateAsync(Guest guest) => guard(() async {
    final response = await _dio.patch(
      '/collections/guests/records/${guest.id}',
      data: {'name': guest.name, 'email': guest.email, 'phone': guest.phone},
    );
    return Guest.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  void delete(String id, {bool soft = true}) {
    throw UnimplementedError('Используйте deleteAsync');
  }

  Future<void> deleteAsync(String id) => guard(() async {
    await _dio.delete('/collections/guests/records/$id');
  });

  @override
  void restore(String id) {
    throw UnimplementedError('PocketBase не поддерживает восстановление');
  }

  @override
  bool isEmailUnique(String email, {String? excludeId}) {
    //
    return true;
  }

  Future<bool> isEmailUniqueAsync(String email, {String? excludeId}) =>
      guard(() async {
        final response = await _dio.get(
          '/collections/guests/records',
          queryParameters: {'filter': 'email="$email"', 'perPage': 1},
        );

        final data = response.data as Map<String, dynamic>;
        final items = data['items'] as List;

        if (items.isEmpty) return true;

        if (excludeId != null) {
          final found = Guest.fromJson(items.first as Map<String, dynamic>);
          return found.id == excludeId;
        }

        return false;
      });
}
