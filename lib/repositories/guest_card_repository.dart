import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/guest_card.dart';

abstract interface class GuestCardRepository {
  List<GuestCard> getAll({bool includeDeleted = false});
  GuestCard? getById(int id);
  GuestCard? getByGuestId(int guestId);
  GuestCard create(GuestCard card);
  GuestCard update(GuestCard card);
  void delete(int id, {bool soft = true});
  void restore(int id);
}

final List<GuestCard> _seedGuestCards = [
  GuestCard(
    id: 1,
    guestId: 1,
    passportNumber: '4510 123456',
    passportIssuedBy: 'УФМС России по г. Москве',
    passportIssuedDate: DateTime(2015, 3, 15),
  ),
  GuestCard(
    id: 2,
    guestId: 2,
    passportNumber: '4511 234567',
    passportIssuedBy: 'УФМС России по г. Санкт-Петербургу',
    passportIssuedDate: DateTime(2016, 7, 22),
  ),
  GuestCard(
    id: 3,
    guestId: 3,
    passportNumber: '4512 345678',
    passportIssuedBy: 'УФМС России по Московской области',
    passportIssuedDate: DateTime(2017, 11, 8),
  ),
  GuestCard(
    id: 4,
    guestId: 4,
    passportNumber: '4513 456789',
    passportIssuedBy: 'УФМС России по г. Казани',
    passportIssuedDate: DateTime(2018, 5, 19),
  ),
  GuestCard(
    id: 5,
    guestId: 5,
    passportNumber: '4514 567890',
    passportIssuedBy: 'УФМС России по г. Екатеринбургу',
    passportIssuedDate: DateTime(2019, 9, 30),
  ),
];

class InMemoryGuestCardRepository implements GuestCardRepository {
  static const _key = 'guest_cards_v1';
  final SharedPreferences? _prefs;

  final List<GuestCard> _cards = [];
  int _nextId = 6;

  InMemoryGuestCardRepository([this._prefs]) {
    _restore();
  }

  void _restore() {
    if (_prefs == null) {
      _cards.addAll(_seedGuestCards);
      return;
    }

    final raw = _prefs.getString(_key);
    if (raw == null) {
      _cards.addAll(_seedGuestCards);
      _persist();
      return;
    }

    try {
      final list = jsonDecode(raw) as List;
      _cards.addAll(
        list.map((e) => GuestCard.fromJson(e as Map<String, dynamic>)).toList(),
      );

      if (_cards.isNotEmpty) {
        _nextId = _cards.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
      }
    } catch (e) {
      _cards.addAll(_seedGuestCards);
      _persist();
    }
  }

  void _persist() {
    final prefs = _prefs;
    if (prefs == null) return;

    prefs.setString(_key, jsonEncode(_cards.map((c) => c.toJson()).toList()));
  }

  @override
  List<GuestCard> getAll({bool includeDeleted = false}) {
    return _cards.where((c) => includeDeleted || !c.isDeleted).toList();
  }

  @override
  GuestCard? getById(int id) {
    try {
      return _cards.firstWhere((c) => c.id == id && !c.isDeleted);
    } catch (e) {
      return null;
    }
  }

  @override
  GuestCard? getByGuestId(int guestId) {
    try {
      return _cards.firstWhere((c) => c.guestId == guestId && !c.isDeleted);
    } catch (e) {
      return null;
    }
  }

  @override
  GuestCard create(GuestCard card) {
    final newCard = GuestCard(
      id: _nextId++,
      guestId: card.guestId,
      passportNumber: card.passportNumber,
      passportIssuedBy: card.passportIssuedBy,
      passportIssuedDate: card.passportIssuedDate,
    );
    _cards.add(newCard);
    _persist();
    return newCard;
  }

  @override
  GuestCard update(GuestCard card) {
    final i = _cards.indexWhere((c) => c.id == card.id);
    if (i == -1) throw StateError('Карточка ${card.id} не найдена');
    _cards[i] = card;
    _persist();
    return card;
  }

  @override
  void delete(int id, {bool soft = true}) {
    final i = _cards.indexWhere((c) => c.id == id);
    if (i == -1) throw StateError('Карточка $id не найдена');

    if (soft) {
      _cards[i] = _cards[i].copyWith(deletedAt: DateTime.now());
    } else {
      _cards.removeAt(i);
    }
    _persist();
  }

  @override
  void restore(int id) {
    final i = _cards.indexWhere((c) => c.id == id);
    if (i == -1) throw StateError('Карточка $id не найдена');
    _cards[i] = _cards[i].copyWith(clearDeletedAt: true);
    _persist();
  }
}
