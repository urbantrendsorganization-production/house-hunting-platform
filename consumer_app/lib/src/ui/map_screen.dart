import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../config.dart';
import '../data/models.dart';
import '../providers.dart';
import 'building_sheet.dart';
import 'filter_sheet.dart';
import 'search_bar.dart';

/// Map-first discovery. Open → locate → see vacant houses → tap → details.
/// Markers/clusters come from the viewport API (server-side clustering), pans
/// are debounced, and a list view keeps the app usable without a Maps key or on
/// a low-end device.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _controller;
  CameraPosition _camera = const CameraPosition(
    target: LatLng(AppConfig.defaultLat, AppConfig.defaultLng),
    zoom: 14,
  );

  Timer? _debounce;
  Set<Marker> _markers = {};
  List<BuildingMarker> _lastMarkers = const [];
  bool _loading = false;
  bool _listView = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _goToUser();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _goToUser() async {
    Position? pos;
    try {
      pos = await ref.read(locationServiceProvider).currentPosition();
    } catch (_) {
      pos = null;
    }
    if (pos == null) {
      _refetch(); // no permission/fix — just load the default camera area
      return;
    }
    final target = LatLng(pos.latitude, pos.longitude);
    _camera = CameraPosition(target: target, zoom: 16);
    try {
      await _controller?.animateCamera(CameraUpdate.newCameraPosition(_camera));
    } catch (_) {
      // Controller may be disposed (list view) — the camera target is already
      // updated, so _refetch still queries the right place.
    }
    _refetch();
  }

  void _onIdle() {
    _debounce?.cancel();
    _debounce = Timer(AppConfig.viewportDebounce, _refetch);
  }

  Future<void> _refetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final controller = _controller;
      if (controller != null && !_listView) {
        final bounds = await controller.getVisibleRegion();
        final zoom = _camera.zoom.round();
        final result = await ref.read(apiClientProvider).viewport(
              w: bounds.southwest.longitude,
              s: bounds.southwest.latitude,
              e: bounds.northeast.longitude,
              n: bounds.northeast.latitude,
              zoom: zoom,
            );
        _applyResult(result);
      } else {
        // No map controller yet (no Maps key, or list-only view) — we can't
        // read a viewport bbox, so fall back to a radius query around the
        // current camera target. Keeps the list usable per the
        // graceful-degradation rule (CLAUDE.md).
        final target = _camera.target;
        final markers = await ref.read(apiClientProvider).nearMe(
              lat: target.latitude,
              lng: target.longitude,
              radiusKm: AppConfig.nearMeRadiusKm,
            );
        _applyMarkers(markers);
      }
    } catch (e) {
      setState(() => _error = 'Could not load listings. Check your connection.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyResult(ViewportResult result) {
    final markers = <Marker>{};

    if (result.isClusters) {
      for (final c in result.clusters) {
        markers.add(Marker(
          markerId: MarkerId('cluster_${c.lat}_${c.lng}'),
          position: LatLng(c.lat, c.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: '${c.count} vacancies'),
          onTap: () => _zoomInto(LatLng(c.lat, c.lng)),
        ));
      }
      _lastMarkers = const [];
      setState(() => _markers = markers);
    } else {
      _applyMarkers(result.markers);
    }
  }

  /// Build pins + the list-view backing data from a flat marker list. Shared by
  /// the viewport path and the keyless near-me fallback.
  void _applyMarkers(List<BuildingMarker> raw) {
    final filters = ref.read(mapFiltersProvider);
    final visible = raw.where(filters.allows).toList();
    _lastMarkers = visible;
    final markers = <Marker>{};
    for (final b in visible) {
      markers.add(Marker(
        markerId: MarkerId(b.id),
        position: LatLng(b.lat, b.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          b.isDemoted ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueGreen,
        ),
        infoWindow: InfoWindow(
          title: b.name.isEmpty ? b.estate : b.name,
          snippet: _freshness(b.verifiedDaysAgo),
        ),
        onTap: () => _openBuilding(b.id),
      ));
    }
    setState(() => _markers = markers);
  }

  Future<void> _zoomInto(LatLng target) async {
    _camera = CameraPosition(target: target, zoom: _camera.zoom + 3);
    await _controller?.animateCamera(CameraUpdate.newCameraPosition(_camera));
    _refetch();
  }

  Future<void> _openBuilding(String id) async {
    final detail = await ref.read(apiClientProvider).buildingDetail(id);
    if (!mounted) return;
    if (detail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This listing is no longer available.')));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BuildingSheet(detail: detail),
    );
  }

  static String _freshness(int? days) {
    if (days == null) return 'Verified recently';
    if (days == 0) return 'Verified today';
    if (days == 1) return 'Verified yesterday';
    return 'Verified $days days ago';
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(mapFiltersProvider);
    return Scaffold(
      body: Stack(
        children: [
          if (_listView)
            _ListView(markers: _lastMarkers, onTap: _openBuilding)
          else
            GoogleMap(
              initialCameraPosition: _camera,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
              onMapCreated: (c) {
                _controller = c;
                _refetch();
              },
              onCameraMove: (pos) => _camera = pos,
              onCameraIdle: _onIdle,
            ),

          // Search + filter row.
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Row(
              children: [
                Expanded(
                  child: PlacesSearchBar(
                    onPicked: (lat, lng) => _zoomInto(LatLng(lat, lng)),
                  ),
                ),
                const SizedBox(width: 8),
                Badge(
                  isLabelVisible: filters.isActive,
                  child: Material(
                    elevation: 2,
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        builder: (_) => const FilterSheet(),
                      ).then((_) => _refetch()),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_loading)
            const Positioned(
              top: 0, left: 0, right: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),

          if (_error != null)
            Positioned(
              bottom: 90,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_error!),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'list',
            onPressed: () {
              setState(() {
                _listView = !_listView;
                // The GoogleMap widget is torn down when we show the list, so
                // its controller becomes stale — drop it and let _refetch use
                // the near-me fallback instead of a disposed controller.
                if (_listView) _controller = null;
              });
              if (_listView) _refetch();
            },
            child: Icon(_listView ? Icons.map : Icons.list),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'near',
            icon: const Icon(Icons.my_location),
            label: const Text('Near me'),
            onPressed: _goToUser,
          ),
        ],
      ),
    );
  }
}

/// Low-end / no-key fallback: a plain list of the buildings in view.
class _ListView extends StatelessWidget {
  const _ListView({required this.markers, required this.onTap});
  final List<BuildingMarker> markers;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (markers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Zoom in on the map to load nearby vacancies.',
              textAlign: TextAlign.center),
        ),
      );
    }
    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 72, bottom: 96),
        itemCount: markers.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final b = markers[i];
          return ListTile(
            leading: Icon(Icons.home_work,
                color: b.isDemoted ? Colors.orange : Colors.green),
            title: Text(b.name.isEmpty ? b.estate : b.name),
            subtitle: Text(_MapScreenState._freshness(b.verifiedDaysAgo)),
            trailing: b.distanceM != null
                ? Text('${(b.distanceM! / 1000).toStringAsFixed(1)} km')
                : const Icon(Icons.chevron_right),
            onTap: () => onTap(b.id),
          );
        },
      ),
    );
  }
}
