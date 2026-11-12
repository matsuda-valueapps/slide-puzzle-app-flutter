import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/puzzle_state.dart';
import '../services/puzzle_engine.dart';
import 'picture_tile.dart';
import 'puzzle_tile.dart';

/// スライドパズルの盤面全体を表示するウィジェット
class PuzzleBoard extends StatelessWidget {
  /// パズルの状態
  final PuzzleState puzzleState;

  /// タイルをタップしたときの処理
  final ValueChanged<int>? onTileTap;

  /// タイルをフリックしたときの処理
  final ValueChanged<int>? onTileSwipe;

  /// Pictureモードで使用する画像のアセットパス
  /// nullの場合はNumberモードとして表示する
  final String? pictureAssetPath;

  /// 盤面の最大サイズ
  final double maxBoardSize;

  /// タイル同士の間隔・盤面内側の余白
  ///
  /// 既存コードとの互換性のため残している。
  /// 実際の盤面では常に2.0を使用する。
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
  ///
  /// 既存コードとの互換性のため残している。
  /// 実際のタイルには角丸を適用しない。
  final double borderRadius;

  /// タイル間隔・盤面内側の余白
  static const double _boardSpacing = 2.0;

  /// 盤面外枠の線幅
  static const double _boardBorderWidth = 3.0;

  const PuzzleBoard({
    super.key,
    required this.puzzleState,
    this.onTileTap,
    this.onTileSwipe,
    this.pictureAssetPath,
    this.maxBoardSize = 500,
    this.spacing = 2,
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

        // 盤面の内側のサイズ
        // 左右・上下の余白2.0を差し引く
        final double innerBoardWidth =
            boardWidth - _boardSpacing * 2;

        // タイル1マスの実際のサイズ
        // 盤面内側の余白とタイル間隔を差し引いて計算
        final double actualTileSize =
            (innerBoardWidth -
                    _boardSpacing * (boardSize - 1)) /
                boardSize;

        // タイル間隔を含めた1マスの幅
        final double tileStride =
            actualTileSize + _boardSpacing;

        // フリック開始位置を盤面インデックスに変換
        int? getTileIndex(Offset position) {
          final double x = position.dx - _boardSpacing;
          final double y = position.dy - _boardSpacing;

          if (x < 0 ||
              y < 0 ||
              x >= innerBoardWidth ||
              y >= innerBoardWidth) {
            return null;
          }

          final int column =
              (x / tileStride).floor();

          final int row =
              (y / tileStride).floor();

          if (row < 0 ||
              row >= boardSize ||
              column < 0 ||
              column >= boardSize) {
            return null;
          }

          // タイルとタイルの間の隙間は対象外
          final double positionInCellX =
              x - column * tileStride;

          final double positionInCellY =
              y - row * tileStride;

          if (positionInCellX >= actualTileSize ||
              positionInCellY >= actualTileSize) {
            return null;
          }

          return row * boardSize + column;
        }

        // フリック方向が空白マスの方向か確認
        bool isFlickingTowardBlank(
          int tileIndex,
          Offset velocity,
        ) {
          final int blankIndex =
              PuzzleEngine.getBlankIndex(board);

          final int tileRow =
              tileIndex ~/ boardSize;

          final int tileColumn =
              tileIndex % boardSize;

          final int blankRow =
              blankIndex ~/ boardSize;

          final int blankColumn =
              blankIndex % boardSize;

          // 同じ行の場合は左右方向を判定
          if (tileRow == blankRow) {
            if (velocity.dx.abs() <
                velocity.dy.abs() * 1.2) {
              return false;
            }

            if (blankColumn > tileColumn) {
              return velocity.dx > 0;
            }

            return velocity.dx < 0;
          }

          // 同じ列の場合は上下方向を判定
          if (tileColumn == blankColumn) {
            if (velocity.dy.abs() <
                velocity.dx.abs() * 1.2) {
              return false;
            }

            if (blankRow > tileRow) {
              return velocity.dy > 0;
            }

            return velocity.dy < 0;
          }

          return false;
        }

        Offset? swipeStartPosition;

        return Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: onTileSwipe == null
                ? null
                : (details) {
                    swipeStartPosition =
                        details.localPosition;
                  },
            onPanEnd: onTileSwipe == null
                ? null
                : (details) {
                    final Offset? startPosition =
                        swipeStartPosition;

                    swipeStartPosition = null;

                    if (startPosition == null) {
                      return;
                    }

                    final Offset velocity =
                        details.velocity.pixelsPerSecond;

                    // 短すぎる操作や弱い操作は無視
                    if (velocity.distance < 250) {
                      return;
                    }

                    final int? tileIndex =
                        getTileIndex(startPosition);

                    if (tileIndex == null) {
                      return;
                    }

                    // 空白マス自体は対象外
                    if (board[tileIndex] == 0) {
                      return;
                    }

                    // 指定したタイルから空白マスまで
                    // 移動できる配置か確認
                    if (!PuzzleEngine.canMoveTilesToBlank(
                      board,
                      tileIndex,
                      boardSize,
                    )) {
                      return;
                    }

                    // フリック方向が空白マスの方向か確認
                    if (!isFlickingTowardBlank(
                      tileIndex,
                      velocity,
                    )) {
                      return;
                    }

                    onTileSwipe?.call(tileIndex);
                  },
            onPanCancel: () {
              swipeStartPosition = null;
            },
            child: Container(
              width: boardWidth,
              height: boardWidth,
              padding: const EdgeInsets.all(_boardSpacing),
              decoration: BoxDecoration(
                color: boardColor ??
                    AppColors.cardBackground,

                // 盤面外枠を完全な四角形にする
                borderRadius: BorderRadius.zero,

                // シャンパンゴールドの外枠
                // Numberモード・Pictureモード共通
                border: Border.all(
                  color: AppColors.primary,
                  width: _boardBorderWidth,
                ),
              ),
              child: GridView.builder(
                physics:
                    const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: boardSize,
                  crossAxisSpacing: _boardSpacing,
                  mainAxisSpacing: _boardSpacing,
                  childAspectRatio: 1,
                ),
                itemCount: board.length,
                itemBuilder: (context, index) {
                  final int number = board[index];

                  // Pictureモードの場合
                  if (pictureAssetPath != null) {
                    return PictureTile(
                      assetPath: pictureAssetPath!,
                      number: number,
                      boardSize: boardSize,
                      size: actualTileSize,
                      backgroundColor: tileColor,
                      blankColor: blankColor,
                      borderRadius: borderRadius,
                      onTap: number == 0
                          ? null
                          : () => onTileTap?.call(index),
                    );
                  }

                  // Numberモードの場合
                  return PuzzleTile(
                    number: number,
                    size: actualTileSize,
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
          ),
        );
      },
    );
  }
}