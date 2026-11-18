/// アプリ全体の設定を管理するモデル
class AppSettings {
  /// Sound Effects のON / OFF
  ///
  /// true  : 効果音を有効にする
  /// false : 効果音を無効にする
  final bool soundEffectsEnabled;

  /// Vibration のON / OFF
  ///
  /// true  : 振動を有効にする
  /// false : 振動を無効にする
  final bool vibrationEnabled;

  /// コンストラクタ
  ///
  /// 初期状態では両方ともONにする
  const AppSettings({
    this.soundEffectsEnabled = true,
    this.vibrationEnabled = true,
  });

  /// 設定を一部変更した新しいインスタンスを生成
  AppSettings copyWith({
    bool? soundEffectsEnabled,
    bool? vibrationEnabled,
  }) {
    return AppSettings(
      soundEffectsEnabled:
          soundEffectsEnabled ?? this.soundEffectsEnabled,
      vibrationEnabled:
          vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}