import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// アプリ内で共通して使用するボタン
class GameButton extends StatelessWidget {
  /// ボタンに表示する文字
  final String text;

  /// ボタンを押したときの処理
  final VoidCallback? onPressed;

  /// ボタンの背景色
  final Color? backgroundColor;

  /// ボタンの文字色
  final Color? textColor;

  /// ボタンに表示するアイコン
  final IconData? icon;

  /// ボタンの横幅
  final double? width;

  /// ボタンの高さ
  final double height;

  /// 文字サイズ
  final double fontSize;

  /// 角丸の大きさ
  final double borderRadius;

  /// アイコンと文字の間隔
  final double iconSpacing;

  const GameButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height = 52,
    this.fontSize = 16,
    this.borderRadius = 12,
    this.iconSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final Color buttonColor =
        backgroundColor ?? AppColors.buttonPrimary;

    final Color labelColor =
        textColor ?? AppColors.buttonText;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: labelColor,
          disabledBackgroundColor: AppColors.buttonDisabled,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius,
            ),
          ),
        ),
        child: icon == null
            ? Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: fontSize + 4,
                  ),
                  SizedBox(width: iconSpacing),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}