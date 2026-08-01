import 'package:injectable/injectable.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/user_settings.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDatasource _datasource;

  SettingsRepositoryImpl(this._datasource);

  @override
  Future<UserSettings> getSettings() {
    return _datasource.getSettings();
  }

  @override
  Future<void> saveSettings(UserSettings settings) {
    return _datasource.saveSettings(settings);
  }
}
