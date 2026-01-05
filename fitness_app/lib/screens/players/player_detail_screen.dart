import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/player.dart';
import '../../models/subscription.dart';
import '../../providers/auth_provider.dart';
import '../../providers/players_provider.dart';
import '../../providers/subscriptions_provider.dart';
import '../../providers/workout_plans_provider.dart';
import '../../utils/theme.dart';
import '../../utils/date_helpers.dart';
import '../subscriptions/subscription_form_screen.dart';
import 'player_form_screen.dart';
import 'player_workout_plan_screen.dart';

class PlayerDetailScreen extends StatefulWidget {
  final int playerId;

  const PlayerDetailScreen({super.key, required this.playerId});

  @override
  State<PlayerDetailScreen> createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen> {
  List<Subscription> _subscriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    final subscriptionsProvider = Provider.of<SubscriptionsProvider>(context, listen: false);
    final subs = await subscriptionsProvider.getByPlayer(widget.playerId);
    setState(() {
      _subscriptions = subs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final playersProvider = Provider.of<PlayersProvider>(context);
    final player = playersProvider.getById(widget.playerId);

    if (player == null) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n?.error ?? 'اللاعب غير موجود')),
      );
    }

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.playerDetails ?? 'تفاصيل اللاعب'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PlayerFormScreen(player: player),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                final confirmed = await _showDeleteDialog(context, l10n);
                if (confirmed == true && context.mounted) {
                  await playersProvider.deletePlayer(player.id!);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, color: AppTheme.error),
                    const SizedBox(width: 8),
                    Text(l10n?.delete ?? 'حذف', style: const TextStyle(color: AppTheme.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player Info Card
            _buildPlayerInfoCard(context, player, l10n),
            const SizedBox(height: 24),

            // Active Subscription
            _buildActiveSubscriptionSection(context, player, l10n),
            const SizedBox(height: 24),

            // Subscription History
            _buildSubscriptionHistory(context, player, l10n),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SubscriptionFormScreen(playerId: widget.playerId),
            ),
          );
          _loadSubscriptions();
        },
        icon: const Icon(Icons.add),
        label: Text(l10n?.assignPlan ?? 'تعيين خطة'),
      ),
    );
  }

  Widget _buildPlayerInfoCard(BuildContext context, Player player, AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              player.name,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Weight and Height
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (player.weight != null)
                  _InfoChip(
                    icon: Icons.monitor_weight_outlined,
                    label: '${player.weight} كغ',
                  ),
                if (player.weight != null && player.height != null)
                  const SizedBox(width: 8),
                if (player.height != null)
                  _InfoChip(
                    icon: Icons.height_outlined,
                    label: '${player.height} سم',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (player.phone != null && player.phone!.isNotEmpty)
                  _InfoChip(
                    icon: Icons.phone_outlined,
                    label: player.phone!,
                  ),
                if (player.email != null && player.email!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.email_outlined,
                    label: player.email!,
                  ),
                ],
              ],
            ),
            if (player.notes != null && player.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes, size: 20, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      player.notes!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSubscriptionSection(BuildContext context, Player player, AppLocalizations? l10n) {
    final activeSubscription = _subscriptions.where((s) => s.isActive).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.activeSubscription ?? 'الاشتراك النشط',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        if (activeSubscription.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.textSecondary.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.card_membership_outlined,
                  size: 48,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n?.noActiveSubscription ?? 'لا يوجد اشتراك نشط',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          _buildSubscriptionCard(context, activeSubscription.first, player, l10n, isActive: true),
      ],
    );
  }

  Widget _buildSubscriptionHistory(BuildContext context, Player player, AppLocalizations? l10n) {
    final pastSubscriptions = _subscriptions.where((s) => !s.isActive).toList();

    if (pastSubscriptions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.subscriptionHistory ?? 'سجل الاشتراكات',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        ...pastSubscriptions.map((sub) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSubscriptionCard(context, sub, player, l10n),
        )),
        const SizedBox(height: 60), // Space for FAB
      ],
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, Subscription subscription, Player player, AppLocalizations? l10n, {bool isActive = false}) {
    final plansProvider = Provider.of<WorkoutPlansProvider>(context);
    final plan = plansProvider.getById(subscription.planId);

    Color statusColor;
    String statusText;
    
    if (subscription.status == Subscription.statusCancelled) {
      statusColor = AppTheme.error;
      statusText = l10n?.cancelled ?? 'ملغي';
    } else if (subscription.isExpired) {
      statusColor = AppTheme.textSecondary;
      statusText = l10n?.expired ?? 'منتهي';
    } else if (subscription.isExpiringSoon) {
      statusColor = AppTheme.warning;
      statusText = 'باقي ${subscription.daysRemaining} أيام';
    } else {
      statusColor = AppTheme.success;
      statusText = l10n?.active ?? 'نشط';
    }

    return Card(
      color: isActive ? AppTheme.primaryColor.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isActive
            ? const BorderSide(color: AppTheme.primaryColor, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan?.name ?? 'خطة غير معروفة',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.date_range, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Text(
                  '${DateHelpers.formatShortDate(subscription.startDate)} - ${DateHelpers.formatShortDate(subscription.endDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (subscription.amountPaid != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.payments_outlined, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    '\$${subscription.amountPaid!.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            // View Plan Button
            if (plan != null && isActive) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PlayerWorkoutPlanScreen(
                          player: player,
                          plan: plan,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.fitness_center),
                  label: Text(l10n?.viewPlan ?? 'عرض الخطة'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context, AppLocalizations? l10n) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.deleteConfirmation ?? 'حذف اللاعب؟'),
        content: Text(
          'هل أنت متأكد أنك تريد حذف هذا اللاعب؟ سيتم حذف جميع اشتراكاته.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.cancel ?? 'إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: Text(l10n?.delete ?? 'حذف'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
