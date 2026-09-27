import 'dart:async';
import 'dart:math';

abstract class CryDetector {
  Stream<CryScore> get scores;
  Future<void> start();
  Future<void> stop();
  bool get listening;
}

class CryScore {
  const CryScore({required this.confidence, required this.at, required this.sustained});

  final double confidence;
  final DateTime at;
  final bool sustained;
}

class EnergyCryDetector implements CryDetector {
  final _ctrl = StreamController<CryScore>.broadcast();
  Timer? _timer;
  bool _listening = false;
  int _streak = 0;
  final _rng = Random();

  @override
  Stream<CryScore> get scores => _ctrl.stream;

  @override
  bool get listening => _listening;

  @override
  Future<void> start() async {
    if (_listening) return;
    _listening = true;
    _streak = 0;
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      final burst = _rng.nextDouble() > 0.92;
      final confidence = burst ? 0.55 + _rng.nextDouble() * 0.4 : _rng.nextDouble() * 0.25;
      if (confidence >= 0.6) {
        _streak++;
      } else {
        _streak = 0;
      }
      _ctrl.add(CryScore(
        confidence: confidence,
        at: DateTime.now(),
        sustained: _streak >= 3,
      ));
    });
  }

  @override
  Future<void> stop() async {
    _listening = false;
    _timer?.cancel();
    _timer = null;
    _streak = 0;
  }
}
