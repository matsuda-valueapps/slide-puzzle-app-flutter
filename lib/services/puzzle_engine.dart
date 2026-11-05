import 'dart:math';

/// スライドパズルの基本処理を管理するクラス。
///
/// 主な機能
/// ・完成盤面の生成
/// ・空白マスの管理
/// ・タイルの移動可否判定
/// ・タイルの移動
/// ・複数タイルの移動
/// ・シャッフル
/// ・クリア判定
///
/// 盤面の数字は以下のルールで管理する。
/// 0 = 空白マス
/// 1以上 = タイルの数字
class PuzzleEngine {
  /// 空白マスを表す値
  static const int blankTile = 0;

  /// 対応する最小盤面サイズ
  static const int minBoardSize = 3;

  /// 対応する最大盤面サイズ
  static const int maxBoardSize = 7;

  /// デフォルトのシャッフル回数
  static const int defaultShuffleMoves = 500;

  /// 指定サイズの標準完成盤面を生成する。
  ///
  /// 例：3×3
  /// [1, 2, 3,
  ///  4, 5, 6,
  ///  7, 8, 0]
  ///
  /// 0は空白マス。
  static List<int> createSolvedBoard(int boardSize) {
    _validateBoardSize(boardSize);

    final int totalTiles = boardSize * boardSize;

    return List<int>.generate(
      totalTiles,
      (index) => index == totalTiles - 1 ? blankTile : index + 1,
    );
  }

  /// 盤面サイズが有効か確認する。
  static void _validateBoardSize(int boardSize) {
    if (boardSize < minBoardSize || boardSize > maxBoardSize) {
      throw ArgumentError(
        'Board size must be between '
        '$minBoardSize and $maxBoardSize.',
      );
    }
  }

  /// 盤面データが有効か確認する。
  ///
  /// ・盤面の要素数が boardSize × boardSize と一致する
  /// ・0から盤面のマス数 - 1までの数字が1つずつ存在する
  static void _validateBoard(
    List<int> board,
    int boardSize,
  ) {
    _validateBoardSize(boardSize);

    final int totalTiles = boardSize * boardSize;

    if (board.length != totalTiles) {
      throw ArgumentError(
        'Board length must be $totalTiles.',
      );
    }

    final Set<int> uniqueTiles = board.toSet();

    if (uniqueTiles.length != totalTiles) {
      throw ArgumentError(
        'Board must not contain duplicate values.',
      );
    }

    for (int value = 0; value < totalTiles; value++) {
      if (!uniqueTiles.contains(value)) {
        throw ArgumentError(
          'Board must contain every value from '
          '0 to ${totalTiles - 1}.',
        );
      }
    }
  }

  /// 盤面内の空白マスの位置を取得する。
  ///
  /// 戻り値はリスト内のインデックス。
  /// 見つからない場合は例外を発生させる。
  static int getBlankIndex(List<int> board) {
    final int blankIndex = board.indexOf(blankTile);

    if (blankIndex == -1) {
      throw ArgumentError(
        'The board does not contain a blank tile.',
      );
    }

    return blankIndex;
  }

  /// 空白マスに隣接するマスのインデックスを取得する。
  ///
  /// 上下左右のみを対象とする。
  /// 斜め方向は対象外。
  static List<int> getAdjacentIndices(
    int index,
    int boardSize,
  ) {
    _validateBoardSize(boardSize);

    final int totalTiles = boardSize * boardSize;

    if (index < 0 || index >= totalTiles) {
      throw RangeError.index(
        index,
        List<int>.filled(totalTiles, 0),
      );
    }

    final int row = index ~/ boardSize;
    final int column = index % boardSize;

    final List<int> adjacentIndices = [];

    // 上
    if (row > 0) {
      adjacentIndices.add(index - boardSize);
    }

    // 下
    if (row < boardSize - 1) {
      adjacentIndices.add(index + boardSize);
    }

    // 左
    if (column > 0) {
      adjacentIndices.add(index - 1);
    }

    // 右
    if (column < boardSize - 1) {
      adjacentIndices.add(index + 1);
    }

    return adjacentIndices;
  }

  /// 指定したタイルが移動可能か判定する。
  ///
  /// 移動可能な条件：
  /// 指定したタイルが空白マスの上下左右に存在すること。
  static bool canMove(
    List<int> board,
    int tileIndex,
    int boardSize,
  ) {
    _validateBoard(board, boardSize);

    final int totalTiles = boardSize * boardSize;

    if (tileIndex < 0 || tileIndex >= totalTiles) {
      return false;
    }

    // 空白マス自体は移動できない。
    if (board[tileIndex] == blankTile) {
      return false;
    }

    final int blankIndex = getBlankIndex(board);

    final List<int> adjacentIndices = getAdjacentIndices(
      blankIndex,
      boardSize,
    );

    return adjacentIndices.contains(tileIndex);
  }

  /// 指定したタイルを移動する。
  ///
  /// 移動可能な場合：
  /// ・空白マスとタイルの位置を交換する
  /// ・新しい盤面リストを返す
  ///
  /// 移動不可能な場合：
  /// nullを返す
  ///
  /// 元の盤面データは変更しない。
  static List<int>? moveTile(
    List<int> board,
    int tileIndex,
    int boardSize,
  ) {
    if (!canMove(board, tileIndex, boardSize)) {
      return null;
    }

    final List<int> newBoard = List<int>.from(board);

    final int blankIndex = getBlankIndex(newBoard);

    // タイルと空白マスを交換する。
    newBoard[blankIndex] = newBoard[tileIndex];
    newBoard[tileIndex] = blankTile;

    return newBoard;
  }

  /// 指定したタイルを空白マスまで移動できるか判定する。
  ///
  /// 移動可能な条件：
  /// ・指定したタイルが空白マスと同じ行にある
  /// ・または指定したタイルが空白マスと同じ列にある
  /// ・指定したタイルと空白マスの間に別の空白マスがない
  ///
  /// 空白マスと隣接している場合も移動可能。
  static bool canMoveTilesToBlank(
    List<int> board,
    int tileIndex,
    int boardSize,
  ) {
    _validateBoard(board, boardSize);

    final int totalTiles = boardSize * boardSize;

    if (tileIndex < 0 || tileIndex >= totalTiles) {
      return false;
    }

    // 空白マス自体は移動できない。
    if (board[tileIndex] == blankTile) {
      return false;
    }

    final int blankIndex = getBlankIndex(board);

    final int tileRow = tileIndex ~/ boardSize;
    final int tileColumn = tileIndex % boardSize;

    final int blankRow = blankIndex ~/ boardSize;
    final int blankColumn = blankIndex % boardSize;

    // 同じ行でも列でもない場合は移動できない。
    if (tileRow != blankRow && tileColumn != blankColumn) {
      return false;
    }

    return true;
  }

  /// 指定したタイルから空白マスまでの複数タイルを移動する。
  ///
  /// 移動可能な場合：
  /// ・指定したタイルから空白マスまでの間にあるタイルを
  ///   空白マスの方向へ1マスずつ移動する
  /// ・指定したタイルの位置が新しい空白マスになる
  /// ・新しい盤面リストを返す
  ///
  /// 移動不可能な場合：
  /// nullを返す
  ///
  /// 元の盤面データは変更しない。
  ///
  /// 例：
  /// 移動前：[1, 2, 3, 0]
  /// 指定位置：0番目
  /// 移動後：[0, 1, 2, 3]
  ///
  /// 横方向・縦方向の両方に対応する。
  static List<int>? moveTilesToBlank(
    List<int> board,
    int tileIndex,
    int boardSize,
  ) {
    if (!canMoveTilesToBlank(
      board,
      tileIndex,
      boardSize,
    )) {
      return null;
    }

    final List<int> newBoard = List<int>.from(board);

    final int blankIndex = getBlankIndex(newBoard);

    final int tileRow = tileIndex ~/ boardSize;
    final int blankRow = blankIndex ~/ boardSize;

    int step;

    // 同じ行にある場合
    if (tileRow == blankRow) {
      step = tileIndex < blankIndex ? 1 : -1;
    } else {
      // 同じ列にある場合
      step = tileIndex < blankIndex
          ? boardSize
          : -boardSize;
    }

    int currentIndex = blankIndex;

    // 空白マスに向かってタイルを順番に移動する。
    while (currentIndex != tileIndex) {
      final int nextIndex = currentIndex - step;

      newBoard[currentIndex] = newBoard[nextIndex];

      currentIndex = nextIndex;
    }

    // 指定したタイルの位置を新しい空白マスにする。
    newBoard[tileIndex] = blankTile;

    return newBoard;
  }

  /// 完成盤面をシャッフルする。
  ///
  /// 完成盤面から合法的な移動を繰り返すため、
  /// 必ず解ける盤面が生成される。
  ///
  /// goalBoardを指定すると、Normal以外の完成パターンにも
  /// 対応できる。
  ///
  /// shuffleMovesを省略した場合は500回移動する。
  ///
  /// randomを指定すると、乱数を外部から制御できる。
  static List<int> shuffleBoard({
    required int boardSize,
    List<int>? goalBoard,
    int shuffleMoves = defaultShuffleMoves,
    Random? random,
  }) {
    _validateBoardSize(boardSize);

    if (shuffleMoves < 1) {
      throw ArgumentError(
        'shuffleMoves must be greater than 0.',
      );
    }

    final List<int> baseBoard = goalBoard == null
        ? createSolvedBoard(boardSize)
        : List<int>.from(goalBoard);

    _validateBoard(baseBoard, boardSize);

    final Random rng = random ?? Random();

    // 完成状態から合法的にシャッフルする。
    // シャッフル後に完成状態だった場合は再試行する。
    for (int attempt = 0; attempt < 10; attempt++) {
      final List<int> board = List<int>.from(baseBoard);

      int previousBlankIndex = -1;

      for (int move = 0; move < shuffleMoves; move++) {
        final int blankIndex = getBlankIndex(board);

        List<int> candidates = getAdjacentIndices(
          blankIndex,
          boardSize,
        );

        // 直前の移動をすぐに取り消す動きを避ける。
        final List<int> filteredCandidates = candidates
            .where((index) => index != previousBlankIndex)
            .toList();

        if (filteredCandidates.isNotEmpty) {
          candidates = filteredCandidates;
        }

        final int selectedIndex = candidates[
          rng.nextInt(candidates.length)
        ];

        previousBlankIndex = blankIndex;

        // 選択したタイルと空白マスを交換する。
        board[blankIndex] = board[selectedIndex];
        board[selectedIndex] = blankTile;
      }

      // 完成状態になっていなければ、その盤面を返す。
      if (!isSolved(board, baseBoard)) {
        return board;
      }
    }

    // 通常はここには到達しない。
    // 念のため、完成盤面から合法的な移動を1回行う。
    final List<int> fallbackBoard = List<int>.from(baseBoard);

    final int blankIndex = getBlankIndex(fallbackBoard);

    final List<int> candidates = getAdjacentIndices(
      blankIndex,
      boardSize,
    );

    final int selectedIndex = candidates[
      rng.nextInt(candidates.length)
    ];

    fallbackBoard[blankIndex] = fallbackBoard[selectedIndex];
    fallbackBoard[selectedIndex] = blankTile;

    return fallbackBoard;
  }

  /// 現在の盤面が完成しているか判定する。
  ///
  /// goalBoardを省略した場合は標準完成盤面と比較する。
  /// goalBoardを指定した場合は、その盤面と比較する。
  static bool isSolved(
    List<int> board, [
    List<int>? goalBoard,
  ]) {
    if (board.isEmpty) {
      return false;
    }

    final List<int> targetBoard = goalBoard ??
        createSolvedBoard(
          _inferBoardSize(board),
        );

    if (board.length != targetBoard.length) {
      return false;
    }

    for (int index = 0; index < board.length; index++) {
      if (board[index] != targetBoard[index]) {
        return false;
      }
    }

    return true;
  }

  /// 盤面の要素数から盤面サイズを推測する。
  static int _inferBoardSize(List<int> board) {
    final int size = sqrt(board.length).toInt();

    if (size * size != board.length) {
      throw ArgumentError(
        'Board length must be a perfect square.',
      );
    }

    _validateBoardSize(size);

    return size;
  }
}