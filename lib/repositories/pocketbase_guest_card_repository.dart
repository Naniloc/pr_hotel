import 'package:dio/dio.dart';

import '../models/guest_card.dart';
import '../core/api_client.dart';
import 'guest_card_repository.dart';

class PocketBaseGuestCardRepository implements GuestCardRepository {
  final Dio _dio;

  PocketBaseGuestCardRepository(this._dio);

  @override
  List<GuestCard> getAll({bool includeDeleted = false}) {
    // Синхронный метод — заглушка
    return [];
  }

  Future<List<GuestCard>> getAllAsync({bool includeDeleted = false}) =>
      guard(() async {
        final response = await _dio.get(
          '/collections/guest_cards/records',
          queryParameters: {'perPage': 200, 'expand': 'guestId'},
        );

        final data = response.data as Map<String, dynamic>;
        return (data['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(GuestCard.fromJson)
            .toList();
      });

  @override
  GuestCard? getById(String id) {
    // Синхронный метод — заглушка
    return null;
  }

  Future<GuestCard?> getByIdAsync(String id) => guard(() async {
    try {
      final response = await _dio.get(
        '/collections/guest_cards/records/$id',
        queryParameters: {'expand': 'guestId'},
      );
      return GuestCard.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  });

  @override
  GuestCard? getByGuestId(String guestId) {
    // Синхронный метод — заглушка
    return null;
  }

  Future<GuestCard?> getByGuestIdAsync(String guestId) => guard(() async {
    final response = await _dio.get(
      '/collections/guest_cards/records',
      queryParameters: {'filter': 'guestId="$guestId"', 'perPage': 1},
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List;

    if (items.isEmpty) return null;

    return GuestCard.fromJson(items.first as Map<String, dynamic>);
  });

  @override
  GuestCard create(GuestCard card) {
    throw UnimplementedError('Используйте createAsync');
  }

  Future<GuestCard> createAsync(GuestCard card) => guard(() async {
    final response = await _dio.post(
      '/collections/guest_cards/records',
      data: {
        'guestId': card.guestId,
        'passportNumber': card.passportNumber,
        'passportIssuedBy': card.passportIssuedBy,
        'passportIssuedDate': card.passportIssuedDate.toIso8601String(),
      },
    );
    return GuestCard.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  GuestCard update(GuestCard card) {
    throw UnimplementedError('Используйте updateAsync');
  }

  Future<GuestCard> updateAsync(GuestCard card) => guard(() async {
    final response = await _dio.patch(
      '/collections/guest_cards/records/${card.id}',
      data: {
        'guestId': card.guestId,
        'passportNumber': card.passportNumber,
        'passportIssuedBy': card.passportIssuedBy,
        'passportIssuedDate': card.passportIssuedDate.toIso8601String(),
      },
    );
    return GuestCard.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  void delete(String id, {bool soft = true}) {
    throw UnimplementedError('Используйте deleteAsync');
  }

  Future<void> deleteAsync(String id) => guard(() async {
    await _dio.delete('/collections/guest_cards/records/$id');
  });

  @override
  void restore(String id) {
    throw UnimplementedError('PocketBase не поддерживает восстановление');
  }
}
