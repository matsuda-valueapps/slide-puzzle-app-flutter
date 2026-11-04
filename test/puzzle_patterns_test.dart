import 'package:flutter_test/flutter_test.dart';

import 'package:slide_puzzle_app/constants/puzzle_patterns.dart';

void main() {
  group('PuzzlePatterns - 完成パターン生成', () {
    // --------------------------------------------------
    // 1. Normal
    // --------------------------------------------------

    test('Normal - 3×3の完成盤面を正しく生成できる', () {
      final board = PuzzlePatterns.createGoalBoard(
        boardSize: 3,
        pattern: PuzzlePattern.normal,
      );

      expect(board, [1, 2, 3, 4, 5, 6, 7, 8, 0]);
    });

    // --------------------------------------------------
    // 2. Reverse
    // --------------------------------------------------

    test('Reverse - 3×3の完成盤面を正しく生成できる', () {
      final board = PuzzlePatterns.createGoalBoard(
        boardSize: 3,
        pattern: PuzzlePattern.reverse,
      );

      expect(board, [0, 8, 7, 6, 5, 4, 3, 2, 1]);
    });

    // --------------------------------------------------
    // 3. Vertical
    // --------------------------------------------------

    test('Vertical - 3×3の完成盤面を正しく生成できる', () {
      final board = PuzzlePatterns.createGoalBoard(
        boardSize: 3,
        pattern: PuzzlePattern.vertical,
      );

      expect(board, [1, 4, 7, 2, 5, 8, 3, 6, 0]);
    });

    // --------------------------------------------------
    // 4. Zigzag
    // --------------------------------------------------

    test('Zigzag - 3×3の完成盤面を正しく生成できる', () {
      final board = PuzzlePatterns.createGoalBoard(
        boardSize: 3,
        pattern: PuzzlePattern.zigzag,
      );

      expect(board, [1, 2, 3, 6, 5, 4, 7, 8, 0]);
    });

    // --------------------------------------------------
    // 5. Swirl
    // --------------------------------------------------

    test('Swirl - 3×3の完成盤面を正しく生成できる', () {
      final board = PuzzlePatterns.createGoalBoard(
        boardSize: 3,
        pattern: PuzzlePattern.swirl,
      );

      expect(board, [1, 2, 3, 8, 0, 4, 7, 6, 5]);
    });
  });

  // ----------------------------------------------------
  // 全パターン共通テスト
  // ----------------------------------------------------

  group('PuzzlePatterns - 盤面の整合性', () {
    test('3×3～7×7の全パターンで正しいマス数になる', () {
      for (final pattern in PuzzlePatterns.allPatterns) {
        for (int size = 3; size <= 7; size++) {
          final board = PuzzlePatterns.createGoalBoard(
            boardSize: size,
            pattern: pattern,
          );

          expect(
            board.length,
            size * size,
            reason: '${PuzzlePatterns.getPatternName(pattern)} $size×$size',
          );
        }
      }
    });

    test('全パターンで数字の重複や欠落がない', () {
      for (final pattern in PuzzlePatterns.allPatterns) {
        for (int size = 3; size <= 7; size++) {
          final board = PuzzlePatterns.createGoalBoard(
            boardSize: size,
            pattern: pattern,
          );

          final sortedBoard = List<int>.from(board)..sort();

          expect(
            sortedBoard,
            List<int>.generate(size * size, (index) => index),
            reason: '${PuzzlePatterns.getPatternName(pattern)} $size×$size',
          );
        }
      }
    });

    test('全パターンで空白マスは必ず1つ存在する', () {
      for (final pattern in PuzzlePatterns.allPatterns) {
        for (int size = 3; size <= 7; size++) {
          final board = PuzzlePatterns.createGoalBoard(
            boardSize: size,
            pattern: pattern,
          );

          expect(
            board.where((tile) => tile == 0).length,
            1,
            reason: '${PuzzlePatterns.getPatternName(pattern)} $size×$size',
          );
        }
      }
    });

    test('全パターンで空白以外の数字が正しく存在する', () {
      for (final pattern in PuzzlePatterns.allPatterns) {
        for (int size = 3; size <= 7; size++) {
          final board = PuzzlePatterns.createGoalBoard(
            boardSize: size,
            pattern: pattern,
          );

          expect(
            board.where((tile) => tile != 0).length,
            size * size - 1,
            reason: '${PuzzlePatterns.getPatternName(pattern)} $size×$size',
          );
        }
      }
    });
  });

  // ----------------------------------------------------
  // パターン名テスト
  // ----------------------------------------------------

  group('PuzzlePatterns - パターン名', () {
    test('5種類のパターン名を正しく取得できる', () {
      expect(
        PuzzlePatterns.getPatternName(PuzzlePattern.normal),
        'Normal',
      );

      expect(
        PuzzlePatterns.getPatternName(PuzzlePattern.reverse),
        'Reverse',
      );

      expect(
        PuzzlePatterns.getPatternName(PuzzlePattern.vertical),
        'Vertical',
      );

      expect(
        PuzzlePatterns.getPatternName(PuzzlePattern.zigzag),
        'Zigzag',
      );

      expect(
        PuzzlePatterns.getPatternName(PuzzlePattern.swirl),
        'Swirl',
      );
    });

    test('5種類のパターンが登録されている', () {
      expect(PuzzlePatterns.allPatterns.length, 5);
    });
  });

  // ----------------------------------------------------
  // 不正なサイズのテスト
  // ----------------------------------------------------

  group('PuzzlePatterns - エラー処理', () {
    test('2×2の盤面生成はエラーになる', () {
      expect(
        () => PuzzlePatterns.createGoalBoard(
          boardSize: 2,
          pattern: PuzzlePattern.normal,
        ),
        throwsArgumentError,
      );
    });

    test('8×8の盤面生成はエラーになる', () {
      expect(
        () => PuzzlePatterns.createGoalBoard(
          boardSize: 8,
          pattern: PuzzlePattern.normal,
        ),
        throwsArgumentError,
      );
    });
  });
}