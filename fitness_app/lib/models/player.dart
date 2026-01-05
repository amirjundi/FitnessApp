class Player {
  final int? id;
  final int trainerId;
  final String name;
  final String? phone;
  final String? email;
  final String? notes;
  final double? weight; // kg
  final double? height; // cm
  final DateTime createdAt;

  Player({
    this.id,
    required this.trainerId,
    required this.name,
    this.phone,
    this.email,
    this.notes,
    this.weight,
    this.height,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trainer_id': trainerId,
      'name': name,
      'phone': phone,
      'email': email,
      'notes': notes,
      'weight': weight,
      'height': height,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as int?,
      trainerId: map['trainer_id'] as int,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      notes: map['notes'] as String?,
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      height: map['height'] != null ? (map['height'] as num).toDouble() : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Player copyWith({
    int? id,
    int? trainerId,
    String? name,
    String? phone,
    String? email,
    String? notes,
    double? weight,
    double? height,
    DateTime? createdAt,
  }) {
    return Player(
      id: id ?? this.id,
      trainerId: trainerId ?? this.trainerId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
