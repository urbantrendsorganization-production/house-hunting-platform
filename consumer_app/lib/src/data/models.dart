// Plain models mirroring the consumer API serializers
// (`api/core/consumer_serializers.py`). Every listing carries a verified age —
// the freshness promise is baked into the type.

class BuildingMarker {
  BuildingMarker({
    required this.id,
    required this.name,
    required this.estate,
    required this.lat,
    required this.lng,
    required this.verifiedDaysAgo,
    required this.isDemoted,
    this.distanceM,
  });

  final String id;
  final String name;
  final String estate;
  final double lat;
  final double lng;
  final int? verifiedDaysAgo;
  final bool isDemoted;
  final int? distanceM; // only set by near-me

  factory BuildingMarker.fromJson(Map<String, dynamic> j) => BuildingMarker(
        id: j['id'] as String,
        name: (j['name'] as String?) ?? '',
        estate: (j['estate'] as String?) ?? '',
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        verifiedDaysAgo: j['verified_days_ago'] as int?,
        isDemoted: (j['is_demoted'] as bool?) ?? false,
        distanceM: j['distance_m'] as int?,
      );
}

class Cluster {
  Cluster({required this.lat, required this.lng, required this.count});
  final double lat;
  final double lng;
  final int count;

  factory Cluster.fromJson(Map<String, dynamic> j) => Cluster(
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        count: j['count'] as int,
      );
}

/// A viewport response is either markers or clusters (server decides by zoom).
class ViewportResult {
  ViewportResult({required this.markers, required this.clusters});
  final List<BuildingMarker> markers;
  final List<Cluster> clusters;

  bool get isClusters => clusters.isNotEmpty && markers.isEmpty;

  factory ViewportResult.fromJson(Map<String, dynamic> j) {
    final mode = j['mode'] as String?;
    if (mode == 'clusters') {
      return ViewportResult(
        markers: const [],
        clusters: (j['clusters'] as List)
            .cast<Map<String, dynamic>>()
            .map(Cluster.fromJson)
            .toList(),
      );
    }
    return ViewportResult(
      markers: (j['markers'] as List)
          .cast<Map<String, dynamic>>()
          .map(BuildingMarker.fromJson)
          .toList(),
      clusters: const [],
    );
  }
}

class UnitType {
  UnitType({
    required this.kind,
    required this.kindDisplay,
    required this.rentKes,
    this.depositKes,
    this.amenities = const {},
  });

  final String kind;
  final String kindDisplay;
  final int rentKes;
  final int? depositKes;
  final Map<String, dynamic> amenities;

  factory UnitType.fromJson(Map<String, dynamic> j) => UnitType(
        kind: j['kind'] as String,
        kindDisplay: (j['kind_display'] as String?) ?? j['kind'] as String,
        rentKes: j['rent_kes'] as int,
        depositKes: j['deposit_kes'] as int?,
        amenities: (j['amenities'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
}

class BuildingDetail {
  BuildingDetail({
    required this.id,
    required this.name,
    required this.estate,
    required this.lat,
    required this.lng,
    required this.verifiedDaysAgo,
    required this.isDemoted,
    required this.floors,
    required this.parking,
    required this.waterNotes,
    required this.powerNotes,
    required this.securityNotes,
    required this.caretakerName,
    required this.unitTypes,
  });

  final String id;
  final String name;
  final String estate;
  final double lat;
  final double lng;
  final int? verifiedDaysAgo;
  final bool isDemoted;
  final int? floors;
  final bool parking;
  final String waterNotes;
  final String powerNotes;
  final String securityNotes;
  final String caretakerName;
  final List<UnitType> unitTypes;

  int? get minRentKes => unitTypes.isEmpty
      ? null
      : unitTypes.map((u) => u.rentKes).reduce((a, b) => a < b ? a : b);

  factory BuildingDetail.fromJson(Map<String, dynamic> j) => BuildingDetail(
        id: j['id'] as String,
        name: (j['name'] as String?) ?? '',
        estate: (j['estate'] as String?) ?? '',
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        verifiedDaysAgo: j['verified_days_ago'] as int?,
        isDemoted: (j['is_demoted'] as bool?) ?? false,
        floors: j['floors'] as int?,
        parking: (j['parking'] as bool?) ?? false,
        waterNotes: (j['water_notes'] as String?) ?? '',
        powerNotes: (j['power_notes'] as String?) ?? '',
        securityNotes: (j['security_notes'] as String?) ?? '',
        caretakerName: (j['caretaker_name'] as String?) ?? '',
        unitTypes: (j['unit_types'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(UnitType.fromJson)
            .toList(),
      );
}
