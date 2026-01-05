import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/subscription.dart';
import '../../providers/players_provider.dart';
import '../../providers/workout_plans_provider.dart';
import '../../providers/subscriptions_provider.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../utils/date_helpers.dart';
import '../../l10n/app_localizations.dart';

class SubscriptionFormScreen extends StatefulWidget {
  final int? playerId;
  final Subscription? subscription;

  const SubscriptionFormScreen({
    super.key, 
    this.playerId,
    this.subscription,
  });

  @override
  State<SubscriptionFormScreen> createState() => _SubscriptionFormScreenState();
}

class _SubscriptionFormScreenState extends State<SubscriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  int? _selectedPlayerId;
  int? _selectedPlanId;
  DateTime _startDate = DateTime.now();
  int _durationMonths = 1;
  bool _isLoading = false;

  bool get isEditing => widget.subscription != null;

  @override
  void initState() {
    super.initState();
    _selectedPlayerId = widget.playerId ?? widget.subscription?.playerId;
    
    if (isEditing) {
      _selectedPlanId = widget.subscription!.planId;
      _startDate = widget.subscription!.startDate;
      _amountController.text = widget.subscription!.amountPaid?.toString() ?? '';
      _notesController.text = widget.subscription!.paymentNotes ?? '';
      
      // Calculate duration from dates
      final months = widget.subscription!.endDate.month - widget.subscription!.startDate.month + 
          (widget.subscription!.endDate.year - widget.subscription!.startDate.year) * 12;
      _durationMonths = months > 0 ? months : 1;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  DateTime get _endDate {
    return DateHelpers.addMonths(_startDate, _durationMonths);
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              surface: AppTheme.surfaceColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedPlayerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a player'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    
    if (_selectedPlanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a workout plan'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final subscriptionsProvider = Provider.of<SubscriptionsProvider>(context, listen: false);

    final subscription = Subscription(
      id: widget.subscription?.id,
      playerId: _selectedPlayerId!,
      planId: _selectedPlanId!,
      startDate: _startDate,
      endDate: _endDate,
      status: Subscription.statusActive,
      amountPaid: _amountController.text.isEmpty 
          ? null 
          : double.tryParse(_amountController.text),
      paymentNotes: _notesController.text.isEmpty ? null : _notesController.text,
      createdAt: widget.subscription?.createdAt,
    );

    bool success;
    if (isEditing) {
      success = await subscriptionsProvider.updateSubscription(subscription);
    } else {
      final newSub = await subscriptionsProvider.createSubscription(subscription);
      success = newSub != null;
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Subscription updated' : 'Subscription created'),
          backgroundColor: AppTheme.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(subscriptionsProvider.error ?? 'Failed to save subscription'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final playersProvider = Provider.of<PlayersProvider>(context);
    final plansProvider = Provider.of<WorkoutPlansProvider>(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Subscription' : 'New Subscription'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Player Selection
            Text(
              l10n?.selectPlayer ?? 'Select Player',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _selectedPlayerId,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outlined),
                hintText: l10n?.pleaseSelectPlayer ?? 'Choose a player',
              ),
              items: playersProvider.players.map((player) {
                return DropdownMenuItem(
                  value: player.id,
                  child: Text(player.name),
                );
              }).toList(),
              onChanged: widget.playerId == null ? (value) {
                setState(() => _selectedPlayerId = value);
              } : null,
            ),
            const SizedBox(height: 24),

            // Plan Selection
            Text(
              l10n?.selectPlan ?? 'Select Workout Plan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _selectedPlanId,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.fitness_center_outlined),
                hintText: l10n?.pleaseSelectPlan ?? 'Choose a workout plan',
              ),
              items: plansProvider.plans.where((p) => p.isActive).map((plan) {
                return DropdownMenuItem(
                  value: plan.id,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(plan.name),
                      Text(
                        plan.difficultyLevel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedPlanId = value);
              },
            ),
            const SizedBox(height: 24),

            // Duration
            Text(
              l10n?.subscriptionDuration ?? 'Subscription Duration',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Constants.subscriptionDurations.map((duration) {
                final months = duration['months'] as int;
                final isSelected = _durationMonths == months;
                return ChoiceChip(
                  // Use specific text based on months if possible, or just append "Months" 
                  // For now assume the label in Constants is generic, but better 
                  // to manual override for Arabic context: "1 Month" -> "شهر 1"
                  label: Text('${duration['months']} شهر'), 
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _durationMonths = months);
                  },
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : AppTheme.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Start Date
            Text(
              l10n?.startDate ?? 'Start Date',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectStartDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3A3A3A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppTheme.textSecondary),
                    const SizedBox(width: 12),
                    Text(
                      DateHelpers.formatDate(_startDate),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    const Icon(Icons.edit, size: 18, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // End Date (calculated)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.endDate ?? 'End Date',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        DateHelpers.formatDate(_endDate),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment (optional)
            Text(
              l10n?.payment ?? 'Payment (Optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n?.amount ?? 'Amount',
                prefixIcon: const Icon(Icons.attach_money),
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n?.paymentNotes ?? 'Payment Notes',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Icon(Icons.notes_outlined),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Text(isEditing 
                      ? (l10n?.saveChanges ?? 'Save Changes') 
                      : (l10n?.newSubscription ?? 'Create Subscription')),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
