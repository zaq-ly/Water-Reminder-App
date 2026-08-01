import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../services/notification_service.dart';
import '../repositories/settings_repository.dart';
import 'get_today_intake.dart';

@injectable
class ScheduleNotification {
  final NotificationService _notificationService;
  final SettingsRepository _settingsRepository;
  final GetTodayIntake _getTodayIntake;

  ScheduleNotification(
    this._notificationService,
    this._settingsRepository,
    this._getTodayIntake,
  );

  Future<void> call() async {
    final settings = await _settingsRepository.getSettings();
    final todayTotal = await _getTodayIntake();

    if (!settings.notificationsEnabled || settings.isPaused || todayTotal >= settings.targetMl) {
      await _notificationService.cancelAll();
      return;
    }

    final now = DateTime.now();
    DateTime activeStart = DateTime(
      now.year,
      now.month,
      now.day,
      settings.wakeUpTime.hour,
      settings.wakeUpTime.minute,
    );
    DateTime activeEnd = DateTime(
      now.year,
      now.month,
      now.day,
      settings.sleepTime.hour,
      settings.sleepTime.minute,
    );

    // If activeEnd is before activeStart (e.g. sleeps past midnight), adjust for tomorrow
    if (activeEnd.isBefore(activeStart)) {
      if (now.isAfter(activeStart) || now.isAtSameMomentAs(activeStart)) {
        activeEnd = activeEnd.add(const Duration(days: 1));
      } else {
        activeStart = activeStart.subtract(const Duration(days: 1));
      }
    }

    DateTime nextAlarm;

    if (now.isAfter(activeEnd) || now.isAtSameMomentAs(activeEnd)) {
      // Past active hours today -> schedule for tomorrow at start time
      nextAlarm = activeStart.add(const Duration(days: 1));
    } else if (now.isBefore(activeStart)) {
      // Before active hours today -> schedule for today at start time
      nextAlarm = activeStart;
    } else {
      // Within active hours -> schedule now + interval
      nextAlarm = now.add(Duration(minutes: settings.intervalMinutes));
      
      // If the scheduled time falls outside active hours (e.g. close to sleep),
      // we push it to tomorrow's active start.
      if (nextAlarm.isAfter(activeEnd)) {
        nextAlarm = activeStart.add(const Duration(days: 1));
      }
    }

    await _notificationService.scheduleAlarmAt(nextAlarm);
  }
}
