import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';

import '../../l10n/app_localizations.dart';
import '../../models/player.dart';
import '../../models/workout_plan.dart';
import '../../providers/workout_plans_provider.dart';
import '../../services/pdf_service.dart';
import '../../utils/theme.dart';

class PlayerWorkoutPlanScreen extends StatefulWidget {
  final Player player;
  final WorkoutPlan plan;

  const PlayerWorkoutPlanScreen({
    super.key,
    required this.player,
    required this.plan,
  });

  @override
  State<PlayerWorkoutPlanScreen> createState() => _PlayerWorkoutPlanScreenState();
}

class _PlayerWorkoutPlanScreenState extends State<PlayerWorkoutPlanScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlanDetails();
  }

  Future<void> _loadPlanDetails() async {
    final provider = Provider.of<WorkoutPlansProvider>(context, listen: false);
    await provider.loadPlanDetails(widget.plan.id!);
    setState(() => _isLoading = false);
  }

  Future<void> _exportPdf(WorkoutPlan plan) async {
    final pdfService = PdfService();
    final l10n = AppLocalizations.of(context);
    try {
      final pdfData = await pdfService.generatePlayerPlanPdf(
        widget.player, 
        plan, 
        plan.days
      );
      await Printing.layoutPdf(
        onLayout: (format) async => pdfData,
        name: '${widget.player.name}_${plan.name}.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n?.error ?? "Error"}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer<WorkoutPlansProvider>(
      builder: (context, provider, child) {
        final plan = provider.selectedPlan ?? widget.plan;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n?.playerWorkoutPlan ?? 'خطة تمرين اللاعب'),
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                tooltip: l10n?.exportPdf ?? 'تصدير PDF',
                onPressed: () => _exportPdf(plan),
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Player Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  widget.player.name.isNotEmpty 
                                      ? widget.player.name[0].toUpperCase() 
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.player.name,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (widget.player.weight != null) ...[
                                        Icon(Icons.monitor_weight_outlined, size: 16, color: AppTheme.textSecondary),
                                        const SizedBox(width: 4),
                                        Text('${widget.player.weight} كغ'),
                                        const SizedBox(width: 16),
                                      ],
                                      if (widget.player.height != null) ...[
                                        Icon(Icons.height_outlined, size: 16, color: AppTheme.textSecondary),
                                        const SizedBox(width: 4),
                                        Text('${widget.player.height} سم'),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Plan Info
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (plan.description != null && plan.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(plan.description!),
                              ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                plan.difficultyLevel,
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Days
                    Text(
                      l10n?.weeklySchedule ?? 'جدول التدريب',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    
                    ...plan.days.map((day) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        title: Text(
                          l10n?.day(day.sequenceOrder) ?? 'اليوم ${day.sequenceOrder}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: day.isRestDay 
                            ? Text(l10n?.restDay ?? 'راحة', style: const TextStyle(color: AppTheme.accentColor))
                            : Text('${day.exercises.length} ${l10n?.exercises ?? "تمرين"}'),
                        leading: Icon(
                          day.isRestDay ? Icons.hotel : Icons.fitness_center,
                          color: day.isRestDay ? AppTheme.accentColor : AppTheme.primaryColor,
                        ),
                        children: [
                          if (!day.isRestDay && day.exercises.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: day.exercises.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final ex = entry.value;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${idx + 1}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ex.exerciseName ?? 'Exercise',
                                                style: const TextStyle(fontWeight: FontWeight.w600),
                                              ),
                                              if (ex.sets.isNotEmpty)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Text(
                                                    '${ex.sets.length} ${l10n?.sets ?? "مجموعات"}',
                                                    style: Theme.of(context).textTheme.bodySmall,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    )).toList(),

                    if (plan.days.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            l10n?.noWorkoutDays ?? 'لا توجد أيام تمرين',
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}
