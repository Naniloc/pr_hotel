import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/room_type.dart';

abstract interface class RoomTypeRepository {
  List<RoomType> getAll({bool includeDeleted = false});
  RoomType? getById(String id);
  RoomType create(RoomType roomType);
  RoomType update(RoomType roomType);
  void delete(String id, {bool soft = true});
  void restore(String id);
  int countRoomsByTypeId(String typeId);
}

class InMemoryRoomTypeRepository implements RoomTypeRepository {
  static const _key = 'room_types_v1';
  final SharedPreferences? _prefs;

  final List<RoomType> _roomTypes = [];
  int _nextId = 1;

  InMemoryRoomTypeRepository([this._prefs]) {
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
      _roomTypes.addAll(
        list.map((e) => RoomType.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      // Если не удалось загрузить - оставляем пустым
    }
  }

  void _persist() {
    final prefs = _prefs;
    if (prefs == null) return;

    prefs.setString(
      _key,
      jsonEncode(_roomTypes.map((rt) => rt.toJson()).toList()),
    );
  }

  @override
  List<RoomType> getAll({bool includeDeleted = false}) {
    return _roomTypes.where((rt) => includeDeleted || !rt.isDeleted).toList();
  }

  @override
  RoomType? getById(String id) {
    try {
      return _roomTypes.firstWhere((rt) => rt.id == id && !rt.isDeleted);
    } catch (e) {
      return null;
    }
  }

  @override
  RoomType create(RoomType roomType) {
    final newRoomType = RoomType(
      id: 'temp_type_${_nextId++}', // ← String
      name: roomType.name,
      description: roomType.description,
    );
    _roomTypes.add(newRoomType);
    _persist();
    return newRoomType;
  }

  @override
  RoomType update(RoomType roomType) {
    final i = _roomTypes.indexWhere((rt) => rt.id == roomType.id);
    if (i == -1) throw StateError('Тип номера ${roomType.id} не найден');
    _roomTypes[i] = roomType;
    _persist();
    return roomType;
  }

  @override
  void delete(String id, {bool soft = true}) {
    final i = _roomTypes.indexWhere((rt) => rt.id == id);
    if (i == -1) throw StateError('Тип номера $id не найден');

    if (soft) {
      _roomTypes[i] = _roomTypes[i].copyWith(deletedAt: DateTime.now());
    } else {
      _roomTypes.removeAt(i);
    }
    _persist();
  }

  @override
  void restore(String id) {
    final i = _roomTypes.indexWhere((rt) => rt.id == id);
    if (i == -1) throw StateError('Тип номера $id не найден');
    _roomTypes[i] = _roomTypes[i].copyWith(clearDeletedAt: true);
    _persist();
  }

  @override
  int countRoomsByTypeId(String typeId) {
    // ← String
    // Заглушка - реализуем при интеграции
    return 0;
  }
}
