import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/puzzle_patterns.dart';
import '../models/game_settings.dart';
import '../models/puzzle_state.dart';
import '../models/puzzle_save_data.dart';
import '../models/puzzle_record.dart';
import '../services/puzzle_engine.dart';
import '../services/puzzle_save_service.dart';
import '../services/record_service.dart';
import '../widgets/game_button.dart';
import '../widgets/game_timer.dart';
import '../widgets/puzzle_board.dart';

/// パズルゲーム画面
class PuzzleGamePage extends StatefulWidget {
  /// ゲーム設定
  final GameSettings settings;

  /// Pictureモードで使用する画像ID
  final String? imageId;

  /// 保存済みゲームデータ（続きから再開する場合）
  final PuzzleSaveData? initialSaveData;

  /// 戻るボタンの処理
  final VoidCallback? onBack;

  /// ゲーム完成時に記録を渡す処理
  final ValueChanged<PuzzleRecord>? onCompleted;

  const PuzzleGamePage({
    super.key,
    required this.settings,
    this.imageId,
    this.initialSaveData,
    this.onBack,
    this.onCompleted,
  });

  @override
  State<PuzzleGamePage> createState() => _PuzzleGamePageState();
}

class _PuzzleGamePageState extends State<PuzzleGamePage> {
  final PuzzleSaveService _saveService = PuzzleSaveService();
  final RecordService _recordService = RecordService();

  late PuzzleState _puzzleState;

  Timer? _gameTimer;

  bool _isSaving = false;
  bool _isCompleting = false;

  String? get _imageId =>
      widget.initialSaveData?.imageId ?? widget.imageId;

  @override
  void initState() {
    super.initState();

    _initializeGame();
  }

  /// ゲームの初期化
  void _initializeGame() {
    final savedData = widget.initialSaveData;

    // 保存データがある場合は続きから再開
    if (savedData != null) {
      _puzzleState = savedData.puzzleState.copyWith(
        isPaused: false,
      );
    } else {
      _createNewGame();
    }

    // 完成済みでなければタイマーを開始
    if (!_puzzleState.isCompleted) {
      _startTimer();
    }
  }

  /// 新しいゲームを生成
  void _createNewGame() {
    final int boardSize = widget.settings.boardSize;

    // Pictureモードは通常配置を使用する
    final PuzzlePattern pattern =
        widget.settings.isPictureMode
            ? PuzzlePattern.normal
            : widget.settings.pattern;

    // 完成盤面を生成
    final List<int> goalBoard =
        PuzzlePatterns.createGoalBoard(
      boardSize: boardSize,
      pattern: pattern,
    );

    // 完成盤面から合法的にシャッフル
    final List<int> shuffledBoard =
        PuzzleEngine.shuffleBoard(
      boardSize: boardSize,
      goalBoard: goalBoard,
    );

    _puzzleState = PuzzleState(
      board: shuffledBoard,
      goalBoard: goalBoard,
      boardSize: boardSize,
    );
  }

  /// タイマーを開始
  void _startTimer() {
    _gameTimer?.cancel();

    _gameTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted ||
            _puzzleState.isPaused ||
            _puzzleState.isCompleted) {
          return;
        }

        setState(() {
          _puzzleState = _puzzleState.copyWith(
            elapsedSeconds:
                _puzzleState.elapsedSeconds + 1,
          );
        });

        // 5秒ごとに途中経過を保存
        if (_puzzleState.elapsedSeconds % 5 == 0) {
          _saveGame();
        }
      },
    );
  }

  /// タイルをタップしたときの処理
  void _handleTileTap(int tileIndex) {
    if (_puzzleState.isPaused ||
        _puzzleState.isCompleted ||
        _isCompleting) {
      return;
    }

    // タイルを移動
    final List<int>? newBoard = PuzzleEngine.moveTile(
      _puzzleState.board,
      tileIndex,
      _puzzleState.boardSize,
    );

    // 移動できない場合は何もしない
    if (newBoard == null) {
      return;
    }

    setState(() {
      _puzzleState = _puzzleState.copyWith(
        board: newBoard,
        moveCount: _puzzleState.moveCount + 1,
      );
    });

    // 完成判定
    if (_puzzleState.isSolved) {
      _completeGame();
    } else {
      _saveGame();
    }
  }

  /// ゲームを一時停止
  Future<void> _pauseGame() async {
    if (_puzzleState.isCompleted) {
      return;
    }

    _gameTimer?.cancel();

    setState(() {
      _puzzleState = _puzzleState.copyWith(
        isPaused: true,
      );
    });

    await _saveGame();
  }

  /// ゲームを再開
  void _resumeGame() {
    if (_puzzleState.isCompleted) {
      return;
    }

    setState(() {
      _puzzleState = _puzzleState.copyWith(
        isPaused: false,
      );
    });

    _startTimer();
  }

  /// ゲームをシャッフルし直す
  Future<void> _shuffleGame() async {
    if (_puzzleState.isPaused ||
        _puzzleState.isCompleted ||
        _isCompleting) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Shuffle Puzzle'),
          content: const Text(
            'Current progress will be reset. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Shuffle'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final List<int> newBoard =
        PuzzleEngine.shuffleBoard(
      boardSize: _puzzleState.boardSize,
      goalBoard: _puzzleState.goalBoard,
    );

    setState(() {
      _puzzleState = _puzzleState.copyWith(
        board: newBoard,
        moveCount: 0,
        elapsedSeconds: 0,
        isPaused: false,
        isCompleted: false,
      );
    });

    _startTimer();

    await _saveGame();
  }

  /// ゲームの途中経過を保存
  Future<void> _saveGame() async {
    if (_isSaving || _puzzleState.isCompleted) {
      return;
    }

    _isSaving = true;

    try {
      final saveData = PuzzleSaveData(
        settings: widget.settings,
        puzzleState: _puzzleState,
        imageId: _imageId,
        savedAt: DateTime.now(),
      );

      await _saveService.saveGame(saveData);
    } catch (e) {
      debugPrint('Game save error: $e');
    } finally {
      _isSaving = false;
    }
  }

  /// ゲーム完成時の処理
  Future<void> _completeGame() async {
    if (_isCompleting) {
      return;
    }

    _isCompleting = true;

    _gameTimer?.cancel();

    setState(() {
      _puzzleState = _puzzleState.copyWith(
        isCompleted: true,
        isPaused: false,
      );
    });

    final PuzzleRecord record = PuzzleRecord(
      gameType: widget.settings.gameType,
      boardSize: widget.settings.boardSize,
      pattern: widget.settings.isPictureMode
          ? PuzzlePattern.normal
          : widget.settings.pattern,
      imageId: _imageId,
      bestTimeSeconds: _puzzleState.elapsedSeconds,
      bestMoveCount: _puzzleState.moveCount,
      achievedAt: DateTime.now(),
    );

    try {
      // ベスト記録を保存
      await _recordService.saveRecord(record);

      // 完成したゲームの途中保存データを削除
      await _saveService.deleteSaveData(
        widget.settings.gameType,
      );

      if (!mounted) {
        return;
      }

      // 完成画面へ結果を渡す
      widget.onCompleted?.call(record);
    } catch (e) {
      debugPrint('Game completion error: $e');
    }
  }

  /// ホーム画面などへ戻る
  Future<void> _handleBack() async {
    await _saveGame();

    if (!mounted) {
      return;
    }

    _gameTimer?.cancel();

    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();

    // 画面を閉じる直前にも保存を試みる
    if (!_puzzleState.isCompleted) {
      _saveGame();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
        title: const Text(
          'Puzzle Game',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.home_outlined),
            onPressed: _handleBack,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: Column(
                  children: [
                    // ゲーム情報
                    _buildGameInformation(),

                    const SizedBox(height: 24),

                    // パズル盤面
                    _buildPuzzleArea(
                      constraints.maxWidth,
                    ),

                    const SizedBox(height: 24),

                    // 操作ボタン
                    _buildControlButtons(),

                    const SizedBox(height: 20),

                    // 一時停止中の表示
                    if (_puzzleState.isPaused)
                      _buildPausedMessage(),

                    // 完成時の表示
                    if (_puzzleState.isCompleted)
                      _buildCompletedMessage(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// ゲーム情報
  Widget _buildGameInformation() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text(
                'Moves',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_puzzleState.moveCount}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          Container(
            width: 1,
            height: 42,
            color: AppColors.border,
          ),

          Column(
            children: [
              const Text(
                'Time',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              GameTimer(
                elapsedSeconds: _puzzleState.elapsedSeconds,
                fontSize: 20,
                iconSize: 18,
                showIcon: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// パズル盤面
  Widget _buildPuzzleArea(double availableWidth) {
    final double boardSize = availableWidth > 520
        ? 500
        : availableWidth;

    return Stack(
      alignment: Alignment.center,
      children: [
        PuzzleBoard(
          puzzleState: _puzzleState,
          maxBoardSize: boardSize,
          spacing: 4,
          onTileTap: _handleTileTap,
        ),

        if (_puzzleState.isPaused ||
            _puzzleState.isCompleted)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _puzzleState.isCompleted
                      ? 'Completed!'
                      : 'Paused',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 操作ボタン
  Widget _buildControlButtons() {
    return Row(
      children: [
        Expanded(
          child: GameButton(
            text: _puzzleState.isPaused
                ? 'Resume'
                : 'Pause',
            icon: _puzzleState.isPaused
                ? Icons.play_arrow_rounded
                : Icons.pause_rounded,
            height: 52,
            fontSize: 15,
            onPressed: _puzzleState.isCompleted
                ? null
                : () {
                    if (_puzzleState.isPaused) {
                      _resumeGame();
                    } else {
                      _pauseGame();
                    }
                  },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: GameButton(
            text: 'Shuffle',
            icon: Icons.shuffle_rounded,
            height: 52,
            fontSize: 15,
            backgroundColor: AppColors.buttonPrimary,
            onPressed: _puzzleState.isPaused ||
                    _puzzleState.isCompleted
                ? null
                : _shuffleGame,
          ),
        ),
      ],
    );
  }

  /// 一時停止中のメッセージ
  Widget _buildPausedMessage() {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Text(
        'Game Paused',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// 完成時のメッセージ
  Widget _buildCompletedMessage() {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Text(
        'Congratulations!',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}