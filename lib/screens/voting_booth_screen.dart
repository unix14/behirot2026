import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/party.dart';
import '../services/localization.dart';
import '../services/poll_state.dart';
import '../widgets/app_footer.dart';
import '../widgets/ballot_box.dart';
import '../widgets/ballot_slip.dart';
import '../widgets/color_ballot_box_emoji.dart';
import '../widgets/voter_guide_accordion.dart';

class VotingBoothScreen extends StatefulWidget {
  const VotingBoothScreen({super.key});

  @override
  State<VotingBoothScreen> createState() => _VotingBoothScreenState();
}

class _VotingBoothScreenState extends State<VotingBoothScreen> {
  final GlobalKey<BallotBoxWidgetState> _ballotBoxKey = GlobalKey<BallotBoxWidgetState>();

  void _showVoteConfirmationDialog(BuildContext context, Party party, PollState state) {
    final l10n = state.l10n;
    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: l10n.textDirection,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFCBD5E1))),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: const Color(0xFF0D2F6B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.how_to_vote_rounded, color: Color(0xFF0D2F6B), size: 26),
                ),
                const SizedBox(width: 12),
                Text(l10n.t('confirm_dialog_title'), style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 16, color: Color(0xFF334155), height: 1.4),
                    children: [
                      TextSpan(text: '${l10n.t('confirm_dialog_body')} '),
                      TextSpan(text: AppLocalization.getPartyTranslatedName(party.id, party.name, l10n.language), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      TextSpan(text: ' ${l10n.t('confirm_dialog_letters')} '),
                      TextSpan(text: '"${party.ballotLetter}"', style: GoogleFonts.frankRuhlLibre(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0D2F6B))),
                      const TextSpan(text: '?'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded, color: Color(0xFF0D2F6B), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(l10n.t('confirm_dialog_warning'), style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.t('cancel_btn'), style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  // 150ms delay lets dialog transition complete so ballot box is in clear view
                  await Future.delayed(const Duration(milliseconds: 150));
                  await _ballotBoxKey.currentState?.animateVoteDrop(party);
                  await state.castVote(party.id);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D2F6B), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ColorBallotBoxEmoji(size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.t('vote_now_btn'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAlreadyVotedToast(BuildContext context, AppLocalization l10n, PollState state) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const ColorBallotBoxEmoji(size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.isRtl ? 'כבר הצבעת! כל משתמש רשאי להצביע פעם אחת בלבד' : 'You already voted! Each user may vote only once',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: l10n.isRtl ? 'לתוצאות' : 'Results',
          textColor: const Color(0xFF60A5FA),
          onPressed: () => state.setTabIndex(1),
        ),
      ),
    );
  }

  Widget _buildLockedState(BuildContext context, PollState state) {
    final l10n = state.l10n;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCBD5E1)),
              boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF0D2F6B).withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.lock_clock_rounded, color: Color(0xFF0D2F6B), size: 44),
                ),
                const SizedBox(height: 16),
                Text(l10n.t('window_closed_title'), style: GoogleFonts.rubik(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                const SizedBox(height: 8),
                Text(l10n.t('window_closed_body'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF475569))),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => state.setTabIndex(1),
                  icon: const Icon(Icons.analytics_rounded),
                  label: Text(l10n.t('view_results_btn')),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D2F6B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Q&A section accessible in closed window as requested
          Row(
            children: [
              const Icon(Icons.help_outline_rounded, color: Color(0xFF0D2F6B), size: 24),
              const SizedBox(width: 10),
              Expanded(child: Text(l10n.t('guide_tab'), style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)))),
            ],
          ),
          const SizedBox(height: 16),
          VoterGuideAccordion(l10n: l10n),
          const SizedBox(height: 24),
          AppFooter(l10n: l10n, showEducationalBanner: true),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<PollState>(context);
    final l10n = state.l10n;

    if (!state.isVotingWindowOpen) {
      return _buildLockedState(context, state);
    }

    final partiesList = state.parties.values.toList();

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        // Partition header banner ("ההצבעה שלי")
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: isMobile ? 10 : 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            boxShadow: [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Row(
            children: [
              const Icon(Icons.how_to_vote_rounded, color: Color(0xFF0D2F6B), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.t('booth_instruction'),
                  style: TextStyle(fontSize: isMobile ? 12 : 13, color: const Color(0xFF334155), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),

        // Scrollable area containing the booth partition & slips grid
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 16, vertical: isMobile ? 12 : 20),
            child: Column(
              children: [
                if (state.hasVoted)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(l10n.t('already_voted_banner'), style: const TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => state.setTabIndex(1),
                          icon: const Icon(Icons.analytics_rounded, size: 16),
                          label: Text(l10n.t('results_tab_short'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Ballot Box receiver placed above the parties fliers
                BallotBoxWidget(
                  key: _ballotBoxKey,
                  l10n: l10n,
                  isSubmitting: state.isSubmittingVote,
                  isLocked: state.hasVoted,
                  onSlipDropped: (party) {
                    if (state.hasVoted) {
                      _showAlreadyVotedToast(context, l10n, state);
                    } else {
                      _showVoteConfirmationDialog(context, party, state);
                    }
                  },
                ),
                SizedBox(height: isMobile ? 16 : 24),
                // Authentic Booth Card with partition wood/fabric texture feel
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 22, vertical: isMobile ? 16 : 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBFBF9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD6D3D1), width: 1.5),
                    boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF0D2F6B), shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              l10n.isRtl ? 'תא ההצבעה הרשמי - הקלפי הוירטואלית' : 'Official Polling Booth - The Virtual Ballot Box',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.rubik(fontSize: isMobile ? 15.5 : 18, fontWeight: FontWeight.w700, color: const Color(0xFF0D2F6B)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF0D2F6B), shape: BoxShape.circle)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(height: 1, width: 160, color: const Color(0xFFD4AF37)),
                      SizedBox(height: isMobile ? 14 : 20),
                      // Responsive grid of authentic ballot slips (max 3 items per row on mobile/narrower window)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final double availableWidth = constraints.maxWidth;
                          final bool isNarrow = isMobile || availableWidth < 580;
                          final double spacing = isNarrow ? (availableWidth < 380 ? 6.0 : 8.0) : 16.0;
                          final double runSpacing = isNarrow ? (availableWidth < 380 ? 10.0 : 12.0) : 18.0;

                          final double itemWidth;
                          final double itemHeight;

                          if (isNarrow) {
                            itemWidth = ((availableWidth - (2 * spacing) - 1.0) / 3).floorToDouble().clamp(80.0, 160.0);
                            itemHeight = (itemWidth * 1.16).roundToDouble().clamp(110.0, 160.0);
                          } else {
                            itemWidth = 140.0;
                            itemHeight = 155.0;
                          }

                          return Wrap(
                            spacing: spacing,
                            runSpacing: runSpacing,
                            alignment: WrapAlignment.center,
                            children: partiesList.map((party) {
                              return BallotSlipWidget(
                                party: party,
                                l10n: l10n,
                                width: itemWidth,
                                height: itemHeight,
                                isDraggable: true,
                                canVote: !state.hasVoted,
                                onTap: () {
                                  if (state.hasVoted) {
                                    _showAlreadyVotedToast(context, l10n, state);
                                  } else {
                                    _showVoteConfirmationDialog(context, party, state);
                                  }
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Voter Guide Q&A Section inside the booth window!
                Row(
                  children: [
                    const Icon(Icons.help_outline_rounded, color: Color(0xFF0D2F6B), size: 24),
                    const SizedBox(width: 10),
                    Expanded(child: Text(l10n.t('guide_tab'), style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)))),
                  ],
                ),
                const SizedBox(height: 16),
                VoterGuideAccordion(l10n: l10n),
                const SizedBox(height: 24),
                AppFooter(l10n: l10n, showEducationalBanner: true),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
