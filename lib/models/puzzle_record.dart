import '../constants/puzzle_patterns.dart';
import 'game_settings.dart';

/// パズルゲームのベスト記録を管理するモデル。
///
/// Number / Picture の両方に対応し、
/// 盤面サイズ・パターン・画像IDごとに記録を管理する。
class PuzzleRecord {
  /// ゲームタイプ
  final GameType gameType;

  /// 盤面サイズ（3～7）
  final int boardSize;

  /// パズルの完成パターン
  final PuzzlePattern pattern;

  /// Pictureモードで使用した画像ID
  /// Numberモードでは null
  final String? imageId;

  /// ベストタイム（秒）
  final int bestTimeSeconds;

  /// 最少手数
  final int bestMoveCount;

  /// 記録を達成した日時
  final DateTime achievedAt;

  PuzzleRecord({
    required this.gameType,
    required this.boardSize,
    required this.pattern,
    this.imageId,
    required this.bestTimeSeconds,
    required this.bestMoveCount,
    required this.achievedAt,
  }) {
    if (boardSize < 3 || boardSize > 7) {
      throw ArgumentError('boardSize must be between 3 and 7.');
    }

    if (bestTimeSeconds < 0) {
      throw ArgumentError('bestTimeSeconds must not be negative.');
    }

    if (bestMoveCount < 0) {
      throw ArgumentError('bestMoveCount must not be negative.');
    }

    if (gameType == GameType.picture &&
        (imageId == null || imageId!.trim().isEmpty)) {
      throw ArgumentError(
        'imageId is required for Picture mode.',
      );
    }
  }

  /// 記録を識別するための一意のキー。
  ///
  /// Number:
  /// number_3_normal_none
  ///
  /// Picture:
  /// picture_3_normal_image001
  String get recordKey {
    return '${gameType.name}_'
        '${boardSize}_'
        '${pattern.name}_'
        '${imageId ?? 'none'}';
  }

  /// JSON形式に変換する。
  Map<String, dynamic> toJson() {
    return {
      'gameType': gameType.name,
      'boardSize': boardSize,
      'pattern': pattern.name,
      'imageId': imageId,
      'bestTimeSeconds': bestTimeSeconds,
      'bestMoveCount': bestMoveCount,
      'achievedAt': achievedAt.toIso8601String(),
    };
  }

  /// JSON形式からPuzzleRecordを生成する。
  factory PuzzleRecord.fromJson(Map<String, dynamic> json) {
    final gameTypeName = json['gameType'] as String;
    final patternName = json['pattern'] as String;

    final gameType = GameType.values.firstWhere(
      (value) => value.name == gameTypeName,
      orElse: () => throw FormatException(
        'Unknown game type: $gameTypeName',
      ),
    );

    final pattern = PuzzlePattern.values.firstWhere(
      (value) => value.name == patternName,
      orElse: () => throw FormatException(
        'Unknown puzzle pattern: $patternName',
      ),
    );

    final imageId = json['imageId'] as String?;

    return PuzzleRecord(
      gameType: gameType,
      boardSize: json['boardSize'] as int,
      pattern: pattern,
      imageId: imageId,
      bestTimeSeconds: json['bestTimeSeconds'] as int,
      bestMoveCount: json['bestMoveCount'] as int,
      achievedAt: DateTime.parse(
        json['achievedAt'] as String,
      ),
    );
  }
}