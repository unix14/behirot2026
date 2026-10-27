import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:behirot2026/services/localization.dart';

void main() {
  group('WhatsApp Share Randomization Tests', () {
    test('Hebrew localization has exactly 5 unique share messages with live URL', () {
      const l10n = AppLocalization(AppLanguage.hebrew);
      final messages = l10n.whatsappShareMessages;

      expect(messages.length, equals(5));
      expect(messages.toSet().length, equals(5), reason: 'All 5 messages must be distinct');

      for (final msg in messages) {
        expect(msg.contains('https://bhirot2026.web.app'), isTrue);
        expect(msg.isNotEmpty, isTrue);
      }

      expect(messages.any((m) => m.contains('אני הצבעתי בקלפי הווירטואלית, מה איתך?')), isTrue);
      expect(messages.any((m) => m.contains('צאו להצביע בקלפי הווירטואלית')), isTrue);
      expect(messages.any((m) => m.contains('צפו בתוצאות הבחירות בלייב בקלפי הווירטואלית!')), isTrue);
    });

    test('English localization has exactly 5 unique share messages with live URL', () {
      const l10n = AppLocalization(AppLanguage.english);
      final messages = l10n.whatsappShareMessages;

      expect(messages.length, equals(5));
      expect(messages.toSet().length, equals(5), reason: 'All 5 English messages must be distinct');

      for (final msg in messages) {
        expect(msg.contains('https://bhirot2026.web.app'), isTrue);
        expect(msg.isNotEmpty, isTrue);
      }
    });

    test('getRandomWhatsAppShareText returns one of the 5 messages', () {
      const l10n = AppLocalization(AppLanguage.hebrew);
      final messages = l10n.whatsappShareMessages;

      for (int i = 0; i < 20; i++) {
        final randomText = l10n.getRandomWhatsAppShareText(Random(i));
        expect(messages.contains(randomText), isTrue);
      }
    });
  });
}
