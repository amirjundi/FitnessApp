import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise.dart';
import '../../providers/exercises_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/empty_state.dart';
import 'exercise_detail_screen.dart';
import 'exercise_form_screen.dart';

class CategoryExercisesScreen extends StatelessWidget {
  final String categoryName;

  const CategoryExercisesScreen({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: Consumer<ExercisesProvider>(
        builder: (context, provider, child) {
          // Filter exercises by category
          final exercises = provider.allExercises
              .where((e) => e.muscleGroup == categoryName)
              .toList();
            
          // Sort alpha
          exercises.sort((a, b) => a.name.compareTo(b.name));

          if (exercises.isEmpty) {
            return Center(
              child: EmptyState(
                icon: Icons.folder_open_outlined,
                title: 'No Exercises',
                message: 'No exercises found in $categoryName',
                actionLabel: 'Add Exercise',
                onAction: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ExerciseFormScreen(),
                      ),
                    );
                },
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return _ExerciseCard(
                exercise: exercise,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ExerciseDetailScreen(exerciseId: exercise.id!),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
             Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ExerciseFormScreen(initialMuscleGroup: categoryName),
              ),
            );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Exercise'),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // YouTube Thumbnail
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  image: (exercise.thumbnailPath != null && exercise.thumbnailPath!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(exercise.thumbnailPath!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (exercise.thumbnailPath == null || exercise.thumbnailPath!.isEmpty)
                    ? const Icon(
                        Icons.play_circle_outline,
                        size: 32,
                        color: AppTheme.textSecondary,
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (exercise.description != null && exercise.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          exercise.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
