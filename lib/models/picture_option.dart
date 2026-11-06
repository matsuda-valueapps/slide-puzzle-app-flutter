/// Pictureモードで使用する画像情報を管理するモデル
class PictureOption {
  /// 画像を識別するID
  ///
  /// 例: picture_001
  /// 保存データやベスト記録との紐付けに使用する。
  final String id;

  /// 画像の表示名
  ///
  /// 例: Mount Fuji
  final String title;

  /// 画像ファイルのパス
  ///
  /// 例: assets/images/picture_001.jpg
  final String assetPath;

  /// 画像の提供元・撮影者など
  final String credit;

  /// 画像のライセンス情報
  final String license;

  /// コンストラクタ
  const PictureOption({
    required this.id,
    required this.title,
    required this.assetPath,
    required this.credit,
    required this.license,
  });
}