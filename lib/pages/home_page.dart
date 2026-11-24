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
      // Game Settings画面と同じ背景色
      backgroundColor: AppColors.background,
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
                          // 写真を9分割したスライドパズルロゴ
                          const _SlidePuzzleLogo(),

                          const SizedBox(height: 28),

                          // アプリタイトル
                          const Text(
                            'Ritzy Slide Puzzle',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 0.3,
                            ),
                          ),

                          // アプリ名とボタンの間隔を縮小
                          const SizedBox(height: 32),

                          // New Game
                          GameButton(
                            text: 'New Game',
                            icon: Icons.play_arrow_rounded,
                            height: 58,
                            fontSize: 18,
                            backgroundColor: AppColors.buttonPrimary,
                            textColor: AppColors.primary,
                            borderColor: AppColors.primary,
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
                            textColor: AppColors.primary,
                            borderColor: AppColors.primary,
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
                            textColor: AppColors.primary,
                            borderColor: AppColors.primary,
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
                            textColor: AppColors.primary,
                            borderColor: AppColors.primary,
                            onPressed: onSettings,
                          ),

                          const SizedBox(height: 32),

                          // フッター
                          const Text(
                            'Ritzy Slide Puzzle',
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

/// 写真を3×3に分割したスライドパズルロゴ
///
/// picture_001.jpgを使用し、
/// 9マスすべてに写真が表示されるロゴにする。
class _SlidePuzzleLogo extends StatelessWidget {
  const _SlidePuzzleLogo();

  @override
  Widget build(BuildContext context) {
    // ロゴサイズを144から180に拡大
    const double logoSize = 180;

    return Align(
      alignment: Alignment.center,
      child: Container(
        width: logoSize,
        height: logoSize,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          // 角丸なしの四角い外枠
          border: Border.all(
            color: AppColors.primary,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Pictureモードで使用している画像
            // 角丸なしで表示
            Image.asset(
              'assets/images/picture_001.jpg',
              fit: BoxFit.cover,
            ),

            // 3×3のパズル盤面の区切り線
            CustomPaint(
              painter: _PuzzleLogoGridPainter(),
              child: const SizedBox.expand(),
            ),
          ],
        ),
      ),
    );
  }
}

/// ロゴ上に3×3の区切り線を描画する
class _PuzzleLogoGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.background.withValues(alpha: 0.85)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // 縦方向の区切り線
    for (int i = 1; i < 3; i++) {
      final double x = size.width * i / 3;

      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // 横方向の区切り線
    for (int i = 1; i < 3; i++) {
      final double y = size.height * i / 3;

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _PuzzleLogoGridPainter oldDelegate,
  ) {
    return false;
  }
}