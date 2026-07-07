import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/places_service.dart';
import '../providers.dart';

/// Google Places search box. Debounced (≥ 300ms) and KE-restricted with session
/// tokens (CLAUDE.md cost discipline). If no Places key is configured it renders
/// as an inert, greyed hint rather than a broken box.
class PlacesSearchBar extends ConsumerStatefulWidget {
  const PlacesSearchBar({super.key, required this.onPicked});

  /// Called with the resolved coordinates of the chosen place.
  final void Function(double lat, double lng) onPicked;

  @override
  ConsumerState<PlacesSearchBar> createState() => _PlacesSearchBarState();
}

class _PlacesSearchBarState extends ConsumerState<PlacesSearchBar> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<PlacePrediction> _predictions = const [];
  bool _open = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final results =
          await ref.read(placesServiceProvider).autocomplete(value);
      if (mounted) {
        setState(() {
          _predictions = results;
          _open = results.isNotEmpty;
        });
      }
    });
  }

  Future<void> _pick(PlacePrediction p) async {
    _controller.text = p.description;
    setState(() => _open = false);
    FocusScope.of(context).unfocus();
    final loc = await ref.read(placesServiceProvider).resolve(p.placeId);
    if (loc != null) widget.onPicked(loc.lat, loc.lng);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.read(placesServiceProvider).enabled;
    return Column(
      children: [
        Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(28),
          child: TextField(
            controller: _controller,
            enabled: enabled,
            onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: enabled
                  ? 'Search an estate or place'
                  : 'Search disabled (no Places key)',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ),
        if (_open)
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(8),
            child: Column(
              children: _predictions
                  .take(5)
                  .map((p) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.place_outlined),
                        title: Text(p.description),
                        onTap: () => _pick(p),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
