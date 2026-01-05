import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/exercise.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exercises_provider.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';

class ExerciseFormScreen extends StatefulWidget {
  final Exercise? exercise;
  final String? initialMuscleGroup;

  const ExerciseFormScreen({super.key, this.exercise, this.initialMuscleGroup});

  @override
  State<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends State<ExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _youtubeUrlController = TextEditingController();
  String _muscleGroup = 'Chest';
  bool _isLoading = false;
  String? _previewThumbnail;

  bool get isEditing => widget.exercise != null;

  @override
  void initState() {
    super.initState();
    if (widget.initialMuscleGroup != null) {
        _muscleGroup = widget.initialMuscleGroup!;
    }
    if (isEditing) {
      _nameController.text = widget.exercise!.name;
      _descriptionController.text = widget.exercise!.description ?? '';
      _youtubeUrlController.text = widget.exercise!.youtubeUrl ?? '';
      _muscleGroup = widget.exercise!.muscleGroup;
      _updatePreview();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _youtubeUrlController.dispose();
    super.dispose();
  }

  void _updatePreview() {
    final url = _youtubeUrlController.text.trim();
    if (url.isEmpty) {
      setState(() => _previewThumbnail = null);
      return;
    }

    // Attempt to extract video ID for thumbnail
    String? videoId;
    
    // Simple regex for standard YouTube URLs
    final regExp = RegExp(r"(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^""&?\/\s]{11})");
    final match = regExp.firstMatch(url);
    
    if (match != null && match.groupCount >= 1) {
       videoId = match.group(1);
    }

    if (videoId != null) {
      setState(() {
        _previewThumbnail = 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
      });
    } else {
      setState(() => _previewThumbnail = null);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final exercisesProvider = Provider.of<ExercisesProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);

    // Ensure trainer is loaded (should be auto-logged in)
    final trainerId = authProvider.trainerId;
    
    if (trainerId == null) {
        // Fallback or error
        setState(() => _isLoading = false);
        return;
    }

    final exercise = Exercise(
      id: widget.exercise?.id,
      trainerId: trainerId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      muscleGroup: _muscleGroup,
      youtubeUrl: _youtubeUrlController.text.trim().isEmpty ? null : _youtubeUrlController.text.trim(),
      // Removed default sets/reps/duration
    );

    bool success;
    if (isEditing) {
      success = await exercisesProvider.updateExercise(exercise);
    } else {
      final newExercise = await exercisesProvider.createExercise(exercise);
      success = newExercise != null;
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing 
                ? (l10n?.saveChanges ?? 'Exercise Updated') 
                : (l10n?.success ?? 'Exercise Added')),
          backgroundColor: AppTheme.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exercisesProvider.error ?? (l10n?.error ?? 'Error saving exercise')),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  // Helper to localize muscle groups if needed, or just use English keys for DB and Arabic for Display
  String _getLocalizedMuscleGroup(String group, AppLocalizations? l10n) {
      // Simple mapping or return as is if not critical yet
      // Ideally we map 'Chest' -> 'صدر', etc.
      // For now, let's keep the internal value English for DB consistency if needed, 
      // but we should probably switch DB to Arabic or map it.
      // Given "Translate to Arabic", I will use Arabic display names.
      switch (group) {
          case 'Chest': return 'صدر';
          case 'Back': return 'ظهر';
          case 'Legs': return 'أرجل';
          case 'Arms': return 'أذرع';
          case 'Shoulders': return 'أكتاف';
          case 'Core': return 'بطن/عضلات وسط';
          case 'Cardio': return 'كارديو';
          case 'Full Body': return 'جسم كامل';
          default: return group;
      }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing 
            ? (l10n?.exerciseDetails ?? 'Edit Exercise') 
            : (l10n?.addExercise ?? 'Add Exercise')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Exercise Name
            TextFormField(
              controller: _nameController,
              validator: (value) => Validators.required(value, fieldName: l10n?.exercises ?? 'Exercise Name'),
              decoration: InputDecoration(
                labelText: l10n?.exercises ?? 'Exercise Name',
                prefixIcon: const Icon(Icons.fitness_center_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Muscle Group
            DropdownButtonFormField<String>(
              value: _muscleGroup,
              decoration: InputDecoration(
                labelText: l10n?.muscleGroup ?? 'Muscle Group',
                prefixIcon: const Icon(Icons.category_outlined),
              ),
              items: Constants.muscleGroups.map((group) {
                return DropdownMenuItem(
                  value: group,
                  child: Text(_getLocalizedMuscleGroup(group, l10n)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _muscleGroup = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // YouTube URL
            TextFormField(
              controller: _youtubeUrlController,
              // Relaxed validation or "Any link" logic
              validator: (val) {
                  if (val != null && val.isNotEmpty) {
                      // Accept any string for now, or minimal url check
                      if (!val.contains('http')) return 'Link invalid';
                  }
                  return null;
              }, 
              decoration: InputDecoration(
                labelText: l10n?.youtubeUrl ?? 'YouTube URL',
                prefixIcon: const Icon(Icons.play_circle_outline),
                hintText: 'https://...',
              ),
              onChanged: (_) => _updatePreview(),
            ),
            const SizedBox(height: 16),

            // Video Preview
            if (_previewThumbnail != null) ...[
              Text(
                l10n?.videoPreview ?? 'Preview',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _previewThumbnail!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: AppTheme.surfaceColor,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n?.description ?? 'Description',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.description_outlined),
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
                  : Text(l10n?.save ?? 'Save'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
