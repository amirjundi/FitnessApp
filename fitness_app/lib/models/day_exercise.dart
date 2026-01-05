import 'dart:convert';

class SetGoal {
  final int reps;
  final double? weight; // Optional target weight

  SetGoal({required this.reps, this.weight});

  Map<String, dynamic> toJson() => {
        'reps': reps,
        if (weight != null) 'weight': weight,
      };

  factory SetGoal.fromJson(Map<String, dynamic> json) {
    return SetGoal(
      reps: json['reps'] as int,
      weight: (json['weight'] as num?)?.toDouble(),
    );
  }
}

class DayExercise {
  final int? id;
  final int dayId;
  final int exerciseId;
  final int orderIndex;
  final String? notes;
  final List<SetGoal> sets; // List of specific set goals

  // Joined fields
  final String? exerciseName;
  final String? muscleGroup;
  final String? youtubeUrl;

  DayExercise({
    this.id,
    required this.dayId,
    required this.exerciseId,
    required this.orderIndex,
    this.notes,
    required this.sets,
    this.exerciseName,
    this.muscleGroup,
    this.youtubeUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day_id': dayId,
      'exercise_id': exerciseId,
      'order_index': orderIndex,
      'notes': notes,
      'set_goals_json': jsonEncode(sets.map((s) => s.toJson()).toList()),
    };
  }

  factory DayExercise.fromMap(Map<String, dynamic> map) {
    List<SetGoal> parsedSets = [];
    if (map['set_goals_json'] != null) {
      try {
        final List<dynamic> decoded = jsonDecode(map['set_goals_json']);
        parsedSets = decoded.map((e) => SetGoal.fromJson(e)).toList();
      } catch (e) {
        // Fallback for old data or errors
        parsedSets = [];
      }
    } else if (map['sets'] != null && map['reps'] != null) {
      // Legacy support if needed during migration, though we are dropping tables
      int count = map['sets'] as int;
      int reps = map['reps'] as int;
      parsedSets = List.generate(count, (_) => SetGoal(reps: reps));
    }

    return DayExercise(
      id: map['id'],
      dayId: map['day_id'],
      exerciseId: map['exercise_id'],
      orderIndex: map['order_index'],
      notes: map['notes'],
      sets: parsedSets,
      exerciseName: map['exercise_name'],
      muscleGroup: map['muscle_group'],
      youtubeUrl: map['youtube_url'],
    );
  }

  DayExercise copyWith({
    int? id,
    int? dayId,
    int? exerciseId,
    int? orderIndex,
    String? notes,
    List<SetGoal>? sets,
  }) {
    return DayExercise(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      exerciseId: exerciseId ?? this.exerciseId,
      orderIndex: orderIndex ?? this.orderIndex,
      notes: notes ?? this.notes,
      sets: sets ?? this.sets,
      exerciseName: exerciseName,
      muscleGroup: muscleGroup,
      youtubeUrl: youtubeUrl,
    );
  }
}
