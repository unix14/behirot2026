import 'package:flutter_test/flutter_test.dart';
import 'package:behirot2026/services/poll_state.dart';

void main() {
  test('PollState voting window is open from now until October 27, 2026 20:30 UTC', () {
    expect(PollState.votingDeadlineUtc, DateTime.utc(2026, 10, 27, 20, 30, 0));
    final nowUtc = DateTime.now().toUtc();
    final isOpen = nowUtc.isBefore(PollState.votingDeadlineUtc);
    expect(isOpen, true);
  });
}
