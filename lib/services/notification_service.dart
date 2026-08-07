import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../core/di/injection.dart';
import '../data/models/intake_entry.dart';
import '../data/models/daily_summary.dart';
import '../domain/usecases/add_intake.dart';
import '../domain/usecases/schedule_notification.dart';
import '../domain/repositories/settings_repository.dart';
import 'alarm_service.dart';

@lazySingleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final AlarmService _alarmService;

  NotificationService(this._alarmService);

  static const _channelId = 'water_reminder_channel';
  static const _channelName = 'Pengingat Minum Air';
  static const _channelDesc = 'Notifikasi pengingat untuk minum air secara rutin';

  Future<void> _logError(String msg) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/notif_log.txt');
      await file.writeAsString('${DateTime.now()}: $msg\n', mode: FileMode.append);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> init() async {
    try {
      const androidSettings = AndroidInitializationSettings('ic_notification');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
      );

      const androidChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
        enableVibration: true,
      );

      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
          
      await _logError('init success');
    } catch (e) {
      await _logError('init failed: $e');
      rethrow;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // We can handle foreground taps here
  }

  Future<void> showReminderNotification(int remainingMl) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        actions: [
          AndroidNotificationAction(
            'drink_preset',
            'Sudah Minum',
            showsUserInterface: false,
          ),
          AndroidNotificationAction(
            'snooze_60',
            'Snooze 1 Jam',
            showsUserInterface: false,
          ),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(
        id: 0,
        title: '💧 Waktunya minum air!',
        body: '${remainingMl}ml lagi menuju target harianmu',
        notificationDetails: details,
      );
      
      await _logError('showReminderNotification success');
    } catch (e) {
      await _logError('showReminderNotification failed: $e');
      rethrow;
    }
  }

  Future<void> scheduleAlarmAt(DateTime nextAlarm) async {
    await _alarmService.scheduleNextAlarm(nextAlarm);
  }

  Future<void> cancelAll() async {
    await _alarmService.cancelAlarm();
    await _plugin.cancelAll();
  }

  Future<void> cancelById(int id) async {
    await _plugin.cancel(id: id);
  }
}

@pragma('vm:entry-point')
void _onBackgroundNotificationTapped(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(IntakeEntryAdapter());
    Hive.registerAdapter(DailySummaryAdapter());
  } catch (e) {
    // Ignore if already initialized
  }

  try {
    getIt.get<NotificationService>();
  } catch (e) {
    configureDependencies();
  }
  
  final notificationService = getIt<NotificationService>();
  await notificationService.init();

  if (response.actionId == 'drink_preset') {
    final addIntake = getIt<AddIntake>();
    final settingsRepo = getIt<SettingsRepository>();
    final settings = await settingsRepo.getSettings();
    await addIntake(settings.preset1Ml);
    
    // Check if target reached and reschedule
    final scheduleNotification = getIt<ScheduleNotification>();
    await scheduleNotification();
    
    // Clear notification after action
    await notificationService.cancelById(0);
    
  } else if (response.actionId == 'snooze_60') {
    // Schedule alarm 1 hour from now
    await notificationService.cancelById(0);
    final nextAlarm = DateTime.now().add(const Duration(hours: 1));
    await notificationService.scheduleAlarmAt(nextAlarm);
  }
}
