import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'settings_state.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../../../domain/usecases/schedule_notification.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;
  final ScheduleNotification _scheduleNotification;

  SettingsCubit({
    required SettingsRepository settingsRepository,
    required ScheduleNotification scheduleNotification,
  })  : _settingsRepository = settingsRepository,
        _scheduleNotification = scheduleNotification,
        super(const SettingsState());

  Future<void> loadSettings() async {
    final settings = await _settingsRepository.getSettings();
    emit(state.copyWith(
      targetMl: settings.targetMl,
      intervalMinutes: settings.intervalMinutes,
      activeStartHour: settings.wakeUpTime.hour,
      activeStartMinute: settings.wakeUpTime.minute,
      activeEndHour: settings.sleepTime.hour,
      activeEndMinute: settings.sleepTime.minute,
      pauseMode: settings.isPaused,
      bodyWeightKg: settings.bodyWeightKg,
      autoCalcTarget: settings.autoCalcTarget,
      preset1Ml: settings.preset1Ml,
      preset2Ml: settings.preset2Ml,
    ));
  }

  Future<void> updateTarget(int ml) async {
    final settings = await _settingsRepository.getSettings();
    await _settingsRepository.saveSettings(settings.copyWith(targetMl: ml));
    await loadSettings();
  }

  Future<void> updateInterval(int minutes) async {
    final settings = await _settingsRepository.getSettings();
    await _settingsRepository.saveSettings(settings.copyWith(intervalMinutes: minutes));
    await loadSettings();
    if (settings.notificationsEnabled && !settings.isPaused) {
      await _scheduleNotification();
    }
  }

  Future<void> togglePause() async {
    final settings = await _settingsRepository.getSettings();
    final newStatus = !settings.isPaused;
    await _settingsRepository.saveSettings(settings.copyWith(isPaused: newStatus));
    await loadSettings();
    
    if (newStatus) {
      // Pause active, cancel alarms
    } else {
      // Resume, reschedule alarms
      await _scheduleNotification();
    }
  }

  Future<void> setBodyWeight(double kg) async {
    final settings = await _settingsRepository.getSettings();
    var newSettings = settings.copyWith(bodyWeightKg: kg);
    if (settings.autoCalcTarget) {
      newSettings = newSettings.copyWith(targetMl: (kg * 30).toInt());
    }
    await _settingsRepository.saveSettings(newSettings);
    await loadSettings();
  }

  Future<void> toggleAutoCalc(bool value) async {
    final settings = await _settingsRepository.getSettings();
    var newSettings = settings.copyWith(autoCalcTarget: value);
    if (value && settings.bodyWeightKg != null) {
      newSettings = newSettings.copyWith(targetMl: (settings.bodyWeightKg! * 30).toInt());
    }
    await _settingsRepository.saveSettings(newSettings);
    await loadSettings();
  }

  Future<void> updateActiveHours({
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
  }) async {
    final settings = await _settingsRepository.getSettings();
    await _settingsRepository.saveSettings(settings.copyWith(
      wakeUpTime: settings.wakeUpTime.replacing(hour: startHour, minute: startMinute),
      sleepTime: settings.sleepTime.replacing(hour: endHour, minute: endMinute),
    ));
    await loadSettings();
  }

  Future<void> updatePresets({required int preset1, required int preset2}) async {
    final settings = await _settingsRepository.getSettings();
    await _settingsRepository.saveSettings(settings.copyWith(
      preset1Ml: preset1,
      preset2Ml: preset2,
    ));
    await loadSettings();
  }

  Future<void> completeOnboarding({double? weightKg}) async {
    final settings = await _settingsRepository.getSettings();
    var newSettings = settings.copyWith(isFirstLaunch: false);
    if (weightKg != null) {
      newSettings = newSettings.copyWith(
        bodyWeightKg: weightKg,
        autoCalcTarget: true,
        targetMl: (weightKg * 30).toInt(),
      );
    }
    await _settingsRepository.saveSettings(newSettings);
    await loadSettings();
  }
}
