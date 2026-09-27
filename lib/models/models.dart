import 'dart:math';

class GeoPoint {
  const GeoPoint({required this.lat, required this.lon, this.at});

  final double lat;
  final double lon;
  final DateTime? at;

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lon': lon,
        'at': at?.toIso8601String(),
      };

  factory GeoPoint.fromJson(Map<String, dynamic> json) => GeoPoint(
        lat: (json['lat'] as num).toDouble(),
        lon: (json['lon'] as num).toDouble(),
        at: json['at'] == null ? null : DateTime.tryParse(json['at'] as String),
      );

  double distanceTo(GeoPoint other) {
    const r = 6371000.0;
    final dLat = _rad(other.lat - lat);
    final dLon = _rad(other.lon - lon);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat)) * cos(_rad(other.lat)) * sin(dLon / 2) * sin(dLon / 2);
    return 2 * r * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _rad(double deg) => deg * pi / 180.0;
}

class Geofence {
  Geofence({
    required this.id,
    required this.name,
    required this.center,
    required this.radiusMeters,
    this.enabled = true,
  });

  final String id;
  String name;
  GeoPoint center;
  double radiusMeters;
  bool enabled;

  bool contains(GeoPoint p) => p.distanceTo(center) <= radiusMeters;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'center': center.toJson(),
        'radiusMeters': radiusMeters,
        'enabled': enabled,
      };

  factory Geofence.fromJson(Map<String, dynamic> json) => Geofence(
        id: json['id'] as String,
        name: json['name'] as String,
        center: GeoPoint.fromJson(json['center'] as Map<String, dynamic>),
        radiusMeters: (json['radiusMeters'] as num).toDouble(),
        enabled: json['enabled'] as bool? ?? true,
      );
}

enum AlertKind { geofenceEnter, geofenceExit, cry, sos, lowBattery, info }

class WatchAlert {
  WatchAlert({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.at,
    this.read = false,
  });

  final String id;
  final AlertKind kind;
  final String title;
  final String body;
  final DateTime at;
  bool read;

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'title': title,
        'body': body,
        'at': at.toIso8601String(),
        'read': read,
      };

  factory WatchAlert.fromJson(Map<String, dynamic> json) => WatchAlert(
        id: json['id'] as String,
        kind: AlertKind.values.firstWhere(
          (k) => k.name == json['kind'],
          orElse: () => AlertKind.info,
        ),
        title: json['title'] as String,
        body: json['body'] as String,
        at: DateTime.parse(json['at'] as String),
        read: json['read'] as bool? ?? false,
      );
}

class ChildProfile {
  ChildProfile({
    required this.id,
    required this.displayName,
    this.pairingPin,
    this.lastFix,
    this.batteryPercent = 100,
    this.watchConnected = false,
  });

  final String id;
  String displayName;
  String? pairingPin;
  GeoPoint? lastFix;
  int batteryPercent;
  bool watchConnected;

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'pairingPin': pairingPin,
        'lastFix': lastFix?.toJson(),
        'batteryPercent': batteryPercent,
        'watchConnected': watchConnected,
      };

  factory ChildProfile.fromJson(Map<String, dynamic> json) => ChildProfile(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        pairingPin: json['pairingPin'] as String?,
        lastFix: json['lastFix'] == null
            ? null
            : GeoPoint.fromJson(json['lastFix'] as Map<String, dynamic>),
        batteryPercent: json['batteryPercent'] as int? ?? 100,
        watchConnected: json['watchConnected'] as bool? ?? false,
      );
}

class AppSnapshot {
  AppSnapshot({
    required this.child,
    required this.fences,
    required this.alerts,
    this.cryListening = false,
    this.demoMode = true,
  });

  ChildProfile child;
  List<Geofence> fences;
  List<WatchAlert> alerts;
  bool cryListening;
  bool demoMode;

  Map<String, dynamic> toJson() => {
        'child': child.toJson(),
        'fences': fences.map((f) => f.toJson()).toList(),
        'alerts': alerts.map((a) => a.toJson()).toList(),
        'cryListening': cryListening,
        'demoMode': demoMode,
      };

  factory AppSnapshot.fromJson(Map<String, dynamic> json) => AppSnapshot(
        child: ChildProfile.fromJson(json['child'] as Map<String, dynamic>),
        fences: (json['fences'] as List<dynamic>)
            .map((e) => Geofence.fromJson(e as Map<String, dynamic>))
            .toList(),
        alerts: (json['alerts'] as List<dynamic>)
            .map((e) => WatchAlert.fromJson(e as Map<String, dynamic>))
            .toList(),
        cryListening: json['cryListening'] as bool? ?? false,
        demoMode: json['demoMode'] as bool? ?? true,
      );
}
