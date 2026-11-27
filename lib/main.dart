import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants/app_colors.dart';
import 'constants/picture_options.dart';
import 'models/game_settings.dart';
import 'models/puzzle_save_data.dart';
import 'pages/game_select_page.dart';
import 'pages/home_page.dart';
import 'pages/picture_select_page.dart';
import 'pages/puzzle_game_page.dart';
import 'pages/records_page.dart';
import 'pages/settings_page.dart';
import 'services/puzzle_save_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Lora Bold（700）を適用したTextThemeを生成する
TextTheme _buildLoraTextTheme() {
  final TextTheme baseTheme = GoogleFonts.loraTextTheme();

  return baseTheme.copyWith(
    displayLarge: baseTheme.displayLarge?.copyWith(
      fontWeight: FontWeight.w700,
    ),
    displayMedium: baseTheme.displayMedium?.copyWith(
      fontWeight: FontWeight.w700,
    ),
    displaySmall: baseTheme.displaySmall?.copyWith(
      fontWeight: FontWeight.w700,
    ),
    headlineLarge: baseTheme.headlineLarge?.copyWith(
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: baseTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: baseTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
    ),
    titleLarge: baseTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
    ),
    titleMedium: baseTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    ),
    titleSmall: baseTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
    ),
    bodyLarge: baseTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w700,
    ),
    bodyMedium: baseTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w700,
    ),
    bodySmall: baseTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w700,
    ),
    labelLarge: baseTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
    ),
    labelMedium: baseTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w700,
    ),
    labelSmall: baseTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme loraTextTheme = _buildLoraTextTheme();

    return MaterialApp(
      title: 'Ritzy Slide Puzzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
        ),

        // アプリ全体の背景色をネイビーに統一
        scaffoldBackgroundColor: AppColors.background,

        // アプリ全体の標準フォントをLoraに設定
        fontFamily: GoogleFonts.lora().fontFamily,

        // アプリ全体の文字をLora Bold（700）に設定
        textTheme: loraTextTheme,

        // AppBarなどのプライマリテキストにも適用
        primaryTextTheme: loraTextTheme,

        // =====================================
        // ボタンのタップ演出を無効化
        // =====================================

        // 波紋アニメーションを無効化
        splashFactory: NoSplash.splashFactory,

        // タップ時の波紋・ハイライトを透明化
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,

        // ElevatedButtonのタップ時の色変化を無効化
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            overlayColor:
                const WidgetStatePropertyAll<Color>(
              Colors.transparent,
            ),
          ),
        ),

        // OutlinedButtonのタップ時の色変化を無効化
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            overlayColor:
                const WidgetStatePropertyAll<Color>(
              Colors.transparent,
            ),
          ),
        ),

        // TextButtonのタップ時の色変化を無効化
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            overlayColor:
                const WidgetStatePropertyAll<Color>(
              Colors.transparent,
            ),
          ),
        ),

        // IconButtonのタップ時の色変化を無効化
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            overlayColor:
                const WidgetStatePropertyAll<Color>(
              Colors.transparent,
            ),
          ),
        ),

        // =====================================
        // ページ遷移アニメーション
        // =====================================

        // Android・iOSではアニメーションを無効化
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android:
                _NoPageTransitionsBuilder(),
            TargetPlatform.iOS:
                _NoPageTransitionsBuilder(),
          },
        ),

        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

/// ページ遷移アニメーションを無効にする
///
/// 画面をフェード・移動させず、
/// 遷移先の画面をそのまま表示する。
class _NoPageTransitionsBuilder
    extends PageTransitionsBuilder {
  const _NoPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PuzzleSaveService _saveService = PuzzleSaveService();

  // 新しいゲームの設定画面を開く
  void _openGameSelect() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return GameSelectPage(
            onStart: _startGame,
            onBack: () {
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }

  // ゲームを開始する
  void _startGame(GameSettings settings) {
    // Pictureモードの場合は画像選択画面を開く
    if (settings.gameType == GameType.picture) {
      _openPictureSelect(settings);
      return;
    }

    // Numberモードの場合はそのままゲームを開始する
    _openPuzzleGame(settings: settings);
  }

  // Pictureモードの画像選択画面を開く
  void _openPictureSelect(GameSettings settings) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return PictureSelectPage(
            pictures: pictureOptions,
            onStart: (imageId) {
              // 画像選択画面を閉じる
              Navigator.of(context).pop();

              // 選択した画像IDを渡してゲームを開始する
              _openPuzzleGame(
                settings: settings,
                imageId: imageId,
              );
            },
            onBack: () {
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }

  // パズルゲーム画面を開く
  void _openPuzzleGame({
    required GameSettings settings,
    String? imageId,
    PuzzleSaveData? initialSaveData,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return PuzzleGamePage(
            settings: settings,
            imageId: imageId,
            initialSaveData: initialSaveData,
            onBack: () {
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }

  // 保存データからゲームを再開する
  Future<void> _continueGame() async {
    try {
      final numberSave = await _saveService.loadGame(
        GameType.number,
      );

      final pictureSave = await _saveService.loadGame(
        GameType.picture,
      );

      if (!mounted) return;

      if (numberSave == null && pictureSave == null) {
        _showMessage('No saved game found.');
        return;
      }

      // NumberとPictureの両方に保存データがある場合
      if (numberSave != null && pictureSave != null) {
        final selectedType = await _showContinueGameDialog();

        if (!mounted || selectedType == null) return;

        if (selectedType == GameType.number) {
          _resumeSavedGame(numberSave);
        } else {
          _resumeSavedGame(pictureSave);
        }

        return;
      }

      // Numberだけに保存データがある場合
      if (numberSave != null) {
        _resumeSavedGame(numberSave);
        return;
      }

      // Pictureだけに保存データがある場合
      if (pictureSave != null) {
        _resumeSavedGame(pictureSave);
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage('Failed to load saved game.');
    }
  }

  // Continue Gameダイアログ
  Future<GameType?> _showContinueGameDialog() {
    return showDialog<GameType>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.primary,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // タイトル
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Continue Game',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ゴールドの区切り線
                Container(
                  height: 1,
                  width: double.infinity,
                  color: AppColors.primary.withValues(
                    alpha: 0.7,
                  ),
                ),

                const SizedBox(height: 24),

                // 説明文
                const Text(
                  'Which game to continue?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                // Number / Picture 選択ボタン
                Row(
                  children: [
                    Expanded(
                      child: _buildContinueButton(
                        context: dialogContext,
                        text: 'Number',
                        gameType: GameType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildContinueButton(
                        context: dialogContext,
                        text: 'Picture',
                        gameType: GameType.picture,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Continue Gameの選択ボタン
  Widget _buildContinueButton({
    required BuildContext context,
    required String text,
    required GameType gameType,
  }) {
    return OutlinedButton(
      onPressed: () {
        Navigator.of(context).pop(gameType);
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: gameType == GameType.number
            ? AppColors.primaryLight
            : AppColors.cardBackground,
        side: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 保存データを使ってゲームを再開する
  void _resumeSavedGame(PuzzleSaveData saveData) {
    _openPuzzleGame(
      settings: saveData.settings,
      imageId: saveData.imageId,
      initialSaveData: saveData,
    );
  }

  // Records画面を開く
  void _openRecords() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const RecordsPage();
        },
      ),
    );
  }

  // Settings画面を開く
  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const SettingsPage();
        },
      ),
    );
  }

  // メッセージを表示する
  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return HomePage(
      onNewGame: _openGameSelect,
      onContinue: _continueGame,
      onRecords: _openRecords,
      onSettings: _openSettings,
    );
  }
}