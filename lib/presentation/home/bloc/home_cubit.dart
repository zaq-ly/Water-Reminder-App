import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'home_state.dart';
import '../../../domain/usecases/add_intake.dart';
import '../../../domain/usecases/get_today_intake.dart';
import '../../../domain/usecases/reset_daily.dart';
import '../../../domain/usecases/schedule_notification.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../../../domain/repositories/intake_repository.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  final AddIntake _addIntake;
  final GetTodayIntake _getTodayIntake;
  final ResetDaily _resetDaily;
  final ScheduleNotification _scheduleNotification;
  final SettingsRepository _settingsRepository;
  final IntakeRepository _intakeRepository;

  HomeCubit({
    required AddIntake addIntake,
    required GetTodayIntake getTodayIntake,
    required ResetDaily resetDaily,
    required ScheduleNotification scheduleNotification,
    required SettingsRepository settingsRepository,
    required IntakeRepository intakeRepository,
  })  : _addIntake = addIntake,
        _getTodayIntake = getTodayIntake,
        _resetDaily = resetDaily,
        _scheduleNotification = scheduleNotification,
        _settingsRepository = settingsRepository,
        _intakeRepository = intakeRepository,
        super(const HomeState());

  Future<void> loadToday() async {
    final settings = await _settingsRepository.getSettings();
    final todayTotal = await _getTodayIntake();
    
    final now = DateTime.now();
    final date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final entries = await _intakeRepository.getEntriesForDate(date);
    
    final remaining = settings.targetMl - todayTotal;
    final progress = todayTotal / settings.targetMl;

    emit(state.copyWith(
      todayIntakeMl: todayTotal,
      targetMl: settings.targetMl,
      entries: entries,
      targetReached: todayTotal >= settings.targetMl,
      progressPercent: progress > 1.0 ? 1.0 : progress,
      remainingMl: remaining < 0 ? 0 : remaining,
      isPauseMode: settings.isPaused,
      isPermissionGranted: settings.notificationsEnabled, // simplistic for now
      isFirstLaunch: settings.isFirstLaunch,
      preset1Ml: settings.preset1Ml,
      preset2Ml: settings.preset2Ml,
    ));
  }

  Future<void> addIntake(int ml) async {
    await _addIntake(ml);
    await loadToday();
    // ScheduleNotification handles all cases: cancels if target reached, reschedules if not
    await _scheduleNotification();
  }

  Future<void> resetDaily() async {
    await _resetDaily();
    await loadToday();
    await _scheduleNotification();
  }
}
