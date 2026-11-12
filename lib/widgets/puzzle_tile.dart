import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// スライドパズルの各タイルを表示するウィジェット
class PuzzleTile extends StatelessWidget {
  /// タイルに表示する数字
  /// 0の場合は空白マスとして扱う
  final int number;

  /// タイルの一辺のサイズ
  final double size;

  /// タイルをタップしたときの処理
  final VoidCallback? onTap;

  /// タイルの背景色
  final Color? backgroundColor;

  /// タイルの文字色
  final Color? textColor;

  /// 空白マスの背景色
  final Color? blankColor;

  /// 数字の文字サイズ
  final double? fontSize;

  /// タイルの角丸の大きさ
  ///
  /// 既存コードとの互換性のため残している。
  /// 実際の表示では角丸を使用しない。
  final double borderRadius;

  /// タイル同士の境界線の太さ
  final double borderWidth;

  /// 空白マスを表示するか
  final bool showBlankTile;

  const PuzzleTile({
    super.key,
    required this.number,
    required this.size,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.blankColor,
    this.fontSize,
    this.borderRadius = 8,
    this.borderWidth = 1,
    this.showBlankTile = false,
  });

  /// 空白マスかどうか
  bool get isBlank => number == 0;

  @override
  Widget build(BuildContext context) {
    // 空白マスの色
    // アプリ全体の背景色と同じ色にする
    final Color tileBlankColor =
        blankColor ?? AppColors.background;

    // 通常タイルの背景色
    // 濃紺
    final Color tileBackgroundColor =
        backgroundColor ?? AppColors.tileBackground;

    // 数字の文字色
    // ゴールド
    final Color tileTextColor =
        textColor ?? AppColors.tileText;

    // 数字のサイズ
    final double tileFontSize =
        fontSize ?? size * 0.35;

    // 空白マスの表示設定
    if (isBlank && !showBlankTile) {
      return SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tileBlankColor,
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.08),
              width: borderWidth,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: isBlank
            ? tileBlankColor
            : tileBackgroundColor,

        // タイルの角丸をなくして完全な正方形にする
        borderRadius: BorderRadius.zero,

        child: InkWell(
          onTap: isBlank ? null : onTap,

          // タップ時の反応範囲も角丸にしない
          borderRadius: BorderRadius.zero,

          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // タイルの角丸をなくす
              borderRadius: BorderRadius.zero,

              border: Border.all(
                color: Colors.black.withValues(alpha: 0.08),
                width: borderWidth,
              ),
            ),
            child: isBlank
                ? const SizedBox.shrink()
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Text(
                        number.toString(),
                        style: TextStyle(
                          color: tileTextColor,
                          fontSize: tileFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}