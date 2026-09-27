import '../models/models.dart';

class AlertService {
  final List<void Function(WatchAlert)> _listeners = [];

  void addListener(void Function(WatchAlert) fn) => _listeners.add(fn);

  void emit(WatchAlert alert) {
    for (final fn in List.of(_listeners)) {
      fn(alert);
    }
  }
}
