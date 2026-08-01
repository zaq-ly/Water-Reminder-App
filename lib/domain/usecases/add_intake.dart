import 'package:injectable/injectable.dart';
import '../repositories/intake_repository.dart';
import '../../data/models/intake_entry.dart';
import 'package:uuid/uuid.dart';

@injectable
class AddIntake {
  final IntakeRepository _repository;
  final Uuid _uuid = const Uuid();

  AddIntake(this._repository);

  Future<void> call(int amountMl) async {
    final entry = IntakeEntry(
      id: _uuid.v4(),
      amountMl: amountMl,
      timestamp: DateTime.now(),
    );
    await _repository.addIntake(entry);
  }
}
