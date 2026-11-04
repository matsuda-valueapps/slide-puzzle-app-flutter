import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/game_settings.dart';
import '../constants/puzzle_patterns.dart';
import '../widgets/game_button.dart';

/// ゲーム設定画面
class GameSelectPage extends StatefulWidget {
  /// ゲーム開始時に設定を渡す処理
  final ValueChanged<GameSettings> onStart;

  /// 戻るボタンの処理
  final VoidCallback? onBack;

  const GameSelectPage({
    super.key,
    required this.onStart,
    this.onBack,
  });

  @override
  State<GameSelectPage> createState() => _GameSelectPageState();
}

class _GameSelectPageState extends State<GameSelectPage> {
  /// 選択中のゲームタイプ
  GameType _selectedGameType = GameType.number;

  /// 選択中の盤面サイズ
  int _selectedBoardSize = 3;

  /// 選択中の完成パターン
  PuzzlePattern _selectedPattern = PuzzlePattern.normal;

  /// パターン名を表示用の文字列に変換
  String _patternLabel(PuzzlePattern pattern) {
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
    }
  }

  /// 選択中のサイズとパターンから完成盤面を生成
  List<int> _createPatternPreview() {
    return PuzzlePatterns.createGoalBoard(
      boardSize: _selectedBoardSize,
      pattern: _selectedPattern,
    );
  }

  /// 選択した設定でゲームを開始
  void _startGame() {
    final settings = GameSettings(
      gameType: _selectedGameType,
      boardSize: _selectedBoardSize,
      pattern: _selectedPattern,
    );

    widget.onStart(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Game Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack ??
              () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Game Type
                  _buildSectionTitle('Game Type'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSelectionCard(
                          title: 'Number',
                          icon: Icons.grid_on_rounded,
                          isSelected:
                              _selectedGameType == GameType.number,
                          onTap: () {
                            setState(() {
                              _selectedGameType = GameType.number;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSelectionCard(
                          title: 'Picture',
                          icon: Icons.image_outlined,
                          isSelected:
                              _selectedGameType == GameType.picture,
                          onTap: () {
                            setState(() {
                              _selectedGameType = GameType.picture;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Board Size
                  _buildSectionTitle('Board Size'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: GameSettings.availableBoardSizes.map((size) {
                      final bool isSelected =
                          _selectedBoardSize == size;

                      return ChoiceChip(
                        label: Text('$size×$size'),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedBoardSize = size;
                            });
                          }
                        },
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.cardBackground,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.buttonText
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      );
                    }).toList(),
                  ),

                  // Pattern
                  if (_selectedGameType == GameType.number) ...[
                    const SizedBox(height: 32),
                    _buildSectionTitle('Pattern'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: PuzzlePattern.values.map((pattern) {
                        final bool isSelected =
                            _selectedPattern == pattern;

                        return ChoiceChip(
                          label: Text(_patternLabel(pattern)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedPattern = pattern;
                              });
                            }
                          },
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.cardBackground,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.buttonText
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Pattern Preview
                    _buildPatternPreview(),
                  ],

                  const SizedBox(height: 40),

                  // Start Game
                  GameButton(
                    text: _selectedGameType == GameType.picture
                        ? 'Select Picture'
                        : 'Start Game',
                    icon: Icons.play_arrow_rounded,
                    height: 58,
                    fontSize: 18,
                    onPressed: _startGame,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 完成盤面の見本
  Widget _buildPatternPreview() {
    final previewBoard = _createPatternPreview();

    return Column(
      children: [
        Text(
          _patternLabel(_selectedPattern),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final boardWidth = constraints.maxWidth
                .clamp(0.0, 320.0)
                .toDouble();

            final tileSpacing = _selectedBoardSize >= 6 ? 2.0 : 3.0;
            final boardPadding = _selectedBoardSize >= 6 ? 4.0 : 6.0;

            final tileFontSize =
                (_selectedBoardSize <= 3 ? 30.0 : 26.0) /
                    (_selectedBoardSize / 3);

            return Center(
              child: Container(
                width: boardWidth,
                height: boardWidth,
                padding: EdgeInsets.all(boardPadding),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 3,
                  ),
                ),
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: previewBoard.length,
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _selectedBoardSize,
                    crossAxisSpacing: tileSpacing,
                    mainAxisSpacing: tileSpacing,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final number = previewBoard[index];
                    final isBlank = number == 0;

                    return Container(
                      decoration: BoxDecoration(
                        color: isBlank
                            ? AppColors.background
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(
                          _selectedBoardSize >= 6 ? 3 : 6,
                        ),
                        border: Border.all(
                          color: isBlank
                              ? AppColors.border
                              : AppColors.primary,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isBlank
                          ? const SizedBox.shrink()
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '$number',
                                style: TextStyle(
                                  fontSize: tileFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.buttonText,
                                ),
                              ),
                            ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Text(
          '$_selectedBoardSize×$_selectedBoardSize Preview',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// セクションタイトル
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// ゲームタイプ選択カード
  Widget _buildSelectionCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected
          ? AppColors.primaryLight
          : AppColors.cardBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 24,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 36,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}