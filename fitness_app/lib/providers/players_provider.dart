import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../services/player_service.dart';

class PlayersProvider with ChangeNotifier {
  final PlayerService _playerService = PlayerService();
  List<Player> _players = [];
  bool _isLoading = false;
  String? _error;

  List<Player> get players => _players;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _players.length;

  Future<void> loadPlayers(int trainerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _players = await _playerService.getAllByTrainer(trainerId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Player?> createPlayer(Player player) async {
    _error = null;
    
    try {
      final newPlayer = await _playerService.create(player);
      _players.add(newPlayer);
      _players.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
      return newPlayer;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updatePlayer(Player player) async {
    _error = null;
    
    try {
      await _playerService.update(player);
      final index = _players.indexWhere((p) => p.id == player.id);
      if (index != -1) {
        _players[index] = player;
        _players.sort((a, b) => a.name.compareTo(b.name));
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePlayer(int id) async {
    _error = null;
    
    try {
      await _playerService.delete(id);
      _players.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> search(int trainerId, String query) async {
    if (query.isEmpty) {
      await loadPlayers(trainerId);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _players = await _playerService.search(trainerId, query);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Player? getById(int id) {
    try {
      return _players.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
