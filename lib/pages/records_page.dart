import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/picture_options.dart';
import '../constants/puzzle_patterns.dart';
import '../models/game_settings.dart';
import '../models/puzzle_record.dart';
import '../services/record_service.dart';

/// ベスト記録を表示する画面
class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final RecordService _recordService = RecordService();

  /// 保存されているすべての記録
  List<PuzzleRecord> _records = [];

  /// 選択中のゲームタイプ
  GameType _selectedGameType = GameType.number;

  /// 読み込み中かどうか
  bool _isLoading = true;

  /// 読み込みエラーメッセージ
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  /// 保存されている記録を取得
  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final records = await _recordService.getAllRecords();

      if (!mounted) {
        return;
      }

      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Could not load records.';
        _isLoading = false;
      });

      debugPrint('Record loading error: $e');
    }
  }

  /// 選択中のゲームタイプに対応する記録を取得
  List<PuzzleRecord> get _filteredRecords {
    final records = _records
        .where((record) => record.gameType == _selectedGameType)
        .toList();

    // 盤面サイズ順に並べる
    records.sort((a, b) {
      final sizeComparison =
          a.boardSize.compareTo(b.boardSize);

      if (sizeComparison != 0) {
        return sizeComparison;
      }

      // 同じ盤面サイズの場合
      if (_selectedGameType == GameType.number) {
        return a.pattern.index.compareTo(b.pattern.index);
      }

      // Pictureモードは画像ID順
      return (a.imageId ?? '').compareTo(b.imageId ?? '');
    });

    return records;
  }

  /// 秒数を mm:ss 形式に変換
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Pictureモードの画像タイトルを取得
  String _getPictureTitle(String? imageId) {
    if (imageId == null) {
      return 'Unknown Picture';
    }

    for (final picture in pictureOptions) {
      if (picture.id == imageId) {
        return picture.title;
      }
    }

    return 'Unknown Picture';
  }

  /// Number / Picture 切り替えボタン
  Widget _buildGameTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildSelectorButton(
            title: 'Number',
            gameType: GameType.number,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSelectorButton(
            title: 'Picture',
            gameType: GameType.picture,
          ),
        ),
      ],
    );
  }

  /// ゲームタイプ選択ボタン
  Widget _buildSelectorButton({
    required String title,
    required GameType gameType,
  }) {
    final bool isSelected =
        _selectedGameType == gameType;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          _selectedGameType = gameType;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? AppColors.primaryLight
            : AppColors.cardBackground,
        foregroundColor: isSelected
            ? Colors.white
            : AppColors.primary,
        side: BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  /// 記録一覧
  Widget _buildRecordList() {
    final records = _filteredRecords;

    if (records.isEmpty) {
      return _buildEmptyMessage();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        return _buildRecordCard(records[index]);
      },
    );
  }

  /// 記録カード
  Widget _buildRecordCard(PuzzleRecord record) {
    final bool isPictureMode =
        record.gameType == GameType.picture;

    final String title = isPictureMode
        ? _getPictureTitle(record.imageId)
        : PuzzlePatterns.getPatternName(record.pattern);

    final String subtitle = isPictureMode
        ? 'Picture'
        : 'Number';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // タイトル
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.buttonPrimary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '${record.boardSize} × ${record.boardSize}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Best Moves / Best Time
          Row(
            children: [
              Expanded(
                child: _buildRecordValue(
                  label: 'Best Moves',
                  value: '${record.bestMoveCount}',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.primary.withValues(
                  alpha: 0.6,
                ),
              ),
              Expanded(
                child: _buildRecordValue(
                  label: 'Best Time',
                  value: _formatTime(
                    record.bestTimeSeconds,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 記録数値の表示
  Widget _buildRecordValue({
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 記録がない場合の表示
  Widget _buildEmptyMessage() {
    final String message =
        _selectedGameType == GameType.number
            ? 'No Number records yet.'
            : 'No Picture records yet.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  /// 読み込みエラー表示
  Widget _buildErrorMessage() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _loadRecords,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Records',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadRecords,
          color: AppColors.primary,
          backgroundColor: AppColors.cardBackground,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Number / Picture 切り替え
                _buildGameTypeSelector(),

                const SizedBox(height: 20),

                // 記録一覧
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 60,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_errorMessage != null)
                  SizedBox(
                    height: 250,
                    child: _buildErrorMessage(),
                  )
                else
                  _buildRecordList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}