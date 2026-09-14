import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isRoomNumberUnique(String number, {int? excludeId});
}

const List<Room> _seedRooms = [
  Room(
    id: 1,
    number: '101',
    floorId: 1,
    roomTypeId: 1,
    capacity: 2,
    pricePerNight: 3500,
  ),
  Room(
    id: 2,
    number: '102',
    floorId: 1,
    roomTypeId: 1,
    capacity: 2,
    pricePerNight: 3500,
  ),
  Room(
    id: 3,
    number: '103',
    floorId: 1,
    roomTypeId: 2,
    capacity: 2,
    pricePerNight: 4000,
  ),
  Room(
    id: 4,
    number: '104',
    floorId: 1,
    roomTypeId: 2,
    capacity: 3,
    pricePerNight: 4500,
  ),
  Room(
    id: 5,
    number: '105',
    floorId: 1,
    roomTypeId: 1,
    capacity: 2,
    pricePerNight: 3500,
  ),
  Room(
    id: 6,
    number: '201',
    floorId: 2,
    roomTypeId: 1,
    capacity: 2,
    pricePerNight: 3500,
  ),
  Room(
    id: 7,
    number: '202',
    floorId: 2,
    roomTypeId: 3,
    capacity: 4,
    pricePerNight: 6500,
  ),
  Room(
    id: 8,
    number: '203',
    floorId: 2,
    roomTypeId: 1,
    capacity: 2,
    pricePerNight: 3500,
  ),
  Room(
    id: 9,
    number: '204',
    floorId: 2,
    roomTypeId: 2,
    capacity: 2,
    pricePerNight: 4000,
  ),
  Room(
    id: 10,
    number: '205',
    floorId: 2,
    roomTypeId: 4,
    capacity: 4,
    pricePerNight: 7000,
  ),
  Room(
    id: 11,
    number: '301',
    floorId: 3,
    roomTypeId: 4,
    capacity: 4,
    pricePerNight: 7000,
  ),
  Room(
    id: 12,
    number: '302',
    floorId: 3,
    roomTypeId: 1,
    capacity: 2,
    pricePerNight: 3500,
  ),
  Room(
    id: 13,
    number: '303',
    floorId: 3,
    roomTypeId: 3,
    capacity: 4,
    pricePerNight: 6500,
  ),
  Room(
    id: 14,
    number: '304',
    floorId: 3,
    roomTypeId: 2,
    capacity: 3,
    pricePerNight: 4500,
  ),
  Room(
    id: 15,
    number: '305',
    floorId: 3,
    roomTypeId: 1,
    capacity: 2,
    pricePerNight: 3500,
  ),
  Room(
    id: 16,
    number: '401',
    floorId: 4,
    roomTypeId: 4,
    capacity: 4,
    pricePerNight: 7000,
  ),
  Room(
    id: 17,
    number: '402',
    floorId: 4,
    roomTypeId: 3,
    capacity: 4,
    pricePerNight: 6500,
  ),
  Room(
    id: 18,
    number: '403',
    floorId: 4,
    roomTypeId: 5,
    capacity: 6,
    pricePerNight: 9000,
  ),
  Room(
    id: 19,
    number: '404',
    floorId: 4,
    roomTypeId: 2,
    capacity: 3,
    pricePerNight: 4500,
  ),
  Room(
    id: 20,
    number: '405',
    floorId: 4,
    roomTypeId: 1,
    capacity: 2,
    pricePerNight: 3500,
  ),
];

class InMemoryRoomRepository implements RoomRepository {
  static const _key = 'rooms_v1';
  final SharedPreferences? _prefs;

  final List<Room> _rooms = [];
  int _nextId = 21;

  InMemoryRoomRepository([this._prefs]) {
    _restore();
  }

  void _restore() {
    if (_prefs == null) {
      _rooms.addAll(_seedRooms);
      return;
    }

    final raw = _prefs.getString(_key);
    if (raw == null) {
      _rooms.addAll(_seedRooms);
      _persist();
      return;
    }

    try {
      final list = jsonDecode(raw) as List;
      _rooms.addAll(
        list.map((e) => Room.fromJson(e as Map<String, dynamic>)).toList(),
      );

      if (_rooms.isNotEmpty) {
        _nextId = _rooms.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1;
      }
    } catch (e) {
      _rooms.addAll(_seedRooms);
      _persist();
    }
  }

  Future<void> _persist() async {
    final prefs = _prefs;
    if (prefs == null) return;

    await prefs.setString(
      _key,
      jsonEncode(_rooms.map((r) => r.toJson()).toList()),
    );
  }

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

    if (q.roomTypeId != null) {
      rows = rows.where((r) => r.roomTypeId == q.roomTypeId).toList();
    }

    if (q.floor != null) {
      rows = rows.where((r) => r.floorId == q.floor).toList();
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
        'floor' => a.floorId.compareTo(b.floorId),
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
      floorId: room.floorId,
      roomTypeId: room.roomTypeId,
      capacity: room.capacity,
      pricePerNight: room.pricePerNight,
      isAvailable: room.isAvailable,
    );
    _rooms.add(newRoom);
    await _persist();
    return newRoom;
  }

  @override
  Future<Room> update(Room room) async {
    final i = _rooms.indexWhere((r) => r.id == room.id);
    if (i == -1) throw StateError('Номер ${room.id} не найден');
    _rooms[i] = room;
    await _persist();
    return room;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _rooms.indexWhere((r) => r.id == id);
    if (i == -1) throw StateError('Номер $id не найден');
    _rooms[i] = _rooms[i].copyWith(deletedAt: DateTime.now());
    await _persist();
  }

  @override
  Future<void> hardDelete(int id) async {
    _rooms.removeWhere((r) => r.id == id);
    await _persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = _rooms.indexWhere((r) => r.id == id);
    if (i == -1) throw StateError('Номер $id не найден');
    _rooms[i] = _rooms[i].copyWith(clearDeletedAt: true);
    await _persist();
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
    await _persist();
    return count;
  }

  @override
  bool isRoomNumberUnique(String number, {int? excludeId}) {
    return !_rooms.any(
      (r) =>
          r.number.toLowerCase() == number.toLowerCase() &&
          r.id != excludeId &&
          !r.isDeleted,
    );
  }
}
