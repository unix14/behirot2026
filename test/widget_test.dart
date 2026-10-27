import 'package:flutter_test/flutter_test.dart';
import 'package:behirot2026/main.dart';
import 'package:provider/provider.dart';
import 'package:behirot2026/services/poll_state.dart';

void main() {
  testWidgets('BehirotApp renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => PollState(),
        child: const BehirotApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(BehirotApp), findsOneWidget);
  });
}
