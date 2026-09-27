import 'package:flutter_test/flutter_test.dart';
import 'package:kidwhisperer_watchman/models/models.dart';
import 'package:kidwhisperer_watchman/services/geofence_engine.dart';

void main() {
  test('enter then exit fires once each', () {
    final engine = GeofenceEngine();
    final home = GeoPoint(lat: 46.1288, lon: -112.9420);
    final fences = [
      Geofence(id: 'home', name: 'Home', center: home, radiusMeters: 80),
    ];

    expect(engine.evaluate(home, fences), isEmpty);

    final outside = GeoPoint(lat: 46.1320, lon: -112.9420);
    final exitEvents = engine.evaluate(outside, fences);
    expect(exitEvents.length, 1);
    expect(exitEvents.first.entered, isFalse);

    final enterEvents = engine.evaluate(home, fences);
    expect(enterEvents.length, 1);
    expect(enterEvents.first.entered, isTrue);
  });

  test('disabled fence is ignored', () {
    final engine = GeofenceEngine();
    final home = GeoPoint(lat: 46.1288, lon: -112.9420);
    final fences = [
      Geofence(id: 'home', name: 'Home', center: home, radiusMeters: 80, enabled: false),
    ];
    engine.evaluate(home, fences);
    final outside = GeoPoint(lat: 46.1400, lon: -112.9420);
    expect(engine.evaluate(outside, fences), isEmpty);
  });
}
