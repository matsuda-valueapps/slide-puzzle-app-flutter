
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/puzzle_patterns.dart';
import '../models/game_settings.dart';
import '../models/puzzle_record.dart';

/// パズルゲームのベスト記録を管理するサービス。
///
/// Number / Picture の記録を端末内に保存し、
/// ゲーム設定ごとに取得・更新・削除できる。
class RecordService {
  /// 記録データの保存キーに付ける接頭辞。
  static const String _recordPrefix = 'puzzle_record_';

  /// PuzzleRecordからSharedPreferences用のキーを生成する。
  String _getRecordKey(PuzzleRecord record) {
    return '$_recordPrefix${record.recordKey}';
  }

  /// ゲーム設定からSharedPreferences用のキーを生成する。
  String _createRecordKey({
    required GameType gameType,
    required int boardSize,
    required PuzzlePattern pattern,
    String? imageId,
  }) {
    final record = PuzzleRecord(
      gameType: gameType,
      boardSize: boardSize,
      pattern: pattern,
      imageId: imageId,
      bestTimeSeconds: 0,
      bestMoveCount: 0,
      achievedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );

    return _getRecordKey(record);
  }

  /// ベスト記録を保存・更新する。
  ///
  /// タイムと手数は、それぞれ独立して最良の値を保持する。
  /// 更新に成功した場合は true を返す。
  Future<bool> saveRecord(PuzzleRecord newRecord) async {
    final prefs = await SharedPreferences.getInstance();

    final key = _getRecordKey(newRecord);

    final existingJson = prefs.getString(key);

    PuzzleRecord recordToSave = newRecord;

    if (existingJson != null && existingJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(existingJson);

        if (decoded is Map<String, dynamic>) {
          final existingRecord = PuzzleRecord.fromJson(decoded);

          final improvedTime =
              newRecord.bestTimeSeconds <
              existingRecord.bestTimeSeconds;

          final improvedMoves =
              newRecord.bestMoveCount <
              existingRecord.bestMoveCount;

          recordToSave = PuzzleRecord(
            gameType: newRecord.gameType,
            boardSize: newRecord.boardSize,
            pattern: newRecord.pattern,
            imageId: newRecord.imageId,
            bestTimeSeconds: improvedTime
                ? newRecord.bestTimeSeconds
                : existingRecord.bestTimeSeconds,
            bestMoveCount: improvedMoves
                ? newRecord.bestMoveCount
                : existingRecord.bestMoveCount,
            achievedAt: improvedTime || improvedMoves
                ? newRecord.achievedAt
                : existingRecord.achievedAt,
          );
        }
      } on FormatException {
        // 保存データが不正な場合は新しい記録で上書きする。
      } on TypeError {
        // 保存データの型が不正な場合は新しい記録で上書きする。
      } on ArgumentError {
        // 保存データの内容が不正な場合は新しい記録で上書きする。
      }
    }

    final jsonString = jsonEncode(recordToSave.toJson());

    return await prefs.setString(key, jsonString);
  }

  /// 指定したゲーム設定のベスト記録を取得する。
  ///
  /// 記録が存在しない場合は null を返す。
  Future<PuzzleRecord?> getRecord({
    required GameType gameType,
    required int boardSize,
    required PuzzlePattern pattern,
    String? imageId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final key = _createRecordKey(
      gameType: gameType,
      boardSize: boardSize,
      pattern: pattern,
      imageId: imageId,
    );

    final jsonString = prefs.getString(key);

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return PuzzleRecord.fromJson(decoded);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  /// 保存されているすべてのベスト記録を取得する。
  Future<List<PuzzleRecord>> getAllRecords() async {
    final prefs = await SharedPreferences.getInstance();

    final records = <PuzzleRecord>[];

    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_recordPrefix)) {
        continue;
      }

      final jsonString = prefs.getString(key);

      if (jsonString == null || jsonString.isEmpty) {
        continue;
      }

      try {
        final decoded = jsonDecode(jsonString);

        if (decoded is Map<String, dynamic>) {
          records.add(PuzzleRecord.fromJson(decoded));
        }
      } on FormatException {
        continue;
      } on TypeError {
        continue;
      } on ArgumentError {
        continue;
      }
    }

    return records;
  }

  /// 指定したゲーム設定の記録が存在するか確認する。
  Future<bool> hasRecord({
    required GameType gameType,
    required int boardSize,
    required PuzzlePattern pattern,
    String? imageId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final key = _createRecordKey(
      gameType: gameType,
      boardSize: boardSize,
      pattern: pattern,
      imageId: imageId,
    );

    return prefs.containsKey(key);
  }

  /// 指定したゲーム設定の記録を削除する。
  ///
  /// 削除に成功した場合は true を返す。
  Future<bool> deleteRecord({
    required GameType gameType,
    required int boardSize,
    required PuzzlePattern pattern,
    String? imageId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final key = _createRecordKey(
      gameType: gameType,
      boardSize: boardSize,
      pattern: pattern,
      imageId: imageId,
    );

    return await prefs.remove(key);
  }

  /// Number / Picture のすべてのベスト記録を削除する。
  Future<void> deleteAllRecords() async {
    final prefs = await SharedPreferences.getInstance();

    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(_recordPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}