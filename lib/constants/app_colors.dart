import 'package:flutter/material.dart';

/// アプリ全体で使用する色を管理するクラス。
///
/// ホーム画面・ゲーム設定画面・パズル画面などで
/// 共通の色を使用するために定義する。
abstract final class AppColors {
  // =========================
  // 背景色
  // =========================

  /// アプリ全体の背景色
  static const Color background = Color(0xFF101827);

  /// カード・パネルの背景色
  static const Color cardBackground = Color(0xFF1C293B);

  /// カードのサブ背景色
  static const Color cardSecondary = Color(0xFF26364A);

  /// ダイアログの背景色
  static const Color dialogBackground = Color(0xFF202E42);

  // =========================
  // メインカラー・アクセントカラー
  // =========================

  /// メインカラー
  static const Color primary = Color(0xFF3B82F6);

  /// メインカラーの明るい色
  static const Color primaryLight = Color(0xFF60A5FA);

  /// メインカラーの暗い色
  static const Color primaryDark = Color(0xFF2563EB);

  /// アクセントカラー
  static const Color accent = Color(0xFF22D3EE);

  // =========================
  // 文字色
  // =========================

  /// メインの文字色
  static const Color textPrimary = Color(0xFFF8FAFC);

  /// サブの文字色
  static const Color textSecondary = Color(0xFFCBD5E1);

  /// 補足説明などの文字色
  static const Color textMuted = Color(0xFF94A3B8);

  /// 無効状態の文字色
  static const Color textDisabled = Color(0xFF64748B);

  // =========================
  // パズルタイル
  // =========================

  /// 通常タイルの背景色
  static const Color tileBackground = Color(0xFF3B82F6);

  /// タイルを選択したときの背景色
  static const Color tileSelected = Color(0xFF60A5FA);

  /// タイルの文字色
  static const Color tileText = Color(0xFFFFFFFF);

  /// 空白マスの背景色
  static const Color emptyTile = Color(0xFF0B1220);

  /// タイルの境界線
  static const Color tileBorder = Color(0xFF475569);

  // =========================
  // ボタン
  // =========================

  /// 通常ボタン
  static const Color buttonPrimary = Color(0xFF3B82F6);

  /// サブボタン
  static const Color buttonSecondary = Color(0xFF334155);

  /// ボタンの無効状態
  static const Color buttonDisabled = Color(0xFF475569);

  /// ボタン上の文字色
  static const Color buttonText = Color(0xFFFFFFFF);

  // =========================
  // ステータスカラー
  // =========================

  /// 成功・クリア表示
  static const Color success = Color(0xFF22C55E);

  /// 注意表示
  static const Color warning = Color(0xFFF59E0B);

  /// エラー表示
  static const Color error = Color(0xFFEF4444);

  /// 情報表示
  static const Color info = Color(0xFF38BDF8);

  // =========================
  // その他
  // =========================

  /// 区切り線
  static const Color divider = Color(0xFF334155);

  /// カードの境界線
  static const Color border = Color(0xFF475569);

  /// 半透明の黒色
  static const Color overlay = Color(0x80000000);
}