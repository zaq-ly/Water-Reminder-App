import 'package:injectable/injectable.dart';
import '../repositories/intake_repository.dart';

@injectable
class ResetDaily {
  final IntakeRepository _repository;

  ResetDaily(this._repository);

  Future<void> call() async {
    // Midnight reset runs at 00:00+ so DateTime.now() is already the new day.
    // We clear YESTERDAY's individual entries to save storage,
    // but keep the DailySummary as historical record.
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final date = "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
    await _repository.clearDailyIntakes(date);
  }
}
