import '../models/booking.dart';
import '../models/booking_query.dart';
import '../models/page_result.dart';

abstract interface class BookingRepository {
  Future<PageResult<Booking>> find(BookingQuery query);
  Future<Booking?> findById(int id);
  Future<Booking> create(Booking booking);
  Future<Booking> update(Booking booking);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}

// Демо-данные
final List<Booking> _seedBookings = [
  Booking(
    id: 1,
    roomId: 1,
    guestName: 'Иван Петров',
    checkIn: DateTime(2026, 4, 15),
    checkOut: DateTime(2026, 4, 18),
    status: 'confirmed',
  ),
  Booking(
    id: 2,
    roomId: 2,
    guestName: 'Мария Сидорова',
    checkIn: DateTime(2026, 2, 10),
    checkOut: DateTime(2026, 2, 15),
    status: 'completed',
  ),
  Booking(
    id: 3,
    roomId: 3,
    guestName: 'Алексей Иванов',
    checkIn: DateTime(2026, 1, 20),
    checkOut: DateTime(2026, 1, 23),
    status: 'pending',
  ),
  Booking(
    id: 4,
    roomId: 4,
    guestName: 'Елена Смирнова',
    checkIn: DateTime(2026, 10, 12),
    checkOut: DateTime(2026, 10, 19),
    status: 'confirmed',
  ),
  Booking(
    id: 5,
    roomId: 5,
    guestName: 'Дмитрий Кузнецов',
    checkIn: DateTime(2026, 9, 22),
    checkOut: DateTime(2026, 9, 25),
    status: 'confirmed',
  ),
  Booking(
    id: 6,
    roomId: 6,
    guestName: 'Ольга Морозова',
    checkIn: DateTime(2026, 11, 8),
    checkOut: DateTime(2026, 11, 12),
    status: 'completed',
  ),
  Booking(
    id: 7,
    roomId: 7,
    guestName: 'Сергей Волков',
    checkIn: DateTime(2026, 5, 25),
    checkOut: DateTime(2026, 5, 28),
    status: 'pending',
  ),
  Booking(
    id: 8,
    roomId: 8,
    guestName: 'Анна Соколова',
    checkIn: DateTime(2026, 4, 18),
    checkOut: DateTime(2026, 4, 21),
    status: 'confirmed',
  ),
  Booking(
    id: 9,
    roomId: 9,
    guestName: 'Николай Лебедев',
    checkIn: DateTime(2026, 9, 14),
    checkOut: DateTime(2026, 9, 17),
    status: 'completed',
  ),
  Booking(
    id: 10,
    roomId: 10,
    guestName: 'Татьяна Козлова',
    checkIn: DateTime(2026, 7, 11),
    checkOut: DateTime(2026, 7, 16),
    status: 'confirmed',
  ),
];

class InMemoryBookingRepository implements BookingRepository {
  final List<Booking> _bookings = List.from(_seedBookings);
  int _nextId = _seedBookings.length + 1;

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
  Future<Booking?> findById(int id) async {
    try {
      return _bookings.firstWhere((b) => b.id == id && !b.isDeleted);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Booking> create(Booking booking) async {
    final newBooking = Booking(
      id: _nextId++,
      roomId: booking.roomId,
      guestName: booking.guestName,
      checkIn: booking.checkIn,
      checkOut: booking.checkOut,
      status: booking.status,
    );
    _bookings.add(newBooking);
    return newBooking;
  }

  @override
  Future<Booking> update(Booking booking) async {
    final i = _bookings.indexWhere((b) => b.id == booking.id);
    if (i == -1) throw StateError('Бронирование ${booking.id} не найдено');
    _bookings[i] = booking;
    return booking;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _bookings.indexWhere((b) => b.id == id);
    if (i == -1) throw StateError('Бронирование $id не найдено');
    _bookings[i] = _bookings[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _bookings.removeWhere((b) => b.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _bookings.indexWhere((b) => b.id == id);
    if (i == -1) throw StateError('Бронирование $id не найдено');
    _bookings[i] = _bookings[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = _bookings.indexWhere((b) => b.id == id && !b.isDeleted);
      if (i != -1) {
        _bookings[i] = _bookings[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }
}
