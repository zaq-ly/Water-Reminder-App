import 'package:injectable/injectable.dart';
import '../repositories/intake_repository.dart';

@injectable
class ResetDaily {
  final IntakeRepository _repository;

  ResetDaily(this._repository);

  Future<void> call() async {
    // In a real scenario, this might archive data and reset today's counter.
    // For now we rely on the logic that gets today's total based on the date.
    // So "reset" might not literally clear the DB, but just start a new DailySummary
    // if it's a new day. Since getTodayTotalMl() checks current date, it resets automatically.
    // However, if manual reset is needed:
    await _repository.clearDailyIntakes();
  }
}
