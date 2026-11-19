import 'dart:async';

import 'package:flutter/services.dart';

import '../models/app_settings.dart';
import 'app_settings_service.dart';

/// アプリ内の振動を管理するサービス
class VibrationService {
  /// アプリ設定サービス
  final AppSettingsService _settingsService =
      AppSettingsService();

  /// Vibration が有効かどうか
  bool _vibrationEnabled = false;

  /// 初期化が完了しているかどうか
  bool _isInitialized = false;

  /// 解放済みかどうか
  bool _isDisposed = false;

  /// 初期化処理の重複を防ぐ
  Future<void>? _initializationFuture;

  /// パズル完成時の振動演出が実行中かどうか
  bool _isPlayingCompletionVibration = false;

  /// Vibration の現在の状態
  bool get isVibrationEnabled => _vibrationEnabled;

  /// 振動サービスを初期化する
  ///
  /// 端末に保存されているVibration設定を読み込む。
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

      _vibrationEnabled = settings.vibrationEnabled;

      _isInitialized = true;
    } catch (e) {
      _vibrationEnabled = false;
      _isInitialized = false;
    }
  }

  /// Vibration の設定を更新する
  Future<void> updateVibrationEnabled(
    bool enabled,
  ) async {
    if (_isDisposed) {
      return;
    }

    _vibrationEnabled = enabled;

    // Vibration がOFFになった場合、
    // 実行中の完成演出は次の振動から中断する
  }

  /// タイル移動時の短い振動
  ///
  /// Vibration がOFFの場合は振動しない。
  Future<void> playTileMove() async {
    if (_isDisposed) {
      return;
    }

    // 初期化されていない場合は初期化する
    if (!_isInitialized) {
      await initialize();
    }

    // 初期化失敗・OFF・解放済みの場合は振動しない
    if (!_isInitialized ||
        !_vibrationEnabled ||
        _isDisposed) {
      return;
    }

    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // 振動に対応していない端末でもゲームを継続できるようにする
    }
  }

  /// パズル完成時の振動演出
  ///
  /// 約5秒間、短い振動を繰り返す。
  ///
  /// Vibration がOFFの場合は振動しない。
  /// 演出中にVibrationがOFFになった場合は中断する。
  Future<void> playPuzzleComplete() async {
    if (_isDisposed) {
      return;
    }

    // 初期化されていない場合は初期化する
    if (!_isInitialized) {
      await initialize();
    }

    // 初期化失敗・OFF・解放済みの場合は振動しない
    if (!_isInitialized ||
        !_vibrationEnabled ||
        _isDisposed) {
      return;
    }

    // 完成時の振動演出が実行中なら重複実行しない
    if (_isPlayingCompletionVibration) {
      return;
    }

    _isPlayingCompletionVibration = true;

    try {
      // 約500ミリ秒間隔で10回振動する
      for (int i = 0; i < 10; i++) {
        // OFF・解放済みになった場合は中断
        if (!_vibrationEnabled || _isDisposed) {
          break;
        }

        // 短い振動を実行
        await HapticFeedback.lightImpact();

        // 次の振動まで少し間隔を空ける
        await Future.delayed(
          const Duration(milliseconds: 500),
        );
      }
    } catch (e) {
      // 振動に対応していない端末でもゲームを継続できるようにする
    } finally {
      _isPlayingCompletionVibration = false;
    }
  }

  /// 振動サービスを解放する
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }

    _isDisposed = true;
    _vibrationEnabled = false;
    _isInitialized = false;
  }
}