import 'package:flutter/material.dart';
import 'package:nutrisphere_flutter/app/app.dart';
import 'package:nutrisphere_flutter/core/services/hive/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hiveService = HiveService();
  await hiveService.init();
  runApp(App());
}

