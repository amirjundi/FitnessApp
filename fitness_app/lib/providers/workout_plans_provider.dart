import 'package:flutter/foundation.dart';
import '../models/workout_plan.dart';
import '../models/plan_day.dart';
import '../models/day_exercise.dart';
import '../services/workout_plan_service.dart';

class WorkoutPlansProvider with ChangeNotifier {
  final WorkoutPlanService _service = WorkoutPlanService();
  List<WorkoutPlan> _plans = [];
  WorkoutPlan? _selectedPlan;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<WorkoutPlan> get plans => _plans;
  WorkoutPlan? get selectedPlan => _selectedPlan;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _plans.length;

  void setSearchQuery(String query) {
    _searchQuery = query;
  }

  Future<void> loadPlans(int trainerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _plans = await _service.getPlans(trainerId, query: _searchQuery);
    } catch (e) {
      _error = e.toString();
      print('Error loading plans: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPlanDetails(int planId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _selectedPlan = await _service.getPlanById(planId);
      if (_selectedPlan != null) {
        // Load days and then their exercises
        final days = await _service.getPlanDays(planId);
        final List<PlanDay> daysWithExercises = [];
        
        for (var day in days) {
          final exercises = await _service.getDayExercises(day.id!);
          daysWithExercises.add(day.copyWith(exercises: exercises));
        }

        _selectedPlan = _selectedPlan!.copyWith(days: daysWithExercises);
      }
    } catch (e) {
      _error = e.toString();
      print('Error loading plan details: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPlan(WorkoutPlan plan) async {
    _error = null;
    try {
      await _service.createPlan(plan);
      await loadPlans(plan.trainerId);
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error creating plan: $e');
      return false;
    }
  }

  Future<bool> updatePlan(WorkoutPlan plan) async {
    _error = null;
    try {
      await _service.updatePlan(plan);
      await loadPlans(plan.trainerId);
      // specific reload if selected?
      if (_selectedPlan != null && _selectedPlan!.id == plan.id) {
          await loadPlanDetails(plan.id!);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> deletePlan(int id) async {
    _error = null;
    try {
      await _service.deletePlan(id);
      _plans.removeWhere((p) => p.id == id);
      if (_selectedPlan?.id == id) {
          _selectedPlan = null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // --- Day Management ---

  Future<bool> addDayToPlan(int planId) async {
    _error = null;
    try {
      // Find max sequence locally or fetch? Locally is faster if loaded.
      int maxSeq = 0;
      if (_selectedPlan != null && _selectedPlan!.id == planId) {
         for (var d in _selectedPlan!.days) {
           if (d.sequenceOrder > maxSeq) maxSeq = d.sequenceOrder;
         }
      } else {
         // Fallback if not selected (unlikely for UI flow)
         final days = await _service.getPlanDays(planId);
         for (var d in days) {
            if (d.sequenceOrder > maxSeq) maxSeq = d.sequenceOrder;
         }
      }
      
      final newDay = PlanDay(
        planId: planId,
        sequenceOrder: maxSeq + 1,
        isRestDay: false,
      );
      
      await _service.addDay(newDay);
      await loadPlanDetails(planId); 
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error adding day: $e');
      return false;
    }
  }

  Future<bool> deleteDay(int dayId, int planId) async {
    _error = null;
    try {
      await _service.deleteDay(dayId);
      await loadPlanDetails(planId);
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error deleting day: $e');
      return false;
    }
  }

  Future<bool> toggleRestDay(PlanDay day) async {
    _error = null;
    try {
      final updated = day.copyWith(isRestDay: !day.isRestDay);
      await _service.updateDay(updated);
       
      if (_selectedPlan != null) {
          final days = _selectedPlan!.days.map((d) => d.id == day.id ? updated : d).toList();
          _selectedPlan = _selectedPlan!.copyWith(days: days);
          notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // --- Exercise Management ---

  Future<bool> addExerciseToDay(DayExercise exercise, int planId) async {
    _error = null;
    try {
      await _service.addExerciseToDay(exercise);
      await loadPlanDetails(planId); 
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error adding exercise: $e');
      return false;
    }
  }

  Future<bool> updateDayExercise(DayExercise exercise, int planId) async {
    _error = null;
    try {
      await _service.updateDayExercise(exercise);
      await loadPlanDetails(planId); 
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error updating exercise: $e');
      return false;
    }
  }

  Future<bool> removeExerciseFromDay(int dayExerciseId, int planId) async {
    _error = null;
    try {
      await _service.deleteDayExercise(dayExerciseId);
      await loadPlanDetails(planId);
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error removing exercise: $e');
      return false;
    }
  }

  WorkoutPlan? getById(int id) {
     if (_selectedPlan != null && _selectedPlan!.id == id) return _selectedPlan;
     try {
       return _plans.firstWhere((p) => p.id == id);
     } catch (_) {
       return null;
     }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
