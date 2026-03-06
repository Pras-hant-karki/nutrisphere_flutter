import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';

class FitnessSensorService {
  // 10-second timeout for now
  static const Duration GYM_FLOOR_TIMEOUT = Duration(seconds: 10); 
  static const double SHAKE_THRESHOLD = 13.0;
  static const double FLAT_Z_THRESHOLD = 9.0;
  // Approximation for "close to face" using orientation/accel only (no distance sensor).
  static const double EYE_CARE_ENTER_Z_THRESHOLD = 9.4;
  static const double EYE_CARE_EXIT_Z_THRESHOLD = 8.6;
  static const int EYE_CARE_STABLE_SAMPLES = 4;

  final _shakeController = StreamController<bool>.broadcast();
  final _eyeCareController = StreamController<bool>.broadcast();
  final _earDetectionController = StreamController<bool>.broadcast();
  final _safetyController = StreamController<bool>.broadcast();

  StreamSubscription<AccelerometerEvent>? _accelSub;
  Timer? _safetyTimer;
  double _baseBrightness = 0.5;
  bool _isDimmed = false;
  bool _eyeCareCandidate = false;
  int _eyeCareStableCount = 0;
  bool _isListening = false;
  bool _isDisposed = false;
  DateTime _lastShake = DateTime.now();

  Stream<bool> get shakeStream => _shakeController.stream;
  Stream<bool> get eyeCareStream => _eyeCareController.stream;
  Stream<bool> get earStream => _earDetectionController.stream;
  Stream<bool> get safetyStream => _safetyController.stream;

  Future<void> start() async {
    if (_isListening) return;
    _isListening = true;

    try {
      _baseBrightness = await ScreenBrightness().application;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Could not read screen brightness: $error');
      }
    }

    _accelSub = accelerometerEventStream().listen(
      (event) {
        if (_isDisposed) return;
        _handleShake(event);
        _handleEyeCare(event);
        _handleEar(event);
        _handleSafety(event);
      },
      onError: (error) {
        if (kDebugMode) {
          debugPrint('Accelerometer stream error: $error');
        }
      },
      cancelOnError: false,
    );
  }

  void _handleShake(AccelerometerEvent event) {
    final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    final force = (magnitude - 9.8).abs();
    if (force > SHAKE_THRESHOLD) {
      if (DateTime.now().difference(_lastShake) > const Duration(seconds: 1)) {
        _lastShake = DateTime.now();
        _shakeController.add(true);
        if (kDebugMode) {
          debugPrint('Sensor event: shake detected (force=$force)');
        }
      }
    }
  }

  void _handleEyeCare(AccelerometerEvent event) {
    // Enter/exit thresholds reduce flicker around a single boundary value.
    final nextCandidate = _isDimmed
        ? (event.z > EYE_CARE_EXIT_Z_THRESHOLD && event.x.abs() < 1.8)
        : (event.z > EYE_CARE_ENTER_Z_THRESHOLD && event.x.abs() < 1.8);

    if (nextCandidate == _eyeCareCandidate) {
      _eyeCareStableCount++;
    } else {
      _eyeCareCandidate = nextCandidate;
      _eyeCareStableCount = 1;
    }

    if (_eyeCareStableCount < EYE_CARE_STABLE_SAMPLES) {
      return;
    }

    if (_eyeCareCandidate == _isDimmed) {
      return;
    }

    _isDimmed = _eyeCareCandidate;
    _eyeCareController.add(_isDimmed);
    if (kDebugMode) {
      debugPrint('Sensor event: eye-care ${_isDimmed ? 'ON' : 'OFF'}');
    }
    unawaited(_setEyeCareBrightness(_isDimmed));
  }

  Future<void> _setEyeCareBrightness(bool dimmed) async {
    try {
      if (dimmed) {
        await ScreenBrightness().setApplicationScreenBrightness(_baseBrightness * 0.5);
      } else {
        await ScreenBrightness().resetApplicationScreenBrightness();
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Could not update screen brightness: $error');
      }
    }
  }

  void _handleEar(AccelerometerEvent event) {
    final atEar = event.y > 8.5 && event.z.abs() < 2.5;
    _earDetectionController.add(atEar);
    if (kDebugMode && atEar) {
      debugPrint('Sensor event: ear detected');
    }
  }

  void _handleSafety(AccelerometerEvent event) {
    // Detects if phone is flat (z > 9.0)
    bool isFlat = event.z > FLAT_Z_THRESHOLD && event.x.abs() < 1.0 && event.y.abs() < 1.0;

    if (isFlat) {
      _safetyTimer ??= Timer(GYM_FLOOR_TIMEOUT, () {
        _safetyController.add(true);
        if (kDebugMode) {
          debugPrint('Sensor event: safety alert (flat timeout reached)');
        }
      });
    } else {
      _safetyTimer?.cancel();
      _safetyTimer = null;
      _safetyController.add(false);
    }
  }

  void dispose() {
    _isDisposed = true;
    _isListening = false;
    _accelSub?.cancel();
    _safetyTimer?.cancel();
    if (_isDimmed) {
      unawaited(_setEyeCareBrightness(false));
      _isDimmed = false;
    }
    _shakeController.close();
    _eyeCareController.close();
    _earDetectionController.close();
    _safetyController.close();
  }
}