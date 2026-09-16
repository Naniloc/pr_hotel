import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/room.dart';
import '../models/room_query.dart';
import '../models/page_result.dart';

abstract interface class RoomRepository {
  Future<PageResult<Room>> find(RoomQuery query);
  Future<Room?> findById(String id);
  Future<Room> create(Room room);
  Future<Room> update(Room room);
  Future<void> softDelete(String id);
  Future<void> hardDelete(String id);
  Future<void> restore(String id);
  Future<int> deleteMany(List<String> ids);
  bool isRoomNumberUnique(String number, {String? excludeId});
}

class InMemoryRoomRepository implements RoomRepository {
  static const _key = 'rooms_v1';
  final SharedPreferences? _prefs;

  final List<Room> _rooms = [];
  int _nextId = 1;

  InMemoryRoomRepository([this._prefs]) {
    _restore();
  }

  void _restore() {
    if (_prefs == null) {
      return;
    }

    final raw = _prefs.getString(_key);
    if (raw == null) return;

    try {
      final list = jsonDecode(raw) as List;
      _rooms.addAll(
        list.map((e) => Room.fromJson(e as Map<String, dynamic>)).toList(),
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
      // floor - это номер этажа (int), а floorId - это String ID
      // Нужно найти Floor по номеру и сравнить ID
      // Пока упрощённо: пропускаем эту фильтрацию
      // rows = rows.where((r) => r.floorId == ???).toList();
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
  Future<Room?> findById(String id) async {
    // ← String
    try {
      return _rooms.firstWhere((r) => r.id == id && !r.isDeleted);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Room> create(Room room) async {
    final newRoom = Room(
      id: 'temp_${_nextId++}',
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
  Future<void> softDelete(String id) async {
    // ← String
    final i = _rooms.indexWhere((r) => r.id == id);
    if (i == -1) throw StateError('Номер $id не найден');
    _rooms[i] = _rooms[i].copyWith(deletedAt: DateTime.now());
    await _persist();
  }

  @override
  Future<void> hardDelete(String id) async {
    // ← String
    _rooms.removeWhere((r) => r.id == id);
    await _persist();
  }

  @override
  Future<void> restore(String id) async {
    // ← String
    final i = _rooms.indexWhere((r) => r.id == id);
    if (i == -1) throw StateError('Номер $id не найден');
    _rooms[i] = _rooms[i].copyWith(clearDeletedAt: true);
    await _persist();
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    // ← List<String>
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
  bool isRoomNumberUnique(String number, {String? excludeId}) {
    // ← String?
    return !_rooms.any(
      (r) =>
          r.number.toLowerCase() == number.toLowerCase() &&
          r.id != excludeId &&
          !r.isDeleted,
    );
  }
}
