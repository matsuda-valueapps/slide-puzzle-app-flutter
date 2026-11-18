import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants/app_colors.dart';
import '../models/app_settings.dart';
import '../services/app_settings_service.dart';

/// アプリ全体の設定を変更する画面
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AppSettingsService _settingsService =
      AppSettingsService();

  /// 現在のアプリ設定
  AppSettings _settings = const AppSettings();

  /// アプリのバージョン
  String _appVersion = '';

  /// 設定の読み込み中かどうか
  bool _isLoading = true;

  /// 設定の保存中かどうか
  bool _isSaving = false;

  /// 読み込みエラーメッセージ
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppVersion();
  }

  /// 保存されているアプリ設定を読み込む
  Future<void> _loadSettings() async {
    try {
      final settings =
          await _settingsService.loadSettings();

      if (!mounted) {
        return;
      }

      setState(() {
        _settings = settings;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load settings.';
      });

      debugPrint('Settings loading error: $e');
    }
  }

  /// アプリのバージョンを取得する
  Future<void> _loadAppVersion() async {
    try {
      final packageInfo =
          await PackageInfo.fromPlatform();

      if (!mounted) {
        return;
      }

      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _appVersion = 'Unknown';
      });

      debugPrint('App version loading error: $e');
    }
  }

  /// Sound Effects の設定を変更・保存する
  Future<void> _updateSoundEffects(bool enabled) async {
    if (_isSaving || _isLoading) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final success =
          await _settingsService.saveSoundEffectsEnabled(
        enabled,
      );

      if (!mounted) {
        return;
      }

      if (success) {
        setState(() {
          _settings = _settings.copyWith(
            soundEffectsEnabled: enabled,
          );
        });
      } else {
        _showErrorMessage(
          'Could not save Sound Effects setting.',
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showErrorMessage(
        'Could not save Sound Effects setting.',
      );

      debugPrint('Sound Effects saving error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Vibration の設定を変更・保存する
  Future<void> _updateVibration(bool enabled) async {
    if (_isSaving || _isLoading) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final success =
          await _settingsService.saveVibrationEnabled(
        enabled,
      );

      if (!mounted) {
        return;
      }

      if (success) {
        setState(() {
          _settings = _settings.copyWith(
            vibrationEnabled: enabled,
          );
        });
      } else {
        _showErrorMessage(
          'Could not save Vibration setting.',
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showErrorMessage(
        'Could not save Vibration setting.',
      );

      debugPrint('Vibration saving error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// エラーメッセージを表示する
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.cardBackground,
      ),
    );
  }

  /// 設定項目のカード
  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
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
      child: Row(
        children: [
          Icon(
            icon,
            size: 28,
            color: AppColors.primary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primaryLight,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.border,
          ),
        ],
      ),
    );
  }

  /// App Version のカード
  Widget _buildVersionCard() {
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
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 28,
            color: AppColors.primary,
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'App Version',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            _appVersion.isEmpty ? 'Loading...' : _appVersion,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 設定読み込みエラー表示
  Widget _buildErrorMessage() {
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
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
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
            onPressed: _loadSettings,
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
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                _buildErrorMessage()
              else ...[
                // Sound Effects
                _buildSettingCard(
                  icon: Icons.volume_up_outlined,
                  title: 'Sound Effects',
                  value: _settings.soundEffectsEnabled,
                  onChanged: _isSaving
                      ? null
                      : _updateSoundEffects,
                ),

                const SizedBox(height: 12),

                // Vibration
                _buildSettingCard(
                  icon: Icons.vibration,
                  title: 'Vibration',
                  value: _settings.vibrationEnabled,
                  onChanged: _isSaving
                      ? null
                      : _updateVibration,
                ),

                const SizedBox(height: 20),

                // App Version
                _buildVersionCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}