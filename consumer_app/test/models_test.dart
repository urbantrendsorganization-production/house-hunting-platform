import 'package:consumer_app/src/data/models.dart';
import 'package:consumer_app/src/providers.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 4 correctness: the client parses both viewport modes and the freshness
/// filter drops the right listings — pure logic, no device.
void main() {
  test('viewport parses marker mode', () {
    final r = ViewportResult.fromJson({
      'mode': 'markers',
      'markers': [
        {
          'id': 'abc',
          'name': 'Green Court',
          'estate': 'Roysambu',
          'lng': 36.89,
          'lat': -1.21,
          'verified_days_ago': 2,
          'is_demoted': false,
        }
      ],
      'count': 1,
    });
    expect(r.isClusters, isFalse);
    expect(r.markers.single.name, 'Green Court');
    expect(r.markers.single.verifiedDaysAgo, 2);
  });

  test('viewport parses cluster mode', () {
    final r = ViewportResult.fromJson({
      'mode': 'clusters',
      'clusters': [
        {'lng': 36.8, 'lat': -1.2, 'count': 7}
      ],
      'count': 7,
    });
    expect(r.isClusters, isTrue);
    expect(r.clusters.single.count, 7);
  });

  test('building detail exposes min rent across unit types', () {
    final d = BuildingDetail.fromJson({
      'id': 'x',
      'name': 'Court',
      'estate': 'Kilimani',
      'lng': 36.8,
      'lat': -1.2,
      'verified_days_ago': 1,
      'is_demoted': false,
      'floors': 4,
      'parking': true,
      'water_notes': '',
      'power_notes': '',
      'security_notes': '',
      'caretaker_name': 'Jane',
      'unit_types': [
        {'kind': '1BR', 'kind_display': '1 Bedroom', 'rent_kes': 20000},
        {'kind': 'BEDSITTER', 'kind_display': 'Bedsitter', 'rent_kes': 12000},
      ],
    });
    expect(d.minRentKes, 12000);
    expect(d.parking, isTrue);
  });

  test('freshness filter drops stale + demoted per settings', () {
    BuildingMarker m({int? days, bool demoted = false}) => BuildingMarker(
          id: 'i',
          name: 'n',
          estate: 'e',
          lat: 0,
          lng: 0,
          verifiedDaysAgo: days,
          isDemoted: demoted,
        );

    const max3 = MapFilters(maxVerifiedDays: 3);
    expect(max3.allows(m(days: 2)), isTrue);
    expect(max3.allows(m(days: 10)), isFalse);
    expect(max3.allows(m(days: null)), isFalse);

    const hideDemoted = MapFilters(hideDemoted: true);
    expect(hideDemoted.allows(m(days: 1, demoted: true)), isFalse);
    expect(hideDemoted.allows(m(days: 1)), isTrue);

    expect(const MapFilters().allows(m(days: 99, demoted: true)), isTrue);
  });
}
