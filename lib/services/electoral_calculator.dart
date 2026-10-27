import '../models/party.dart';

class PartySeatAllocation {
  final String partyId;
  final int rawVotes;
  final double percentage;
  final bool passedThreshold;
  final int seats;
  final double remainderFraction;

  const PartySeatAllocation({required this.partyId, required this.rawVotes, required this.percentage, required this.passedThreshold, required this.seats, required this.remainderFraction});
}

class ElectoralResult {
  final int totalVotes;
  final double thresholdVotes;
  final List<PartySeatAllocation> passingParties;
  final List<PartySeatAllocation> failingParties;
  final int coalitionSeats;
  final int oppositionSeats;
  final int undecidedSeats;
  final Map<String, int> seatsByPartyId;
  final Map<String, double> percentageByPartyId;

  const ElectoralResult({required this.totalVotes, required this.thresholdVotes, required this.passingParties, required this.failingParties, required this.coalitionSeats, required this.oppositionSeats, required this.undecidedSeats, required this.seatsByPartyId, required this.percentageByPartyId});

  factory ElectoralResult.empty() {
    return const ElectoralResult(totalVotes: 0, thresholdVotes: 0, passingParties: [], failingParties: [], coalitionSeats: 0, oppositionSeats: 0, undecidedSeats: 0, seatsByPartyId: {}, percentageByPartyId: {});
  }
}

class ElectoralCalculator {
  static const int totalKnessetSeats = 120;
  static const double thresholdPercentage = 0.0325; // 3.25%

  static ElectoralResult calculateSeats(Map<String, int> rawVotes, {Map<String, Party>? partiesMap}) {
    final int totalValidVotes = rawVotes.values.fold(0, (sum, val) => sum + (val > 0 ? val : 0));
    if (totalValidVotes <= 0) {
      return ElectoralResult.empty();
    }

    final double thresholdVotes = totalValidVotes * thresholdPercentage;
    final Map<String, double> percentageByPartyId = {};
    for (final entry in rawVotes.entries) {
      percentageByPartyId[entry.key] = (entry.value / totalValidVotes) * 100.0;
    }

    final List<MapEntry<String, int>> passing = [];
    final List<PartySeatAllocation> failingParties = [];

    for (final entry in rawVotes.entries) {
      final votes = entry.value;
      final pct = percentageByPartyId[entry.key] ?? 0.0;
      if (votes >= thresholdVotes) {
        passing.add(entry);
      } else {
        failingParties.add(PartySeatAllocation(partyId: entry.key, rawVotes: votes, percentage: pct, passedThreshold: false, seats: 0, remainderFraction: 0.0));
      }
    }

    failingParties.sort((a, b) => b.rawVotes.compareTo(a.rawVotes));

    if (passing.isEmpty) {
      return ElectoralResult(totalVotes: totalValidVotes, thresholdVotes: thresholdVotes, passingParties: const [], failingParties: failingParties, coalitionSeats: 0, oppositionSeats: 0, undecidedSeats: 0, seatsByPartyId: const {}, percentageByPartyId: percentageByPartyId);
    }

    final int sumOfPassingVotes = passing.fold(0, (sum, item) => sum + item.value);
    final double generalQuota = sumOfPassingVotes / totalKnessetSeats;

    final Map<String, int> initialSeats = {};
    final Map<String, double> remainderFractions = {};
    int allocatedSeatsSum = 0;

    for (final item in passing) {
      final double exactSeats = item.value / generalQuota;
      final int wholeSeats = exactSeats.floor();
      final double remainder = exactSeats - wholeSeats;
      initialSeats[item.key] = wholeSeats;
      remainderFractions[item.key] = remainder;
      allocatedSeatsSum += wholeSeats;
    }

    int remainingSeats = totalKnessetSeats - allocatedSeatsSum;
    final List<String> sortedByRemainder = passing.map((e) => e.key).toList()..sort((a, b) {
      final cmp = (remainderFractions[b] ?? 0.0).compareTo(remainderFractions[a] ?? 0.0);
      if (cmp != 0) return cmp;
      return (rawVotes[b] ?? 0).compareTo(rawVotes[a] ?? 0);
    });

    final Map<String, int> finalSeats = Map.from(initialSeats);
    for (int i = 0; i < remainingSeats && i < sortedByRemainder.length; i++) {
      final partyId = sortedByRemainder[i % sortedByRemainder.length];
      finalSeats[partyId] = (finalSeats[partyId] ?? 0) + 1;
    }

    final List<PartySeatAllocation> passingParties = [];
    for (final item in passing) {
      final partyId = item.key;
      passingParties.add(PartySeatAllocation(partyId: partyId, rawVotes: item.value, percentage: percentageByPartyId[partyId] ?? 0.0, passedThreshold: true, seats: finalSeats[partyId] ?? 0, remainderFraction: remainderFractions[partyId] ?? 0.0));
    }
    passingParties.sort((a, b) => b.seats != a.seats ? b.seats.compareTo(a.seats) : b.rawVotes.compareTo(a.rawVotes));

    int coalitionSeats = 0;
    int oppositionSeats = 0;
    int undecidedSeats = 0;

    if (partiesMap != null) {
      for (final p in passingParties) {
        final party = partiesMap[p.partyId];
        if (party != null) {
          if (party.bloc == PartyBloc.coalition) {
            coalitionSeats += p.seats;
          } else if (party.bloc == PartyBloc.opposition) {
            oppositionSeats += p.seats;
          } else {
            undecidedSeats += p.seats;
          }
        }
      }
    }

    return ElectoralResult(totalVotes: totalValidVotes, thresholdVotes: thresholdVotes, passingParties: passingParties, failingParties: failingParties, coalitionSeats: coalitionSeats, oppositionSeats: oppositionSeats, undecidedSeats: undecidedSeats, seatsByPartyId: finalSeats, percentageByPartyId: percentageByPartyId);
  }
}
