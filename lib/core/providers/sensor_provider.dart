import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sensor_service.dart';

final sensorServiceProvider = Provider<FitnessSensorService>((ref) {
  final service = FitnessSensorService();
  service.start();
  ref.onDispose(() => service.dispose());
  return service;
});