import 'package:injectable/injectable.dart';
import '../../domain/repositories/intake_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/intake_local_datasource.dart';
import '../models/intake_entry.dart';
import '../models/daily_summary.dart';

@LazySingleton(as: IntakeRepository)
class IntakeRepositoryImpl implements IntakeRepository {
  final IntakeLocalDatasource _datasource;
  final SettingsRepository _settingsRepository;

  IntakeRepositoryImpl(this._datasource, this._settingsRepository);

  @override
  Future<void> addIntake(IntakeEntry entry) async {
    await _datasource.addIntake(entry);
    
    // Also update daily summary
    final date = "${entry.timestamp.year}-${entry.timestamp.month.toString().padLeft(2, '0')}-${entry.timestamp.day.toString().padLeft(2, '0')}";
    var summary = await _datasource.getDailySummary(date);
    if (summary != null) {
      summary = summary.copyWith(totalMl: summary.totalMl + entry.amountMl);
    } else {
      final settings = await _settingsRepository.getSettings();
      summary = DailySummary(date: date, totalMl: entry.amountMl, targetMl: settings.targetMl);
    }
    await _datasource.updateDailySummary(summary);
  }

  @override
  Future<List<IntakeEntry>> getEntriesForDate(String date) {
    return _datasource.getEntriesForDate(date);
  }

  @override
  Future<DailySummary?> getDailySummary(String date) {
    return _datasource.getDailySummary(date);
  }

  @override
  Future<void> updateDailySummary(DailySummary summary) {
    return _datasource.updateDailySummary(summary);
  }

  @override
  Future<int> getTodayTotalMl() async {
    final now = DateTime.now();
    final date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final summary = await _datasource.getDailySummary(date);
    return summary?.totalMl ?? 0;
  }

  @override
  Future<void> clearDailyIntakes(String date) {
    return _datasource.clearDailyIntakes(date);
  }
}

