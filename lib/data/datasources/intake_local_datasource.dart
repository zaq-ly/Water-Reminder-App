import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../models/intake_entry.dart';
import '../models/daily_summary.dart';

@lazySingleton
class IntakeLocalDatasource {
  static const String _intakeBoxName = 'intake_entries';
  static const String _summaryBoxName = 'daily_summaries';

  Future<Box<IntakeEntry>> _getIntakeBox() async {
    if (!Hive.isBoxOpen(_intakeBoxName)) {
      return await Hive.openBox<IntakeEntry>(_intakeBoxName);
    }
    return Hive.box<IntakeEntry>(_intakeBoxName);
  }

  Future<Box<DailySummary>> _getSummaryBox() async {
    if (!Hive.isBoxOpen(_summaryBoxName)) {
      return await Hive.openBox<DailySummary>(_summaryBoxName);
    }
    return Hive.box<DailySummary>(_summaryBoxName);
  }

  Future<void> addIntake(IntakeEntry entry) async {
    final box = await _getIntakeBox();
    await box.put(entry.id, entry);
  }

  Future<List<IntakeEntry>> getEntriesForDate(String date) async {
    final box = await _getIntakeBox();
    // Simplified: matching the date string representation
    // Assuming entry.timestamp can be matched to 'YYYY-MM-DD'
    return box.values.where((entry) {
      final entryDate = "${entry.timestamp.year}-${entry.timestamp.month.toString().padLeft(2, '0')}-${entry.timestamp.day.toString().padLeft(2, '0')}";
      return entryDate == date;
    }).toList();
  }

  Future<DailySummary?> getDailySummary(String date) async {
    final box = await _getSummaryBox();
    return box.get(date);
  }

  Future<void> updateDailySummary(DailySummary summary) async {
    final box = await _getSummaryBox();
    await box.put(summary.date, summary);
  }

  Future<void> clearDailyIntakes() async {
    // This removes all intakes. 
    // Usually, we only want to clear today's if we reset, or keep them for history.
    // Let's implement it to clear all intakes for now.
    final box = await _getIntakeBox();
    await box.clear();
  }
}
