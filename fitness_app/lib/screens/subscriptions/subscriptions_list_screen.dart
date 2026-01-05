import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/subscription.dart';
import '../../providers/subscriptions_provider.dart';
import '../../providers/players_provider.dart';
import '../../providers/workout_plans_provider.dart';
import '../../utils/theme.dart';
import '../../utils/date_helpers.dart';
import '../../widgets/empty_state.dart';
import 'subscription_form_screen.dart';

class SubscriptionsListScreen extends StatelessWidget {
  const SubscriptionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.subscriptions ?? 'الاشتراكات'),
      ),
      body: Consumer<SubscriptionsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.subscriptions.isEmpty) {
            return EmptyState(
              icon: Icons.card_membership_outlined,
              title: l10n?.noSubscriptions ?? 'لا يوجد اشتراكات',
              message: l10n?.assignPlansToPlayers ?? 'قم بتعيين خطط تمرين للاعبين',
            );
          }

          // Group by status
          final active = provider.subscriptions.where((s) => s.isActive).toList();
          final expiring = provider.subscriptions.where((s) => s.isExpiringSoon && s.isActive).toList();
          final expired = provider.subscriptions.where((s) => s.isExpired || s.status == Subscription.statusCancelled).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle,
                      label: 'Active',
                      value: active.length.toString(),
                      color: AppTheme.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.warning,
                      label: 'Expiring Soon',
                      value: expiring.length.toString(),
                      color: AppTheme.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.history,
                      label: 'Expired',
                      value: expired.length.toString(),
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Active Subscriptions
              if (active.isNotEmpty) ...[
                _buildSectionHeader(context, 'Active Subscriptions', active.length),
                const SizedBox(height: 12),
                ...active.map((sub) => _SubscriptionCard(subscription: sub)),
                const SizedBox(height: 24),
              ],

              // Expired/Cancelled
              if (expired.isNotEmpty) ...[
                _buildSectionHeader(context, 'Past Subscriptions', expired.length),
                const SizedBox(height: 12),
                ...expired.map((sub) => _SubscriptionCard(subscription: sub)),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SubscriptionFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(l10n?.newSubscription ?? 'اشتراك جديد'),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final Subscription subscription;

  const _SubscriptionCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final playersProvider = Provider.of<PlayersProvider>(context);
    final plansProvider = Provider.of<WorkoutPlansProvider>(context);
    
    final player = playersProvider.getById(subscription.playerId);
    final plan = plansProvider.getById(subscription.planId);

    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    if (subscription.status == Subscription.statusCancelled) {
      statusColor = AppTheme.error;
      statusText = 'Cancelled';
      statusIcon = Icons.cancel;
    } else if (subscription.isExpired) {
      statusColor = AppTheme.textSecondary;
      statusText = 'Expired';
      statusIcon = Icons.history;
    } else if (subscription.isExpiringSoon) {
      statusColor = AppTheme.warning;
      statusText = '${subscription.daysRemaining} days left';
      statusIcon = Icons.warning;
    } else {
      statusColor = AppTheme.success;
      statusText = 'Active';
      statusIcon = Icons.check_circle;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Player Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      player?.name.isNotEmpty == true 
                          ? player!.name[0].toUpperCase() 
                          : '?',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Player & Plan Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player?.name ?? 'Unknown Player',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        plan?.name ?? 'Unknown Plan',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            
            // Details Row
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.date_range, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        '${DateHelpers.formatShortDate(subscription.startDate)} - ${DateHelpers.formatShortDate(subscription.endDate)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (subscription.amountPaid != null)
                  Row(
                    children: [
                      const Icon(Icons.payments, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        '\$${subscription.amountPaid!.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
