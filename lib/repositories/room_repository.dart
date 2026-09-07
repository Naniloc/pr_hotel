import '../models/room.dart';
import '../models/room_query.dart';
import '../models/page_result.dart';

abstract interface class RoomRepository {
  Future<PageResult<Room>> find(RoomQuery query);
  Future<Room?> findById(int id);
  Future<Room> create(Room room);
  Future<Room> update(Room room);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}

// Демо-данные
const List<Room> _seedRooms = [
  Room(
    id: 1,
    number: '101',
    type: 'standard',
    floor: 1,
    capacity: 2,
    pricePerNight: 3500,
  ),
  Room(
    id: 2,
    number: '102',
    type: 'standard',
    floor: 1,
    capacity: 2,
    pricePerNight: 3500,
  ),
  Room(
    id: 3,
    number: '103',
    type: 'twin',
    floor: 1,
    capacity: 2,
    pricePerNight: 4000,
  ),
  Room(
    id: 4,
    number: '104',
    type: 'twin',
    floor: 1,
    capacity: 3,
    pricePerNight: 4500,
  ),
  Room(
    id: 5,
    number: '105',
    type: 'standard',
    floor: 1,
    capacity: 2,
    pricePerNight: 3500,
  ),

  Room(
    id: 6,
    number: '201',
    type: 'standard',
    floor: 2,
    capacity: 2,
    pricePerNight: 3500,
  ),
  Room(
    id: 7,
    number: '202',
    type: 'suite',
    floor: 2,
    capacity: 4,
    pricePerNight: 6500,
  ),
  Room(
    id: 8,
    number: '203',
    type: 'standard',
    floor: 2,
    capacity: 2,
    pricePerNight: 3500,
  ),
  Room(
    id: 9,
    number: '204',
    type: 'twin',
    floor: 2,
    capacity: 2,
    pricePerNight: 4000,
  ),
  Room(
    id: 10,
    number: '205',
    type: 'family',
    floor: 2,
    capacity: 4,
    pricePerNight: 7000,
  ),

  Room(
    id: 11,
    number: '301',
    type: 'family',
    floor: 3,
    capacity: 4,
    pricePerNight: 7000,
  ),
  Room(
    id: 12,
    number: '302',
    type: 'standard',
    floor: 3,
    capacity: 2,
    pricePerNight: 3500,
  ),
  Room(
    id: 13,
    number: '303',
    type: 'suite',
    floor: 3,
    capacity: 4,
    pricePerNight: 6500,
  ),
  Room(
    id: 14,
    number: '304',
    type: 'twin',
    floor: 3,
    capacity: 3,
    pricePerNight: 4500,
  ),
  Room(
    id: 15,
    number: '305',
    type: 'standard',
    floor: 3,
    capacity: 2,
    pricePerNight: 3500,
  ),

  Room(
    id: 16,
    number: '401',
    type: 'family',
    floor: 4,
    capacity: 4,
    pricePerNight: 7000,
  ),
  Room(
    id: 17,
    number: '402',
    type: 'suite',
    floor: 4,
    capacity: 4,
    pricePerNight: 6500,
  ),
  Room(
    id: 18,
    number: '403',
    type: 'apartment',
    floor: 4,
    capacity: 6,
    pricePerNight: 9000,
  ),
  Room(
    id: 19,
    number: '404',
    type: 'twin',
    floor: 4,
    capacity: 3,
    pricePerNight: 4500,
  ),
  Room(
    id: 20,
    number: '405',
    type: 'standard',
    floor: 4,
    capacity: 2,
    pricePerNight: 3500,
  ),
];

class InMemoryRoomRepository implements RoomRepository {
  final List<Room> _rooms = List.from(_seedRooms);
  int _nextId = _seedRooms.length + 1;

  @override
  Future<PageResult<Room>> find(RoomQuery q) async {
    await Future.delayed(const Duration(milliseconds: 250));

    var rows = _rooms.where((r) => q.includeDeleted || !r.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where((r) => r.number.toLowerCase().contains(needle))
          .toList();
    }

    if (q.type != null) {
      rows = rows.where((r) => r.type == q.type).toList();
    }

    if (q.floor != null) {
      rows = rows.where((r) => r.floor == q.floor).toList();
    }

    if (q.priceMin != null) {
      rows = rows.where((r) => r.pricePerNight >= q.priceMin!).toList();
    }

    if (q.priceMax != null) {
      rows = rows.where((r) => r.pricePerNight <= q.priceMax!).toList();
    }

    if (q.capacity != null) {
      rows = rows.where((r) => r.capacity >= q.capacity!).toList();
    }

    if (q.onlyAvailable) {
      rows = rows.where((r) => r.isAvailable).toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'floor' => a.floor.compareTo(b.floor),
        'capacity' => a.capacity.compareTo(b.capacity),
        'price' => a.pricePerNight.compareTo(b.pricePerNight),
        _ => a.number.compareTo(b.number),
      };
      return q.sortAscending ? result : -result;
    });

    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <Room>[] : rows.sublist(from, to);

    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Room?> findById(int id) async {
    try {
      return _rooms.firstWhere((r) => r.id == id && !r.isDeleted);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Room> create(Room room) async {
    final newRoom = Room(
      id: _nextId++,
      number: room.number,
      type: room.type,
      floor: room.floor,
      capacity: room.capacity,
      pricePerNight: room.pricePerNight,
    );
    _rooms.add(newRoom);
    return newRoom;
  }

  @override
  Future<Room> update(Room room) async {
    final i = _rooms.indexWhere((r) => r.id == room.id);
    if (i == -1) throw StateError('Номер ${room.id} не найден');
    _rooms[i] = room;
    return room;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _rooms.indexWhere((r) => r.id == id);
    if (i == -1) throw StateError('Номер $id не найден');
    _rooms[i] = _rooms[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _rooms.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _rooms.indexWhere((r) => r.id == id);
    if (i == -1) throw StateError('Номер $id не найден');
    _rooms[i] = _rooms[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = _rooms.indexWhere((r) => r.id == id && !r.isDeleted);
      if (i != -1) {
        _rooms[i] = _rooms[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }
}
