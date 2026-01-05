import 'package:flutter/foundation.dart';
import '../models/subscription.dart';
import '../services/subscription_service.dart';

class SubscriptionsProvider with ChangeNotifier {
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<Subscription> _subscriptions = [];
  List<Subscription> _expiringSoon = [];
  bool _isLoading = false;
  String? _error;

  List<Subscription> get subscriptions => _subscriptions;
  List<Subscription> get expiringSoon => _expiringSoon;
  List<Subscription> get activeSubscriptions => 
      _subscriptions.where((s) => s.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get activeCount => activeSubscriptions.length;

  Future<void> loadSubscriptions(int trainerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Update expired subscriptions first
      await _subscriptionService.updateExpiredSubscriptions();
      
      _subscriptions = await _subscriptionService.getAllByTrainer(trainerId);
      _expiringSoon = await _subscriptionService.getExpiringSoon(trainerId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Subscription>> getByPlayer(int playerId) async {
    try {
      return await _subscriptionService.getByPlayer(playerId);
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  Future<Subscription?> getActiveByPlayer(int playerId) async {
    try {
      return await _subscriptionService.getActiveByPlayer(playerId);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  Future<Subscription?> createSubscription(Subscription subscription) async {
    _error = null;
    
    try {
      final newSubscription = await _subscriptionService.create(subscription);
      _subscriptions.add(newSubscription);
      _subscriptions.sort((a, b) => a.endDate.compareTo(b.endDate));
      notifyListeners();
      return newSubscription;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateSubscription(Subscription subscription) async {
    _error = null;
    
    try {
      await _subscriptionService.update(subscription);
      final index = _subscriptions.indexWhere((s) => s.id == subscription.id);
      if (index != -1) {
        _subscriptions[index] = subscription;
        _subscriptions.sort((a, b) => a.endDate.compareTo(b.endDate));
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelSubscription(int id) async {
    _error = null;
    
    try {
      await _subscriptionService.cancel(id);
      final index = _subscriptions.indexWhere((s) => s.id == id);
      if (index != -1) {
        _subscriptions[index] = _subscriptions[index].copyWith(
          status: Subscription.statusCancelled,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSubscription(int id) async {
    _error = null;
    
    try {
      await _subscriptionService.delete(id);
      _subscriptions.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Subscription? getById(int id) {
    try {
      return _subscriptions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
