import '../constants/puzzle_patterns.dart';

/// ゲームタイプ
enum GameType {
  /// 数字パズル
  number,

  /// 世界遺産の画像パズル
  picture,
}

/// ゲーム設定を管理するモデル
class GameSettings {
  /// 選択可能な盤面サイズ
  static const List<int> availableBoardSizes = [
    3,
    4,
    5,
    6,
    7,
  ];

  /// ゲームタイプ
  final GameType gameType;

  /// 盤面サイズ（3～7）
  final int boardSize;

  /// 完成パターン
  ///
  /// Numberモードで使用する。
  /// Pictureモードでは通常の画像完成配置を使用する。
  final PuzzlePattern pattern;

  /// コンストラクタ
  const GameSettings({
    this.gameType = GameType.number,
    this.boardSize = 3,
    this.pattern = PuzzlePattern.normal,
  }) : assert(
          boardSize >= 3 && boardSize <= 7,
          'Board size must be between 3 and 7.',
        );

  /// 盤面サイズが有効かどうか
  static bool isValidBoardSize(int size) {
    return availableBoardSizes.contains(size);
  }

  /// Numberモードかどうか
  bool get isNumberMode {
    return gameType == GameType.number;
  }

  /// Pictureモードかどうか
  bool get isPictureMode {
    return gameType == GameType.picture;
  }

  /// 盤面の総マス数
  int get totalTiles {
    return boardSize * boardSize;
  }

  /// 空白マスを除いたタイル数
  int get puzzleTileCount {
    return totalTiles - 1;
  }

  /// 設定を一部変更した新しいインスタンスを生成
  GameSettings copyWith({
    GameType? gameType,
    int? boardSize,
    PuzzlePattern? pattern,
  }) {
    return GameSettings(
      gameType: gameType ?? this.gameType,
      boardSize: boardSize ?? this.boardSize,
      pattern: pattern ?? this.pattern,
    );
  }
}