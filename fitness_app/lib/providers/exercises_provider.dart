import 'package:flutter/foundation.dart';
import '../models/exercise.dart';
import '../services/exercise_service.dart';

class ExercisesProvider with ChangeNotifier {
  final ExerciseService _exerciseService = ExerciseService();
  List<Exercise> _exercises = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedMuscleGroup;

  List<Exercise> get exercises => _selectedMuscleGroup == null
      ? _exercises
      : _exercises.where((e) => e.muscleGroup == _selectedMuscleGroup).toList();
  
  List<Exercise> get allExercises => _exercises;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _exercises.length;
  String? get selectedMuscleGroup => _selectedMuscleGroup;

  Future<void> loadExercises(int trainerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _exercises = await _exerciseService.getExercises(trainerId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setMuscleGroupFilter(String? muscleGroup) {
    _selectedMuscleGroup = muscleGroup;
    notifyListeners();
  }

  Future<Exercise?> createExercise(Exercise exercise) async {
    _error = null;
    
    try {
      final id = await _exerciseService.createExercise(exercise);
      final newExercise = exercise.copyWith(id: id);
      _exercises.add(newExercise);
      _exercises.sort((a, b) {
        final muscleCompare = a.muscleGroup.compareTo(b.muscleGroup);
        if (muscleCompare != 0) return muscleCompare;
        return a.name.compareTo(b.name);
      });
      notifyListeners();
      return newExercise;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateExercise(Exercise exercise) async {
    _error = null;
    
    try {
      final rows = await _exerciseService.updateExercise(exercise);
      if (rows > 0) {
        final index = _exercises.indexWhere((e) => e.id == exercise.id);
        if (index != -1) {
          _exercises[index] = exercise;
          _exercises.sort((a, b) {
            final muscleCompare = a.muscleGroup.compareTo(b.muscleGroup);
            if (muscleCompare != 0) return muscleCompare;
            return a.name.compareTo(b.name);
          });
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExercise(int id) async {
    _error = null;
    
    try {
      await _exerciseService.deleteExercise(id);
      _exercises.removeWhere((e) => e.id == id);
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
      await loadExercises(trainerId);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Use getExercises with query param
      _exercises = await _exerciseService.getExercises(trainerId, query: query);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Exercise? getById(int id) {
    try {
      return _exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  List<String> get muscleGroups {
    final groups = _exercises.map((e) => e.muscleGroup).toSet().toList();
    groups.sort();
    return groups;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
