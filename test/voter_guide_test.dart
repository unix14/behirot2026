import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:behirot2026/services/localization.dart';
import 'package:behirot2026/widgets/find_polling_station_card.dart';
import 'package:behirot2026/widgets/voter_guide_accordion.dart';

void main() {
  testWidgets('VoterGuideAccordion renders FindPollingStationCard with gov.il link', (WidgetTester tester) async {
    const l10n = AppLocalization(AppLanguage.hebrew);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: VoterGuideAccordion(l10n: l10n),
          ),
        ),
      ),
    );

    // Verify FindPollingStationCard is rendered
    expect(find.byType(FindPollingStationCard), findsOneWidget);
    expect(find.text('רוצה לדעת איפה הקלפי שלך?'), findsOneWidget);
    expect(find.textContaining('מרשם הבוחרים הרשמי של משרד הפנים'), findsOneWidget);
    expect(find.text('לבדיקת מיקום הקלפי במשרד הפנים ↗'), findsOneWidget);

    // Verify the URL constant is accurate
    expect(FindPollingStationCard.bocharimUrl, 'https://www.gov.il/apps/moin/bocharim/');
  });
}
