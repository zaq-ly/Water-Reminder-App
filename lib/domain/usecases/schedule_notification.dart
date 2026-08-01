import 'package:injectable/injectable.dart';
import '../../services/notification_service.dart';
import '../repositories/settings_repository.dart';

@injectable
class ScheduleNotification {
  final NotificationService _notificationService;
  final SettingsRepository _settingsRepository;

  ScheduleNotification(this._notificationService, this._settingsRepository);

  Future<void> call() async {
    final settings = await _settingsRepository.getSettings();
    if (settings.notificationsEnabled && !settings.isPaused) {
      await _notificationService.scheduleNextReminder(settings.intervalMinutes);
    } else {
      await _notificationService.cancelAll();
    }
  }
}
