import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/di/injection.dart';
import 'data/models/intake_entry.dart';
import 'data/models/daily_summary.dart';
import 'services/alarm_service.dart';
import 'services/notification_service.dart';
import 'services/midnight_reset_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(IntakeEntryAdapter());
    Hive.registerAdapter(DailySummaryAdapter());
    
    configureDependencies();

    final alarmService = getIt<AlarmService>();
    await alarmService.init();

    final notificationService = getIt<NotificationService>();
    await notificationService.init();

    final midnightResetService = getIt<MidnightResetService>();
    await midnightResetService.init();

    runApp(const WaterReminderApp());
  } catch (e, stackTrace) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Startup Error:\n$e\n\n$stackTrace',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
