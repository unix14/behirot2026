import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/electoral_calculator.dart';
import '../services/localization.dart';

class BlocComparisonBar extends StatelessWidget {
  final ElectoralResult result;
  final AppLocalization l10n;

  const BlocComparisonBar({super.key, required this.result, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final int coalition = result.coalitionSeats;
    final int opposition = result.oppositionSeats;
    final int undecided = result.undecidedSeats;

    final bool coalitionMajority = coalition >= 61;
    final bool oppositionMajority = opposition >= 61;

    final double coalitionFlex = coalition.toDouble().clamp(1.0, 120.0);
    final double oppositionFlex = opposition.toDouble().clamp(1.0, 120.0);
    final double undecidedFlex = undecided > 0 ? undecided.toDouble() : 0.0;

    return Container(
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
                child: const Icon(Icons.balance_rounded, color: Color(0xFF0D2F6B), size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l10n.t('bloc_comparison_title'), style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFD4AF37), width: 1.2)),
                child: Text(l10n.t('majority_needed'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF0D2F6B), shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Flexible(child: Text(l10n.t('coalition'), overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155), fontSize: 13.5))),
                    const SizedBox(width: 6),
                    Text('$coalition', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: coalitionMajority ? const Color(0xFF0D2F6B) : const Color(0xFF0F172A))),
                    if (coalitionMajority) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF0D2F6B), size: 16),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (oppositionMajority) ...[
                      const Icon(Icons.check_circle_rounded, color: Color(0xFFC62828), size: 16),
                      const SizedBox(width: 4),
                    ],
                    Text('$opposition', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: oppositionMajority ? const Color(0xFFC62828) : const Color(0xFF0F172A))),
                    const SizedBox(width: 6),
                    Flexible(child: Text(l10n.t('opposition'), overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155), fontSize: 13.5))),
                    const SizedBox(width: 5),
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFC62828), shape: BoxShape.circle)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 30,
                  child: Row(
                    children: [
                      Expanded(
                        flex: coalitionFlex.toInt(),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFF0D2F6B), Color(0xFF1E88E5)]),
                          ),
                          alignment: Alignment.center,
                          child: coalition > 8 ? Text('$coalition', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)) : null,
                        ),
                      ),
                      if (undecidedFlex > 0)
                        Expanded(
                          flex: undecidedFlex.toInt(),
                          child: Container(color: const Color(0xFF94A3B8), alignment: Alignment.center, child: Text('$undecided', style: const TextStyle(color: Colors.white, fontSize: 11))),
                        ),
                      Expanded(
                        flex: oppositionFlex.toInt(),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFFE53935), Color(0xFFB71C1C)]),
                          ),
                          alignment: Alignment.center,
                          child: opposition > 8 ? Text('$opposition', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)) : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Majority 61 threshold indicator mark at exact center
              Container(
                width: 3.5,
                height: 40,
                decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(2), boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4)]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: (coalitionMajority || oppositionMajority) ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: (coalitionMajority || oppositionMajority) ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1)),
              ),
              child: Text(
                coalitionMajority
                    ? (l10n.isRtl ? 'לקואליציה יש רוב להקמת ממשלה ($coalition מנדטים)' : 'Coalition holds a parliamentary majority ($coalition seats)')
                    : oppositionMajority
                        ? (l10n.isRtl ? 'לאופוזיציה יש רוב להקמת ממשלה ($opposition מנדטים)' : 'Opposition holds a parliamentary majority ($opposition seats)')
                        : (l10n.isRtl ? 'תיקו פוליטי - אף גוש אינו מגיע ל-61 מנדטים' : 'Political deadlock - neither bloc reaches 61 seats'),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: (coalitionMajority || oppositionMajority) ? const Color(0xFF92400E) : const Color(0xFF475569)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: InkWell(
              onTap: () async {
                final uri = Uri.parse('https://www.kan.org.il/lobby/skarim/');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videogame_asset_rounded, size: 17, color: Color(0xFF0D2F6B)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n.t('try_coalition_game_btn'),
                        style: GoogleFonts.rubik(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0D2F6B)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
