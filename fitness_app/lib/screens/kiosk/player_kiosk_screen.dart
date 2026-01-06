import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'player_exercise_detail_screen.dart';
import 'package:fitness_app/l10n/app_localizations.dart';

import '../../models/player.dart';
import '../../models/workout_plan.dart';
import '../../models/plan_day.dart';
import '../../models/day_exercise.dart';
import '../../providers/players_provider.dart';
import '../../providers/workout_plans_provider.dart';
import '../../providers/subscriptions_provider.dart';
import '../../utils/theme.dart';

class PlayerKioskScreen extends StatefulWidget {
  const PlayerKioskScreen({super.key});

  @override
  State<PlayerKioskScreen> createState() => _PlayerKioskScreenState();
}

class _PlayerKioskScreenState extends State<PlayerKioskScreen> {
  final TextEditingController _searchController = TextEditingController();
  Player? _selectedPlayer;
  WorkoutPlan? _activePlan;
  List<PlanDay> _planDays = [];
  bool _isLoading = false;
  List<Player> _searchResults = [];

  @override
  void initState() {
    super.initState();
    // Hide system UI for kiosk mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _searchPlayers(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    
    final playersProvider = Provider.of<PlayersProvider>(context, listen: false);
    final results = playersProvider.players
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
    
    setState(() => _searchResults = results);
  }

  Future<void> _selectPlayer(Player player) async {
    setState(() {
      _selectedPlayer = player;
      _isLoading = true;
      _searchResults = [];
      _searchController.text = player.name;
    });

    // Find active subscription for player
    final subsProvider = Provider.of<SubscriptionsProvider>(context, listen: false);
    final plansProvider = Provider.of<WorkoutPlansProvider>(context, listen: false);
    
    // Use the correct provider method
    final activeSub = await subsProvider.getActiveByPlayer(player.id!);

    if (activeSub != null) {
      // Load the plan details (this populates plansProvider.selectedPlan)
      await plansProvider.loadPlanDetails(activeSub.planId);
      final plan = plansProvider.selectedPlan;
      if (plan != null) {
        setState(() {
          _activePlan = plan;
          _planDays = plan.days;
        });
      }
    }

    setState(() => _isLoading = false);
  }

  void _clearSelection() {
    setState(() {
      _selectedPlayer = null;
      _activePlan = null;
      _planDays = [];
      _searchController.clear();
    });
  }

  void _playVideo(String youtubeUrl) {
    final videoId = YoutubePlayer.convertUrlToId(youtubeUrl);
    if (videoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رابط الفيديو غير صالح')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _VideoPlayerScreen(videoId: videoId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Exit button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 28),
                    tooltip: 'خروج',
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'وضع اللاعب',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  if (_selectedPlayer != null)
                    TextButton.icon(
                      onPressed: _clearSelection,
                      icon: const Icon(Icons.search),
                      label: const Text('بحث جديد'),
                    ),
                ],
              ),
            ),

            // Search Box (when no player selected)
            if (_selectedPlayer == null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    const Icon(
                      Icons.fitness_center,
                      size: 80,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ابحث عن اسمك',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'لعرض خطة التمرين الخاصة بك',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _searchController,
                      onChanged: _searchPlayers,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        hintText: 'اكتب اسمك هنا...',
                        prefixIcon: const Icon(Icons.search, size: 28),
                        filled: true,
                        fillColor: AppTheme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Search Results
                    if (_searchResults.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: _searchResults.map((player) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryColor,
                                child: Text(
                                  player.name[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                              title: Text(player.name),
                              onTap: () => _selectPlayer(player),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            // Player Workout Plan
            if (_selectedPlayer != null) ...[
              if (_isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_activePlan == null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.event_busy,
                          size: 80,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا يوجد اشتراك نشط',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'تواصل مع المدرب للحصول على خطة تمرين',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plan Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          color: Color.fromRGBO(AppTheme.primaryColor.r.toInt(), AppTheme.primaryColor.g.toInt(), AppTheme.primaryColor.b.toInt(), 0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppTheme.primaryColor,
                                  child: Text(
                                    _selectedPlayer!.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedPlayer!.name,
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      Text(
                                        _activePlan!.name,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Days List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _planDays.length,
                          itemBuilder: (context, index) {
                            final day = _planDays[index];
                            return _buildDayCard(day);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(PlanDay day) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: day.isRestDay ? AppTheme.warning : AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '${day.sequenceOrder}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        title: Text(
          'اليوم ${day.sequenceOrder}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          day.isRestDay 
              ? 'يوم راحة' 
              : day.focusArea ?? '${day.exercises.length} تمرين',
          style: TextStyle(
            color: day.isRestDay ? AppTheme.warning : AppTheme.textSecondary,
          ),
        ),
        children: day.isRestDay
            ? [
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    '🌙 استرح واستعد لليوم التالي',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ]
            : day.exercises.map((ex) => _buildExerciseTile(ex)).toList(),
      ),
    );
  }

  Widget _buildExerciseTile(DayExercise exercise) {
    final hasVideo = exercise.youtubeUrl != null && exercise.youtubeUrl!.isNotEmpty;
    String? videoId;
    String? thumbnailUrl;
    
    if (hasVideo) {
      videoId = YoutubePlayer.convertUrlToId(exercise.youtubeUrl!);
      if (videoId != null) {
        thumbnailUrl = 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
      }
    }
    
    return ListTile(
      leading: Container(
        width: 80,
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: thumbnailUrl != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.play_circle_fill,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              )
            : const Icon(
                Icons.fitness_center,
                color: AppTheme.textSecondary,
                size: 28,
              ),
      ),
      title: Text(exercise.exerciseName ?? 'تمرين'),
      subtitle: Text(
        exercise.sets.isEmpty 
            ? 'لا توجد تفاصيل'
            : '${exercise.sets.length} مجموعات',
      ),
      trailing: hasVideo
          ? const Icon(Icons.arrow_forward_ios, size: 16)
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerExerciseDetailScreen(exercise: exercise),
          ),
        );
      },
    );
  }
}

// Fullscreen YouTube Video Player
class _VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  
  const _VideoPlayerScreen({required this.videoId});

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Force landscape for video
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        hideControls: false,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    // Restore portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppTheme.primaryColor,
              progressColors: const ProgressBarColors(
                playedColor: AppTheme.primaryColor,
                handleColor: AppTheme.primaryLight,
              ),
            ),
          ),
          // Back button overlay
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
