import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/picture_options.dart';
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

  /// フリック開始位置
  Offset? _swipeStartPosition;

  /// 使用する画像ID
  String? get _imageId =>
      widget.initialSaveData?.imageId ?? widget.imageId;

  /// 画像IDから画像ファイルのパスを取得
  String? get _pictureAssetPath {
    final String? imageId = _imageId;

    if (imageId == null) {
      return null;
    }

    for (final picture in pictureOptions) {
      if (picture.id == imageId) {
        return picture.assetPath;
      }
    }

    return null;
  }

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

  /// 経過時間を mm:ss 形式に変換
  String _formatElapsedTime(int elapsedSeconds) {
    final int minutes = elapsedSeconds ~/ 60;
    final int seconds = elapsedSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
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

    // タップしたタイルから空白マスまでまとめて移動
    _moveTilesToBlank(tileIndex);
  }

  /// 指定したタイルから空白マスまで移動
  ///
  /// タップ・フリック共通の移動処理
  void _moveTilesToBlank(int tileIndex) {
    if (_puzzleState.isPaused ||
        _puzzleState.isCompleted ||
        _isCompleting) {
      return;
    }

    final int boardSize = _puzzleState.boardSize;
    final List<int> board = _puzzleState.board;

    // 範囲外のインデックスは無視
    if (tileIndex < 0 || tileIndex >= board.length) {
      return;
    }

    // 空白マス自体は移動できない
    if (board[tileIndex] == PuzzleEngine.blankTile) {
      return;
    }

    final int blankIndex =
        PuzzleEngine.getBlankIndex(board);

    // タイルと空白マスが同じ行・列にあるか確認
    final int tileRow = tileIndex ~/ boardSize;
    final int tileColumn = tileIndex % boardSize;

    final int blankRow = blankIndex ~/ boardSize;
    final int blankColumn = blankIndex % boardSize;

    final bool sameRow = tileRow == blankRow;
    final bool sameColumn = tileColumn == blankColumn;

    // 同じ行でも列でもない場合は移動できない
    if (!sameRow && !sameColumn) {
      return;
    }

    // 複数タイルを移動できるか確認
    if (!PuzzleEngine.canMoveTilesToBlank(
      board,
      tileIndex,
      boardSize,
    )) {
      return;
    }

    // 空白マスまで複数タイルを移動
    final List<int>? newBoard =
        PuzzleEngine.moveTilesToBlank(
      board,
      tileIndex,
      boardSize,
    );

    if (newBoard == null) {
      return;
    }

    // 移動したタイルの枚数を計算
    final int movedTileCount = sameRow
        ? (blankColumn - tileColumn).abs()
        : (blankRow - tileRow).abs();

    _applyBoardMove(
      newBoard,
      movedTileCount,
    );
  }

  /// フリック開始時の位置を取得
  ///
  /// Listenerを使用することで、
  /// 子ウィジェットのタップ処理と競合せずに位置を取得する
  void _handleSwipeStart(PointerDownEvent event) {
    if (_puzzleState.isPaused ||
        _puzzleState.isCompleted ||
        _isCompleting) {
      _swipeStartPosition = null;
      return;
    }

    _swipeStartPosition = event.localPosition;
  }

  /// フリック終了時の処理
  void _handleSwipeEnd(
    PointerUpEvent event,
    double boardDisplaySize,
  ) {
    final Offset? startPosition = _swipeStartPosition;

    _swipeStartPosition = null;

    if (startPosition == null ||
        _puzzleState.isPaused ||
        _puzzleState.isCompleted ||
        _isCompleting) {
      return;
    }

    final Offset endPosition = event.localPosition;

    final double deltaX =
        endPosition.dx - startPosition.dx;

    final double deltaY =
        endPosition.dy - startPosition.dy;

    // 盤面の大きさから1マスのサイズを計算
    final double tileSize =
        boardDisplaySize / _puzzleState.boardSize;

    // 最低限必要なフリック距離
    final double minimumSwipeDistance =
        tileSize * 0.2 > 18
            ? tileSize * 0.2
            : 18;

    // 短すぎる操作は無視
    if (Offset(deltaX, deltaY).distance <
        minimumSwipeDistance) {
      return;
    }

    // 横方向・縦方向のどちらのフリックか判定
    final bool isHorizontalSwipe =
        deltaX.abs() > deltaY.abs();

    // フリック開始位置から対象タイルを特定
    final int boardSize = _puzzleState.boardSize;

    final int tileColumn =
        (startPosition.dx / boardDisplaySize * boardSize)
            .floor();

    final int tileRow =
        (startPosition.dy / boardDisplaySize * boardSize)
            .floor();

    if (tileColumn < 0 ||
        tileColumn >= boardSize ||
        tileRow < 0 ||
        tileRow >= boardSize) {
      return;
    }

    final int tileIndex =
        tileRow * boardSize + tileColumn;

    // 空白マス自体からのフリックは無視
    if (_puzzleState.board[tileIndex] ==
        PuzzleEngine.blankTile) {
      return;
    }

    final int blankIndex =
        PuzzleEngine.getBlankIndex(_puzzleState.board);

    final int blankRow = blankIndex ~/ boardSize;
    final int blankColumn = blankIndex % boardSize;

    final bool sameRow = tileRow == blankRow;
    final bool sameColumn = tileColumn == blankColumn;

    // 空白マスと同じ行・列にない場合は移動できない
    if (!sameRow && !sameColumn) {
      return;
    }

    // 横方向のフリックの場合
    if (isHorizontalSwipe) {
      // 空白マスと同じ行でなければ無効
      if (!sameRow) {
        return;
      }

      // 空白マスの方向へフリックしているか確認
      final bool isCorrectDirection =
          (blankColumn > tileColumn && deltaX > 0) ||
          (blankColumn < tileColumn && deltaX < 0);

      if (!isCorrectDirection) {
        return;
      }
    } else {
      // 縦方向のフリックの場合
      if (!sameColumn) {
        return;
      }

      // 空白マスの方向へフリックしているか確認
      final bool isCorrectDirection =
          (blankRow > tileRow && deltaY > 0) ||
          (blankRow < tileRow && deltaY < 0);

      if (!isCorrectDirection) {
        return;
      }
    }

    // タップと共通の移動処理を実行
    _moveTilesToBlank(tileIndex);
  }

  /// フリックキャンセル時の処理
  void _handleSwipeCancel() {
    _swipeStartPosition = null;
  }

  /// 盤面の更新・手数加算・完成判定
  void _applyBoardMove(
    List<int> newBoard,
    int movedTileCount,
  ) {
    if (!mounted ||
        _puzzleState.isPaused ||
        _puzzleState.isCompleted ||
        _isCompleting) {
      return;
    }

    setState(() {
      _puzzleState = _puzzleState.copyWith(
        board: newBoard,
        moveCount:
            _puzzleState.moveCount + movedTileCount,
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

      // ゲーム完成時の記録を必要に応じて渡す
      // main.dartでは中央ダイアログを表示しない
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
        foregroundColor: AppColors.primary,
        elevation: 0,

        // タイトルを画面中央に配置
        centerTitle: true,

        // 左端の戻る矢印
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),

        // 中央のタイトル
        title: const Text(
          'Puzzle Game',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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

                    // 完成時の結果表示
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
          color: AppColors.primary,
          width: 1.5,
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
                  fontSize: 15,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_puzzleState.moveCount}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 42,
            color: AppColors.primary,
          ),
          Column(
            children: [
              const Text(
                'Time',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatElapsedTime(
                  _puzzleState.elapsedSeconds,
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// パズル盤面
  Widget _buildPuzzleArea(double availableWidth) {
    final double boardDisplaySize = availableWidth > 520
        ? 500
        : availableWidth;

    final String? pictureAssetPath = _pictureAssetPath;

    return Center(
      child: SizedBox(
        width: boardDisplaySize,
        height: boardDisplaySize,
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _handleSwipeStart,
          onPointerUp: (event) {
            _handleSwipeEnd(
              event,
              boardDisplaySize,
            );
          },
          onPointerCancel: (event) {
            _handleSwipeCancel();
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pictureモードで画像が見つからない場合
              if (widget.settings.isPictureMode &&
                  pictureAssetPath == null)
                Container(
                  width: boardDisplaySize,
                  height: boardDisplaySize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.image_not_supported_outlined,
                        size: 56,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Picture not available',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'The selected picture could not be found. Please add the picture to the picture list.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                PuzzleBoard(
                  puzzleState: _puzzleState,
                  maxBoardSize: boardDisplaySize,

                  // タイル間隔・盤面内側の余白を2.0に統一
                  spacing: 2,

                  pictureAssetPath: pictureAssetPath,
                  onTileTap: _handleTileTap,
                ),

              // 一時停止中のみ盤面にオーバーレイを表示
              // 完成時は画像を隠さない
              if (_puzzleState.isPaused)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Paused',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
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
            backgroundColor: AppColors.buttonPrimary,
            textColor: AppColors.primary,
            borderColor: AppColors.primary,
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
            textColor: AppColors.primary,
            borderColor: AppColors.primary,
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

  /// 完成時の結果表示
  ///
  /// パズル盤面を隠さず、画面下部にコンパクトに表示する
  Widget _buildCompletedMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  const SizedBox(height: 4),
                  Text(
                    '${_puzzleState.moveCount}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 36,
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
                  const SizedBox(height: 4),
                  GameTimer(
                    elapsedSeconds: _puzzleState.elapsedSeconds,
                    fontSize: 18,
                    iconSize: 16,
                    showIcon: false,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 150,
            child: GameButton(
              text: 'Home',
              icon: Icons.home_outlined,
              height: 44,
              fontSize: 14,
              onPressed: _handleBack,
            ),
          ),
        ],
      ),
    );
  }
}