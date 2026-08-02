import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/di/injection.dart';
import '../data/models/intake_entry.dart';
import '../data/models/daily_summary.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/usecases/get_today_intake.dart';
import '../domain/usecases/schedule_notification.dart';
import 'notification_service.dart';

@lazySingleton
class AlarmService {
  static const int _alarmId = 0;

  Future<void> init() async {
    await AndroidAlarmManager.initialize();
  }

  Future<void> scheduleNextAlarm(DateTime triggerAt) async {
    await AndroidAlarmManager.cancel(_alarmId);
    try {
      await AndroidAlarmManager.oneShotAt(
        triggerAt,
        _alarmId,
        _alarmCallback,
        exact: true,
        wakeup: true,
        allowWhileIdle: true,
        rescheduleOnReboot: true,
      );
    } catch (e) {
      debugPrint('Failed to schedule exact alarm: $e');
      // Fallback to inexact alarm if exact alarm permission is missing
      await AndroidAlarmManager.oneShotAt(
        triggerAt,
        _alarmId,
        _alarmCallback,
        exact: false,
        wakeup: true,
        allowWhileIdle: true,
        rescheduleOnReboot: true,
      );
    }
  }

  Future<void> cancelAlarm() async {
    await AndroidAlarmManager.cancel(_alarmId);
  }

}

@pragma('vm:entry-point')
Future<void> _alarmCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if Hive is initialized (it might not be in a background isolate)
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(IntakeEntryAdapter());
    Hive.registerAdapter(DailySummaryAdapter());
  } catch (e) {
    // Ignore if already initialized
  }
  
  // Initialize DI if not already done
  try {
    getIt.get<NotificationService>();
  } catch (e) {
    configureDependencies();
  }

  final settingsRepo = getIt<SettingsRepository>();
  final getTodayIntake = getIt<GetTodayIntake>();
  final notificationService = getIt<NotificationService>();
  final scheduleNotification = getIt<ScheduleNotification>();
  
  // Ensure plugin is initialized in this background isolate
  await notificationService.init();

  debugPrint('AlarmCallback Triggered! Fetching settings...');
  final settings = await settingsRepo.getSettings();
  if (!settings.notificationsEnabled || settings.isPaused) {
    debugPrint('Notifications disabled or paused. Exiting.');
    return;
  }

  final todayTotal = await getTodayIntake();
  final remaining = settings.targetMl - todayTotal;
  debugPrint('Today total: $todayTotal, Remaining: $remaining');

  if (remaining > 0) {
    debugPrint('Showing notification...');
    await notificationService.showReminderNotification(remaining);
    // Chain scheduling: schedule the next one!
    await scheduleNotification();
  } else {
    debugPrint('Target reached! No notification shown.');
  }
}
