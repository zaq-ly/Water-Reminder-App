import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_settings.freezed.dart';

@freezed
abstract class UserSettings with _$UserSettings {
  const factory UserSettings({
    @Default(2500) int targetMl,
    @Default(TimeOfDay(hour: 8, minute: 0)) TimeOfDay wakeUpTime,
    @Default(TimeOfDay(hour: 22, minute: 0)) TimeOfDay sleepTime,
    @Default(true) bool notificationsEnabled,
    @Default(30) int intervalMinutes,
    @Default(false) bool isPaused,
    double? bodyWeightKg,
    @Default(false) bool autoCalcTarget,
    @Default(200) int preset1Ml,
    @Default(300) int preset2Ml,
    @Default(true) bool isFirstLaunch,
  }) = _UserSettings;
}
