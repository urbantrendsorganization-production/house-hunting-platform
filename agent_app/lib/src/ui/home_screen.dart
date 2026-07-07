import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/local/database.dart';
import '../providers.dart';
import '../sync/sync_service.dart';
import 'capture_screen.dart';
import 'login_screen.dart';
import 'reverify_sheet.dart';

/// "My buildings" — the daily-use surface. Shows each captured building with its
/// sync state, a headline pending/sync badge, and a tap-to-re-verify flow.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buildings = ref.watch(buildingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My buildings'),
        actions: [
          const _SyncBadge(),
          IconButton(
            tooltip: 'Sync now',
            icon: const Icon(Icons.sync),
            onPressed: () => ref.read(syncServiceProvider).drain(),
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Capture'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CaptureScreen()),
        ),
      ),
      body: buildings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rows) {
          if (rows.isEmpty) return const _EmptyState();
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) => _BuildingTile(building: rows[i]),
          );
        },
      ),
    );
  }
}

class _BuildingTile extends StatelessWidget {
  const _BuildingTile({required this.building});
  final Building building;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _statusIcon(building.syncStatus),
      title: Text(building.name.isEmpty ? '(unnamed building)' : building.name),
      subtitle: Text(
        '${building.estateSlug} · captured '
        '${DateFormat.MMMd().add_jm().format(building.createdAt)}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => ReverifySheet(buildingId: building.id),
      ),
    );
  }

  Widget _statusIcon(SyncStatus s) {
    switch (s) {
      case SyncStatus.synced:
        return const Icon(Icons.cloud_done, color: Colors.green);
      case SyncStatus.failed:
        return const Icon(Icons.error_outline, color: Colors.red);
      case SyncStatus.syncing:
        return const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncStatus.pending:
        return const Icon(Icons.cloud_queue, color: Colors.orange);
    }
  }
}

/// Live headline of unsynced work + the current sync phase.
class _SyncBadge extends ConsumerWidget {
  const _SyncBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingCountProvider).valueOrNull ?? 0;
    final phase = ref.watch(syncPhaseProvider).valueOrNull ?? SyncPhase.idle;

    final (label, color) = switch (phase) {
      SyncPhase.syncing => ('Syncing…', Colors.blue),
      SyncPhase.offline => ('Offline', Colors.grey),
      SyncPhase.idle =>
        pending == 0 ? ('All synced', Colors.green) : ('$pending pending', Colors.orange),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Chip(
          visualDensity: VisualDensity.compact,
          label: Text(label, style: const TextStyle(fontSize: 12)),
          backgroundColor: color.withValues(alpha: 0.15),
          side: BorderSide(color: color),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No buildings captured yet.',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(
              'Stand at a building gate and tap Capture.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
