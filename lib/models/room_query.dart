class RoomQuery {
  final String search;
  final String? roomTypeId;
  final int? floor;
  final int? priceMin;
  final int? priceMax;
  final int? capacity;
  final bool onlyAvailable;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;

  const RoomQuery({
    this.search = '',
    this.roomTypeId,
    this.floor,
    this.priceMin,
    this.priceMax,
    this.capacity,
    this.onlyAvailable = false,
    this.sortField = 'number',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  RoomQuery copyWith({
    String? search,
    Object? roomTypeId = _unset,
    Object? floor = _unset,
    Object? priceMin = _unset,
    Object? priceMax = _unset,
    Object? capacity = _unset,
    bool? onlyAvailable,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return RoomQuery(
      search: search ?? this.search,
      roomTypeId: roomTypeId == _unset
          ? this.roomTypeId
          : roomTypeId as String?, // ← String?
      floor: floor == _unset ? this.floor : floor as int?,
      priceMin: priceMin == _unset ? this.priceMin : priceMin as int?,
      priceMax: priceMax == _unset ? this.priceMax : priceMax as int?,
      capacity: capacity == _unset ? this.capacity : capacity as int?,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  static const _unset = Object();
}
