import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

/// アプリ全体の設定を管理するサービス。
///
/// Sound Effects / Vibration の設定を端末内に保存し、
/// アプリ起動時に読み込む。
class AppSettingsService {
  /// Sound Effects の設定保存キー
  static const String _soundEffectsKey = 'sound_effects_enabled';

  /// Vibration の設定保存キー
  static const String _vibrationKey = 'vibration_enabled';

  /// アプリ設定を読み込む。
  ///
  /// 保存データが存在しない場合は、初期値の ON を使用する。
  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    return AppSettings(
      soundEffectsEnabled:
          prefs.getBool(_soundEffectsKey) ?? true,
      vibrationEnabled:
          prefs.getBool(_vibrationKey) ?? true,
    );
  }

  /// Sound Effects の ON / OFF を保存する。
  ///
  /// 保存に成功した場合は true を返す。
  Future<bool> saveSoundEffectsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();

    return await prefs.setBool(_soundEffectsKey, enabled);
  }

  /// Vibration の ON / OFF を保存する。
  ///
  /// 保存に成功した場合は true を返す。
  Future<bool> saveVibrationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();

    return await prefs.setBool(_vibrationKey, enabled);
  }
}