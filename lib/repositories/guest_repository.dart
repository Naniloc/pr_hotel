import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/guest.dart';

abstract interface class GuestRepository {
  List<Guest> getAll({bool includeDeleted = false});
  Guest? getById(int id);
  Guest create(Guest guest);
  Guest update(Guest guest);
  void delete(int id, {bool soft = true});
  void restore(int id);
  bool isEmailUnique(String email, {int? excludeId});
}

final List<Guest> _seedGuests = [
  Guest(
    id: 1,
    name: 'Иван Петров',
    email: 'ivan.petrov@example.com',
    phone: '+7 (900) 123-45-67',
  ),
  Guest(
    id: 2,
    name: 'Мария Сидорова',
    email: 'maria.sidorova@example.com',
    phone: '+7 (900) 234-56-78',
  ),
  Guest(
    id: 3,
    name: 'Алексей Иванов',
    email: 'alexey.ivanov@example.com',
    phone: '+7 (900) 345-67-89',
  ),
  Guest(
    id: 4,
    name: 'Елена Смирнова',
    email: 'elena.smirnova@example.com',
    phone: '+7 (900) 456-78-90',
  ),
  Guest(
    id: 5,
    name: 'Дмитрий Кузнецов',
    email: 'dmitry.kuznetsov@example.com',
    phone: '+7 (900) 567-89-01',
  ),
  Guest(
    id: 6,
    name: 'Ольга Морозова',
    email: 'olga.morozova@example.com',
    phone: '+7 (900) 678-90-12',
  ),
  Guest(
    id: 7,
    name: 'Сергей Волков',
    email: 'sergey.volkov@example.com',
    phone: '+7 (900) 789-01-23',
  ),
  Guest(
    id: 8,
    name: 'Анна Соколова',
    email: 'anna.sokolova@example.com',
    phone: '+7 (900) 890-12-34',
  ),
  Guest(
    id: 9,
    name: 'Николай Лебедев',
    email: 'nikolay.lebedev@example.com',
    phone: '+7 (900) 901-23-45',
  ),
  Guest(
    id: 10,
    name: 'Татьяна Козлова',
    email: 'tatyana.kozlova@example.com',
    phone: '+7 (900) 012-34-56',
  ),
];

class InMemoryGuestRepository implements GuestRepository {
  static const _key = 'guests_v1';
  final SharedPreferences? _prefs;

  final List<Guest> _guests = [];
  int _nextId = 11;

  InMemoryGuestRepository([this._prefs]) {
    _restore();
  }

  void _restore() {
    if (_prefs == null) {
      _guests.addAll(_seedGuests);
      return;
    }

    final raw = _prefs.getString(_key);
    if (raw == null) {
      _guests.addAll(_seedGuests);
      _persist();
      return;
    }

    try {
      final list = jsonDecode(raw) as List;
      _guests.addAll(
        list.map((e) => Guest.fromJson(e as Map<String, dynamic>)).toList(),
      );

      if (_guests.isNotEmpty) {
        _nextId = _guests.map((g) => g.id).reduce((a, b) => a > b ? a : b) + 1;
      }
    } catch (e) {
      _guests.addAll(_seedGuests);
      _persist();
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
  Guest? getById(int id) {
    try {
      return _guests.firstWhere((g) => g.id == id && !g.isDeleted);
    } catch (e) {
      return null;
    }
  }

  @override
  Guest create(Guest guest) {
    final newGuest = Guest(
      id: _nextId++,
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
  void delete(int id, {bool soft = true}) {
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
  void restore(int id) {
    final i = _guests.indexWhere((g) => g.id == id);
    if (i == -1) throw StateError('Гость $id не найден');
    _guests[i] = _guests[i].copyWith(clearDeletedAt: true);
    _persist();
  }

  @override
  bool isEmailUnique(String email, {int? excludeId}) {
    return !_guests.any(
      (g) =>
          g.email.toLowerCase() == email.toLowerCase() &&
          g.id != excludeId &&
          !g.isDeleted,
    );
  }
}
