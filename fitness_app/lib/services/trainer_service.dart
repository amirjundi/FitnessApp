import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../database/database_helper.dart';
import '../models/trainer.dart';

class TrainerService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Trainer?> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final db = await _dbHelper.database;
    
    // Check if email already exists
    final existing = await db.query(
      'trainers',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    
    if (existing.isNotEmpty) {
      throw Exception('Email already registered');
    }

    final trainer = Trainer(
      name: name,
      email: email.toLowerCase(),
      passwordHash: _hashPassword(password),
      phone: phone,
    );

    final id = await db.insert('trainers', trainer.toMap());
    return trainer.copyWith(id: id);
  }

  Future<Trainer?> login({
    required String email,
    required String password,
  }) async {
    final db = await _dbHelper.database;
    
    final results = await db.query(
      'trainers',
      where: 'email = ? AND password_hash = ?',
      whereArgs: [email.toLowerCase(), _hashPassword(password)],
    );

    if (results.isEmpty) {
      return null;
    }

    return Trainer.fromMap(results.first);
  }

  Future<Trainer?> getById(int id) async {
    final db = await _dbHelper.database;
    
    final results = await db.query(
      'trainers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) {
      return null;
    }

    return Trainer.fromMap(results.first);
  }

  Future<void> update(Trainer trainer) async {
    final db = await _dbHelper.database;
    
    await db.update(
      'trainers',
      trainer.toMap(),
      where: 'id = ?',
      whereArgs: [trainer.id],
    );
  }

  Future<void> updatePassword(int trainerId, String newPassword) async {
    final db = await _dbHelper.database;
    
    await db.update(
      'trainers',
      {'password_hash': _hashPassword(newPassword)},
      where: 'id = ?',
      whereArgs: [trainerId],
    );
  }
}
