import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../../l10n/app_localizations.dart';
import '../../models/workout_plan.dart';
import '../../models/plan_day.dart';
import '../../providers/workout_plans_provider.dart';
import '../../services/pdf_service.dart';
import '../../utils/theme.dart';
import 'day_editor_screen.dart';
import 'plan_form_screen.dart';

class PlanDetailScreen extends StatefulWidget {
  final int planId;
  final String planName;

  const PlanDetailScreen({
    super.key,
    required this.planId,
    required this.planName,
  });

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<WorkoutPlansProvider>(context, listen: false)
            .loadPlanDetails(widget.planId));
  }

  Future<void> _exportPdf(WorkoutPlan plan) async {
    final pdfService = PdfService();
    try {
      final pdfData = await pdfService.generatePlanPdf(plan, plan.days);
      await Printing.layoutPdf(
        onLayout: (format) async => pdfData,
        name: '${plan.name}.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<WorkoutPlansProvider>(
      builder: (context, provider, child) {
        final plan = provider.selectedPlan;

        if (provider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.planName)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (plan == null) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.planName)),
            body: Center(child: Text(l10n?.error ?? 'Error loading plan')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(plan.name),
            actions: [
               IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                tooltip: l10n?.exportPdf ?? 'Export PDF',
                onPressed: () => _exportPdf(plan),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlanFormScreen(plan: plan),
                    ),
                  );
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Plan Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.description ?? 'Description',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(plan.description),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Days Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n?.weeklySchedule ?? 'Schedule',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.addDayToPlan(plan.id!);
                    },
                    icon: const Icon(Icons.add),
                    label: Text(l10n?.addDay ?? 'Add Day'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Days List
              ...plan.days.map((day) => _buildDayCard(context, day, provider, l10n)).toList(),
              
              if (plan.days.isEmpty)
                 Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      l10n?.noWorkoutDays ?? 'No days added yet. Click "Add Day" to start.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayCard(BuildContext context, PlanDay day, WorkoutPlansProvider provider, AppLocalizations? l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: day.isRestDay 
              ? BorderSide.none 
              : BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              l10n?.day(day.sequenceOrder) ?? 'Day ${day.sequenceOrder}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            if (day.isRestDay)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  l10n?.restDay ?? 'REST',
                  style: const TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            else if (day.focusArea != null && day.focusArea!.isNotEmpty)
               Text(
                '• ${day.focusArea}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),               ),
          ],
        ),
        subtitle: day.isRestDay 
            ? null 
            : Text(
                '${day.exercises.length} ${l10n?.exercises ?? "Exercises"}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
        trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
                Switch(
                    value: day.isRestDay,
                    onChanged: (val) {
                        provider.toggleRestDay(day);
                    },
                    activeColor: AppTheme.accentColor,
                ),
               IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                onPressed: () {
                    // Confirm delete
                    showDialog(context: context, builder: (ctx) => AlertDialog(
                        title: Text(l10n?.delete ?? 'Delete'),
                        content: Text(l10n?.deleteConfirmation ?? 'Confirm delete day?'),
                        actions: [
                            TextButton(onPressed: ()=>Navigator.pop(ctx), child: Text(l10n?.cancel ?? 'Cancel')),
                            TextButton(onPressed: (){
                                Navigator.pop(ctx);
                                provider.deleteDay(day.id!, widget.planId);
                            }, child: Text(l10n?.delete ?? 'Delete', style: const TextStyle(color: AppTheme.error))),
                        ],
                    ));
                },
               ),
            ],
        ),
        children: [
            if (!day.isRestDay)
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                            if (day.exercises.isNotEmpty)
                                ...day.exercises.asMap().entries.map((entry) {
                                  final ex = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                       children: [
                                           Text('${entry.key + 1}. ', style: const TextStyle(color: AppTheme.textSecondary)),
                                           Expanded(child: Text(ex.exerciseName ?? 'Exercise')),
                                           Text('${ex.sets.length} Sets', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                       ], 
                                    ),
                                  );
                                }).toList()
                            else
                                Text(l10n?.noExercises ?? 'No exercises', style: const TextStyle(color: AppTheme.textSecondary, fontStyle: FontStyle.italic)),
                            
                            const SizedBox(height: 16),
                            ElevatedButton(
                                onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (_) => DayEditorScreen(
                                            planId: widget.planId,
                                            dayId: day.id!,
                                            dayTitle: l10n?.day(day.sequenceOrder) ?? 'Day ${day.sequenceOrder}',
                                        )
                                    ));
                                }, 
                                child: Text(l10n?.edit ?? 'Edit Exercises')
                            ),
                        ],
                    ),
                ),
        ],
      ),
    );
  }
}
