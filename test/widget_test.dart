import 'package:flutter_test/flutter_test.dart';
import 'package:slide_puzzle_app/main.dart';
import 'package:slide_puzzle_app/pages/home_page.dart';

void main() {
  testWidgets('アプリ起動時にホーム画面が表示される', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // ホーム画面が表示されることを確認
    expect(find.byType(HomePage), findsOneWidget);
  });
}