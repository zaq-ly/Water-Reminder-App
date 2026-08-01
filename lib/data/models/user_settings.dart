import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_settings.freezed.dart';

@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    @Default(2500) int targetMl,
    @Default(TimeOfDay(hour: 8, minute: 0)) TimeOfDay wakeUpTime,
    @Default(TimeOfDay(hour: 22, minute: 0)) TimeOfDay sleepTime,
    @Default(true) bool notificationsEnabled,
    @Default(90) int intervalMinutes,
    @Default(false) bool isPaused,
  }) = _UserSettings;
}
