
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:slide_puzzle_app/constants/puzzle_patterns.dart';
import 'package:slide_puzzle_app/models/game_settings.dart';
import 'package:slide_puzzle_app/models/puzzle_record.dart';
import 'package:slide_puzzle_app/services/record_service.dart';

void main() {
  late RecordService recordService;

  // テストごとに保存データを初期化する。
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    recordService = RecordService();
  });

  /// テスト用のPuzzleRecordを作成する。
  PuzzleRecord createTestRecord({
    GameType gameType = GameType.number,
    int boardSize = 3,
    PuzzlePattern pattern = PuzzlePattern.normal,
    String? imageId,
    int bestTimeSeconds = 120,
    int bestMoveCount = 45,
    DateTime? achievedAt,
  }) {
    return PuzzleRecord(
      gameType: gameType,
      boardSize: boardSize,
      pattern: pattern,
      imageId: imageId,
      bestTimeSeconds: bestTimeSeconds,
      bestMoveCount: bestMoveCount,
      achievedAt: achievedAt ?? DateTime(2026, 11, 4, 10, 30),
    );
  }

  group('RecordService - 記録の保存・取得', () {
    test('ベスト記録を保存できる', () async {
      final record = createTestRecord();

      final result = await recordService.saveRecord(record);

      expect(result, isTrue);
    });

    test('保存した記録を正しく取得できる', () async {
      final record = createTestRecord();

      await recordService.saveRecord(record);

      final loadedRecord = await recordService.getRecord(
        gameType: GameType.number,
        boardSize: 3,
        pattern: PuzzlePattern.normal,
      );

      expect(loadedRecord, isNotNull);
      expect(loadedRecord!.gameType, GameType.number);
      expect(loadedRecord.boardSize, 3);
      expect(loadedRecord.pattern, PuzzlePattern.normal);
      expect(loadedRecord.bestTimeSeconds, 120);
      expect(loadedRecord.bestMoveCount, 45);
      expect(
        loadedRecord.achievedAt,
        DateTime(2026, 11, 4, 10, 30),
      );
    });

    test('ベストタイムだけを更新できる', () async {
      final originalRecord = createTestRecord(
        bestTimeSeconds: 120,
        bestMoveCount: 45,
      );

      final improvedRecord = createTestRecord(
        bestTimeSeconds: 100,
        bestMoveCount: 50,
        achievedAt: DateTime(2026, 11, 4, 11, 30),
      );

      await recordService.saveRecord(originalRecord);
      await recordService.saveRecord(improvedRecord);

      final loadedRecord = await recordService.getRecord(
        gameType: GameType.number,
        boardSize: 3,
        pattern: PuzzlePattern.normal,
      );

      expect(loadedRecord, isNotNull);
      expect(loadedRecord!.bestTimeSeconds, 100);
      expect(loadedRecord.bestMoveCount, 45);
    });

    test('最少手数だけを更新できる', () async {
      final originalRecord = createTestRecord(
        bestTimeSeconds: 120,
        bestMoveCount: 45,
      );

      final improvedRecord = createTestRecord(
        bestTimeSeconds: 130,
        bestMoveCount: 35,
        achievedAt: DateTime(2026, 11, 4, 11, 30),
      );

      await recordService.saveRecord(originalRecord);
      await recordService.saveRecord(improvedRecord);

      final loadedRecord = await recordService.getRecord(
        gameType: GameType.number,
        boardSize: 3,
        pattern: PuzzlePattern.normal,
      );

      expect(loadedRecord, isNotNull);
      expect(loadedRecord!.bestTimeSeconds, 120);
      expect(loadedRecord.bestMoveCount, 35);
    });
  });

  group('RecordService - 記録の管理', () {
    test('NumberとPictureの記録を別々に管理できる', () async {
      final numberRecord = createTestRecord(
        gameType: GameType.number,
      );

      final pictureRecord = createTestRecord(
        gameType: GameType.picture,
        imageId: 'image001',
      );

      await recordService.saveRecord(numberRecord);
      await recordService.saveRecord(pictureRecord);

      final loadedNumberRecord = await recordService.getRecord(
        gameType: GameType.number,
        boardSize: 3,
        pattern: PuzzlePattern.normal,
      );

      final loadedPictureRecord = await recordService.getRecord(
        gameType: GameType.picture,
        boardSize: 3,
        pattern: PuzzlePattern.normal,
        imageId: 'image001',
      );

      expect(loadedNumberRecord, isNotNull);
      expect(loadedNumberRecord!.gameType, GameType.number);

      expect(loadedPictureRecord, isNotNull);
      expect(loadedPictureRecord!.gameType, GameType.picture);
      expect(loadedPictureRecord.imageId, 'image001');
    });

    test('保存されているすべての記録を取得できる', () async {
      await recordService.saveRecord(
        createTestRecord(
          boardSize: 3,
        ),
      );

      await recordService.saveRecord(
        createTestRecord(
          boardSize: 4,
        ),
      );

      await recordService.saveRecord(
        createTestRecord(
          gameType: GameType.picture,
          imageId: 'image001',
        ),
      );

      final records = await recordService.getAllRecords();

      expect(records.length, 3);
    });

    test('記録の有無を正しく確認できる', () async {
      expect(
        await recordService.hasRecord(
          gameType: GameType.number,
          boardSize: 3,
          pattern: PuzzlePattern.normal,
        ),
        isFalse,
      );

      await recordService.saveRecord(
        createTestRecord(),
      );

      expect(
        await recordService.hasRecord(
          gameType: GameType.number,
          boardSize: 3,
          pattern: PuzzlePattern.normal,
        ),
        isTrue,
      );
    });

    test('指定した記録を削除できる', () async {
      await recordService.saveRecord(
        createTestRecord(
          boardSize: 3,
        ),
      );

      await recordService.saveRecord(
        createTestRecord(
          boardSize: 4,
        ),
      );

      final result = await recordService.deleteRecord(
        gameType: GameType.number,
        boardSize: 3,
        pattern: PuzzlePattern.normal,
      );

      expect(result, isTrue);

      expect(
        await recordService.hasRecord(
          gameType: GameType.number,
          boardSize: 3,
          pattern: PuzzlePattern.normal,
        ),
        isFalse,
      );

      expect(
        await recordService.hasRecord(
          gameType: GameType.number,
          boardSize: 4,
          pattern: PuzzlePattern.normal,
        ),
        isTrue,
      );
    });

    test('すべての記録を削除できる', () async {
      await recordService.saveRecord(
        createTestRecord(
          boardSize: 3,
        ),
      );

      await recordService.saveRecord(
        createTestRecord(
          boardSize: 4,
        ),
      );

      await recordService.saveRecord(
        createTestRecord(
          gameType: GameType.picture,
          imageId: 'image001',
        ),
      );

      await recordService.deleteAllRecords();

      final records = await recordService.getAllRecords();

      expect(records, isEmpty);
    });
  });
}