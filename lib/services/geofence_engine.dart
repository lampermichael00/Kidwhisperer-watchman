import '../models/models.dart';

class GeofenceEvent {
  GeofenceEvent({required this.fence, required this.entered, required this.at});

  final Geofence fence;
  final bool entered;
  final DateTime at;
}

class GeofenceEngine {
  final Map<String, bool> _inside = {};

  List<GeofenceEvent> evaluate(GeoPoint fix, List<Geofence> fences) {
    final events = <GeofenceEvent>[];
    for (final fence in fences.where((f) => f.enabled)) {
      final nowInside = fence.contains(fix);
      final wasInside = _inside[fence.id];
      _inside[fence.id] = nowInside;
      if (wasInside == null) continue;
      if (nowInside && !wasInside) {
        events.add(GeofenceEvent(fence: fence, entered: true, at: fix.at ?? DateTime.now()));
      } else if (!nowInside && wasInside) {
        events.add(GeofenceEvent(fence: fence, entered: false, at: fix.at ?? DateTime.now()));
      }
    }
    return events;
  }

  void reset() => _inside.clear();
}
