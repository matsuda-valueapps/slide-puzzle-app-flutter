import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_settings.dart';
import '../models/puzzle_save_data.dart';

/// パズルゲームの途中経過を端末内に保存・読み込みするサービス。
///
/// Number と Picture の保存データは、それぞれ独立して管理する。
class PuzzleSaveService {
  /// 保存データのキーを取得する。
  String _getSaveKey(GameType gameType) {
    return 'puzzle_save_${gameType.name}';
  }

  /// ゲームの途中経過を保存する。
  ///
  /// 保存に成功した場合は true を返す。
  Future<bool> saveGame(PuzzleSaveData saveData) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(saveData.toJson());

    return await prefs.setString(
      saveData.saveKey,
      jsonString,
    );
  }

  /// 保存されているゲームデータを読み込む。
  ///
  /// 保存データが存在しない場合は null を返す。
  Future<PuzzleSaveData?> loadGame(GameType gameType) async {
    final prefs = await SharedPreferences.getInstance();

    final saveKey = _getSaveKey(gameType);
    final jsonString = prefs.getString(saveKey);

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return PuzzleSaveData.fromJson(decoded);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  /// 指定したゲームタイプの保存データが存在するか確認する。
  Future<bool> hasSaveData(GameType gameType) async {
    final prefs = await SharedPreferences.getInstance();

    final saveKey = _getSaveKey(gameType);

    return prefs.containsKey(saveKey);
  }

  /// 指定したゲームタイプの保存データを削除する。
  ///
  /// 削除に成功した場合は true を返す。
  Future<bool> deleteSaveData(GameType gameType) async {
    final prefs = await SharedPreferences.getInstance();

    final saveKey = _getSaveKey(gameType);

    return await prefs.remove(saveKey);
  }

  /// Number と Picture の両方の保存データを削除する。
  Future<void> deleteAllSaveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_getSaveKey(GameType.number));
    await prefs.remove(_getSaveKey(GameType.picture));
  }
}