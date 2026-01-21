import 'package:flutter_test/flutter_test.dart';
import 'package:speak_english/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SpeakEnglishApp());
    await tester.pumpAndSettle();

    // Verify that the app loads
    expect(find.text('Speak English'), findsOneWidget);
  });
}
