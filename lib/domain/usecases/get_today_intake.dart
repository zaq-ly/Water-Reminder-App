import 'package:injectable/injectable.dart';
import '../repositories/intake_repository.dart';

@injectable
class GetTodayIntake {
  final IntakeRepository _repository;

  GetTodayIntake(this._repository);

  Future<int> call() async {
    return _repository.getTodayTotalMl();
  }
}
