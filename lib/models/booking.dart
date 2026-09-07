class Booking {
  final int id;
  final int roomId;
  final String guestName;
  final DateTime checkIn;
  final DateTime checkOut;
  final String status;
  final DateTime? deletedAt;

  const Booking({
    required this.id,
    required this.roomId,
    required this.guestName,
    required this.checkIn,
    required this.checkOut,
    this.status = 'confirmed',
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  int get nights => checkOut.difference(checkIn).inDays;

  Booking copyWith({
    int? roomId,
    String? guestName,
    DateTime? checkIn,
    DateTime? checkOut,
    String? status,
    Object? deletedAt = _unset,
    bool clearDeletedAt = false,
  }) {
    return Booking(
      id: id,
      roomId: roomId ?? this.roomId,
      guestName: guestName ?? this.guestName,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      deletedAt: clearDeletedAt
          ? null
          : (deletedAt == _unset ? this.deletedAt : deletedAt as DateTime?),
    );
  }

  static const _unset = Object();
}
