import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/booking.dart';
import '../models/booking_query.dart';
import '../models/page_result.dart';

abstract interface class BookingRepository {
  Future<PageResult<Booking>> find(BookingQuery query);
  Future<Booking?> findById(String id); // ← String
  Future<Booking> create(Booking booking);
  Future<Booking> update(Booking booking);
  Future<void> softDelete(String id); // ← String
  Future<void> hardDelete(String id); // ← String
  Future<void> restore(String id); // ← String
  Future<int> deleteMany(List<String> ids); // ← List<String>
}

class InMemoryBookingRepository implements BookingRepository {
  static const _key = 'bookings_v1';
  final SharedPreferences? _prefs;

  final List<Booking> _bookings = [];
  int _nextId = 1;

  InMemoryBookingRepository([this._prefs]) {
    _restore();
  }

  void _restore() {
    if (_prefs == null) {
      return; // Не загружаем seed-данные
    }

    final raw = _prefs.getString(_key);
    if (raw == null) return;

    try {
      final list = jsonDecode(raw) as List;
      _bookings.addAll(
        list.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      // Если не удалось загрузить - оставляем пустым
    }
  }

  Future<void> _persist() async {
    final prefs = _prefs;
    if (prefs == null) return;

    await prefs.setString(
      _key,
      jsonEncode(_bookings.map((b) => b.toJson()).toList()),
    );
  }

  @override
  Future<PageResult<Booking>> find(BookingQuery q) async {
    await Future.delayed(const Duration(milliseconds: 250));

    var rows = _bookings
        .where((b) => q.includeDeleted || !b.isDeleted)
        .toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where((b) => b.guestName.toLowerCase().contains(needle))
          .toList();
    }

    if (q.status != null) {
      rows = rows.where((b) => b.status == q.status).toList();
    }

    if (q.dateFrom != null) {
      rows = rows.where((b) => b.checkIn.isAfter(q.dateFrom!)).toList();
    }

    if (q.dateTo != null) {
      rows = rows.where((b) => b.checkIn.isBefore(q.dateTo!)).toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'guestName' => a.guestName.compareTo(b.guestName),
        'nights' => a.nights.compareTo(b.nights),
        _ => a.checkIn.compareTo(b.checkIn),
      };
      return q.sortAscending ? result : -result;
    });

    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <Booking>[] : rows.sublist(from, to);

    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Booking?> findById(String id) async {
    // ← String
    try {
      return _bookings.firstWhere((b) => b.id == id && !b.isDeleted);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Booking> create(Booking booking) async {
    final newBooking = Booking(
      id: 'temp_booking_${_nextId++}', // ← String
      roomId: booking.roomId,
      guestId: booking.guestId,
      guestName: booking.guestName,
      checkIn: booking.checkIn,
      checkOut: booking.checkOut,
      status: booking.status,
    );
    _bookings.add(newBooking);
    await _persist();
    return newBooking;
  }

  @override
  Future<Booking> update(Booking booking) async {
    final i = _bookings.indexWhere((b) => b.id == booking.id);
    if (i == -1) throw StateError('Бронирование ${booking.id} не найдено');
    _bookings[i] = booking;
    await _persist();
    return booking;
  }

  @override
  Future<void> softDelete(String id) async {
    // ← String
    final i = _bookings.indexWhere((b) => b.id == id);
    if (i == -1) throw StateError('Бронирование $id не найдено');
    _bookings[i] = _bookings[i].copyWith(deletedAt: DateTime.now());
    await _persist();
  }

  @override
  Future<void> hardDelete(String id) async {
    // ← String
    _bookings.removeWhere((b) => b.id == id);
    await _persist();
  }

  @override
  Future<void> restore(String id) async {
    // ← String
    final i = _bookings.indexWhere((b) => b.id == id);
    if (i == -1) throw StateError('Бронирование $id не найдено');
    _bookings[i] = _bookings[i].copyWith(clearDeletedAt: true);
    await _persist();
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = _bookings.indexWhere((b) => b.id == id && !b.isDeleted);
      if (i != -1) {
        _bookings[i] = _bookings[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    await _persist();
    return count;
  }
}
