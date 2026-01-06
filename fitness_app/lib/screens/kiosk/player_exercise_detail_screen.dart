import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../models/day_exercise.dart';
import '../../utils/theme.dart';
import '../../l10n/app_localizations.dart';

class PlayerExerciseDetailScreen extends StatefulWidget {
  final DayExercise exercise;

  const PlayerExerciseDetailScreen({
    super.key,
    required this.exercise,
  });

  @override
  State<PlayerExerciseDetailScreen> createState() => _PlayerExerciseDetailScreenState();
}

class _PlayerExerciseDetailScreenState extends State<PlayerExerciseDetailScreen> {
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    if (widget.exercise.youtubeUrl != null) {
      final videoId = YoutubePlayer.convertUrlToId(widget.exercise.youtubeUrl!);
      if (videoId != null) {
        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: false,
          ),
        )..addListener(_listener);
      }
    }
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller!.value.isFullScreen) {
      setState(() {});
    }
  }

  @override
  void deactivate() {
    _controller?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.exerciseName ?? 'التمرين'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video Player Section
            if (_controller != null)
              YoutubePlayerBuilder(
                player: YoutubePlayer(
                  controller: _controller!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: AppTheme.primaryColor,
                  onReady: () => _isPlayerReady = true,
                ),
                builder: (context, player) => player,
              )
            else
              Container(
                height: 200,
                color: AppTheme.surfaceColor,
                child: const Center(
                  child: Icon(
                    Icons.videocam_off_outlined,
                    size: 64,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),

            // Exercise Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Exercise Name Header
                   Text(
                     widget.exercise.exerciseName ?? 'التمرين',
                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                       color: AppTheme.primaryColor,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                   const SizedBox(height: 16),

                   // Notes (if any)
                   if (widget.exercise.notes != null && widget.exercise.notes!.isNotEmpty) ...[
                     Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(
                         color: AppTheme.primaryColor.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(8),
                         border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                       ),
                       child: Row(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 20),
                           const SizedBox(width: 8),
                           Expanded(
                             child: Text(
                               widget.exercise.notes!,
                               style: const TextStyle(fontSize: 16),
                             ),
                           ),
                         ],
                       ),
                     ),
                     const SizedBox(height: 24),
                   ],

                   // Sets & Reps Table
                   Text(
                     l10n?.setDetails ?? 'تفاصيل المجموعات',
                     style: Theme.of(context).textTheme.titleLarge,
                   ),
                   const SizedBox(height: 12),
                   _buildSetsList(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetsList(BuildContext context) {
    if (widget.exercise.sets.isEmpty) {
      return Center(
        child: Text(
          'لا توجد مجموعات محددة',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.exercise.sets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final set = widget.exercise.sets[index];
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.black,
              child: Text('${index + 1}'),
            ),
            title: Text(
              '${set.reps} تكرار',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: set.weight != null && set.weight! > 0 
                ? Text('${set.weight} كغ') 
                : null,
            trailing: Checkbox(
              value: false, 
              onChanged: (val) {
                // Interactive checklist logic (local state)
              },
              activeColor: AppTheme.success,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
        );
      },
    );
  }
}
