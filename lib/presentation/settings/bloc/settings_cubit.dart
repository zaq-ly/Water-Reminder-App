import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'settings_state.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../../../services/notification_service.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;
  final NotificationService _notificationService;

  SettingsCubit({
    required SettingsRepository settingsRepository,
    required NotificationService notificationService,
  })  : _settingsRepository = settingsRepository,
        _notificationService = notificationService,
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
      await _notificationService.scheduleNextReminder(minutes);
    }
  }
}
