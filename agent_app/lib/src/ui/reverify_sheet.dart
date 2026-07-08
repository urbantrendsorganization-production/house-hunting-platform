import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../providers.dart';

/// The daily re-verify loop — must take < 30s in the field (PLAN Phase 2 gate).
/// Open the building, tap the vacancy counts, hit Save: a fresh append-only
/// snapshot per unit type, then a background sync.
class ReverifySheet extends ConsumerStatefulWidget {
  const ReverifySheet({super.key, required this.buildingId});
  final String buildingId;

  @override
  ConsumerState<ReverifySheet> createState() => _ReverifySheetState();
}

class _ReverifySheetState extends ConsumerState<ReverifySheet> {
  Building? _building;
  List<UnitType>? _units;
  final Map<String, int> _counts = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(captureRepositoryProvider);
    final building = await repo.buildingById(widget.buildingId);
    final units = await repo.unitTypesFor(widget.buildingId);
    if (!mounted) return;
    setState(() {
      _building = building;
      _units = units;
      for (final u in units) {
        _counts[u.id] = 0;
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = ref.read(captureRepositoryProvider);
    for (final u in _units ?? <UnitType>[]) {
      await repo.addVacancy(unitTypeId: u.id, vacantCount: _counts[u.id] ?? 0);
    }
    ref.read(syncServiceProvider).drain();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Vacancy re-verified.')));
      Navigator.of(context).pop();
    }
  }

  /// Re-point a building the server rejected at a valid estate and re-queue it.
  Future<void> _retryEstate(String slug) async {
    await ref
        .read(captureRepositoryProvider)
        .retryBuildingWithEstate(widget.buildingId, slug);
    ref.read(syncServiceProvider).drain();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estate updated — retrying sync.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final units = _units;
    final building = _building;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (building != null && building.syncStatus == SyncStatus.failed)
            _SyncErrorBanner(
              error: building.syncError,
              onFixEstate: _retryEstate,
            ),
          Text('Re-verify vacancy',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          const Text('How many units of each type are vacant right now?',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          if (units == null)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (units.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No unit types captured for this building yet.'),
            )
          else
            ...units.map((u) => _UnitCounter(
                  label: '${u.kind} · KES ${u.rentKes}',
                  count: _counts[u.id] ?? 0,
                  onChanged: (v) => setState(() => _counts[u.id] = v),
                )),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check),
            label: const Text('Save & sync'),
            onPressed: (units == null || units.isEmpty || _saving) ? null : _save,
          ),
        ],
      ),
    );
  }
}

/// Shown when a building failed to sync. Surfaces the server's error (so the
/// agent isn't staring at a bare red icon) and, since the most common cause is
/// an estate that doesn't exist on the server, offers a one-tap re-point to a
/// known-good estate.
class _SyncErrorBanner extends ConsumerStatefulWidget {
  const _SyncErrorBanner({required this.error, required this.onFixEstate});
  final String? error;
  final Future<void> Function(String slug) onFixEstate;

  @override
  ConsumerState<_SyncErrorBanner> createState() => _SyncErrorBannerState();
}

class _SyncErrorBannerState extends ConsumerState<_SyncErrorBanner> {
  String? _slug;

  @override
  Widget build(BuildContext context) {
    final options = ref.watch(estateOptionsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: scheme.onErrorContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sync failed',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.onErrorContainer),
                  ),
                ),
              ],
            ),
            if (widget.error != null && widget.error!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(widget.error!,
                  style: TextStyle(color: scheme.onErrorContainer)),
            ],
            // Estate correction — only useful when we have the estate list.
            options.maybeWhen(
              data: (estates) => estates.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _slug,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Move to estate',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                for (final e in estates)
                                  DropdownMenuItem(
                                      value: e.slug,
                                      child: Text('${e.name} · ${e.slug}')),
                              ],
                              onChanged: (v) => setState(() => _slug = v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: _slug == null
                                ? null
                                : () => widget.onFixEstate(_slug!),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitCounter extends StatelessWidget {
  const _UnitCounter({
    required this.label,
    required this.count,
    required this.onChanged,
  });

  final String label;
  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          IconButton.filledTonal(
            icon: const Icon(Icons.remove),
            onPressed: count > 0 ? () => onChanged(count - 1) : null,
          ),
          SizedBox(
            width: 40,
            child: Text('$count',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
          ),
          IconButton.filledTonal(
            icon: const Icon(Icons.add),
            onPressed: () => onChanged(count + 1),
          ),
        ],
      ),
    );
  }
}
