class Floor {
  final String id;
  final int number;
  final int roomCount;
  final DateTime? deletedAt;

  const Floor({
    required this.id,
    required this.number,
    required this.roomCount,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Floor copyWith({
    int? number,
    int? roomCount,
    Object? deletedAt = _unset,
    bool clearDeletedAt = false,
  }) {
    return Floor(
      id: id,
      number: number ?? this.number,
      roomCount: roomCount ?? this.roomCount,
      deletedAt: clearDeletedAt
          ? null
          : (deletedAt == _unset ? this.deletedAt : deletedAt as DateTime?),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'roomCount': roomCount,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Floor.fromJson(Map<String, dynamic> json) => Floor(
    id: json['id'] as String? ?? '', // ← String
    number: json['number'] as int? ?? 0,
    roomCount: json['roomCount'] as int? ?? 0,
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.parse(json['deletedAt'] as String),
  );

  static const _unset = Object();
}
