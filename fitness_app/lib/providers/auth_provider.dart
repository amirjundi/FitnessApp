import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trainer.dart';
import '../services/trainer_service.dart';
import '../database/database_helper.dart'; // To ensure we can check DB directly if needed

class AuthProvider with ChangeNotifier {
  final TrainerService _trainerService = TrainerService();
  
  Trainer? _currentTrainer;
  bool _isLoading = true; // Start loading immediately
  String? _error;

  Trainer? get currentTrainer => _currentTrainer;
  bool get isAuthenticated => _currentTrainer != null;
  bool get isLoading => _isLoading;
  int? get trainerId => _currentTrainer?.id;
  String? get error => _error;

  // Auto-login logic
  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // For local-only app, we just grab the first trainer from DB
      // or the one we seeded.
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> result = await db.query('trainers', limit: 1);
      
      if (result.isNotEmpty) {
        _currentTrainer = Trainer.fromMap(result.first);
      } else {
        // Technically this shouldn't happen if seed works, but let's handle it
        _error = 'Could not initialize default trainer.';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      // Artificial delay not needed, but ensures UI builds smooth
      _isLoading = false;
      notifyListeners();
    }
  }

  // Deprecated/Unused methods kept empty or simplified
  Future<bool> login(String email, String password) async {
    await checkLoginStatus(); // Just reload
    return isAuthenticated;
  }

  Future<bool> register(String name, String email, String password, String phone) async {
    // Just force create a new one if requested, but UI calls removed
    return true; 
  }

  Future<void> logout() async {
    // No-op for local single user mode really, or maybe splash screen?
    // User requested "Remove login", so maybe logout just restarts app or does nothing.
    // We will just do nothing or reload.
    await checkLoginStatus();
  }
}
