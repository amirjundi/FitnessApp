import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/player.dart';
import '../../providers/auth_provider.dart';
import '../../providers/players_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/empty_state.dart';
import 'player_detail_screen.dart';
import 'player_form_screen.dart';

class PlayersListScreen extends StatefulWidget {
  final bool showAddDialog;

  const PlayersListScreen({super.key, this.showAddDialog = false});

  @override
  State<PlayersListScreen> createState() => _PlayersListScreenState();
}

class _PlayersListScreenState extends State<PlayersListScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.showAddDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToAddPlayer();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddPlayer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PlayerFormScreen(),
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
                  final trainerId = Provider.of<AuthProvider>(context, listen: false).trainerId;
                  if (trainerId != null) {
                    Provider.of<PlayersProvider>(context, listen: false)
                        .search(trainerId, query);
                  }
                },
              )
            : Text(l10n?.players ?? 'اللاعبين'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  final trainerId = Provider.of<AuthProvider>(context, listen: false).trainerId;
                  if (trainerId != null) {
                    Provider.of<PlayersProvider>(context, listen: false)
                        .loadPlayers(trainerId);
                  }
                }
              });
            },
          ),
        ],
      ),
      body: Consumer<PlayersProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.players.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline,
              title: l10n?.noPlayers ?? 'لا يوجد لاعبين',
              message: l10n?.addFirstPlayer ?? 'أضف لاعبك الأول للبدء',
              actionLabel: l10n?.addPlayer ?? 'إضافة لاعب',
              onAction: _navigateToAddPlayer,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.players.length,
            itemBuilder: (context, index) {
              final player = provider.players[index];
              return _PlayerCard(
                player: player,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlayerDetailScreen(playerId: player.id!),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddPlayer,
        icon: const Icon(Icons.person_add),
        label: Text(l10n?.addPlayer ?? 'إضافة لاعب'),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback onTap;

  const _PlayerCard({
    required this.player,
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 24,
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
                      player.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (player.phone != null && player.phone!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              player.phone!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    if (player.email != null && player.email!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              size: 14,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              player.email!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
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
