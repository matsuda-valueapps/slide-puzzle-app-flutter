/// アプリ全体で使用する表示テキストを管理するクラス。
///
/// 画面ごとの英語表記を統一し、
/// 後からテキストを変更しやすくするために定義する。
abstract final class AppStrings {
  // =========================
  // アプリ情報
  // =========================

  static const String appName = 'Slide Puzzle';
  static const String appSubtitle = 'Challenge Your Mind';

  // =========================
  // ホーム画面
  // =========================

  static const String newGame = 'New Game';
  static const String continueGame = 'Continue';
  static const String records = 'Records';
  static const String settings = 'Settings';
  static const String howToPlay = 'How to Play';
  static const String exit = 'Exit';

  // =========================
  // ゲームタイプ
  // =========================

  static const String gameType = 'Game Type';
  static const String number = 'Number';
  static const String picture = 'Picture';

  // =========================
  // ゲーム設定画面
  // =========================

  static const String boardSize = 'Board Size';
  static const String pattern = 'Pattern';
  static const String selectGame = 'Select Game';
  static const String startGame = 'Start Game';
  static const String selectPicture = 'Select Picture';

  // =========================
  // 完成パターン
  // =========================

  static const String normal = 'Normal';
  static const String reverse = 'Reverse';
  static const String vertical = 'Vertical';
  static const String zigzag = 'Zigzag';
  static const String swirl = 'Swirl';

  // =========================
  // パズル画面
  // =========================

  static const String moves = 'Moves';
  static const String time = 'Time';
  static const String bestTime = 'Best Time';
  static const String bestMoves = 'Best Moves';
  static const String pause = 'Pause';
  static const String resume = 'Resume';
  static const String restart = 'Restart';
  static const String shuffle = 'Shuffle';
  static const String home = 'Home';
  static const String back = 'Back';
  static const String info = 'Info';

  // =========================
  // クリア画面
  // =========================

  static const String completed = 'Completed!';
  static const String congratulations = 'Congratulations!';
  static const String puzzleCompleted = 'Puzzle Completed!';
  static const String playAgain = 'Play Again';
  static const String newRecord = 'New Record!';
  static const String result = 'Result';

  // =========================
  // 記録画面
  // =========================

  static const String personalBest = 'Personal Best';
  static const String noRecords = 'No Records Yet';
  static const String totalMoves = 'Total Moves';
  static const String completionTime = 'Completion Time';

  // =========================
  // 設定画面
  // =========================

  static const String sound = 'Sound';
  static const String vibration = 'Vibration';
  static const String language = 'Language';
  static const String resetData = 'Reset Data';
  static const String confirmReset = 'Are you sure you want to reset all data?';

  // =========================
  // 共通ボタン・操作
  // =========================

  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String delete = 'Delete';
  static const String save = 'Save';
  static const String close = 'Close';
  static const String yes = 'Yes';
  static const String no = 'No';

  // =========================
  // メッセージ
  // =========================

  static const String noSavedGame = 'No saved game found.';
  static const String saveGameMessage = 'Game progress has been saved.';
  static const String gameOver = 'Game Over';
  static const String tryAgain = 'Try Again';
  static const String dataDeleted = 'Data has been deleted.';
  static const String loading = 'Loading...';

  // =========================
  // その他
  // =========================

  static const String worldHeritage = 'World Heritage';
  static const String minutes = 'min';
  static const String seconds = 'sec';
}