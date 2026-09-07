class Room {
  final int id;
  final String number;
  final String type;
  final int floor;
  final int capacity;
  final int pricePerNight;
  final bool isAvailable;
  final DateTime? deletedAt;

  const Room({
    required this.id,
    required this.number,
    required this.type,
    required this.floor,
    required this.capacity,
    required this.pricePerNight,
    this.isAvailable = true,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Room copyWith({
    String? number,
    String? type,
    int? floor,
    int? capacity,
    int? pricePerNight,
    bool? isAvailable,
    Object? deletedAt = _unset,
    bool clearDeletedAt = false,
  }) {
    return Room(
      id: id,
      number: number ?? this.number,
      type: type ?? this.type,
      floor: floor ?? this.floor,
      capacity: capacity ?? this.capacity,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      isAvailable: isAvailable ?? this.isAvailable,
      deletedAt: clearDeletedAt
          ? null
          : (deletedAt == _unset ? this.deletedAt : deletedAt as DateTime?),
    );
  }

  static const _unset = Object();
}
