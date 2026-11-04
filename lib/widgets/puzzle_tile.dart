import 'package:flutter/material.dart';

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
    final Color tileBlankColor =
        blankColor ?? const Color(0xFFE5E7EB);

    // 通常タイルの背景色
    final Color tileBackgroundColor =
        backgroundColor ?? const Color(0xFF3B82F6);

    // 数字の文字色
    final Color tileTextColor =
        textColor ?? Colors.white;

    // 数字のサイズ
    final double tileFontSize =
        fontSize ?? size * 0.35;

    // 空白マスの表示設定
    if (isBlank && !showBlankTile) {
      return SizedBox(
        width: size,
        height: size,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: isBlank
            ? tileBlankColor
            : tileBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: isBlank ? null : onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
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