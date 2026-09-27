import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/alert_service.dart';
import 'services/app_state.dart';
import 'services/cry_detector.dart';
import 'services/geofence_engine.dart';
import 'services/local_store.dart';
import 'services/location_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = LocalStore();
  await store.init();

  final alerts = AlertService();
  final geofences = GeofenceEngine();
  final location = LocationService();
  final cry = EnergyCryDetector();

  final state = AppState(
    store: store,
    alerts: alerts,
    geofences: geofences,
    location: location,
    cry: cry,
  );
  await state.hydrate();

  runApp(
    ChangeNotifierProvider<AppState>.value(
      value: state,
      child: const WatchmanApp(),
    ),
  );
}
