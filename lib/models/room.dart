import 'floor.dart';
import 'room_type.dart';

class Room {
  final String id;
  final String number;
  final String floorId;
  final String roomTypeId;
  final Floor? floor; // ← добавьте
  final RoomType? roomType; // ← добавьте
  final int capacity;
  final int pricePerNight;
  final bool isAvailable;
  final DateTime? deletedAt;

  const Room({
    required this.id,
    required this.number,
    required this.floorId,
    required this.roomTypeId,
    this.floor, // ← добавьте
    this.roomType, // ← добавьте
    required this.capacity,
    required this.pricePerNight,
    this.isAvailable = true,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Room copyWith({
    String? number,
    String? floorId,
    String? roomTypeId,
    Floor? floor,
    RoomType? roomType,
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
      floor: floor ?? this.floor,
      roomType: roomType ?? this.roomType,
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

  factory Room.fromJson(Map<String, dynamic> json) {
    // Разбор expand
    final expandData = json['expand'] as Map<String, dynamic>?;
    Floor? floor;
    RoomType? roomType;

    if (expandData != null) {
      final floorData = expandData['floorId'];
      final roomTypeData = expandData['roomTypeId'];

      if (floorData is Map<String, dynamic>) {
        floor = Floor.fromJson(floorData);
      }
      if (roomTypeData is Map<String, dynamic>) {
        roomType = RoomType.fromJson(roomTypeData);
      }
    }

    return Room(
      id: json['id'] as String? ?? '',
      number: json['number'] as String? ?? '',
      floorId: json['floorId'] as String? ?? '',
      roomTypeId: json['roomTypeId'] as String? ?? '',
      floor: floor,
      roomType: roomType,
      capacity: json['capacity'] as int? ?? 0,
      pricePerNight: json['pricePerNight'] as int? ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? true,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );
  }

  static const _unset = Object();
}
