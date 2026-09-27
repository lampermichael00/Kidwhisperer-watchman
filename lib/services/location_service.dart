import 'dart:async';
import 'dart:math';

import '../models/models.dart';

class LocationService {
  final _ctrl = StreamController<GeoPoint>.broadcast();
  Timer? _timer;
  bool demo = true;

  Stream<GeoPoint> get fixes => _ctrl.stream;

  static const GeoPoint home = GeoPoint(lat: 46.1288, lon: -112.9420);

  void startDemo({GeoPoint? origin}) {
    demo = true;
    _timer?.cancel();
    var t = 0.0;
    final start = origin ?? home;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      t += 0.18;
      final lat = start.lat + 0.0012 * sin(t) + 0.0004 * sin(t * 0.37);
      final lon = start.lon + 0.0016 * cos(t * 0.8);
      _ctrl.add(GeoPoint(lat: lat, lon: lon, at: DateTime.now()));
    });
  }

  void inject(GeoPoint point) => _ctrl.add(point);

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> dispose() async {
    stop();
    await _ctrl.close();
  }
}
