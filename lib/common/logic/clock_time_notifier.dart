import 'dart:async';
import 'package:flutter/foundation.dart';

/// A singleton ValueNotifier that fires once per second,
/// shared by all clock widgets to avoid N independent Timer streams.
class ClockTimeNotifier extends ValueNotifier<DateTime> {
  static ClockTimeNotifier? _instance;
  Timer? _timer;
  int _listenerCount = 0;

  ClockTimeNotifier._() : super(DateTime.now());

  static ClockTimeNotifier get instance {
    _instance ??= ClockTimeNotifier._();
    return _instance!;
  }

  /// Call when a clock widget starts listening.
  /// Starts the timer on first listener.
  void startListening() {
    _listenerCount++;
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        value = DateTime.now();
      });
  }

  /// Call when a clock widget stops listening.
  /// Stops the timer when no listeners remain.
  void stopListening() {
    _listenerCount--;
    if (_listenerCount <= 0) {
      _listenerCount = 0;
      _timer?.cancel();
      _timer = null;
    }
  }
}
