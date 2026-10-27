import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/party.dart';
import '../services/localization.dart';
import 'color_ballot_box_emoji.dart';

class PartyInfoModal {
  static void show(
    BuildContext context, {
    required Party party,
    required AppLocalization l10n,
    VoidCallback? onVoteTap,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Directionality(
          textDirection: l10n.textDirection,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 620),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 24, spreadRadius: 4)],
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Drag Bar & Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 32),
                        Container(width: 44, height: 5, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(10))),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                          onPressed: () => Navigator.of(ctx).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                constraints: const BoxConstraints(maxHeight: 85, maxWidth: 220),
                                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))]),
                                child: Image.asset(party.localAssetLogo, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => (party.logoUrl.isNotEmpty ? Image.network(party.logoUrl, fit: BoxFit.contain, errorBuilder: (c, e, s) => const SizedBox.shrink()) : const SizedBox.shrink())),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(color: party.color.withValues(alpha: 0.12), border: Border.all(color: party.color, width: 2), borderRadius: BorderRadius.circular(12)),
                                  alignment: Alignment.center,
                                  child: Text(party.ballotLetter, style: GoogleFonts.frankRuhlLibre(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(AppLocalization.getPartyTranslatedName(party.id, party.name, l10n.language), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                        decoration: BoxDecoration(color: party.bloc == PartyBloc.coalition ? const Color(0xFF0D2F6B).withValues(alpha: 0.1) : (party.bloc == PartyBloc.opposition ? const Color(0xFFE53935).withValues(alpha: 0.1) : const Color(0xFF64748B).withValues(alpha: 0.1)), borderRadius: BorderRadius.circular(8)),
                                        child: Text(party.bloc == PartyBloc.coalition ? l10n.t('coalition') : (party.bloc == PartyBloc.opposition ? l10n.t('opposition') : 'ללא שיוך'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: party.bloc == PartyBloc.coalition ? const Color(0xFF0D2F6B) : (party.bloc == PartyBloc.opposition ? const Color(0xFFC62828) : const Color(0xFF475569)))),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(l10n.t('party_platform_label'), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            const SizedBox(height: 6),
                            Text(party.platform, style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), height: 1.4)),
                            const SizedBox(height: 14),
                            Text(l10n.t('party_leaders_label'), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: party.keyFigures.map((leader) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
                                  child: Text(leader, style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), fontWeight: FontWeight.w500)),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            // Official Resources & Links Header
                            Row(
                              children: [
                                const Icon(Icons.link_rounded, size: 20, color: Color(0xFF0D2F6B)),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.t('official_links_section'),
                                  style: GoogleFonts.rubik(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Resource Link Cards
                            _buildResourceCard(
                              icon: Icons.games_rounded,
                              iconColor: const Color(0xFFD97706),
                              iconBg: const Color(0xFFFEF3C7),
                              title: l10n.t('link_coalition_game_title'),
                              subtitle: l10n.t('link_coalition_game_sub'),
                              url: 'https://www.kan.org.il/lobby/skarim/',
                              tag: l10n.isRtl ? 'סימולטור' : 'Simulator',
                              tagColor: const Color(0xFFD97706),
                              isFeatured: true,
                            ),
                            _buildResourceCard(
                              icon: Icons.person_add_alt_1_rounded,
                              iconColor: const Color(0xFF16A34A),
                              iconBg: const Color(0xFFDCFCE7),
                              title: l10n.t('link_haba_bator_title'),
                              subtitle: l10n.t('link_haba_bator_sub'),
                              url: 'https://haba-bator.vercel.app/',
                              tag: l10n.isRtl ? 'סימולטור חי ↗' : 'Live Simulator ↗',
                              tagColor: const Color(0xFF16A34A),
                              isFeatured: true,
                            ),
                            if (party.platformUrl.isNotEmpty)
                              _buildResourceCard(
                                icon: Icons.menu_book_rounded,
                                iconColor: const Color(0xFF0284C7),
                                iconBg: const Color(0xFFE0F2FE),
                                title: l10n.t('link_platform_title'),
                                subtitle: l10n.t('link_platform_sub'),
                                url: party.platformUrl,
                              ),
                            if (party.candidatesPdfUrl.isNotEmpty)
                              _buildResourceCard(
                                icon: Icons.picture_as_pdf_rounded,
                                iconColor: const Color(0xFFDC2626),
                                iconBg: const Color(0xFFFEE2E2),
                                title: l10n.t('link_candidates_title'),
                                subtitle: l10n.t('link_candidates_sub'),
                                url: party.candidatesPdfUrl,
                                tag: 'PDF',
                                tagColor: const Color(0xFFDC2626),
                              ),
                            if (party.website.isNotEmpty)
                              _buildResourceCard(
                                icon: Icons.language_rounded,
                                iconColor: const Color(0xFF0D2F6B),
                                iconBg: const Color(0xFFE2E8F0),
                                title: l10n.t('link_website_title'),
                                subtitle: l10n.t('link_website_sub'),
                                url: party.website,
                              ),
                            if (party.idiUrl.isNotEmpty)
                              _buildResourceCard(
                                icon: Icons.account_balance_rounded,
                                iconColor: const Color(0xFF475569),
                                iconBg: const Color(0xFFF1F5F9),
                                title: l10n.t('link_idi_title'),
                                subtitle: l10n.t('link_idi_sub'),
                                url: party.idiUrl,
                              ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    if (onVoteTap != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            onVoteTap();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D2F6B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const ColorBallotBoxEmoji(size: 22),
                              const SizedBox(width: 10),
                              Text(
                                '${l10n.t('vote_now_btn')} (${party.ballotLetter})',
                                style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildResourceCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String url,
    String? tag,
    Color? tagColor,
    bool isFeatured = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isFeatured ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => _safeLaunchUrl(url),
          borderRadius: BorderRadius.circular(14),
          hoverColor: isFeatured ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isFeatured ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0), width: isFeatured ? 1.5 : 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                            ),
                          ),
                          if (tag != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: (tagColor ?? const Color(0xFF0D2F6B)).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: tagColor ?? const Color(0xFF0D2F6B)),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.open_in_new_rounded, size: 16, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _safeLaunchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
    } catch (e) {
      debugPrint('Error launching url $url: $e');
    }
  }
}
