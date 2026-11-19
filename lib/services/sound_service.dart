import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import 'app_settings_service.dart';

/// アプリ内の効果音を管理するサービス
class SoundService {
  /// アプリ設定サービス
  final AppSettingsService _settingsService =
      AppSettingsService();

  /// タイル移動用の音声プレイヤー
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// パズル完成用の音声プレイヤー
  final AudioPlayer _completionAudioPlayer = AudioPlayer();

  /// タイル移動時の効果音ファイル
  static const String _tileMoveSoundPath =
      'audio/tile_move.wav';

  /// パズル完成時の効果音ファイル
  static const String _puzzleCompleteSoundPath =
      'audio/puzzle_complete.wav';

  /// Sound Effects が有効かどうか
  bool _soundEffectsEnabled = false;

  /// 初期化が完了しているかどうか
  bool _isInitialized = false;

  /// 解放済みかどうか
  bool _isDisposed = false;

  /// 初期化処理の重複を防ぐ
  Future<void>? _initializationFuture;

  /// Sound Effects の現在の状態
  bool get isSoundEffectsEnabled => _soundEffectsEnabled;

  /// 効果音サービスを初期化する
  ///
  /// 端末に保存されているSound Effects設定を読み込み、
  /// 音声プレイヤーを初期化する。
  Future<void> initialize() async {
    if (_isInitialized || _isDisposed) {
      return;
    }

    // 初期化処理が進行中の場合は同じ処理を待つ
    if (_initializationFuture != null) {
      await _initializationFuture;
      return;
    }

    _initializationFuture = _initializeInternal();

    try {
      await _initializationFuture;
    } finally {
      _initializationFuture = null;
    }
  }

  /// 初期化の内部処理
  Future<void> _initializeInternal() async {
    try {
      // 端末に保存されているアプリ設定を取得
      final AppSettings settings =
          await _settingsService.loadSettings();

      if (_isDisposed) {
        return;
      }

      _soundEffectsEnabled =
          settings.soundEffectsEnabled;

      // タイル移動音を低遅延モードに設定
      await _audioPlayer.setPlayerMode(
        PlayerMode.lowLatency,
      );

      if (_isDisposed) {
        return;
      }

      // パズル完成音は通常のメディアモードに設定
      await _completionAudioPlayer.setPlayerMode(
        PlayerMode.lowLatency,
      );

      if (_isDisposed) {
        return;
      }

      _isInitialized = true;
    } catch (e) {
      _soundEffectsEnabled = false;
      _isInitialized = false;

      debugPrint(
        'Sound service initialization error: $e',
      );
    }
  }

  /// Sound Effects の設定を更新する
  ///
  /// Settings画面のON/OFF設定を反映する場合に使用する。
  Future<void> updateSoundEffectsEnabled(
    bool enabled,
  ) async {
    if (_isDisposed) {
      return;
    }

    _soundEffectsEnabled = enabled;
  }

  /// タイル移動時の効果音を再生する
  ///
  /// Sound Effects がOFFの場合は再生しない。
  Future<void> playTileMove() async {
    if (_isDisposed) {
      return;
    }

    // 初期化されていない場合は初期化する
    if (!_isInitialized) {
      await initialize();
    }

    // 初期化失敗・OFF・解放済みの場合は再生しない
    if (!_isInitialized ||
        !_soundEffectsEnabled ||
        _isDisposed) {
      return;
    }

    try {
      // 前の再生を停止して、新しい効果音を再生
      await _audioPlayer.stop();

      if (_isDisposed || !_soundEffectsEnabled) {
        return;
      }

      await _audioPlayer.play(
        AssetSource(_tileMoveSoundPath),
      );
    } catch (e) {
      debugPrint(
        'Tile move sound playback error: $e',
      );
    }
  }

  /// パズル完成時の効果音を再生する
  ///
  /// Sound Effects がOFFの場合は再生しない。
  Future<void> playPuzzleComplete() async {
    if (_isDisposed) {
      return;
    }

    // 初期化されていない場合は初期化する
    if (!_isInitialized) {
      await initialize();
    }

    // 初期化失敗・OFF・解放済みの場合は再生しない
    if (!_isInitialized ||
        !_soundEffectsEnabled ||
        _isDisposed) {
      return;
    }

    try {
      // 前の完成音が再生中の場合は停止
      await _completionAudioPlayer.stop();

      if (_isDisposed || !_soundEffectsEnabled) {
        return;
      }

      // パズル完成音を再生
      await _completionAudioPlayer.play(
        AssetSource(_puzzleCompleteSoundPath),
      );
    } catch (e) {
      debugPrint(
        'Puzzle completion sound playback error: $e',
      );
    }
  }

  /// 音声プレイヤーを解放する
  ///
  /// ゲーム画面を閉じるときに呼び出す。
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }

    _isDisposed = true;
    _soundEffectsEnabled = false;
    _isInitialized = false;

    try {
      await _audioPlayer.dispose();
    } catch (e) {
      debugPrint(
        'Tile move sound disposal error: $e',
      );
    }

    try {
      await _completionAudioPlayer.dispose();
    } catch (e) {
      debugPrint(
        'Completion sound disposal error: $e',
      );
    }
  }
}