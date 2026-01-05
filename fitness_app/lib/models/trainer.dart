class Trainer {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final String? phone;
  final DateTime createdAt;

  Trainer({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.phone,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Trainer.fromMap(Map<String, dynamic> map) {
    return Trainer(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      phone: map['phone'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Trainer copyWith({
    int? id,
    String? name,
    String? email,
    String? passwordHash,
    String? phone,
    DateTime? createdAt,
  }) {
    return Trainer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
