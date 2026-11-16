import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/picture_option.dart';
import '../widgets/game_button.dart';

/// 画像選択画面
class PictureSelectPage extends StatefulWidget {
  /// 選択可能な画像一覧
  final List<PictureOption> pictures;

  /// 画像選択後に画像IDを渡す処理
  final ValueChanged<String> onStart;

  /// 戻るボタンの処理
  final VoidCallback? onBack;

  const PictureSelectPage({
    super.key,
    required this.pictures,
    required this.onStart,
    this.onBack,
  });

  @override
  State<PictureSelectPage> createState() =>
      _PictureSelectPageState();
}

class _PictureSelectPageState extends State<PictureSelectPage> {
  /// 選択中の画像ID
  String? _selectedImageId;

  /// 選択中の画像情報
  PictureOption? get _selectedPicture {
    for (final picture in widget.pictures) {
      if (picture.id == _selectedImageId) {
        return picture;
      }
    }

    return null;
  }

  /// ゲーム開始
  void _startGame() {
    final picture = _selectedPicture;

    if (picture == null) {
      return;
    }

    widget.onStart(picture.id);
  }

  @override
  void initState() {
    super.initState();

    // 画像が存在する場合、最初の画像を初期選択する
    if (widget.pictures.isNotEmpty) {
      _selectedImageId = widget.pictures.first.id;
    }
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
          'Select Picture',
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
        child: widget.pictures.isEmpty
            ? _buildEmptyMessage()
            : _buildPictureList(),
      ),
    );
  }

  /// 画像一覧
  Widget _buildPictureList() {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // GridViewの左右の余白（16 × 2）を差し引く
              // 画像の横幅と高さを同じにして正方形にする
              final double imageSize =
                  constraints.maxWidth - 32;

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 16,

                  // 正方形の画像 + 画像名の表示領域
                  mainAxisExtent: imageSize + 52,
                ),
                itemCount: widget.pictures.length,
                itemBuilder: (context, index) {
                  final picture = widget.pictures[index];

                  final bool isSelected =
                      picture.id == _selectedImageId;

                  return _buildPictureCard(
                    picture: picture,
                    isSelected: isSelected,
                    imageSize: imageSize,
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: GameButton(
            text: 'Start Game',
            icon: Icons.play_arrow_rounded,
            height: 56,
            fontSize: 18,
            onPressed: _selectedPicture == null
                ? null
                : _startGame,
          ),
        ),
      ],
    );
  }

  /// 画像カード
  Widget _buildPictureCard({
    required PictureOption picture,
    required bool isSelected,
    required double imageSize,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedImageId = picture.id;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 画像部分（正方形）
          SizedBox(
            width: imageSize,
            height: imageSize,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: 0.15,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    picture.assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.background,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),

                  // 選択中のチェックマーク
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 画像名（画像の外側に表示）
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
              top: 10,
            ),
            child: Text(
              picture.title,
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 画像が登録されていない場合の表示
  Widget _buildEmptyMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.image_not_supported_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No pictures available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please add pictures to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}