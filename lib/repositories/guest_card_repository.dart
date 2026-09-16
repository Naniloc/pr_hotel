import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/guest_card.dart';

abstract interface class GuestCardRepository {
  List<GuestCard> getAll({bool includeDeleted = false});
  GuestCard? getById(String id); // ← String
  GuestCard? getByGuestId(String guestId); // ← String
  GuestCard create(GuestCard card);
  GuestCard update(GuestCard card);
  void delete(String id, {bool soft = true}); // ← String
  void restore(String id); // ← String
}

class InMemoryGuestCardRepository implements GuestCardRepository {
  static const _key = 'guest_cards_v1';
  final SharedPreferences? _prefs;

  final List<GuestCard> _cards = [];
  int _nextId = 1;

  InMemoryGuestCardRepository([this._prefs]) {
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
      _cards.addAll(
        list.map((e) => GuestCard.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      // Если не удалось загрузить - оставляем пустым
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
  GuestCard? getById(String id) {
    // ← String
    try {
      return _cards.firstWhere((c) => c.id == id && !c.isDeleted);
    } catch (e) {
      return null;
    }
  }

  @override
  GuestCard? getByGuestId(String guestId) {
    // ← String
    try {
      return _cards.firstWhere((c) => c.guestId == guestId && !c.isDeleted);
    } catch (e) {
      return null;
    }
  }

  @override
  GuestCard create(GuestCard card) {
    final newCard = GuestCard(
      id: 'temp_card_${_nextId++}', // ← String
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
  void delete(String id, {bool soft = true}) {
    // ← String
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
  void restore(String id) {
    // ← String
    final i = _cards.indexWhere((c) => c.id == id);
    if (i == -1) throw StateError('Карточка $id не найдена');
    _cards[i] = _cards[i].copyWith(clearDeletedAt: true);
    _persist();
  }
}
