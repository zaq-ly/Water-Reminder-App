import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import '../core/di/injection.dart';
import '../domain/usecases/reset_daily.dart';
import '../data/models/intake_entry.dart';
import '../data/models/daily_summary.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == MidnightResetService._taskName) {
      WidgetsFlutterBinding.ensureInitialized();
      try {
        await Hive.initFlutter();
        Hive.registerAdapter(IntakeEntryAdapter());
        Hive.registerAdapter(DailySummaryAdapter());
      } catch (_) {}
      
      try {
        getIt.get<ResetDaily>();
      } catch (_) {
        configureDependencies();
      }

      final resetDaily = getIt<ResetDaily>();
      await resetDaily();
    }
    return true;
  });
}

@lazySingleton
class MidnightResetService {
  static const _taskName = 'midnight_reset';

  Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher);
    await _scheduleMidnightReset();
  }

  Future<void> _scheduleMidnightReset() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final initialDelay = midnight.difference(now);

    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(days: 1),
      initialDelay: initialDelay,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }
}
