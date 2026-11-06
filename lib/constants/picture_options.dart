import '../models/picture_option.dart';

/// Pictureモードで選択できる画像の一覧。
///
/// 初期状態では画像ファイルが存在しないため、リストは空にしておく。
/// 世界遺産の画像を追加するときは、
/// assets/images/ に画像を配置したうえで、
/// このリストに PictureOption を追加する。
const List<PictureOption> pictureOptions = <PictureOption>[
  // 画像を追加するときの記述例：
  //
  // PictureOption(
  //   id: 'picture_001',
  //   title: 'Mount Fuji',
  //   assetPath: 'assets/images/picture_001.jpg',
  //   credit: 'Photo by Example',
  //   license: 'CC BY 4.0',
  // ),
];