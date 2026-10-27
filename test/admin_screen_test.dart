import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:behirot2026/screens/admin_screen.dart';
import 'package:behirot2026/services/poll_state.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    isLocalhostOverride = null;
  });

  testWidgets('AdminScreen blocks access with 403 Forbidden when not on localhost', (WidgetTester tester) async {
    isLocalhostOverride = false;
    final pollState = PollState();
    pollState.setIsLoadingForTesting(false);

    await tester.pumpWidget(
      ChangeNotifierProvider<PollState>.value(
        value: pollState,
        child: const MaterialApp(
          home: AdminScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    // Verify 403 Forbidden is rendered
    expect(find.text('403 - גישה חסומה'), findsOneWidget);
    expect(find.textContaining('עמוד הניהול מוגבל אך ורק לסביבת פיתוח מקומית'), findsOneWidget);
    expect(find.text('חזרה לקלפי הראשית'), findsOneWidget);

    // Verify admin stats and batch controls are completely hidden
    expect(find.text('פאנל ניהול קלפי 2026'), findsNothing);
    expect(find.text('סה"כ קולות בקלפי'), findsNothing);
    expect(find.text('הזרקת קולות למפלגה (Batch Injection)'), findsNothing);
  });

  testWidgets('AdminScreen allows access and renders all stats and controls when on localhost', (WidgetTester tester) async {
    isLocalhostOverride = true;
    final pollState = PollState();
    pollState.setIsLoadingForTesting(false);

    await tester.pumpWidget(
      ChangeNotifierProvider<PollState>.value(
        value: pollState,
        child: const MaterialApp(
          home: AdminScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    // Verify admin header is rendered
    expect(find.text('DEV ONLY'), findsOneWidget);
    expect(find.text('פאנל ניהול קלפי 2026'), findsOneWidget);

    // Verify KPI metric cards
    expect(find.text('סה"כ קולות בקלפי'), findsOneWidget);
    expect(find.text('קולות אמיתיים'), findsOneWidget);
    expect(find.text('קולות סימולציה / סיד'), findsOneWidget);

    // Verify batch injection controls
    expect(find.text('הזרקת קולות למפלגה (Batch Injection)'), findsOneWidget);
    expect(find.text('בחר מפלגה:'), findsOneWidget);
    expect(find.text('+10'), findsWidgets);
    expect(find.text('+50'), findsWidgets);
    expect(find.text('הזרק קולות עכשיו ל-RTDB'), findsOneWidget);

    // Verify reset vote dev tool
    expect(find.text('איפוס סטטוס הצבעה של המחשב הנוכחי'), findsOneWidget);
    expect(find.text('אפס הצבעה'), findsOneWidget);
  });
}
