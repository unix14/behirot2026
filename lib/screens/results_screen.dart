import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/party.dart';
import '../services/localization.dart';
import '../services/poll_state.dart';
import '../widgets/app_footer.dart';
import '../widgets/bloc_comparison_bar.dart';
import '../widgets/knesset_arc_chart.dart';
import '../widgets/party_info_modal.dart';
import '../widgets/voter_guide_accordion.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  Widget _buildPartyTile(BuildContext context, Party party, int seats, double percentage, AppLocalization l10n, PollState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => PartyInfoModal.show(context, party: party, l10n: l10n, onVoteTap: state.hasVoted ? null : () => state.castVote(party.id)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: party.color.withValues(alpha: 0.35), width: 1.2)),
                    padding: const EdgeInsets.all(2),
                    child: Image.asset(party.localAssetLogo, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => (party.logoUrl.isNotEmpty ? Image.network(party.logoUrl, fit: BoxFit.contain, errorBuilder: (c, e, s) => Center(child: Text(party.ballotLetter, style: GoogleFonts.frankRuhlLibre(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), fontSize: 16)))) : Center(child: Text(party.ballotLetter, style: GoogleFonts.frankRuhlLibre(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), fontSize: 16))))),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: party.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: party.color, width: 1.5)),
                  alignment: Alignment.center,
                  child: Text(party.ballotLetter, style: GoogleFonts.frankRuhlLibre(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), fontSize: 14)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalization.getPartyTranslatedName(party.id, party.name, l10n.language), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 14)),
                      const SizedBox(height: 2),
                      Text('${percentage.toStringAsFixed(1)}% • ${party.bloc == PartyBloc.coalition ? l10n.t('coalition') : (party.bloc == PartyBloc.opposition ? l10n.t('opposition') : 'ללא שיוך')}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(color: party.color, borderRadius: BorderRadius.circular(20)),
                  child: Text('$seats ${l10n.t('seats_unit')}', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13)),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFailingPartyTile(BuildContext context, Party party, double percentage, AppLocalization l10n, PollState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => PartyInfoModal.show(context, party: party, l10n: l10n, onVoteTap: state.hasVoted ? null : () => state.castVote(party.id)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFEE2E2))),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFFECACA), width: 1.2)),
                    padding: const EdgeInsets.all(2),
                    child: Image.asset(party.localAssetLogo, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => (party.logoUrl.isNotEmpty ? Image.network(party.logoUrl, fit: BoxFit.contain, errorBuilder: (c, e, s) => Center(child: Text(party.ballotLetter, style: GoogleFonts.frankRuhlLibre(fontWeight: FontWeight.bold, color: const Color(0xFF991B1B), fontSize: 14)))) : Center(child: Text(party.ballotLetter, style: GoogleFonts.frankRuhlLibre(fontWeight: FontWeight.bold, color: const Color(0xFF991B1B), fontSize: 14))))),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFFECACA))),
                  alignment: Alignment.center,
                  child: Text(party.ballotLetter, style: GoogleFonts.frankRuhlLibre(fontWeight: FontWeight.bold, color: const Color(0xFF991B1B), fontSize: 14)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(AppLocalization.getPartyTranslatedName(party.id, party.name, l10n.language), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600, fontSize: 14)),
                ),
                Text('${percentage.toStringAsFixed(1)}%', style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(10)),
                  child: const Text('0 מנדטים', style: TextStyle(color: Color(0xFF991B1B), fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFCA5A5), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<PollState>(context);
    final l10n = state.l10n;
    final result = state.electoralResult;

    final passingParties = result.passingParties;
    final failingParties = result.failingParties;

    final bool hasPassingParties = passingParties.isNotEmpty;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      ],
                    ),
                  ),

                // Live status banner at top
                Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.isRtl ? 'תוצאות ומנדטים בזמן אמת' : 'Live Realtime Results',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Top Section: Knesset Plenum Semicircle Arc (Always Shown)
                KnessetArcChart(result: result, parties: state.parties, l10n: l10n),
                const SizedBox(height: 20),

                // Bloc Comparison Bar (Always Shown)
                BlocComparisonBar(result: result, l10n: l10n),
                const SizedBox(height: 24),

                // Ranked Seats Table (Always Shown)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: const Color(0xFF0D2F6B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.format_list_numbered_rounded, color: Color(0xFF0D2F6B), size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(l10n.t('ranked_parties_title'), style: GoogleFonts.rubik(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      if (hasPassingParties) ...[
                        ...passingParties.map((alloc) {
                          final party = state.parties[alloc.partyId];
                          if (party == null) return const SizedBox.shrink();
                          return _buildPartyTile(context, party, alloc.seats, alloc.percentage, l10n, state);
                        }),
                      ] else ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: Color(0xFF475569), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  result.totalVotes == 0
                                      ? (l10n.isRtl ? 'הקלפי פתוחה כעת להצבעה. כל הרשימות מוצגות להלן לפי סדר פתקי ההצבעה:' : 'The voting booth is open. All candidate parties are listed below:')
                                      : (l10n.isRtl ? 'אף רשימה טרם עברה את אחוז החסימה (3.25%). ראו רשימות למטה.' : 'No party has passed the 3.25% threshold yet. See below.'),
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (result.totalVotes == 0)
                          ...state.parties.values.map((party) => _buildPartyTile(context, party, 0, 0.0, l10n, state)),
                      ],
                    ],
                  ),
                ),

                // Distinct Visual Section Below Explicit Line for Parties Failing Threshold (< 3.25%)
                if (failingParties.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 22),
                            const SizedBox(width: 8),
                            Text(l10n.t('below_threshold_title'), style: GoogleFonts.rubik(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF991B1B))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(l10n.t('below_threshold_desc'), style: const TextStyle(fontSize: 13, color: Color(0xFF7F1D1D))),
                        const SizedBox(height: 16),
                        // Explicit separation divider line
                        Container(height: 1.5, color: const Color(0xFFFCA5A5)),
                        const SizedBox(height: 14),
                        ...failingParties.map((alloc) {
                          final party = state.parties[alloc.partyId];
                          if (party == null) return const SizedBox.shrink();
                          return _buildFailingPartyTile(context, party, alloc.percentage, l10n, state);
                        }),
                      ],
                    ),
                  ),
                ],

                // "משחק הרכבת קואליציה" Interactive Feature Card
                Container(
                  margin: const EdgeInsets.only(top: 24, bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1B4B), Color(0xFF3730A3)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Color(0x1F1E1B4B), blurRadius: 16, offset: Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                l10n.t('coalition_game_badge'),
                                style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.videogame_asset_rounded, color: Colors.white70, size: 24),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.t('coalition_game_title'),
                        style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.t('coalition_game_desc'),
                        style: const TextStyle(fontSize: 13.5, color: Color(0xFFE2E8F0), height: 1.45),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse('https://www.kan.org.il/lobby/skarim/');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: Text(l10n.t('coalition_game_btn'), style: GoogleFonts.rubik(fontWeight: FontWeight.bold, fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1E1B4B),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // "הבא בתור" Interactive Feature Card
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D2F6B), Color(0xFF1E3A8A)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Color(0x1F0D2F6B), blurRadius: 16, offset: Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                l10n.t('haba_bator_badge'),
                                style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.person_add_alt_1_rounded, color: Colors.white70, size: 24),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.t('haba_bator_title'),
                        style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.t('haba_bator_desc'),
                        style: const TextStyle(fontSize: 13.5, color: Color(0xFFE2E8F0), height: 1.45),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse('https://haba-bator.vercel.app/');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: Text(l10n.t('haba_bator_btn'), style: GoogleFonts.rubik(fontWeight: FontWeight.bold, fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0D2F6B),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Voter Guide Q&A in results screen
                Row(
                  children: [
                    const Icon(Icons.help_outline_rounded, color: Color(0xFF0D2F6B), size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(l10n.t('guide_tab'), style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                VoterGuideAccordion(l10n: l10n),
                const SizedBox(height: 24),
                AppFooter(l10n: l10n, showEducationalBanner: true),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
