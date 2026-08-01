import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import '../models/user_settings.dart';

@lazySingleton
class SettingsLocalDatasource {
  static const String _kTargetMl = 'targetMl';
  static const String _kWakeUpHour = 'wakeUpHour';
  static const String _kWakeUpMinute = 'wakeUpMinute';
  static const String _kSleepHour = 'sleepHour';
  static const String _kSleepMinute = 'sleepMinute';
  static const String _kNotificationsEnabled = 'notificationsEnabled';
  static const String _kIntervalMinutes = 'intervalMinutes';
  static const String _kIsPaused = 'isPaused';
  static const String _kBodyWeightKg = 'bodyWeightKg';
  static const String _kAutoCalcTarget = 'autoCalcTarget';
  static const String _kPreset1Ml = 'preset1Ml';
  static const String _kPreset2Ml = 'preset2Ml';
  static const String _kIsFirstLaunch = 'isFirstLaunch';

  Future<UserSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return UserSettings(
      targetMl: prefs.getInt(_kTargetMl) ?? 2500,
      wakeUpTime: TimeOfDay(
        hour: prefs.getInt(_kWakeUpHour) ?? 8,
        minute: prefs.getInt(_kWakeUpMinute) ?? 0,
      ),
      sleepTime: TimeOfDay(
        hour: prefs.getInt(_kSleepHour) ?? 22,
        minute: prefs.getInt(_kSleepMinute) ?? 0,
      ),
      notificationsEnabled: prefs.getBool(_kNotificationsEnabled) ?? true,
      intervalMinutes: prefs.getInt(_kIntervalMinutes) ?? 30,
      isPaused: prefs.getBool(_kIsPaused) ?? false,
      bodyWeightKg: prefs.getDouble(_kBodyWeightKg),
      autoCalcTarget: prefs.getBool(_kAutoCalcTarget) ?? false,
      preset1Ml: prefs.getInt(_kPreset1Ml) ?? 200,
      preset2Ml: prefs.getInt(_kPreset2Ml) ?? 300,
      isFirstLaunch: prefs.getBool(_kIsFirstLaunch) ?? true,
    );
  }

  Future<void> saveSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTargetMl, settings.targetMl);
    await prefs.setInt(_kWakeUpHour, settings.wakeUpTime.hour);
    await prefs.setInt(_kWakeUpMinute, settings.wakeUpTime.minute);
    await prefs.setInt(_kSleepHour, settings.sleepTime.hour);
    await prefs.setInt(_kSleepMinute, settings.sleepTime.minute);
    await prefs.setBool(_kNotificationsEnabled, settings.notificationsEnabled);
    await prefs.setInt(_kIntervalMinutes, settings.intervalMinutes);
    await prefs.setBool(_kIsPaused, settings.isPaused);
    if (settings.bodyWeightKg != null) {
      await prefs.setDouble(_kBodyWeightKg, settings.bodyWeightKg!);
    } else {
      await prefs.remove(_kBodyWeightKg);
    }
    await prefs.setBool(_kAutoCalcTarget, settings.autoCalcTarget);
    await prefs.setInt(_kPreset1Ml, settings.preset1Ml);
    await prefs.setInt(_kPreset2Ml, settings.preset2Ml);
    await prefs.setBool(_kIsFirstLaunch, settings.isFirstLaunch);
  }
}
