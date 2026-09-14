import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/room_type.dart';

abstract interface class RoomTypeRepository {
  List<RoomType> getAll({bool includeDeleted = false});
  RoomType? getById(int id);
  RoomType create(RoomType roomType);
  RoomType update(RoomType roomType);
  void delete(int id, {bool soft = true});
  void restore(int id);
  int countRoomsByTypeId(int typeId);
}

const List<RoomType> _seedRoomTypes = [
  RoomType(
    id: 1,
    name: 'Стандарт',
    description: 'Одноместный или двухместный номер с базовыми удобствами',
  ),
  RoomType(
    id: 2,
    name: 'Твин',
    description: 'Номер с двумя раздельными кроватями',
  ),
  RoomType(
    id: 3,
    name: 'Люкс',
    description: 'Улучшенный номер с гостиной зоной',
  ),
  RoomType(
    id: 4,
    name: 'Семейный',
    description: 'Просторный номер для семьи с детьми',
  ),
  RoomType(
    id: 5,
    name: 'Апартаменты',
    description: 'Номер с отдельной кухней и несколькими комнатами',
  ),
];

class InMemoryRoomTypeRepository implements RoomTypeRepository {
  static const _key = 'room_types_v1';
  final SharedPreferences? _prefs;

  final List<RoomType> _roomTypes = [];
  int _nextId = 6;

  InMemoryRoomTypeRepository([this._prefs]) {
    _restore();
  }

  void _restore() {
    if (_prefs == null) {
      _roomTypes.addAll(_seedRoomTypes);
      return;
    }

    final raw = _prefs.getString(_key);
    if (raw == null) {
      _roomTypes.addAll(_seedRoomTypes);
      _persist();
      return;
    }

    try {
      final list = jsonDecode(raw) as List;
      _roomTypes.addAll(
        list.map((e) => RoomType.fromJson(e as Map<String, dynamic>)).toList(),
      );

      if (_roomTypes.isNotEmpty) {
        _nextId =
            _roomTypes.map((rt) => rt.id).reduce((a, b) => a > b ? a : b) + 1;
      }
    } catch (e) {
      _roomTypes.addAll(_seedRoomTypes);
      _persist();
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
  RoomType? getById(int id) {
    try {
      return _roomTypes.firstWhere((rt) => rt.id == id && !rt.isDeleted);
    } catch (e) {
      return null;
    }
  }

  @override
  RoomType create(RoomType roomType) {
    final newRoomType = RoomType(
      id: _nextId++,
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
  void delete(int id, {bool soft = true}) {
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
  void restore(int id) {
    final i = _roomTypes.indexWhere((rt) => rt.id == id);
    if (i == -1) throw StateError('Тип номера $id не найден');
    _roomTypes[i] = _roomTypes[i].copyWith(clearDeletedAt: true);
    _persist();
  }

  @override
  int countRoomsByTypeId(int typeId) {
    // Заглушка - реализуем при интеграции
    return 0;
  }
}
