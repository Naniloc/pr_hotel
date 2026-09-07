class BookingQuery {
  final String search;
  final String? status;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;

  const BookingQuery({
    this.search = '',
    this.status,
    this.dateFrom,
    this.dateTo,
    this.sortField = 'checkIn',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  BookingQuery copyWith({
    String? search,
    Object? status = _unset,
    Object? dateFrom = _unset,
    Object? dateTo = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return BookingQuery(
      search: search ?? this.search,
      status: status == _unset ? this.status : status as String?,
      dateFrom: dateFrom == _unset ? this.dateFrom : dateFrom as DateTime?,
      dateTo: dateTo == _unset ? this.dateTo : dateTo as DateTime?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  static const _unset = Object();
}
