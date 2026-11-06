import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../widgets/game_button.dart';

/// アプリのホーム画面
class HomePage extends StatelessWidget {
  /// New Game ボタンの処理
  final VoidCallback onNewGame;

  /// Continue ボタンの処理
  final VoidCallback onContinue;

  /// Records ボタンの処理
  final VoidCallback onRecords;

  /// Settings ボタンの処理
  final VoidCallback onSettings;

  const HomePage({
    super.key,
    required this.onNewGame,
    required this.onContinue,
    required this.onRecords,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 32,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 420,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // スライドパズルロゴ
                          const _SlidePuzzleLogo(),

                          const SizedBox(height: 24),

                          // アプリタイトル
                          const Text(
                            'Eazy Slide Puzzle',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                              letterSpacing: 0.3,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // サブタイトル
                          const Text(
                            'Challenge Your Mind',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),

                          const SizedBox(height: 56),

                          // New Game
                          GameButton(
                            text: 'New Game',
                            icon: Icons.play_arrow_rounded,
                            height: 58,
                            fontSize: 18,
                            onPressed: onNewGame,
                          ),

                          const SizedBox(height: 16),

                          // Continue
                          GameButton(
                            text: 'Continue',
                            icon: Icons.restore_rounded,
                            height: 58,
                            fontSize: 18,
                            backgroundColor: AppColors.buttonPrimary,
                            onPressed: onContinue,
                          ),

                          const SizedBox(height: 16),

                          // Records
                          GameButton(
                            text: 'Records',
                            icon: Icons.emoji_events_outlined,
                            height: 58,
                            fontSize: 18,
                            backgroundColor: AppColors.buttonPrimary,
                            onPressed: onRecords,
                          ),

                          const SizedBox(height: 16),

                          // Settings
                          GameButton(
                            text: 'Settings',
                            icon: Icons.settings_outlined,
                            height: 58,
                            fontSize: 18,
                            backgroundColor: AppColors.buttonPrimary,
                            onPressed: onSettings,
                          ),

                          const SizedBox(height: 32),

                          // フッター
                          const Text(
                            'Eazy Slide Puzzle',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 3×3のスライドパズルをイメージしたロゴ
class _SlidePuzzleLogo extends StatelessWidget {
  const _SlidePuzzleLogo();

  @override
  Widget build(BuildContext context) {
    const double logoSize = 88;
    const double spacing = 3;

    return Align(
      alignment: Alignment.center,
      child: SizedBox.square(
        dimension: logoSize,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (int row = 0; row < 3; row++) ...[
                if (row > 0) const SizedBox(height: spacing),
                Expanded(
                  child: Row(
                    children: [
                      for (int column = 0; column < 3; column++) ...[
                        if (column > 0) const SizedBox(width: spacing),
                        Expanded(
                          child: _buildTile(row, column),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 数字タイルまたは空白マスを生成
  Widget _buildTile(int row, int column) {
    final int number = row * 3 + column + 1;

    // 右下を空白マスにする
    if (number == 9) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
      );
    }

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '$number',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}