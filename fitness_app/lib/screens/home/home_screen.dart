import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_app/l10n/app_localizations.dart';

import '../../providers/auth_provider.dart';
import '../../providers/players_provider.dart';
import '../../providers/workout_plans_provider.dart';
import '../../providers/exercises_provider.dart';
import '../../providers/subscriptions_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/stat_card.dart';
import '../players/players_list_screen.dart';
import '../workout_plans/plans_list_screen.dart';
import '../exercises/exercises_list_screen.dart';
import '../subscriptions/subscriptions_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _DashboardTab(),
    PlayersListScreen(),
    PlansListScreen(),
    ExercisesListScreen(),
    SubscriptionsListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final trainerId = authProvider.trainerId;
    
    if (trainerId != null) {
      final playersProvider = Provider.of<PlayersProvider>(context, listen: false);
      final plansProvider = Provider.of<WorkoutPlansProvider>(context, listen: false);
      final exercisesProvider = Provider.of<ExercisesProvider>(context, listen: false);
      final subscriptionsProvider = Provider.of<SubscriptionsProvider>(context, listen: false);

      await Future.wait([
        playersProvider.loadPlayers(trainerId),
        plansProvider.loadPlans(trainerId),
        exercisesProvider.loadExercises(trainerId),
        subscriptionsProvider.loadSubscriptions(trainerId),
      ]);
    }
  }

  // Global key to access the drawer from child widgets
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: AppLocalizations.of(context)?.dashboard ?? 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people_outlined),
              activeIcon: const Icon(Icons.people),
              label: AppLocalizations.of(context)?.players ?? 'Players',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.fitness_center_outlined),
              activeIcon: const Icon(Icons.fitness_center),
              label: AppLocalizations.of(context)?.workoutPlans ?? 'Plans',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.sports_gymnastics_outlined),
              activeIcon: const Icon(Icons.sports_gymnastics),
              label: AppLocalizations.of(context)?.exercises ?? 'Exercises',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.card_membership_outlined),
              activeIcon: const Icon(Icons.card_membership),
              label: AppLocalizations.of(context)?.subscriptions ?? 'Subscriptions',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final trainer = authProvider.currentTrainer;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _HomeScreenState.scaffoldKey.currentState?.openDrawer(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.welcome ?? 'Welcome back,',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              trainer?.name ?? 'Trainer',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final trainerId = authProvider.trainerId;
          if (trainerId != null) {
            final playersProvider = Provider.of<PlayersProvider>(context, listen: false);
            final plansProvider = Provider.of<WorkoutPlansProvider>(context, listen: false);
            final exercisesProvider = Provider.of<ExercisesProvider>(context, listen: false);
            final subscriptionsProvider = Provider.of<SubscriptionsProvider>(context, listen: false);

            await Future.wait([
              playersProvider.loadPlayers(trainerId),
              plansProvider.loadPlans(trainerId),
              exercisesProvider.loadExercises(trainerId),
              subscriptionsProvider.loadSubscriptions(trainerId),
            ]);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Grid
              _buildStatsGrid(context),
              const SizedBox(height: 24),

              // Expiring Soon Section
              _buildExpiringSoonSection(context),
              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Consumer4<PlayersProvider, WorkoutPlansProvider, ExercisesProvider, SubscriptionsProvider>(
      builder: (context, players, plans, exercises, subscriptions, child) {
        final l10n = AppLocalizations.of(context);
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            StatCard(
              title: l10n?.players ?? 'Players',
              value: players.count.toString(),
              icon: Icons.people,
              gradient: AppTheme.primaryGradient,
            ),
            StatCard(
              title: l10n?.workoutPlans ?? 'Workout Plans',
              value: plans.count.toString(),
              icon: Icons.fitness_center,
              gradient: const LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)],
              ),
            ),
            StatCard(
              title: l10n?.exercises ?? 'Exercises',
              value: exercises.count.toString(),
              icon: Icons.sports_gymnastics,
              gradient: AppTheme.accentGradient,
            ),
            StatCard(
              title: l10n?.activeSubscription ?? 'Active Subs',
              value: subscriptions.activeCount.toString(),
              icon: Icons.card_membership,
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpiringSoonSection(BuildContext context) {
    return Consumer<SubscriptionsProvider>(
      builder: (context, subscriptions, child) {
        final expiring = subscriptions.expiringSoon;
        final l10n = AppLocalizations.of(context);
        
        if (expiring.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n?.expiringSoon ?? 'Expiring Soon',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to subscriptions tab
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.warning.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: AppTheme.warning,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${expiring.length} subscription${expiring.length == 1 ? '' : 's'} expiring',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.warning,
                              ),
                            ),
                            Text(
                              'within the next 7 days',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.person_add,
                label: l10n?.addPlayer ?? 'Add Player',
                color: AppTheme.primaryColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PlayersListScreen(showAddDialog: true),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.add_box,
                label: l10n?.newPlan ?? 'New Plan',
                color: AppTheme.accentColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PlansListScreen(showAddDialog: true),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
