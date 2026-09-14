class Guest {
  final int id;
  final String name;
  final String email;
  final String phone;
  final DateTime? deletedAt;

  const Guest({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Guest copyWith({
    String? name,
    String? email,
    String? phone,
    Object? deletedAt = _unset,
    bool clearDeletedAt = false,
  }) {
    return Guest(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      deletedAt: clearDeletedAt
          ? null
          : (deletedAt == _unset ? this.deletedAt : deletedAt as DateTime?),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Guest.fromJson(Map<String, dynamic> json) => Guest(
    id: json['id'] as int? ?? 0,
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.parse(json['deletedAt'] as String),
  );

  static const _unset = Object();
}
