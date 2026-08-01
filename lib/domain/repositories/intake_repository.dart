import '../../data/models/intake_entry.dart';
import '../../data/models/daily_summary.dart';

abstract class IntakeRepository {
  Future<void> addIntake(IntakeEntry entry);
  Future<List<IntakeEntry>> getEntriesForDate(String date);
  Future<DailySummary?> getDailySummary(String date);
  Future<void> updateDailySummary(DailySummary summary);
  Future<int> getTodayTotalMl();
  Future<void> clearDailyIntakes();
}
