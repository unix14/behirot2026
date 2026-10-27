import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:behirot2026/screens/voting_booth_screen.dart';
import 'package:behirot2026/services/poll_state.dart';
import 'package:behirot2026/widgets/ballot_slip.dart';

void main() {
  final mobileWidths = [360.0, 390.0, 430.0, 500.0];

  for (final width in mobileWidths) {
    testWidgets('mobile mode renders max 3 party slips per row at width $width', (WidgetTester tester) async {
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
                body: VotingBoothScreen(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final slipFinders = find.byType(BallotSlipWidget);
      expect(slipFinders, findsWidgets);

      final slip0 = tester.getTopLeft(slipFinders.at(0));
      final slip1 = tester.getTopLeft(slipFinders.at(1));
      final slip2 = tester.getTopLeft(slipFinders.at(2));
      final slip3 = tester.getTopLeft(slipFinders.at(3));

      // Exactly 3 slips in the first row
      expect(slip0.dy, equals(slip1.dy));
      expect(slip1.dy, equals(slip2.dy));

      // The 4th slip is on the second row
      expect(slip3.dy, greaterThan(slip0.dy));
    });
  }
}
