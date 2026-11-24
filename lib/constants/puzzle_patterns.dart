/// スライドパズルの完成パターン
///
/// 0 は空白マスを表します。
enum PuzzlePattern {
  normal,
  reverse,
  vertical,
  zigzag,
  swirl,
  tornado,
}

/// スライドパズルの完成盤面を生成するクラス
///
/// 対応サイズ：3×3 ～ 8×8
///
/// 生成した盤面は PuzzleEngine の
/// shuffleBoard() および isSolved() に渡して使用できます。
class PuzzlePatterns {
  PuzzlePatterns._();

  static const int minBoardSize = 3;
  static const int maxBoardSize = 8;
  static const int blankTile = 0;

  /// パターン名を取得
  static String getPatternName(PuzzlePattern pattern) {
    switch (pattern) {
      case PuzzlePattern.normal:
        return 'Normal';
      case PuzzlePattern.reverse:
        return 'Reverse';
      case PuzzlePattern.vertical:
        return 'Vertical';
      case PuzzlePattern.zigzag:
        return 'Zigzag';
      case PuzzlePattern.swirl:
        return 'Swirl';
      case PuzzlePattern.tornado:
        return 'Tornado';
    }
  }

  /// 6種類のパターン一覧を取得
  static List<PuzzlePattern> get allPatterns {
    return PuzzlePattern.values;
  }

  /// 指定したサイズ・パターンの完成盤面を生成
  ///
  /// 例：
  /// createGoalBoard(
  ///   boardSize: 3,
  ///   pattern: PuzzlePattern.normal,
  /// )
  ///
  /// 戻り値：
  /// [1, 2, 3, 4, 5, 6, 7, 8, 0]
  static List<int> createGoalBoard({
    required int boardSize,
    required PuzzlePattern pattern,
  }) {
    _validateBoardSize(boardSize);

    switch (pattern) {
      case PuzzlePattern.normal:
        return _createNormal(boardSize);

      case PuzzlePattern.reverse:
        return _createReverse(boardSize);

      case PuzzlePattern.vertical:
        return _createVertical(boardSize);

      case PuzzlePattern.zigzag:
        return _createZigzag(boardSize);

      case PuzzlePattern.swirl:
        return _createSwirl(boardSize);

      case PuzzlePattern.tornado:
        return _createTornado(boardSize);
    }
  }

  /// 盤面サイズのチェック
  static void _validateBoardSize(int boardSize) {
    if (boardSize < minBoardSize || boardSize > maxBoardSize) {
      throw ArgumentError(
        'Board size must be between '
        '$minBoardSize and $maxBoardSize.',
      );
    }
  }

  /// 1. Normal
  ///
  /// 左上から右方向へ順番に数字を配置します。
  ///
  /// 3×3：
  /// 1 2 3
  /// 4 5 6
  /// 7 8 □
  static List<int> _createNormal(int boardSize) {
    final int totalTiles = boardSize * boardSize;

    return List<int>.generate(
      totalTiles,
      (index) {
        if (index == totalTiles - 1) {
          return blankTile;
        }

        return index + 1;
      },
    );
  }

  /// 2. Reverse
  ///
  /// 左上を空白にして、右から左へ降順に配置します。
  ///
  /// 3×3：
  /// □ 8 7
  /// 6 5 4
  /// 3 2 1
  static List<int> _createReverse(int boardSize) {
    final int totalTiles = boardSize * boardSize;

    return List<int>.generate(
      totalTiles,
      (index) {
        if (index == 0) {
          return blankTile;
        }

        return totalTiles - index;
      },
    );
  }

  /// 3. Vertical
  ///
  /// 上から下、左から右の列単位で数字を配置します。
  ///
  /// 3×3：
  /// 1 4 7
  /// 2 5 8
  /// 3 6 □
  static List<int> _createVertical(int boardSize) {
    final int totalTiles = boardSize * boardSize;
    final List<int> board = List<int>.filled(
      totalTiles,
      blankTile,
    );

    int number = 1;

    for (int column = 0; column < boardSize; column++) {
      for (int row = 0; row < boardSize; row++) {
        final int index = row * boardSize + column;

        if (number < totalTiles) {
          board[index] = number;
          number++;
        }
      }
    }

    return board;
  }

  /// 4. Zigzag
  ///
  /// 行ごとに左右の進行方向を交互に切り替えます。
  ///
  /// 3×3：
  /// 1 2 3
  /// 6 5 4
  /// 7 8 □
  static List<int> _createZigzag(int boardSize) {
    final int totalTiles = boardSize * boardSize;
    final List<int> board = List<int>.filled(
      totalTiles,
      blankTile,
    );

    int number = 1;

    for (int row = 0; row < boardSize; row++) {
      if (row.isEven) {
        // 左から右へ
        for (int column = 0;
            column < boardSize;
            column++) {
          final int index = row * boardSize + column;

          if (number < totalTiles) {
            board[index] = number;
            number++;
          }
        }
      } else {
        // 右から左へ
        for (int column = boardSize - 1;
            column >= 0;
            column--) {
          final int index = row * boardSize + column;

          if (number < totalTiles) {
            board[index] = number;
            number++;
          }
        }
      }
    }

    return board;
  }

  /// 5. Swirl
  ///
  /// 外側から時計回りに渦巻き状に数字を配置します。
  ///
  /// 3×3：
  /// 1 2 3
  /// 8 □ 4
  /// 7 6 5
  static List<int> _createSwirl(int boardSize) {
    final int totalTiles = boardSize * boardSize;
    final List<int> board = List<int>.filled(
      totalTiles,
      blankTile,
    );

    int top = 0;
    int bottom = boardSize - 1;
    int left = 0;
    int right = boardSize - 1;

    int number = 1;

    while (top <= bottom && left <= right) {
      // 上段：左から右
      for (int column = left;
          column <= right;
          column++) {
        _setTile(
          board,
          top * boardSize + column,
          number,
          totalTiles,
        );
        number++;
      }
      top++;

      // 右端：上から下
      for (int row = top;
          row <= bottom;
          row++) {
        _setTile(
          board,
          row * boardSize + right,
          number,
          totalTiles,
        );
        number++;
      }
      right--;

      // 下段：右から左
      if (top <= bottom) {
        for (int column = right;
            column >= left;
            column--) {
          _setTile(
            board,
            bottom * boardSize + column,
            number,
            totalTiles,
          );
          number++;
        }
        bottom--;
      }

      // 左端：下から上
      if (left <= right) {
        for (int row = bottom;
            row >= top;
            row--) {
          _setTile(
            board,
            row * boardSize + left,
            number,
            totalTiles,
          );
          number++;
        }
        left++;
      }
    }

    return board;
  }

  /// 6. Tornado
  ///
  /// Swirlの空白マスの位置を1の開始位置にします。
  ///
  /// 奇数サイズ：
  /// 中央から左 → 下 → 右 → 上の順に進みます。
  ///
  /// 偶数サイズ：
  /// 中央4マスの左下から
  /// 右 → 上 → 左 → 下の順に進みます。
  ///
  /// 盤面の外側にはみ出す位置は飛ばします。
  ///
  /// 最後の1マスは空白（0）として残します。
  ///
  /// 3×3：
  /// □ 8 7
  /// 2 1 6
  /// 3 4 5
  ///
  /// 4×4：
  /// □ 15 14 13
  /// 5  4  3 12
  /// 6  1  2 11
  /// 7  8  9 10
  static List<int> _createTornado(int boardSize) {
    final int totalTiles = boardSize * boardSize;

    final List<int> board = List<int>.filled(
      totalTiles,
      blankTile,
    );

    // Swirlの空白位置をTornadoの開始位置にする。
    //
    // 奇数サイズ：中央
    // 偶数サイズ：中央4マスの左下
    int row = boardSize ~/ 2;
    int column = (boardSize - 1) ~/ 2;

    int number = 1;

    // 進行方向：
    // 0 = 左
    // 1 = 下
    // 2 = 右
    // 3 = 上
    //
    // 奇数サイズ：左から開始
    // 偶数サイズ：右から開始
    int direction = boardSize.isEven ? 2 : 0;

    // 各方向への移動回数
    int stepLength = 1;

    // 最初の数字を中央に配置
    board[row * boardSize + column] = number;

    // 次の数字から外側へ広げる
    while (number < totalTiles - 1) {
      // 同じ移動回数で2方向ずつ進む
      for (int repeat = 0; repeat < 2; repeat++) {
        for (int step = 0; step < stepLength; step++) {
          // 進行方向に1マス移動
          switch (direction) {
            case 0:
              column--;
              break;
            case 1:
              row++;
              break;
            case 2:
              column++;
              break;
            case 3:
              row--;
              break;
          }

          // 盤面の範囲内にある位置だけ数字を配置
          if (row >= 0 &&
              row < boardSize &&
              column >= 0 &&
              column < boardSize) {
            number++;

            board[row * boardSize + column] = number;

            // 最後の1マスは空白として残す
            if (number >= totalTiles - 1) {
              break;
            }
          }
        }

        // 次の方向へ進む
        direction = (direction + 1) % 4;

        if (number >= totalTiles - 1) {
          break;
        }
      }

      // 2方向進んだら移動回数を1増やす
      stepLength++;
    }

    return board;
  }

  /// 指定位置に数字を配置
  ///
  /// 最後の1マスは空白（0）として残します。
  static void _setTile(
    List<int> board,
    int index,
    int number,
    int totalTiles,
  ) {
    if (number < totalTiles) {
      board[index] = number;
    }
  }
}