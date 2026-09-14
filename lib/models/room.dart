class Room {
  final int id;
  final String number;
  final int floorId;
  final int roomTypeId;
  final int capacity;
  final int pricePerNight;
  final bool isAvailable;
  final DateTime? deletedAt;

  const Room({
    required this.id,
    required this.number,
    required this.floorId,
    required this.roomTypeId,
    required this.capacity,
    required this.pricePerNight,
    this.isAvailable = true,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Room copyWith({
    String? number,
    int? floorId,
    int? roomTypeId,
    int? capacity,
    int? pricePerNight,
    bool? isAvailable,
    Object? deletedAt = _unset,
    bool clearDeletedAt = false,
  }) {
    return Room(
      id: id,
      number: number ?? this.number,
      floorId: floorId ?? this.floorId,
      roomTypeId: roomTypeId ?? this.roomTypeId,
      capacity: capacity ?? this.capacity,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      isAvailable: isAvailable ?? this.isAvailable,
      deletedAt: clearDeletedAt
          ? null
          : (deletedAt == _unset ? this.deletedAt : deletedAt as DateTime?),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'floorId': floorId,
    'roomTypeId': roomTypeId,
    'capacity': capacity,
    'pricePerNight': pricePerNight,
    'isAvailable': isAvailable,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json['id'] as int? ?? 0,
    number: json['number'] as String? ?? '',
    floorId: json['floorId'] as int? ?? 0,
    roomTypeId: json['roomTypeId'] as int? ?? 0,
    capacity: json['capacity'] as int? ?? 0,
    pricePerNight: json['pricePerNight'] as int? ?? 0,
    isAvailable: json['isAvailable'] as bool? ?? true,
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.parse(json['deletedAt'] as String),
  );

  static const _unset = Object();
}
