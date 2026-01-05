import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/workout_plan.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workout_plans_provider.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';

class PlanFormScreen extends StatefulWidget {
  final WorkoutPlan? plan;

  const PlanFormScreen({super.key, this.plan});

  @override
  State<PlanFormScreen> createState() => _PlanFormScreenState();
}

class _PlanFormScreenState extends State<PlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _difficultyLevel = 'متوسط';

  @override
  void initState() {
    super.initState();
    if (widget.plan != null) {
      _nameController.text = widget.plan!.name;
      _descriptionController.text = widget.plan!.description;
      _difficultyLevel = widget.plan!.difficultyLevel;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final plansProvider = Provider.of<WorkoutPlansProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);

    final plan = WorkoutPlan(
      id: widget.plan?.id,
      trainerId: authProvider.trainerId!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      difficultyLevel: _difficultyLevel,
      createdAt: widget.plan?.createdAt ?? DateTime.now(),
      isActive: true,
    );

    bool success;
    if (widget.plan != null) {
      success = await plansProvider.updatePlan(plan);
    } else {
      success = await plansProvider.createPlan(plan);
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.error ?? 'An error occurred'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan == null 
            ? (l10n?.newPlan ?? 'New Plan') 
            : (l10n?.editPlan ?? 'Edit Plan')),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _savePlan,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                validator: Validators.required,
                decoration: InputDecoration(
                  labelText: l10n?.fullName ?? 'Plan Name', // Reusing fullName resource to avoid adding new key if desperate, but better use implicit label
                  hintText: 'e.g., Weight Loss Program',
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                validator: Validators.required,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n?.description ?? 'Description',
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _difficultyLevel,
                decoration: InputDecoration(
                  labelText: l10n?.difficultyLevel ?? 'مستوى الصعوبة',
                ),
                items: ['مبتدئ', 'متوسط', 'متقدم']
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _difficultyLevel = value;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 32),
              
              if (widget.plan == null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          l10n?.selectWorkoutDaysSubtitle ?? 'You can add days after creating the plan.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
