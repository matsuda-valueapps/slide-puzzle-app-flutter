import 'package:flutter/material.dart';

import 'constants/picture_options.dart';
import 'models/game_settings.dart';
import 'models/puzzle_save_data.dart';
import 'pages/game_select_page.dart';
import 'pages/home_page.dart';
import 'pages/picture_select_page.dart';
import 'pages/puzzle_game_page.dart';
import 'services/puzzle_save_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slide Puzzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
        ),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
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
        final selectedType = await showDialog<GameType>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Continue Game'),
              content: const Text(
                'Which game would you like to continue?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(
                      GameType.number,
                    );
                  },
                  child: const Text('Number'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(
                      GameType.picture,
                    );
                  },
                  child: const Text('Picture'),
                ),
              ],
            );
          },
        );

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

  // 保存データを使ってゲームを再開する
  void _resumeSavedGame(PuzzleSaveData saveData) {
    _openPuzzleGame(
      settings: saveData.settings,
      imageId: saveData.imageId,
      initialSaveData: saveData,
    );
  }

  // Records画面（今後実装）
  void _openRecords() {
    _showMessage('Records screen is coming soon.');
  }

  // Settings画面（今後実装）
  void _openSettings() {
    _showMessage('Settings screen is coming soon.');
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