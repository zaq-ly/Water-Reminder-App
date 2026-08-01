import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/di/injection.dart';
import 'data/models/intake_entry.dart';
import 'data/models/daily_summary.dart';
import 'services/alarm_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(IntakeEntryAdapter());
  Hive.registerAdapter(DailySummaryAdapter());
  
  configureDependencies();

  final alarmService = getIt<AlarmService>();
  await alarmService.init();

  final notificationService = getIt<NotificationService>();
  await notificationService.init();

  runApp(const WaterReminderApp());
}
