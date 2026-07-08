import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../config.dart';
import '../providers.dart';

/// Capture flow: pin at the gate (GPS accuracy-gated) → building details → unit
/// types with vacancy counts → photos → save locally + kick a sync. Everything
/// writes to the offline db first; the network is never on the critical path.
class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final _formKey = GlobalKey<FormState>();

  // Live GPS.
  Position? _live;
  Position? _pinned; // frozen fix the agent accepted at the gate

  // Building fields.
  final _estate = TextEditingController(text: 'roysambu');
  final _name = TextEditingController();
  final _floors = TextEditingController();
  final _caretakerName = TextEditingController();
  final _caretakerPhone = TextEditingController(text: '+254');
  bool _parking = false;

  final List<_UnitDraft> _units = [_UnitDraft()];
  final List<String> _photoPaths = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _startGps();
  }

  Future<void> _startGps() async {
    final loc = ref.read(locationServiceProvider);
    if (!await loc.ensurePermission()) return;
    loc.watchPosition().listen((pos) {
      if (mounted) setState(() => _live = pos);
    });
  }

  bool get _accurateEnough =>
      _live != null && _live!.accuracy <= AppConfig.maxGpsAccuracyMeters;

  @override
  void dispose() {
    _estate.dispose();
    _name.dispose();
    _floors.dispose();
    _caretakerName.dispose();
    _caretakerPhone.dispose();
    for (final u in _units) {
      u.dispose();
    }
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final path = await ref.read(photoServiceProvider).captureCompressed();
    if (path != null) setState(() => _photoPaths.add(path));
  }

  Future<void> _save() async {
    if (_pinned == null) {
      _toast('Pin the building at the gate first.');
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    final repo = ref.read(captureRepositoryProvider);
    try {
      final buildingId = await repo.saveBuilding(
        estateSlug: _estate.text.trim(),
        name: _name.text.trim(),
        lat: _pinned!.latitude,
        lng: _pinned!.longitude,
        gpsAccuracy: _pinned!.accuracy,
        floors: int.tryParse(_floors.text.trim()),
        parking: _parking,
        caretakerName: _caretakerName.text.trim(),
        caretakerPhone: _cleanPhone(_caretakerPhone.text),
      );

      for (final u in _units) {
        final rent = int.tryParse(u.rent.text.trim());
        if (rent == null) continue; // skip half-filled rows
        final unitId = await repo.saveUnitType(
          buildingId: buildingId,
          kind: u.kind,
          rentKes: rent,
          depositKes: int.tryParse(u.deposit.text.trim()),
        );
        await repo.addVacancy(
          unitTypeId: unitId,
          vacantCount: int.tryParse(u.vacant.text.trim()) ?? 0,
        );
      }

      for (final path in _photoPaths) {
        await repo.addPhoto(buildingId: buildingId, localPath: path);
      }

      // Fire-and-forget: capture is done regardless of whether the sync lands.
      unawaited(ref.read(syncServiceProvider).drain());
      if (mounted) {
        _toast('Saved. It will sync when you are online.');
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  /// The phone field is pre-filled with the bare "+254" prefix for convenience.
  /// If the agent never types a number, don't send the prefix — the server
  /// rejects it as an invalid KE number and fails the whole building sync.
  String _cleanPhone(String raw) {
    final trimmed = raw.trim();
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty || digits == '254') return '';
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture building')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _GpsCard(
              live: _live,
              pinned: _pinned,
              accurateEnough: _accurateEnough,
              onPin: _accurateEnough
                  ? () => setState(() => _pinned = _live)
                  : null,
              onRepin: () => setState(() => _pinned = null),
            ),
            const SizedBox(height: 16),
            _EstateField(controller: _estate),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Building name (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _floors,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Floors',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Parking'),
                    value: _parking,
                    onChanged: (v) => setState(() => _parking = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _caretakerName,
              decoration: const InputDecoration(
                labelText: 'Caretaker name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _caretakerPhone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Caretaker phone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Unit types',
                    style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  onPressed: () => setState(() => _units.add(_UnitDraft())),
                ),
              ],
            ),
            ..._units.asMap().entries.map((e) => _UnitRow(
                  draft: e.value,
                  onRemove: _units.length > 1
                      ? () => setState(() => _units.removeAt(e.key))
                      : null,
                  onChanged: () => setState(() {}),
                )),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: Text(_photoPaths.isEmpty
                  ? 'Add photo'
                  : '${_photoPaths.length} photo(s) — add more'),
              onPressed: _addPhoto,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: const Text('Save capture'),
              onPressed: _saving ? null : _save,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// GPS accuracy gate. The pin button only unlocks at ≤ 15m; a pinned fix is
/// frozen so a later drift doesn't move the gate.
class _GpsCard extends StatelessWidget {
  const _GpsCard({
    required this.live,
    required this.pinned,
    required this.accurateEnough,
    required this.onPin,
    required this.onRepin,
  });

  final Position? live;
  final Position? pinned;
  final bool accurateEnough;
  final VoidCallback? onPin;
  final VoidCallback onRepin;

  @override
  Widget build(BuildContext context) {
    if (pinned != null) {
      return Card(
        color: Colors.green.withValues(alpha: 0.1),
        child: ListTile(
          leading: const Icon(Icons.gps_fixed, color: Colors.green),
          title: Text(
              '${pinned!.latitude.toStringAsFixed(6)}, '
              '${pinned!.longitude.toStringAsFixed(6)}'),
          subtitle: Text('Pinned · ±${pinned!.accuracy.toStringAsFixed(0)}m'),
          trailing: TextButton(onPressed: onRepin, child: const Text('Re-pin')),
        ),
      );
    }

    final acc = live?.accuracy;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(accurateEnough ? Icons.gps_fixed : Icons.gps_not_fixed,
                    color: accurateEnough ? Colors.green : Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    live == null
                        ? 'Acquiring GPS…'
                        : 'Accuracy ±${acc!.toStringAsFixed(0)}m'
                            '${accurateEnough ? '' : ' — move to the gate, wait for ≤ ${AppConfig.maxGpsAccuracyMeters.toInt()}m'}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.push_pin),
                label: const Text('Pin building here'),
                onPressed: onPin, // null (disabled) until accurate enough
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitRow extends StatelessWidget {
  const _UnitRow({
    required this.draft,
    required this.onRemove,
    required this.onChanged,
  });

  final _UnitDraft draft;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  static const _kinds = ['BEDSITTER', '1BR', '2BR', '3BR', 'SINGLE'];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: draft.kind,
                    decoration: const InputDecoration(
                        labelText: 'Type', border: OutlineInputBorder()),
                    items: _kinds
                        .map((k) =>
                            DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) draft.kind = v;
                      onChanged();
                    },
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: draft.rent,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Rent KES', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: draft.deposit,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Deposit', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 90,
                  child: TextFormField(
                    controller: draft.vacant,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Vacant', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Estate picker. A building must pin to an estate slug that already exists on
/// the server — a free-typed slug (e.g. "pipeline") fails every sync silently.
/// So when we have the estate list (cached offline-first), this is a dropdown of
/// known-good slugs. It falls back to free text only if we've never been online
/// and have nothing cached, so field capture is never blocked.
class _EstateField extends ConsumerWidget {
  const _EstateField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(estateOptionsProvider);

    return options.when(
      loading: () => _fallbackTextField(enabled: true),
      error: (_, _) => _fallbackTextField(enabled: true),
      data: (estates) {
        if (estates.isEmpty) return _fallbackTextField(enabled: true);
        final slugs = estates.map((e) => e.slug).toSet();
        final current = slugs.contains(controller.text) ? controller.text : null;
        return DropdownButtonFormField<String>(
          initialValue: current,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Estate',
            helperText: 'Pick the estate this building is in',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final e in estates)
              DropdownMenuItem(value: e.slug, child: Text('${e.name} · ${e.slug}')),
          ],
          onChanged: (v) => controller.text = v ?? '',
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        );
      },
    );
  }

  Widget _fallbackTextField({required bool enabled}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: const InputDecoration(
        labelText: 'Estate slug',
        helperText: 'e.g. roysambu — must exist on the server',
        border: OutlineInputBorder(),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }
}

class _UnitDraft {
  String kind = 'BEDSITTER';
  final rent = TextEditingController();
  final deposit = TextEditingController();
  final vacant = TextEditingController(text: '1');

  void dispose() {
    rent.dispose();
    deposit.dispose();
    vacant.dispose();
  }
}
