import 'plan_day.dart';

class WorkoutPlan {
  final int? id;
  final int trainerId;
  final String name;
  final String description;
  final String difficultyLevel;
  final bool isActive;
  final DateTime createdAt;
  final List<PlanDay> days;

  WorkoutPlan({
    this.id,
    required this.trainerId,
    required this.name,
    required this.description,
    required this.difficultyLevel,
    this.isActive = true,
    required this.createdAt,
    this.days = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trainer_id': trainerId,
      'name': name,
      'description': description,
      'difficulty_level': difficultyLevel,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WorkoutPlan.fromMap(Map<String, dynamic> map) {
    return WorkoutPlan(
      id: map['id'],
      trainerId: map['trainer_id'],
      name: map['name'],
      description: map['description'],
      difficultyLevel: map['difficulty_level'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  WorkoutPlan copyWith({
    int? id,
    int? trainerId,
    String? name,
    String? description,
    String? difficultyLevel,
    bool? isActive,
    DateTime? createdAt,
    List<PlanDay>? days,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      trainerId: trainerId ?? this.trainerId,
      name: name ?? this.name,
      description: description ?? this.description,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      days: days ?? this.days,
    );
  }
}
