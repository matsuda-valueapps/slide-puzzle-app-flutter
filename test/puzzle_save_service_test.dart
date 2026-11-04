import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:slide_puzzle_app/constants/puzzle_patterns.dart';
import 'package:slide_puzzle_app/models/game_settings.dart';
import 'package:slide_puzzle_app/models/puzzle_save_data.dart';
import 'package:slide_puzzle_app/models/puzzle_state.dart';
import 'package:slide_puzzle_app/services/puzzle_save_service.dart';

void main() {
  late PuzzleSaveService saveService;

  // テストごとに保存データを初期化する。
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    saveService = PuzzleSaveService();
  });

  /// テスト用のPuzzleSaveDataを作成する。
  PuzzleSaveData createTestSaveData({
    GameType gameType = GameType.number,
    String? imageId,
  }) {
    final settings = GameSettings(
      gameType: gameType,
      boardSize: 3,
      pattern: PuzzlePattern.normal,
    );

    final puzzleState = PuzzleState(
      board: [1, 2, 3, 4, 5, 6, 7, 0, 8],
      goalBoard: [1, 2, 3, 4, 5, 6, 7, 8, 0],
      boardSize: 3,
      moveCount: 12,
      elapsedSeconds: 65,
      isPaused: true,
      isCompleted: false,
    );

    return PuzzleSaveData(
      settings: settings,
      puzzleState: puzzleState,
      imageId: imageId,
      savedAt: DateTime(2026, 11, 4, 10, 30),
    );
  }

  group('PuzzleSaveService - ゲームデータ保存', () {
    test('Numberのゲームデータを保存できる', () async {
      final saveData = createTestSaveData();

      final result = await saveService.saveGame(saveData);

      expect(result, isTrue);
    });

    test('保存したNumberのゲームデータを読み込める', () async {
      final saveData = createTestSaveData();

      await saveService.saveGame(saveData);

      final loadedData = await saveService.loadGame(
        GameType.number,
      );

      expect(loadedData, isNotNull);
      expect(loadedData!.settings.gameType, GameType.number);
      expect(loadedData.settings.boardSize, 3);
      expect(loadedData.settings.pattern, PuzzlePattern.normal);
      expect(
        loadedData.puzzleState.board,
        equals([1, 2, 3, 4, 5, 6, 7, 0, 8]),
      );
      expect(
        loadedData.puzzleState.goalBoard,
        equals([1, 2, 3, 4, 5, 6, 7, 8, 0]),
      );
      expect(loadedData.puzzleState.moveCount, 12);
      expect(loadedData.puzzleState.elapsedSeconds, 65);
      expect(loadedData.puzzleState.isPaused, isTrue);
      expect(loadedData.puzzleState.isCompleted, isFalse);
      expect(
        loadedData.savedAt,
        DateTime(2026, 11, 4, 10, 30),
      );
    });

    test('保存データが存在しない場合はnullを返す', () async {
      final loadedData = await saveService.loadGame(
        GameType.number,
      );

      expect(loadedData, isNull);
    });

    test('Pictureのゲームデータを保存・読み込みできる', () async {
      final saveData = createTestSaveData(
        gameType: GameType.picture,
        imageId: 'image001',
      );

      final saveResult = await saveService.saveGame(saveData);

      expect(saveResult, isTrue);

      final loadedData = await saveService.loadGame(
        GameType.picture,
      );

      expect(loadedData, isNotNull);
      expect(loadedData!.settings.gameType, GameType.picture);
      expect(loadedData.imageId, 'image001');
      expect(loadedData.puzzleState.moveCount, 12);
    });
  });

  group('PuzzleSaveService - 保存データの管理', () {
    test('NumberとPictureの保存データを別々に管理できる', () async {
      final numberSaveData = createTestSaveData();

      final pictureSaveData = createTestSaveData(
        gameType: GameType.picture,
        imageId: 'image001',
      );

      await saveService.saveGame(numberSaveData);
      await saveService.saveGame(pictureSaveData);

      final numberData = await saveService.loadGame(
        GameType.number,
      );

      final pictureData = await saveService.loadGame(
        GameType.picture,
      );

      expect(numberData, isNotNull);
      expect(numberData!.settings.gameType, GameType.number);
      expect(numberData.imageId, isNull);

      expect(pictureData, isNotNull);
      expect(pictureData!.settings.gameType, GameType.picture);
      expect(pictureData.imageId, 'image001');
    });

    test('保存データの有無を正しく確認できる', () async {
      expect(
        await saveService.hasSaveData(GameType.number),
        isFalse,
      );

      await saveService.saveGame(createTestSaveData());

      expect(
        await saveService.hasSaveData(GameType.number),
        isTrue,
      );

      expect(
        await saveService.hasSaveData(GameType.picture),
        isFalse,
      );
    });

    test('指定したゲームの保存データを削除できる', () async {
      final numberSaveData = createTestSaveData();

      final pictureSaveData = createTestSaveData(
        gameType: GameType.picture,
        imageId: 'image001',
      );

      await saveService.saveGame(numberSaveData);
      await saveService.saveGame(pictureSaveData);

      final deleteResult = await saveService.deleteSaveData(
        GameType.number,
      );

      expect(deleteResult, isTrue);

      expect(
        await saveService.hasSaveData(GameType.number),
        isFalse,
      );

      expect(
        await saveService.hasSaveData(GameType.picture),
        isTrue,
      );
    });

    test('NumberとPictureの保存データをまとめて削除できる', () async {
      await saveService.saveGame(
        createTestSaveData(),
      );

      await saveService.saveGame(
        createTestSaveData(
          gameType: GameType.picture,
          imageId: 'image001',
        ),
      );

      await saveService.deleteAllSaveData();

      expect(
        await saveService.hasSaveData(GameType.number),
        isFalse,
      );

      expect(
        await saveService.hasSaveData(GameType.picture),
        isFalse,
      );
    });
  });
}