import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// ゲームの経過時間を表示するウィジェット
class GameTimer extends StatelessWidget {
  /// 経過時間（秒）
  final int elapsedSeconds;

  /// 文字サイズ
  final double fontSize;

  /// 文字色
  final Color? color;

  /// アイコンを表示するか
  final bool showIcon;

  /// アイコンのサイズ
  final double iconSize;

  /// アイコンと文字の間隔
  final double iconSpacing;

  const GameTimer({
    super.key,
    required this.elapsedSeconds,
    this.fontSize = 16,
    this.color,
    this.showIcon = true,
    this.iconSize = 20,
    this.iconSpacing = 6,
  });

  /// 秒数を時間表示形式に変換する
  String _formatTime(int seconds) {
    final int safeSeconds = seconds < 0 ? 0 : seconds;

    final int hours = safeSeconds ~/ 3600;
    final int minutes = (safeSeconds % 3600) ~/ 60;
    final int remainingSeconds = safeSeconds % 60;

    final String formattedMinutes =
        minutes.toString().padLeft(2, '0');

    final String formattedSeconds =
        remainingSeconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final String formattedHours =
          hours.toString().padLeft(2, '0');

      return '$formattedHours:$formattedMinutes:$formattedSeconds';
    }

    return '$formattedMinutes:$formattedSeconds';
  }

  @override
  Widget build(BuildContext context) {
    final Color timerColor = color ?? AppColors.textPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Icon(
            Icons.timer_outlined,
            size: iconSize,
            color: timerColor,
          ),
          SizedBox(width: iconSpacing),
        ],
        Text(
          _formatTime(elapsedSeconds),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: timerColor,
            fontFeatures: const [
              FontFeature.tabularFigures(),
            ],
          ),
        ),
      ],
    );
  }
}