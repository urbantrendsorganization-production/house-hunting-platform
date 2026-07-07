import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Freshness + quality filters. (Price / unit-type filtering is a noted
/// follow-up that needs denormalized fields on the viewport API — see
/// [MapFilters].)
class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key});

  static const _options = <String, int?>{
    'Any freshness': null,
    'Verified ≤ 3 days': 3,
    'Verified ≤ 7 days': 7,
    'Verified ≤ 14 days': 14,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(mapFiltersProvider);
    final notifier = ref.read(mapFiltersProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter listings',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Text('Freshness'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _options.entries.map((e) {
                final selected = filters.maxVerifiedDays == e.value;
                return ChoiceChip(
                  label: Text(e.key),
                  selected: selected,
                  onSelected: (_) => notifier.setMaxDays(e.value),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Hide older (demoted) listings'),
              subtitle: const Text('Only freshly re-verified vacancies'),
              value: filters.hideDemoted,
              onChanged: (_) => notifier.toggleHideDemoted(),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
