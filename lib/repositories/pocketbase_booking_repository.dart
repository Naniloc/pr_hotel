import 'package:dio/dio.dart';

import '../models/booking.dart';
import '../models/booking_query.dart';
import '../models/page_result.dart';
import '../core/api_client.dart';
import 'booking_repository.dart';

class PocketBaseBookingRepository implements BookingRepository {
  final Dio _dio;

  PocketBaseBookingRepository(this._dio);

  @override
  Future<PageResult<Booking>> find(BookingQuery q) => guard(() async {
    final response = await _dio.get(
      '/collections/bookings/records',
      queryParameters: {
        'page': q.page,
        'perPage': q.size,
        'expand': 'roomId,guestId',
        if (q.search.trim().isNotEmpty)
          'filter': 'guestName~"${q.search.trim()}"',
        if (q.status != null) 'filter': 'status="${q.status}"',
        'sort': q.sortAscending ? q.sortField : '-${q.sortField}',
      },
    );

    final data = response.data as Map<String, dynamic>;

    return PageResult(
      items: (data['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map(Booking.fromJson)
          .toList(),
      page: data['page'] as int? ?? 1,
      size: data['perPage'] as int? ?? q.size,
      total: data['totalItems'] as int? ?? 0,
    );
  });

  @override
  Future<Booking?> findById(String id) => guard(() async {
    try {
      final response = await _dio.get(
        '/collections/bookings/records/$id',
        queryParameters: {'expand': 'roomId,guestId'},
      );
      return Booking.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  });

  @override
  Future<Booking> create(Booking booking) => guard(() async {
    final response = await _dio.post(
      '/collections/bookings/records',
      data: {
        'roomId': booking.roomId,
        'guestId': booking.guestId,
        'guestName': booking.guestName,
        'checkIn': booking.checkIn.toIso8601String(),
        'checkOut': booking.checkOut.toIso8601String(),
        'status': booking.status,
      },
    );
    return Booking.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<Booking> update(Booking booking) => guard(() async {
    final response = await _dio.patch(
      '/collections/bookings/records/${booking.id}',
      data: {
        'roomId': booking.roomId,
        'guestId': booking.guestId,
        'guestName': booking.guestName,
        'checkIn': booking.checkIn.toIso8601String(),
        'checkOut': booking.checkOut.toIso8601String(),
        'status': booking.status,
      },
    );
    return Booking.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> softDelete(String id) => guard(() async {
    await _dio.delete('/collections/bookings/records/$id');
  });

  @override
  Future<void> hardDelete(String id) => guard(() async {
    await _dio.delete('/collections/bookings/records/$id');
  });

  @override
  Future<void> restore(String id) => guard(() async {
    throw UnimplementedError('PocketBase не поддерживает восстановление');
  });

  @override
  Future<int> deleteMany(List<String> ids) => guard(() async {
    var count = 0;
    for (final id in ids) {
      try {
        await _dio.delete('/collections/bookings/records/$id');
        count++;
      } catch (e) {
        // Продолжаем удаление остальных
      }
    }
    return count;
  });
}
