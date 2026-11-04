import 'package:flutter/foundation.dart';

/// パズルの進行状態を管理するモデル
@immutable
class PuzzleState {
  /// 現在の盤面
  ///
  /// 0は空白マスを表す。
  final List<int> board;

  /// 完成時の盤面
  final List<int> goalBoard;

  /// 盤面サイズ（3～7）
  final int boardSize;

  /// タイルの移動回数
  final int moveCount;

  /// 経過時間（秒）
  final int elapsedSeconds;

  /// 一時停止中かどうか
  final bool isPaused;

  /// クリア済みかどうか
  final bool isCompleted;

  /// コンストラクタ
  PuzzleState({
    required List<int> board,
    required List<int> goalBoard,
    required this.boardSize,
    this.moveCount = 0,
    this.elapsedSeconds = 0,
    this.isPaused = false,
    this.isCompleted = false,
  })  : board = List.unmodifiable(board),
        goalBoard = List.unmodifiable(goalBoard) {
    if (boardSize < 3 || boardSize > 7) {
      throw ArgumentError('Board size must be between 3 and 7.');
    }

    if (board.length != boardSize * boardSize) {
      throw ArgumentError('Invalid board length.');
    }

    if (goalBoard.length != boardSize * boardSize) {
      throw ArgumentError('Invalid goal board length.');
    }

    if (moveCount < 0) {
      throw ArgumentError('Move count cannot be negative.');
    }

    if (elapsedSeconds < 0) {
      throw ArgumentError('Elapsed seconds cannot be negative.');
    }
  }

  /// 盤面の総マス数
  int get totalTiles => boardSize * boardSize;

  /// 空白以外のタイル数
  int get puzzleTileCount => totalTiles - 1;

  /// 空白マスの位置
  int get blankIndex => board.indexOf(0);

  /// 空白マスの行
  int get blankRow {
    final index = blankIndex;
    return index == -1 ? -1 : index ~/ boardSize;
  }

  /// 空白マスの列
  int get blankColumn {
    final index = blankIndex;
    return index == -1 ? -1 : index % boardSize;
  }

  /// 新しい状態を生成する
  PuzzleState copyWith({
    List<int>? board,
    List<int>? goalBoard,
    int? boardSize,
    int? moveCount,
    int? elapsedSeconds,
    bool? isPaused,
    bool? isCompleted,
  }) {
    return PuzzleState(
      board: board ?? this.board,
      goalBoard: goalBoard ?? this.goalBoard,
      boardSize: boardSize ?? this.boardSize,
      moveCount: moveCount ?? this.moveCount,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isPaused: isPaused ?? this.isPaused,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// 現在の盤面が完成状態かどうか
  bool get isSolved {
    if (board.length != goalBoard.length) {
      return false;
    }

    for (int i = 0; i < board.length; i++) {
      if (board[i] != goalBoard[i]) {
        return false;
      }
    }

    return true;
  }
}