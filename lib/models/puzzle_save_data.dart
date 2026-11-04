import '../constants/puzzle_patterns.dart';
import 'game_settings.dart';
import 'puzzle_state.dart';

/// ゲームの途中経過を保存するためのデータモデル。
///
/// Number / Picture のゲーム設定と現在の盤面状態を保持し、
/// JSON形式への変換・復元に対応する。
class PuzzleSaveData {
  /// ゲーム設定
  final GameSettings settings;

  /// 現在のパズル状態
  final PuzzleState puzzleState;

  /// Pictureモードで使用している画像ID
  /// Numberモードでは null
  final String? imageId;

  /// データを保存した日時
  final DateTime savedAt;

  PuzzleSaveData({
    required this.settings,
    required this.puzzleState,
    this.imageId,
    required this.savedAt,
  }) {
    if (settings.boardSize != puzzleState.boardSize) {
      throw ArgumentError(
        'GameSettings boardSize and PuzzleState boardSize must match.',
      );
    }

    if (settings.boardSize < 3 || settings.boardSize > 7) {
      throw ArgumentError(
        'boardSize must be between 3 and 7.',
      );
    }

    if (settings.gameType == GameType.picture &&
        (imageId == null || imageId!.trim().isEmpty)) {
      throw ArgumentError(
        'imageId is required for Picture mode.',
      );
    }
  }

  /// 保存データを識別するためのキー。
  ///
  /// Number と Picture の途中経過を別々に保存する。
  String get saveKey {
    return 'puzzle_save_${settings.gameType.name}';
  }

  /// JSON形式に変換する。
  Map<String, dynamic> toJson() {
    return {
      'gameType': settings.gameType.name,
      'boardSize': settings.boardSize,
      'pattern': settings.pattern.name,
      'imageId': imageId,
      'board': puzzleState.board,
      'goalBoard': puzzleState.goalBoard,
      'moveCount': puzzleState.moveCount,
      'elapsedSeconds': puzzleState.elapsedSeconds,
      'isPaused': puzzleState.isPaused,
      'isCompleted': puzzleState.isCompleted,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  /// JSON形式からPuzzleSaveDataを生成する。
  factory PuzzleSaveData.fromJson(Map<String, dynamic> json) {
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

    final boardSize = json['boardSize'] as int;

    final settings = GameSettings(
      gameType: gameType,
      boardSize: boardSize,
      pattern: pattern,
    );

    final puzzleState = PuzzleState(
      board: List<int>.from(json['board'] as List),
      goalBoard: List<int>.from(json['goalBoard'] as List),
      boardSize: boardSize,
      moveCount: json['moveCount'] as int,
      elapsedSeconds: json['elapsedSeconds'] as int,
      isPaused: json['isPaused'] as bool,
      isCompleted: json['isCompleted'] as bool,
    );

    return PuzzleSaveData(
      settings: settings,
      puzzleState: puzzleState,
      imageId: json['imageId'] as String?,
      savedAt: DateTime.parse(
        json['savedAt'] as String,
      ),
    );
  }
}