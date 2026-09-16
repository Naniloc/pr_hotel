class GuestCard {
  final String id;
  final String guestId;
  final String passportNumber;
  final String passportIssuedBy;
  final DateTime passportIssuedDate;
  final DateTime? deletedAt;

  const GuestCard({
    required this.id,
    required this.guestId,
    required this.passportNumber,
    required this.passportIssuedBy,
    required this.passportIssuedDate,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  GuestCard copyWith({
    String? guestId, // ← String
    String? passportNumber,
    String? passportIssuedBy,
    DateTime? passportIssuedDate,
    Object? deletedAt = _unset,
    bool clearDeletedAt = false,
  }) {
    return GuestCard(
      id: id,
      guestId: guestId ?? this.guestId,
      passportNumber: passportNumber ?? this.passportNumber,
      passportIssuedBy: passportIssuedBy ?? this.passportIssuedBy,
      passportIssuedDate: passportIssuedDate ?? this.passportIssuedDate,
      deletedAt: clearDeletedAt
          ? null
          : (deletedAt == _unset ? this.deletedAt : deletedAt as DateTime?),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'guestId': guestId,
    'passportNumber': passportNumber,
    'passportIssuedBy': passportIssuedBy,
    'passportIssuedDate': passportIssuedDate.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory GuestCard.fromJson(Map<String, dynamic> json) => GuestCard(
    id: json['id'] as String? ?? '', // ← String
    guestId: json['guestId'] as String? ?? '', // ← String
    passportNumber: json['passportNumber'] as String? ?? '',
    passportIssuedBy: json['passportIssuedBy'] as String? ?? '',
    passportIssuedDate: json['passportIssuedDate'] == null
        ? DateTime.now()
        : DateTime.parse(json['passportIssuedDate'] as String),
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.parse(json['deletedAt'] as String),
  );

  static const _unset = Object();
}
