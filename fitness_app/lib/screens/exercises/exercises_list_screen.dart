import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/exercises_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/empty_state.dart';
import 'exercise_detail_screen.dart';
import 'exercise_form_screen.dart';
import 'category_exercises_screen.dart';

class ExercisesListScreen extends StatefulWidget {
  const ExercisesListScreen({super.key});

  @override
  State<ExercisesListScreen> createState() => _ExercisesListScreenState();
}

class _ExercisesListScreenState extends State<ExercisesListScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddExercise() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ExerciseFormScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n?.search ?? 'بحث...',
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  setState(() {});
                },
              )
            : Text(l10n?.exercises ?? 'التمارين'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Consumer<ExercisesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.allExercises.isEmpty) {
            return EmptyState(
              icon: Icons.sports_gymnastics_outlined,
              title: l10n?.noExercises ?? 'لا يوجد تمارين',
              message: l10n?.buildLibrary ?? 'ابنِ مكتبة تمارينك',
              actionLabel: l10n?.addExercise ?? 'إضافة تمرين',
              onAction: _navigateToAddExercise,
            );
          }

          // If searching, show flat list of exercises
          if (_isSearching && _searchController.text.isNotEmpty) {
             final query = _searchController.text.toLowerCase();
             final filteredExercises = provider.allExercises.where((e) => 
               e.name.toLowerCase().contains(query) ||
               e.muscleGroup.toLowerCase().contains(query)
             ).toList();

             if (filteredExercises.isEmpty) {
               return Center(child: Text(l10n?.noMatchingExercises ?? 'لا توجد تمارين مطابقة'));
             }

             return ListView.builder(
               padding: const EdgeInsets.all(16),
               itemCount: filteredExercises.length,
               itemBuilder: (context, index) {
                  final exercise = filteredExercises[index];
                  return _ExerciseListCard(
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
          }

          // Default: Show Folders (Muscle Groups)
          final groupedExercises = provider.allExercises.fold<Set<String>>({}, (set, ex) {
            set.add(ex.muscleGroup);
            return set;
          }).toList()..sort();

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: groupedExercises.length,
            itemBuilder: (context, index) {
              final group = groupedExercises[index];
              final count = provider.allExercises.where((e) => e.muscleGroup == group).length;
              
              return _FolderCard(
                title: group,
                count: count,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CategoryExercisesScreen(categoryName: group),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddExercise,
        icon: const Icon(Icons.add),
        label: Text(l10n?.addExercise ?? 'إضافة تمرين'),
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onTap;

  const _FolderCard({
    required this.title,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.surfaceColor,
                AppTheme.surfaceColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open,
                size: 48,
                color: AppTheme.primaryColor.withOpacity(0.8),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '$count Exercises',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseListCard extends StatelessWidget {
  final dynamic exercise; // Using dynamic to avoid import duplication issues if any, but properly typed is better
  final VoidCallback onTap;

  const _ExerciseListCard({required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            image: (exercise.thumbnailPath != null && exercise.thumbnailPath!.isNotEmpty)
                ? DecorationImage(
                    image: NetworkImage(exercise.thumbnailPath!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: (exercise.thumbnailPath == null || exercise.thumbnailPath!.isEmpty)
              ? const Icon(Icons.fitness_center, color: AppTheme.textSecondary)
              : null,
        ),
        title: Text(exercise.name),
        subtitle: Text(exercise.muscleGroup),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
