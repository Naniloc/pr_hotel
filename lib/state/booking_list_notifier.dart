import 'package:flutter/foundation.dart';

import '../models/booking.dart';
import '../models/booking_query.dart';
import '../models/page_result.dart';
import '../repositories/booking_repository.dart';

enum LoadStatus { idle, loading, success, error }

class BookingListNotifier extends ChangeNotifier {
  final BookingRepository _repository;

  BookingListNotifier(this._repository);

  BookingQuery _query = const BookingQuery();
  PageResult<Booking> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<String> _selected = {};

  BookingQuery get query => _query;

  PageResult<Booking> get result => _result;

  LoadStatus get status => _status;

  String? get error => _error;

  Set<String> get selected => Set.unmodifiable(_selected); // ← Set<String>

  bool get hasSelection => _selected.isNotEmpty;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _result = await _repository.find(_query);
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить бронирования: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> applyQuery(BookingQuery next) async {
    _query = next;
    _selected.clear();
    await load();
  }

  void toggleSelection(String id) {
    _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    await _repository.deleteMany(_selected.toList());
    _selected.clear();
    await load();
  }
}
