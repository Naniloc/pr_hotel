import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/floor.dart';

abstract interface class FloorRepository {
  List<Floor> getAll({bool includeDeleted = false});
  Floor? getById(int id);
  Floor create(Floor floor);
  Floor update(Floor floor);
  void delete(int id, {bool soft = true});
  void restore(int id);
  int countRoomsByFloorId(int floorId);
}

const List<Floor> _seedFloors = [
  Floor(id: 1, number: 1, roomCount: 5),
  Floor(id: 2, number: 2, roomCount: 5),
  Floor(id: 3, number: 3, roomCount: 5),
  Floor(id: 4, number: 4, roomCount: 5),
];

class InMemoryFloorRepository implements FloorRepository {
  static const _key = 'floors_v1';
  final SharedPreferences? _prefs;

  final List<Floor> _floors = [];
  int _nextId = 5;

  InMemoryFloorRepository([this._prefs]) {
    _restore();
  }

  void _restore() {
    if (_prefs == null) {
      _floors.addAll(_seedFloors);
      return;
    }

    final raw = _prefs.getString(_key);
    if (raw == null) {
      _floors.addAll(_seedFloors);
      _persist();
      return;
    }

    try {
      final list = jsonDecode(raw) as List;
      _floors.addAll(
        list.map((e) => Floor.fromJson(e as Map<String, dynamic>)).toList(),
      );

      if (_floors.isNotEmpty) {
        _nextId = _floors.map((f) => f.id).reduce((a, b) => a > b ? a : b) + 1;
      }
    } catch (e) {
      _floors.addAll(_seedFloors);
      _persist();
    }
  }

  void _persist() {
    final prefs = _prefs;
    if (prefs == null) return;

    prefs.setString(_key, jsonEncode(_floors.map((f) => f.toJson()).toList()));
  }

  @override
  List<Floor> getAll({bool includeDeleted = false}) {
    return _floors.where((f) => includeDeleted || !f.isDeleted).toList();
  }

  @override
  Floor? getById(int id) {
    try {
      return _floors.firstWhere((f) => f.id == id && !f.isDeleted);
    } catch (e) {
      return null;
    }
  }

  @override
  Floor create(Floor floor) {
    final newFloor = Floor(
      id: _nextId++,
      number: floor.number,
      roomCount: floor.roomCount,
    );
    _floors.add(newFloor);
    _persist();
    return newFloor;
  }

  @override
  Floor update(Floor floor) {
    final i = _floors.indexWhere((f) => f.id == floor.id);
    if (i == -1) throw StateError('Этаж ${floor.id} не найден');
    _floors[i] = floor;
    _persist();
    return floor;
  }

  @override
  void delete(int id, {bool soft = true}) {
    final i = _floors.indexWhere((f) => f.id == id);
    if (i == -1) throw StateError('Этаж $id не найден');

    if (soft) {
      _floors[i] = _floors[i].copyWith(deletedAt: DateTime.now());
    } else {
      _floors.removeAt(i);
    }
    _persist();
  }

  @override
  void restore(int id) {
    final i = _floors.indexWhere((f) => f.id == id);
    if (i == -1) throw StateError('Этаж $id не найден');
    _floors[i] = _floors[i].copyWith(clearDeletedAt: true);
    _persist();
  }

  @override
  int countRoomsByFloorId(int floorId) {
    // Пока заглушка - реализуем после добавления инжекции RoomRepository
    return 0;
  }
}
