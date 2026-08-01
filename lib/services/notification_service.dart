import 'package:injectable/injectable.dart';

@lazySingleton
class NotificationService {
  Future<void> init() async {}
  Future<void> scheduleNextReminder(int intervalMinutes) async {}
  Future<void> cancelAll() async {}
}
