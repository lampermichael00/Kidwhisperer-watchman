import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import 'alert_service.dart';
import 'cry_detector.dart';
import 'geofence_engine.dart';
import 'local_store.dart';
import 'location_service.dart';

class AppState extends ChangeNotifier {
  AppState({
    required this.store,
    required this.alerts,
    required this.geofences,
    required this.location,
    required this.cry,
  });

  final LocalStore store;
  final AlertService alerts;
  final GeofenceEngine geofences;
  final LocationService location;
  final CryDetector cry;

  static const _uuid = Uuid();

  late AppSnapshot snapshot;
  StreamSubscription<GeoPoint>? _locSub;
  StreamSubscription<CryScore>? _crySub;

  ChildProfile get child => snapshot.child;
  List<Geofence> get fences => snapshot.fences;
  List<WatchAlert> get inbox => snapshot.alerts;
  int get unread => snapshot.alerts.where((a) => !a.read).length;
  bool get cryListening => snapshot.cryListening;
  bool get demoMode => snapshot.demoMode;

  Future<void> hydrate() async {
    snapshot = await store.load() ?? _fresh();
    alerts.addListener(_onAlert);
    _locSub = location.fixes.listen(_onFix);
    _crySub = cry.scores.listen(_onCry);
    if (snapshot.demoMode) {
      location.startDemo(origin: LocationService.home);
      snapshot.child.watchConnected = true;
    }
    if (snapshot.cryListening) {
      await cry.start();
    }
    notifyListeners();
  }

  AppSnapshot _fresh() {
    const home = LocationService.home;
    return AppSnapshot(
      child: ChildProfile(
        id: _uuid.v4(),
        displayName: 'Child',
        pairingPin: _pin(),
        lastFix: home,
        batteryPercent: 86,
        watchConnected: false,
      ),
      fences: [
        Geofence(id: _uuid.v4(), name: 'Home', center: home, radiusMeters: 80),
        Geofence(id: _uuid.v4(), name: 'Yard / block', center: home, radiusMeters: 250),
      ],
      alerts: [
        WatchAlert(
          id: _uuid.v4(),
          kind: AlertKind.info,
          title: 'Watchman ready',
          body: 'All processing stays on this phone. No cloud account required.',
          at: DateTime.now(),
        ),
      ],
    );
  }

  String _pin() {
    final n = Random.secure().nextInt(900000) + 100000;
    return n.toString();
  }

  Future<void> persist() => store.save(snapshot);

  void _onAlert(WatchAlert alert) {
    snapshot.alerts.insert(0, alert);
    if (snapshot.alerts.length > 80) {
      snapshot.alerts = snapshot.alerts.take(80).toList();
    }
    persist();
    notifyListeners();
  }

  void _onFix(GeoPoint fix) {
    snapshot.child.lastFix = fix;
    final events = geofences.evaluate(fix, snapshot.fences);
    for (final e in events) {
      alerts.emit(WatchAlert(
        id: _uuid.v4(),
        kind: e.entered ? AlertKind.geofenceEnter : AlertKind.geofenceExit,
        title: e.entered ? 'Arrived · ${e.fence.name}' : 'Left · ${e.fence.name}',
        body: e.entered
            ? '${child.displayName} entered ${e.fence.name}.'
            : '${child.displayName} left ${e.fence.name}.',
        at: e.at,
      ));
    }
    persist();
    notifyListeners();
  }

  void _onCry(CryScore score) {
    if (!snapshot.cryListening) return;
    if (!score.sustained) return;
    alerts.emit(WatchAlert(
      id: _uuid.v4(),
      kind: AlertKind.cry,
      title: 'Cry detected',
      body:
          'On-device detector reported a sustained cry (confidence ${(score.confidence * 100).round()}%). Audio was not saved.',
      at: score.at,
    ));
  }

  Future<void> toggleCry(bool on) async {
    snapshot.cryListening = on;
    if (on) {
      await cry.start();
    } else {
      await cry.stop();
    }
    await persist();
    notifyListeners();
  }

  Future<void> renameChild(String name) async {
    snapshot.child.displayName = name.trim().isEmpty ? 'Child' : name.trim();
    await persist();
    notifyListeners();
  }

  Future<void> rotatePin() async {
    snapshot.child.pairingPin = _pin();
    await persist();
    notifyListeners();
  }

  Future<void> addFence(String name, GeoPoint center, double radius) async {
    snapshot.fences.add(Geofence(
      id: _uuid.v4(),
      name: name,
      center: center,
      radiusMeters: radius,
    ));
    await persist();
    notifyListeners();
  }

  Future<void> removeFence(String id) async {
    snapshot.fences.removeWhere((f) => f.id == id);
    await persist();
    notifyListeners();
  }

  Future<void> toggleFence(String id, bool enabled) async {
    final f = snapshot.fences.cast<Geofence?>().firstWhere((e) => e!.id == id, orElse: () => null);
    if (f == null) return;
    f.enabled = enabled;
    await persist();
    notifyListeners();
  }

  void markAllRead() {
    for (final a in snapshot.alerts) {
      a.read = true;
    }
    persist();
    notifyListeners();
  }

  void triggerSosDemo() {
    alerts.emit(WatchAlert(
      id: _uuid.v4(),
      kind: AlertKind.sos,
      title: 'SOS',
      body: '${child.displayName} held the Watchman SOS button.',
      at: DateTime.now(),
    ));
  }

  Future<void> wipeLocalData() async {
    await cry.stop();
    geofences.reset();
    await store.wipe();
    snapshot = _fresh();
    location.startDemo(origin: LocationService.home);
    snapshot.child.watchConnected = true;
    await persist();
    notifyListeners();
  }

  @override
  void dispose() {
    _locSub?.cancel();
    _crySub?.cancel();
    location.dispose();
    cry.stop();
    super.dispose();
  }
}
