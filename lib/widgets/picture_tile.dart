import 'package:flutter/material.dart';

/// Pictureモードの各タイルを表示するウィジェット
class PictureTile extends StatelessWidget {
  /// 元画像のアセットパス
  final String assetPath;

  /// タイルの番号（1から始まる）
  /// 0の場合は空白マスとして扱う
  final int number;

  /// 盤面の一辺のマス数
  final int boardSize;

  /// タイルの一辺のサイズ
  final double size;

  /// タイルをタップしたときの処理
  final VoidCallback? onTap;

  /// タイルの背景色
  final Color? backgroundColor;

  /// 空白マスの背景色
  final Color? blankColor;

  /// タイルの角丸の大きさ
  final double borderRadius;

  /// タイル同士の境界線の太さ
  final double borderWidth;

  /// 空白マスを表示するか
  final bool showBlankTile;

  const PictureTile({
    super.key,
    required this.assetPath,
    required this.number,
    required this.boardSize,
    required this.size,
    this.onTap,
    this.backgroundColor,
    this.blankColor,
    this.borderRadius = 8,
    this.borderWidth = 1,
    this.showBlankTile = false,
  });

  /// 空白マスかどうか
  bool get isBlank => number == 0;

  /// 元画像から切り出す範囲を計算する
  Widget _buildPicture() {
    // タイル番号を0始まりのインデックスに変換
    final int sourceIndex = number - 1;

    // 元画像における行と列を計算
    final int sourceRow = sourceIndex ~/ boardSize;
    final int sourceColumn = sourceIndex % boardSize;

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment(
          boardSize == 1
              ? 0
              : (boardSize - 1) - sourceColumn * 2,
          boardSize == 1
              ? 0
              : (boardSize - 1) - sourceRow * 2,
        ),
        minWidth: size * boardSize,
        maxWidth: size * boardSize,
        minHeight: size * boardSize,
        maxHeight: size * boardSize,
        child: Image.asset(
          assetPath,
          width: size * boardSize,
          height: size * boardSize,
          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size * boardSize,
              height: size * boardSize,
              color: backgroundColor ?? const Color(0xFF3B82F6),
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 盤面サイズとタイル番号の整合性を確認
    if (boardSize < 3 ||
        boardSize > 7 ||
        number < 0 ||
        number >= boardSize * boardSize) {
      return SizedBox(
        width: size,
        height: size,
      );
    }

    // 空白マスの背景色
    final Color tileBlankColor =
        blankColor ?? const Color(0xFFE5E7EB);

    // 空白マスを非表示にする場合
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
            : backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isBlank ? null : onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.08),
                width: borderWidth,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: isBlank
                ? const SizedBox.expand()
                : _buildPicture(),
          ),
        ),
      ),
    );
  }
}