import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/workout_plan.dart';
import '../models/plan_day.dart';
import '../models/day_exercise.dart';

class WorkoutPlanService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // --- Plans ---

  Future<int> createPlan(WorkoutPlan plan) async {
    final db = await _dbHelper.database;
    return await db.insert('workout_plans', plan.toMap());
  }

  Future<List<WorkoutPlan>> getPlans(int trainerId, {String? query}) async {
    final db = await _dbHelper.database;
    String sql = 'SELECT * FROM workout_plans WHERE trainer_id = ? AND is_active = 1';
    List<dynamic> args = [trainerId];

    if (query != null && query.isNotEmpty) {
      sql += ' AND name LIKE ?';
      args.add('%$query%');
    }

    sql += ' ORDER BY created_at DESC';

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, args);
    return maps.map((e) => WorkoutPlan.fromMap(e)).toList();
  }

  Future<WorkoutPlan?> getPlanById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_plans',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return WorkoutPlan.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updatePlan(WorkoutPlan plan) async {
    final db = await _dbHelper.database;
    await db.update(
      'workout_plans',
      plan.toMap(),
      where: 'id = ?',
      whereArgs: [plan.id],
    );
  }

  Future<void> deletePlan(int id) async {
    final db = await _dbHelper.database;
    // Soft delete usually, but here we might do hard delete or soft.
    // Schema has 'is_active', so soft delete.
    await db.update(
      'workout_plans',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Days ---

  Future<List<PlanDay>> getPlanDays(int planId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'plan_days',
      where: 'plan_id = ?',
      whereArgs: [planId],
      orderBy: 'sequence_order ASC',
    );
    return maps.map((e) => PlanDay.fromMap(e)).toList();
  }

  Future<int> addDay(PlanDay day) async {
    final db = await _dbHelper.database;
    return await db.insert('plan_days', day.toMap());
  }

  Future<void> updateDay(PlanDay day) async {
    final db = await _dbHelper.database;
    await db.update(
      'plan_days',
      day.toMap(),
      where: 'id = ?',
      whereArgs: [day.id],
    );
  }

  Future<void> deleteDay(int dayId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'plan_days',
      where: 'id = ?',
      whereArgs: [dayId],
    );
    // TODO: Reorder remaining days? For now let's leave gaps or handle in logic
  }

  Future<void> reorderDays(List<PlanDay> days) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (int i = 0; i < days.length; i++) {
        batch.update(
          'plan_days',
          {'sequence_order': i + 1}, // 1-based index
          where: 'id = ?',
          whereArgs: [days[i].id],
        );
    }
    await batch.commit(noResult: true);
  }

  // --- Day Exercises ---

  Future<List<DayExercise>> getDayExercises(int dayId) async {
    final db = await _dbHelper.database;
    // Join with exercises table to get details
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT de.*, e.name as exercise_name, e.muscle_group, e.youtube_url 
      FROM day_exercises de
      INNER JOIN exercises e ON de.exercise_id = e.id
      WHERE de.day_id = ?
      ORDER BY de.order_index ASC
    ''', [dayId]);

    return maps.map((e) => DayExercise.fromMap(e)).toList();
  }

  Future<int> addExerciseToDay(DayExercise exercise) async {
    final db = await _dbHelper.database;
    return await db.insert('day_exercises', exercise.toMap());
  }

  Future<void> updateDayExercise(DayExercise exercise) async {
    final db = await _dbHelper.database;
    await db.update(
      'day_exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<void> deleteDayExercise(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'day_exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> reorderExercises(List<DayExercise> exercises) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (int i = 0; i < exercises.length; i++) {
      batch.update(
        'day_exercises',
        {'order_index': i},
        where: 'id = ?',
        whereArgs: [exercises[i].id],
      );
    }
    await batch.commit(noResult: true);
  }
}
