import 'package:flutter/foundation.dart';

import '../models/room.dart';
import '../models/room_query.dart';
import '../models/page_result.dart';
import '../repositories/room_repository.dart';

enum LoadStatus { idle, loading, success, error }

class RoomListNotifier extends ChangeNotifier {
  final RoomRepository _repository;

  RoomListNotifier(this._repository);

  RoomQuery _query = const RoomQuery();
  PageResult<Room> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};

  RoomQuery get query => _query;

  PageResult<Room> get result => _result;

  LoadStatus get status => _status;

  String? get error => _error;

  Set<int> get selected => Set.unmodifiable(_selected);

  bool get hasSelection => _selected.isNotEmpty;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _result = await _repository.find(_query);
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить номера: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> applyQuery(RoomQuery next) async {
    _query = next;
    _selected.clear();
    await load();
  }

  void toggleSelection(int id) {
    _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    await _repository.deleteMany(_selected.toList());
    _selected.clear();
    await load();
  }
}
