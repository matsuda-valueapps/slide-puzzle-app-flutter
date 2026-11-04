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
                          // アプリロゴ
                          const Icon(
                            Icons.extension_rounded,
                            size: 88,
                            color: AppColors.primary,
                          ),

                          const SizedBox(height: 20),

                          // アプリタイトル
                          const Text(
                            'Slide Puzzle',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // サブタイトル
                          const Text(
                            'Challenge Your Mind',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
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
                            backgroundColor: AppColors.accent,
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
                            'Slide Puzzle',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
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