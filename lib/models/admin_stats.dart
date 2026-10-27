class AdminStats {
  final int totalAggregateVotes;
  final int realVotesCount;
  final int simulatedVotesCount;
  final Map<String, int> partyVotes;
  final Map<String, int> partyRealVotes;
  final Map<String, int> partySimulatedVotes;

  const AdminStats({
    required this.totalAggregateVotes,
    required this.realVotesCount,
    required this.simulatedVotesCount,
    required this.partyVotes,
    required this.partyRealVotes,
    required this.partySimulatedVotes,
  });

  factory AdminStats.empty() {
    return const AdminStats(
      totalAggregateVotes: 0,
      realVotesCount: 0,
      simulatedVotesCount: 0,
      partyVotes: {},
      partyRealVotes: {},
      partySimulatedVotes: {},
    );
  }

  double get realPercentage => totalAggregateVotes > 0 ? (realVotesCount / totalAggregateVotes * 100) : 0.0;
  double get simulatedPercentage => totalAggregateVotes > 0 ? (simulatedVotesCount / totalAggregateVotes * 100) : 0.0;
}
