import '../database/database_helper.dart';
import '../models/player.dart';

class PlayerService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Player>> getAllByTrainer(int trainerId) async {
    final db = await _dbHelper.database;
    
    final results = await db.query(
      'players',
      where: 'trainer_id = ?',
      whereArgs: [trainerId],
      orderBy: 'name ASC',
    );

    return results.map((map) => Player.fromMap(map)).toList();
  }

  Future<Player?> getById(int id) async {
    final db = await _dbHelper.database;
    
    final results = await db.query(
      'players',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) {
      return null;
    }

    return Player.fromMap(results.first);
  }

  Future<Player> create(Player player) async {
    final db = await _dbHelper.database;
    
    final id = await db.insert('players', player.toMap());
    return player.copyWith(id: id);
  }

  Future<void> update(Player player) async {
    final db = await _dbHelper.database;
    
    await db.update(
      'players',
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    
    await db.delete(
      'players',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Player>> search(int trainerId, String query) async {
    final db = await _dbHelper.database;
    
    final results = await db.query(
      'players',
      where: 'trainer_id = ? AND (name LIKE ? OR phone LIKE ? OR email LIKE ?)',
      whereArgs: [trainerId, '%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );

    return results.map((map) => Player.fromMap(map)).toList();
  }

  Future<int> getCount(int trainerId) async {
    final db = await _dbHelper.database;
    
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM players WHERE trainer_id = ?',
      [trainerId],
    );

    return result.first['count'] as int;
  }
}
