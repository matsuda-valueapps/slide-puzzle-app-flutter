
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:slide_puzzle_app/services/puzzle_engine.dart';

void main() {
  group('PuzzleEngine - 盤面生成', () {
    test('3×3の完成盤面を正しく生成できる', () {
      final board = PuzzleEngine.createSolvedBoard(3);

      expect(
        board,
        equals([
          1, 2, 3,
          4, 5, 6,
          7, 8, 0,
        ]),
      );
    });

    test('4×4～7×7の完成盤面を正しく生成できる', () {
      for (int size = 4; size <= 7; size++) {
        final board = PuzzleEngine.createSolvedBoard(size);

        expect(board.length, equals(size * size));
        expect(board.first, equals(1));
        expect(board.last, equals(0));

        expect(
          board.toSet().length,
          equals(size * size),
        );
      }
    });

    test('2×2の盤面生成はエラーになる', () {
      expect(
        () => PuzzleEngine.createSolvedBoard(2),
        throwsArgumentError,
      );
    });

    test('8×8の盤面生成はエラーになる', () {
      expect(
        () => PuzzleEngine.createSolvedBoard(8),
        throwsArgumentError,
      );
    });
  });

  group('PuzzleEngine - 空白マスの管理', () {
    test('空白マスの位置を正しく取得できる', () {
      final board = [
        1, 2, 3,
        4, 0, 6,
        7, 8, 5,
      ];

      expect(
        PuzzleEngine.getBlankIndex(board),
        equals(4),
      );
    });

    test('空白マスが存在しない場合はエラーになる', () {
      final board = [
        1, 2, 3,
        4, 5, 6,
        7, 8, 9,
      ];

      expect(
        () => PuzzleEngine.getBlankIndex(board),
        throwsArgumentError,
      );
    });

    test('空白マスに隣接する位置を正しく取得できる', () {
      // 3×3の中央（index 4）
      expect(
        PuzzleEngine.getAdjacentIndices(4, 3).toSet(),
        equals({1, 3, 5, 7}),
      );

      // 3×3の左上（index 0）
      expect(
        PuzzleEngine.getAdjacentIndices(0, 3).toSet(),
        equals({1, 3}),
      );

      // 3×3の右下（index 8）
      expect(
        PuzzleEngine.getAdjacentIndices(8, 3).toSet(),
        equals({5, 7}),
      );
    });
  });

  group('PuzzleEngine - タイル移動判定', () {
    final board = [
      1, 2, 3,
      4, 5, 6,
      7, 0, 8,
    ];

    test('空白マスの左隣のタイルは移動できる', () {
      expect(
        PuzzleEngine.canMove(board, 6, 3),
        isTrue,
      );
    });

    test('空白マスの右隣のタイルは移動できる', () {
      expect(
        PuzzleEngine.canMove(board, 8, 3),
        isTrue,
      );
    });

    test('空白マスから離れたタイルは移動できない', () {
      expect(
        PuzzleEngine.canMove(board, 0, 3),
        isFalse,
      );
    });

    test('空白マス自体は移動できない', () {
      expect(
        PuzzleEngine.canMove(board, 7, 3),
        isFalse,
      );
    });

    test('盤面の範囲外は移動できない', () {
      expect(
        PuzzleEngine.canMove(board, -1, 3),
        isFalse,
      );

      expect(
        PuzzleEngine.canMove(board, 9, 3),
        isFalse,
      );
    });
  });

  group('PuzzleEngine - タイル移動', () {
    test('隣接タイルを正しく移動できる', () {
      final board = [
        1, 2, 3,
        4, 5, 6,
        7, 0, 8,
      ];

      final result = PuzzleEngine.moveTile(
        board,
        8,
        3,
      );

      expect(
        result,
        equals([
          1, 2, 3,
          4, 5, 6,
          7, 8, 0,
        ]),
      );
    });

    test('移動後の元の盤面は変更されない', () {
      final board = [
        1, 2, 3,
        4, 5, 6,
        7, 0, 8,
      ];

      final originalBoard = List<int>.from(board);

      PuzzleEngine.moveTile(board, 8, 3);

      expect(board, equals(originalBoard));
    });

    test('移動できないタイルを指定するとnullになる', () {
      final board = [
        1, 2, 3,
        4, 5, 6,
        7, 0, 8,
      ];

      final result = PuzzleEngine.moveTile(
        board,
        0,
        3,
      );

      expect(result, isNull);
    });
  });

  group('PuzzleEngine - シャッフル', () {
    test('シャッフル後の盤面は正しいマス数になる', () {
      for (int size = 3; size <= 7; size++) {
        final board = PuzzleEngine.shuffleBoard(
          boardSize: size,
          random: Random(42),
        );

        expect(
          board.length,
          equals(size * size),
        );
      }
    });

    test('シャッフル後も全ての数字が1つずつ存在する', () {
      for (int size = 3; size <= 7; size++) {
        final board = PuzzleEngine.shuffleBoard(
          boardSize: size,
          random: Random(size),
        );

        expect(
          board.toSet().length,
          equals(size * size),
        );

        expect(
          board.toSet(),
          equals(
            PuzzleEngine.createSolvedBoard(size).toSet(),
          ),
        );
      }
    });

    test('シャッフル後の盤面は完成状態ではない', () {
      for (int size = 3; size <= 7; size++) {
        final solvedBoard =
            PuzzleEngine.createSolvedBoard(size);

        final shuffledBoard = PuzzleEngine.shuffleBoard(
          boardSize: size,
          random: Random(size * 10),
        );

        expect(
          PuzzleEngine.isSolved(
            shuffledBoard,
            solvedBoard,
          ),
          isFalse,
        );
      }
    });

    test('シャッフル回数が0の場合はエラーになる', () {
      expect(
        () => PuzzleEngine.shuffleBoard(
          boardSize: 3,
          shuffleMoves: 0,
        ),
        throwsArgumentError,
      );
    });

    test('指定した完成盤面を基準にシャッフルできる', () {
      final customGoal = [
        8, 7, 6,
        5, 4, 3,
        2, 1, 0,
      ];

      final shuffledBoard = PuzzleEngine.shuffleBoard(
        boardSize: 3,
        goalBoard: customGoal,
        random: Random(42),
      );

      expect(
        shuffledBoard.toSet(),
        equals(customGoal.toSet()),
      );

      expect(
        PuzzleEngine.isSolved(
          shuffledBoard,
          customGoal,
        ),
        isFalse,
      );
    });
  });

  group('PuzzleEngine - クリア判定', () {
    test('標準完成盤面はクリアと判定される', () {
      final board = PuzzleEngine.createSolvedBoard(3);

      expect(
        PuzzleEngine.isSolved(board),
        isTrue,
      );
    });

    test('未完成の盤面はクリアと判定されない', () {
      final board = [
        1, 2, 3,
        4, 5, 6,
        7, 0, 8,
      ];

      expect(
        PuzzleEngine.isSolved(board),
        isFalse,
      );
    });

    test('指定した完成盤面と一致すればクリアと判定される', () {
      final customGoal = [
        8, 7, 6,
        5, 4, 3,
        2, 1, 0,
      ];

      expect(
        PuzzleEngine.isSolved(
          customGoal,
          customGoal,
        ),
        isTrue,
      );
    });

    test('盤面の要素数が異なる場合はクリアにならない', () {
      final board = [
        1, 2, 3,
        4, 5, 6,
        7, 8,
      ];

      final goalBoard = [
        1, 2, 3,
        4, 5, 6,
        7, 8, 0,
      ];

      expect(
        PuzzleEngine.isSolved(board, goalBoard),
        isFalse,
      );
    });
  });
}