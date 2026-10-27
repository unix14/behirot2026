import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/voter_guide_item.dart';
import '../services/localization.dart';
import 'find_polling_station_card.dart';

class VoterGuideAccordion extends StatefulWidget {
  final AppLocalization l10n;

  const VoterGuideAccordion({super.key, required this.l10n});

  @override
  State<VoterGuideAccordion> createState() => _VoterGuideAccordionState();
}

class _VoterGuideAccordionState extends State<VoterGuideAccordion> {
  final Set<String> _expandedItemIds = {};

  @override
  Widget build(BuildContext context) {
    final bool isHe = widget.l10n.language == AppLanguage.hebrew;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FindPollingStationCard(l10n: widget.l10n),
        ...VoterGuideItem.allItems.map((item) {
            final isExpanded = _expandedItemIds.contains(item.id);
            final question = isHe ? item.questionHe : item.questionEn;
            final answer = isHe ? item.answerHe : item.answerEn;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isExpanded ? const Color(0xFF0D2F6B) : const Color(0xFFCBD5E1), width: isExpanded ? 1.5 : 1),
                boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: isExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        if (expanded) {
                          _expandedItemIds.add(item.id);
                        } else {
                          _expandedItemIds.remove(item.id);
                        }
                      });
                    },
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isExpanded ? const Color(0xFF0D2F6B).withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: isExpanded ? const Color(0xFF0D2F6B) : const Color(0xFF475569), size: 20),
                    ),
                    title: Text(
                      question,
                      style: GoogleFonts.rubik(fontSize: 15.5, fontWeight: FontWeight.w600, color: isExpanded ? const Color(0xFF0D2F6B) : const Color(0xFF0F172A)),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 18, top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: widget.l10n.isRtl ? Alignment.centerRight : Alignment.centerLeft,
                              child: Text(
                                answer,
                                textAlign: widget.l10n.isRtl ? TextAlign.right : TextAlign.left,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.6),
                              ),
                            ),
                            if (item.id == 'where_vote') ...[
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final uri = Uri.parse(FindPollingStationCard.bocharimUrl);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                },
                                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                                label: Text(widget.l10n.t('find_polling_station_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D2F6B),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
