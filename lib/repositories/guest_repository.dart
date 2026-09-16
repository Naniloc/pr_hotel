import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/guest.dart';

abstract interface class GuestRepository {
  List<Guest> getAll({bool includeDeleted = false});
  Guest? getById(String id); // ← String
  Guest create(Guest guest);
  Guest update(Guest guest);
  void delete(String id, {bool soft = true}); // ← String
  void restore(String id); // ← String
  bool isEmailUnique(String email, {String? excludeId}); // ← String?
}

class InMemoryGuestRepository implements GuestRepository {
  static const _key = 'guests_v1';
  final SharedPreferences? _prefs;

  final List<Guest> _guests = [];
  int _nextId = 1;

  InMemoryGuestRepository([this._prefs]) {
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
      _guests.addAll(
        list.map((e) => Guest.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      // Если не удалось загрузить - оставляем пустым
    }
  }

  void _persist() {
    final prefs = _prefs;
    if (prefs == null) return;

    prefs.setString(_key, jsonEncode(_guests.map((g) => g.toJson()).toList()));
  }

  @override
  List<Guest> getAll({bool includeDeleted = false}) {
    return _guests.where((g) => includeDeleted || !g.isDeleted).toList();
  }

  @override
  Guest? getById(String id) {
    // ← String
    try {
      return _guests.firstWhere((g) => g.id == id && !g.isDeleted);
    } catch (e) {
      return null;
    }
  }

  @override
  Guest create(Guest guest) {
    final newGuest = Guest(
      id: 'temp_guest_${_nextId++}', // ← String
      name: guest.name,
      email: guest.email,
      phone: guest.phone,
    );
    _guests.add(newGuest);
    _persist();
    return newGuest;
  }

  @override
  Guest update(Guest guest) {
    final i = _guests.indexWhere((g) => g.id == guest.id);
    if (i == -1) throw StateError('Гость ${guest.id} не найден');
    _guests[i] = guest;
    _persist();
    return guest;
  }

  @override
  void delete(String id, {bool soft = true}) {
    // ← String
    final i = _guests.indexWhere((g) => g.id == id);
    if (i == -1) throw StateError('Гость $id не найден');

    if (soft) {
      _guests[i] = _guests[i].copyWith(deletedAt: DateTime.now());
    } else {
      _guests.removeAt(i);
    }
    _persist();
  }

  @override
  void restore(String id) {
    // ← String
    final i = _guests.indexWhere((g) => g.id == id);
    if (i == -1) throw StateError('Гость $id не найден');
    _guests[i] = _guests[i].copyWith(clearDeletedAt: true);
    _persist();
  }

  @override
  bool isEmailUnique(String email, {String? excludeId}) {
    // ← String?
    return !_guests.any(
      (g) =>
          g.email.toLowerCase() == email.toLowerCase() &&
          g.id != excludeId &&
          !g.isDeleted,
    );
  }
}
