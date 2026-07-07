import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models.dart';

/// Bottom sheet for a tapped building: freshness badge, unit types + prices,
/// building notes, a Google Maps directions deep-link, and an interest action.
class BuildingSheet extends StatelessWidget {
  const BuildingSheet({super.key, required this.detail});
  final BuildingDetail detail;

  static final _kes = NumberFormat.currency(
      locale: 'en_KE', symbol: 'KES ', decimalDigits: 0);

  Future<void> _directions() async {
    // Google Maps directions deep-link — opens the native app if installed.
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${detail.lat},${detail.lng}&travelmode=driving',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _interest(BuildContext context) {
    // Business-model hook: contacting reveals a lead. The lead-capture endpoint
    // is intentionally deferred (PLAN "explicitly deferred"), so for the pilot
    // this confirms intent locally. Wire to POST /leads/ when that lands.
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Interested?'),
        content: Text(
          detail.caretakerName.isEmpty
              ? 'We will connect you with this building. A field agent verified '
                  'it ${_ageLabel(detail.verifiedDaysAgo)}.'
              : 'Caretaker: ${detail.caretakerName}. Verified '
                  '${_ageLabel(detail.verifiedDaysAgo)}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static String _ageLabel(int? days) {
    if (days == null) return 'recently';
    if (days == 0) return 'today';
    if (days == 1) return 'yesterday';
    return '$days days ago';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            detail.name.isEmpty ? 'Building in ${detail.estate}' : detail.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(detail.estate, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          _VerifiedBadge(days: detail.verifiedDaysAgo, demoted: detail.isDemoted),
          const SizedBox(height: 20),

          Text('Available units',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (detail.unitTypes.isEmpty)
            const Text('No unit details listed.')
          else
            ...detail.unitTypes.map((u) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.meeting_room_outlined),
                  title: Text(u.kindDisplay),
                  subtitle: u.depositKes != null
                      ? Text('Deposit ${_kes.format(u.depositKes)}')
                      : null,
                  trailing: Text(_kes.format(u.rentKes),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                )),

          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (detail.parking) const _Feature(icon: Icons.local_parking, label: 'Parking'),
              if (detail.floors != null)
                _Feature(icon: Icons.layers, label: '${detail.floors} floors'),
              if (detail.waterNotes.isNotEmpty)
                _Feature(icon: Icons.water_drop, label: detail.waterNotes),
              if (detail.powerNotes.isNotEmpty)
                _Feature(icon: Icons.bolt, label: detail.powerNotes),
              if (detail.securityNotes.isNotEmpty)
                _Feature(icon: Icons.security, label: detail.securityNotes),
            ],
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.directions),
                  label: const Text('Directions'),
                  onPressed: _directions,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('I\'m interested'),
                  onPressed: () => _interest(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// The freshness promise, made visible on every listing (CLAUDE.md).
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge({required this.days, required this.demoted});
  final int? days;
  final bool demoted;

  @override
  Widget build(BuildContext context) {
    final color = demoted ? Colors.orange : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(demoted ? Icons.schedule : Icons.verified, size: 16, color: color),
          const SizedBox(width: 6),
          Text('Verified ${BuildingSheet._ageLabel(days)}',
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}
