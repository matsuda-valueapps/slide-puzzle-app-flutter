import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/puzzle_state.dart';
import 'puzzle_tile.dart';

/// スライドパズルの盤面全体を表示するウィジェット
class PuzzleBoard extends StatelessWidget {
  /// パズルの状態
  final PuzzleState puzzleState;

  /// タイルをタップしたときの処理
  final ValueChanged<int>? onTileTap;

  /// 盤面の最大サイズ
  final double maxBoardSize;

  /// タイル同士の間隔
  final double spacing;

  /// 盤面の背景色
  final Color? boardColor;

  /// タイルの背景色
  final Color? tileColor;

  /// タイルの文字色
  final Color? textColor;

  /// 空白マスの背景色
  final Color? blankColor;

  /// タイルの角丸
  final double borderRadius;

  const PuzzleBoard({
    super.key,
    required this.puzzleState,
    this.onTileTap,
    this.maxBoardSize = 500,
    this.spacing = 4,
    this.boardColor,
    this.tileColor,
    this.textColor,
    this.blankColor,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final int boardSize = puzzleState.boardSize;
    final List<int> board = puzzleState.board;

    // 盤面データの整合性を確認
    if (boardSize < 3 ||
        boardSize > 7 ||
        board.length != boardSize * boardSize) {
      return const Center(
        child: Text('Invalid puzzle board'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth =
            constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : maxBoardSize;

        final double availableHeight =
            constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : maxBoardSize;

        final double boardWidth = math.min(
          math.min(availableWidth, availableHeight),
          maxBoardSize,
        );

        final double tileSize =
            (boardWidth - spacing * (boardSize - 1)) /
                boardSize;

        return Center(
          child: Container(
            width: boardWidth,
            height: boardWidth,
            padding: EdgeInsets.all(spacing),
            decoration: BoxDecoration(
              color: boardColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(
                borderRadius,
              ),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: boardSize,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: 1,
              ),
              itemCount: board.length,
              itemBuilder: (context, index) {
                final int number = board[index];

                return PuzzleTile(
                  number: number,
                  size: tileSize,
                  backgroundColor: tileColor,
                  textColor: textColor,
                  blankColor: blankColor,
                  borderRadius: borderRadius,
                  onTap: number == 0
                      ? null
                      : () => onTileTap?.call(index),
                );
              },
            ),
          ),
        );
      },
    );
  }
}