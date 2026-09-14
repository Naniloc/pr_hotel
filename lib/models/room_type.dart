class RoomType {
  final int id;
  final String name;
  final String description;
  final DateTime? deletedAt;

  const RoomType({
    required this.id,
    required this.name,
    required this.description,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  RoomType copyWith({
    String? name,
    String? description,
    Object? deletedAt = _unset,
    bool clearDeletedAt = false,
  }) {
    return RoomType(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      deletedAt: clearDeletedAt
          ? null
          : (deletedAt == _unset ? this.deletedAt : deletedAt as DateTime?),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory RoomType.fromJson(Map<String, dynamic> json) => RoomType(
    id: json['id'] as int? ?? 0,
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.parse(json['deletedAt'] as String),
  );

  static const _unset = Object();
}
