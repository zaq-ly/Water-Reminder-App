import 'package:injectable/injectable.dart';
import '../repositories/intake_repository.dart';

@injectable
class ResetDaily {
  final IntakeRepository _repository;

  ResetDaily(this._repository);

  Future<void> call() async {
    final now = DateTime.now();
    final date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    await _repository.clearDailyIntakes(date);
  }
}
