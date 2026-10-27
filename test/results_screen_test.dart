import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:behirot2026/services/poll_state.dart';
import 'package:behirot2026/screens/results_screen.dart';
import 'package:behirot2026/main.dart';
import 'package:behirot2026/widgets/whatsapp_icon.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('WhatsApp share button is visible on all 3 toggle states with authentic WhatsAppIcon', (WidgetTester tester) async {
    final pollState = PollState();
    pollState.setIsLoadingForTesting(false);

    await tester.pumpWidget(
      ChangeNotifierProvider<PollState>.value(
        value: pollState,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    // Tab 0: ההצבעה שלי (Voting Booth)
    expect(find.byType(WhatsAppIcon), findsOneWidget);
    expect(find.text('שתפו את החברים'), findsOneWidget);

    // Tab 1: תוצאות ומנדטים (Results)
    pollState.setTabIndex(1);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(WhatsAppIcon), findsOneWidget);
    expect(find.text('שתפו את החברים'), findsOneWidget);
    expect(find.text(pollState.l10n.t('coalition_game_title')), findsOneWidget);
    expect(find.text(pollState.l10n.t('coalition_game_btn')), findsOneWidget);
    expect(find.text(pollState.l10n.t('haba_bator_title')), findsOneWidget);
    expect(find.textContaining('סך כל המצביעים'), findsNothing);
    expect(find.textContaining('קולות נספרו'), findsNothing);

    // Tab 2: מדריך לבוחר (Voter Guide)
    pollState.setTabIndex(2);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(WhatsAppIcon), findsOneWidget);
    expect(find.text('שתפו את החברים'), findsOneWidget);
  });

  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets('ResultsScreen renders without overflow on mobile width $width', (WidgetTester tester) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final pollState = PollState();

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: ChangeNotifierProvider<PollState>.value(
              value: pollState,
              child: const Scaffold(
                body: ResultsScreen(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
