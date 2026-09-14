class Booking {
  final int id;
  final int roomId;
  final int guestId;
  final String guestName;
  final DateTime checkIn;
  final DateTime checkOut;
  final String status;
  final DateTime? deletedAt;

  const Booking({
    required this.id,
    required this.roomId,
    required this.guestId,
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
    int? guestId,
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
      guestId: guestId ?? this.guestId,
      guestName: guestName ?? this.guestName,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      deletedAt: clearDeletedAt
          ? null
          : (deletedAt == _unset ? this.deletedAt : deletedAt as DateTime?),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'roomId': roomId,
    'guestId': guestId,
    'guestName': guestName,
    'checkIn': checkIn.toIso8601String(),
    'checkOut': checkOut.toIso8601String(),
    'status': status,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Booking.fromJson(Map<String, dynamic> json) {
    DateTime normalizeDate(String? dateStr, DateTime fallback) {
      if (dateStr == null) return fallback;
      final dt = DateTime.parse(dateStr);
      return DateTime(dt.year, dt.month, dt.day);
    }

    return Booking(
      id: json['id'] as int? ?? 0,
      roomId: json['roomId'] as int? ?? 0,
      guestId: json['guestId'] as int? ?? 0,
      guestName: json['guestName'] as String? ?? '',
      checkIn: normalizeDate(json['checkIn'] as String?, DateTime.now()),
      checkOut: normalizeDate(
        json['checkOut'] as String?,
        DateTime.now().add(const Duration(days: 1)),
      ),
      status: json['status'] as String? ?? 'confirmed',
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );
  }

  static const _unset = Object();
}
