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
  List<UnitType>? _units;
  final Map<String, int> _counts = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final units =
        await ref.read(captureRepositoryProvider).unitTypesFor(widget.buildingId);
    setState(() {
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

  @override
  Widget build(BuildContext context) {
    final units = _units;
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
