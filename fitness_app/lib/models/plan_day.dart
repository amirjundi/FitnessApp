import 'day_exercise.dart';

class PlanDay {
  final int? id;
  final int planId;
  final int sequenceOrder; // 1, 2, 3...
  final bool isRestDay;
  final String? focusArea;
  final List<DayExercise> exercises;

  PlanDay({
    this.id,
    required this.planId,
    required this.sequenceOrder,
    this.isRestDay = false,
    this.focusArea,
    this.exercises = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plan_id': planId,
      'sequence_order': sequenceOrder,
      'is_rest_day': isRestDay ? 1 : 0,
      'focus_area': focusArea,
    };
  }

  factory PlanDay.fromMap(Map<String, dynamic> map) {
    return PlanDay(
      id: map['id'],
      planId: map['plan_id'],
      sequenceOrder: map['sequence_order'],
      isRestDay: map['is_rest_day'] == 1,
      focusArea: map['focus_area'],
    );
  }

  PlanDay copyWith({
    int? id,
    int? planId,
    int? sequenceOrder,
    bool? isRestDay,
    String? focusArea,
    List<DayExercise>? exercises,
  }) {
    return PlanDay(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      sequenceOrder: sequenceOrder ?? this.sequenceOrder,
      isRestDay: isRestDay ?? this.isRestDay,
      focusArea: focusArea ?? this.focusArea,
      exercises: exercises ?? this.exercises,
    );
  }
}
