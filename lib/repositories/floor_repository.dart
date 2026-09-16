import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/floor.dart';

abstract interface class FloorRepository {
  List<Floor> getAll({bool includeDeleted = false});
  Floor? getById(String id); // ← String
  Floor create(Floor floor);
  Floor update(Floor floor);
  void delete(String id, {bool soft = true}); // ← String
  void restore(String id); // ← String
  int countRoomsByFloorId(String floorId); // ← String
}

class InMemoryFloorRepository implements FloorRepository {
  static const _key = 'floors_v1';
  final SharedPreferences? _prefs;

  final List<Floor> _floors = [];
  int _nextId = 1;

  InMemoryFloorRepository([this._prefs]) {
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
      _floors.addAll(
        list.map((e) => Floor.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      // Если не удалось загрузить - оставляем пустым
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
  Floor? getById(String id) {
    // ← String
    try {
      return _floors.firstWhere((f) => f.id == id && !f.isDeleted);
    } catch (e) {
      return null;
    }
  }

  @override
  Floor create(Floor floor) {
    final newFloor = Floor(
      id: 'temp_floor_${_nextId++}', // ← String
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
  void delete(String id, {bool soft = true}) {
    // ← String
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
  void restore(String id) {
    // ← String
    final i = _floors.indexWhere((f) => f.id == id);
    if (i == -1) throw StateError('Этаж $id не найден');
    _floors[i] = _floors[i].copyWith(clearDeletedAt: true);
    _persist();
  }

  @override
  int countRoomsByFloorId(String floorId) {
    // ← String
    // Заглушка - реализуем при интеграции
    return 0;
  }
}
