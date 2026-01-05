import '../database/database_helper.dart';
import '../models/subscription.dart';

class SubscriptionService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Subscription>> getAllByTrainer(int trainerId) async {
    final db = await _dbHelper.database;
    
    final results = await db.rawQuery('''
      SELECT s.* FROM subscriptions s
      INNER JOIN players p ON s.player_id = p.id
      WHERE p.trainer_id = ?
      ORDER BY s.end_date ASC
    ''', [trainerId]);

    return results.map((map) => Subscription.fromMap(map)).toList();
  }

  Future<List<Subscription>> getByPlayer(int playerId) async {
    final db = await _dbHelper.database;
    
    final results = await db.query(
      'subscriptions',
      where: 'player_id = ?',
      whereArgs: [playerId],
      orderBy: 'start_date DESC',
    );

    return results.map((map) => Subscription.fromMap(map)).toList();
  }

  Future<Subscription?> getActiveByPlayer(int playerId) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    
    final results = await db.query(
      'subscriptions',
      where: 'player_id = ? AND status = ? AND start_date <= ? AND end_date >= ?',
      whereArgs: [playerId, Subscription.statusActive, now, now],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return Subscription.fromMap(results.first);
  }

  Future<Subscription?> getById(int id) async {
    final db = await _dbHelper.database;
    
    final results = await db.query(
      'subscriptions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) {
      return null;
    }

    return Subscription.fromMap(results.first);
  }

  Future<Subscription> create(Subscription subscription) async {
    final db = await _dbHelper.database;
    
    final id = await db.insert('subscriptions', subscription.toMap());
    return subscription.copyWith(id: id);
  }

  Future<void> update(Subscription subscription) async {
    final db = await _dbHelper.database;
    
    await db.update(
      'subscriptions',
      subscription.toMap(),
      where: 'id = ?',
      whereArgs: [subscription.id],
    );
  }

  Future<void> cancel(int id) async {
    final db = await _dbHelper.database;
    
    await db.update(
      'subscriptions',
      {'status': Subscription.statusCancelled},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    
    await db.delete(
      'subscriptions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Subscription>> getExpiringSoon(int trainerId, {int days = 7}) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days)).toIso8601String();
    
    final results = await db.rawQuery('''
      SELECT s.* FROM subscriptions s
      INNER JOIN players p ON s.player_id = p.id
      WHERE p.trainer_id = ? 
        AND s.status = ?
        AND s.end_date >= ?
        AND s.end_date <= ?
      ORDER BY s.end_date ASC
    ''', [trainerId, Subscription.statusActive, now.toIso8601String(), futureDate]);

    return results.map((map) => Subscription.fromMap(map)).toList();
  }

  Future<int> getActiveCount(int trainerId) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM subscriptions s
      INNER JOIN players p ON s.player_id = p.id
      WHERE p.trainer_id = ? 
        AND s.status = ?
        AND s.start_date <= ?
        AND s.end_date >= ?
    ''', [trainerId, Subscription.statusActive, now, now]);

    return result.first['count'] as int;
  }

  Future<void> updateExpiredSubscriptions() async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    
    await db.update(
      'subscriptions',
      {'status': Subscription.statusExpired},
      where: 'status = ? AND end_date < ?',
      whereArgs: [Subscription.statusActive, now],
    );
  }
}
