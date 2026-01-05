import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/exercise.dart';

class ExerciseService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> createExercise(Exercise exercise) async {
    final db = await _dbHelper.database;
    return await db.insert('exercises', exercise.toMap());
  }

  Future<List<Exercise>> getExercises(int trainerId, {
    String? query, 
    String? muscleGroup,
  }) async {
    final db = await _dbHelper.database;
    
    String sql = 'SELECT * FROM exercises WHERE trainer_id = ?';
    List<dynamic> args = [trainerId];

    if (muscleGroup != null && muscleGroup.isNotEmpty && muscleGroup != 'All') {
      sql += ' AND muscle_group = ?';
      args.add(muscleGroup);
    }

    if (query != null && query.isNotEmpty) {
      sql += ' AND name LIKE ?';
      args.add('%$query%');
    }

    sql += ' ORDER BY name ASC';

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, args);
    return maps.map((e) => Exercise.fromMap(e)).toList();
  }

  Future<Exercise?> getExerciseById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Exercise.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateExercise(Exercise exercise) async {
    final db = await _dbHelper.database;
    return await db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<int> deleteExercise(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
