import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:behirot2026/screens/voting_booth_screen.dart';
import 'package:behirot2026/services/poll_state.dart';
import 'package:behirot2026/widgets/ballot_slip.dart';
import 'package:behirot2026/widgets/ballot_box.dart';

void main() {
  testWidgets('When already voted, slips remain draggable, tapping shows toast, and dropping shows toast', (WidgetTester tester) async {
    final pollState = PollState();
    pollState.setHasVotedForTesting(true);

    await tester.pumpWidget(
      ChangeNotifierProvider<PollState>.value(
        value: pollState,
        child: const MaterialApp(
          home: Scaffold(
            body: VotingBoothScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify all ballot slips have isDraggable == true
    final slips = tester.widgetList<BallotSlipWidget>(find.byType(BallotSlipWidget));
    expect(slips.isNotEmpty, isTrue);
    for (final slip in slips) {
      expect(slip.isDraggable, isTrue);
      expect(slip.canVote, isFalse);
    }

    // Tapping on first ballot slip card should show the toast
    await tester.tap(find.byType(BallotSlipWidget).first);
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(pollState.l10n.isRtl ? 'כבר הצבעת! כל משתמש רשאי להצביע פעם אחת בלבד' : 'You already voted! Each user may vote only once'), findsOneWidget);

    // Dismiss the SnackBar
    tester.binding.scheduleFrame();
    await tester.pumpAndSettle();

    // Drag a slip onto BallotBoxWidget and release (drop)
    final firstSlip = find.byType(BallotSlipWidget).first;
    final ballotBox = find.byType(BallotBoxWidget);

    final gesture = await tester.startGesture(tester.getCenter(firstSlip));
    // Wait for longPress drag delay (150ms)
    await tester.pump(const Duration(milliseconds: 200));

    // Move onto ballot box
    await gesture.moveTo(tester.getCenter(ballotBox));
    await tester.pump();

    // Release (drop)
    await gesture.up();
    await tester.pump();

    // Verify toast is shown again upon dropping
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(pollState.l10n.isRtl ? 'כבר הצבעת! כל משתמש רשאי להצביע פעם אחת בלבד' : 'You already voted! Each user may vote only once'), findsOneWidget);
  });
}
