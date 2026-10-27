import 'package:flutter_test/flutter_test.dart';
import 'package:behirot2026/services/electoral_calculator.dart';

void main() {
  group('ElectoralCalculator Tests', () {
    test('calculateSeats distributes exactly 120 seats for passing parties', () {
      final rawVotes = {'likud': 420, 'national_unity': 350, 'yesh_atid': 260, 'yisrael_beiteinu': 220, 'democrats': 190, 'shas': 180, 'utj': 140, 'otzma_yehudit': 130, 'religious_zionism': 85, 'raam': 95, 'hadash_taal': 80, 'balad': 30};
      final result = ElectoralCalculator.calculateSeats(rawVotes);

      expect(result.totalVotes, equals(2180));
      // Balad has 30 votes = 1.37%, which is under 3.25% (70.85 votes)
      expect(result.failingParties.any((p) => p.partyId == 'balad'), isTrue);
      expect(result.passingParties.any((p) => p.partyId == 'balad'), isFalse);

      final totalAllocatedSeats = result.passingParties.fold(0, (sum, p) => sum + p.seats);
      expect(totalAllocatedSeats, equals(120));
    });

    test('calculateSeats returns empty on zero votes', () {
      final result = ElectoralCalculator.calculateSeats({});
      expect(result.totalVotes, equals(0));
      expect(result.passingParties.isEmpty, isTrue);
      expect(result.failingParties.isEmpty, isTrue);
    });

    test('calculateSeats matches user target 1200 votes distribution', () {
      final rawVotes = {'yashar': 216, 'likud': 196, 'beyachad': 137, 'joint_list': 88, 'democrats': 78, 'otzma_yehudit': 78, 'yahadut_hatorah': 78, 'yisrael_beytenu': 78, 'shas': 69, 'religious_zionism': 68, 'raam': 50, 'miluimniks': 40, 'amcha_yisrael': 24};
      final result = ElectoralCalculator.calculateSeats(rawVotes);
      expect(result.totalVotes, equals(1200));
      expect(result.seatsByPartyId['yashar'], equals(22));
      expect(result.seatsByPartyId['likud'], equals(20));
      expect(result.seatsByPartyId['beyachad'], equals(14));
      expect(result.seatsByPartyId['joint_list'], equals(9));
      expect(result.seatsByPartyId['democrats'], equals(8));
      expect(result.seatsByPartyId['otzma_yehudit'], equals(8));
      expect(result.seatsByPartyId['yahadut_hatorah'], equals(8));
      expect(result.seatsByPartyId['yisrael_beytenu'], equals(8));
      expect(result.seatsByPartyId['shas'], equals(7));
      expect(result.seatsByPartyId['religious_zionism'], equals(7));
      expect(result.seatsByPartyId['raam'], equals(5));
      expect(result.seatsByPartyId['miluimniks'], equals(4));
      expect(result.seatsByPartyId['amcha_yisrael'] ?? 0, equals(0));
      expect(result.failingParties.any((p) => p.partyId == 'amcha_yisrael'), isTrue);
    });
  });
}
