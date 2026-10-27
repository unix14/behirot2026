import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/party.dart';
import '../services/electoral_calculator.dart';
import '../services/localization.dart';

class KnessetArcChart extends StatefulWidget {
  final ElectoralResult result;
  final Map<String, Party> parties;
  final AppLocalization l10n;

  const KnessetArcChart({super.key, required this.result, required this.parties, required this.l10n});

  @override
  State<KnessetArcChart> createState() => _KnessetArcChartState();
}

class _KnessetArcChartState extends State<KnessetArcChart> {
  String? _hoveredPartyId;

  @override
  Widget build(BuildContext context) {
    final passingParties = widget.result.passingParties;
    final bool isEmpty = passingParties.isEmpty;

    // Build the list of 120 seats mapped to party IDs
    final List<String> seatPartyIds = [];
    if (isEmpty) {
      for (int i = 0; i < 120; i++) {
        seatPartyIds.add('empty');
      }
    } else {
      for (final allocation in passingParties) {
        for (int i = 0; i < allocation.seats; i++) {
          seatPartyIds.add(allocation.partyId);
        }
      }
      while (seatPartyIds.length < 120) {
        seatPartyIds.add(passingParties.first.partyId);
      }
    }

    final Party? activeParty = _hoveredPartyId != null ? widget.parties[_hoveredPartyId] : null;
    final PartySeatAllocation? activeAlloc = (!isEmpty && _hoveredPartyId != null) ? passingParties.firstWhere((p) => p.partyId == _hoveredPartyId, orElse: () => passingParties.first) : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFF0D2F6B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.account_balance_rounded, color: Color(0xFF0D2F6B), size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.l10n.t('plenum_title'), style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF0D2F6B), borderRadius: BorderRadius.circular(12)),
                child: const Text('120 ח״כים', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 220,
            child: CustomPaint(
              painter: _KnessetArcPainter(
                seatPartyIds: seatPartyIds,
                parties: widget.parties,
                hoveredPartyId: _hoveredPartyId,
                isRtl: widget.l10n.isRtl,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Interactive detail display
          Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: activeParty?.color ?? const Color(0xFFCBD5E1))),
            alignment: Alignment.center,
            child: activeParty != null && activeAlloc != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: activeParty.color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${activeParty.ballotLetter} - ${AppLocalization.getPartyTranslatedName(activeParty.id, activeParty.name, widget.l10n.language)}:',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('${activeAlloc.seats} ${widget.l10n.t('seats_unit')}', style: TextStyle(fontWeight: FontWeight.w900, color: activeParty.color, fontSize: 15)),
                      const SizedBox(width: 6),
                      Text('(${activeAlloc.percentage.toStringAsFixed(1)}%)', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  )
                : Text(isEmpty ? (widget.l10n.isRtl ? 'מליאת הכנסת - 120 מושבים | הקלפי פתוחה לקליטת קולות' : '120 Knesset Seats | Voting booth is open') : (widget.l10n.isRtl ? 'רחפו או לחצו על רשימה למטה להדגשת מושביה במליאה' : 'Hover or tap a party chip below to highlight its Knesset seats'), style: const TextStyle(color: Color(0xFF64748B), fontSize: 13), textAlign: TextAlign.center),
          ),
          if (passingParties.isNotEmpty) ...[
            const SizedBox(height: 16),
            // Quick party legend chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: passingParties.map((p) {
              final party = widget.parties[p.partyId];
              if (party == null) return const SizedBox.shrink();
              final isHovered = _hoveredPartyId == p.partyId;

              return MouseRegion(
                onEnter: (_) => setState(() => _hoveredPartyId = p.partyId),
                onExit: (_) => setState(() => _hoveredPartyId = null),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _hoveredPartyId = _hoveredPartyId == p.partyId ? null : p.partyId;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isHovered ? party.color.withValues(alpha: 0.15) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isHovered ? party.color : const Color(0xFFCBD5E1), width: isHovered ? 2 : 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: party.color, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(party.ballotLetter, style: GoogleFonts.frankRuhlLibre(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), fontSize: 13)),
                        const SizedBox(width: 6),
                        Text('${p.seats}', style: TextStyle(fontWeight: FontWeight.bold, color: party.color, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    ),
  );
  }
}

class _KnessetArcPainter extends CustomPainter {
  final List<String> seatPartyIds;
  final Map<String, Party> parties;
  final String? hoveredPartyId;
  final bool isRtl;

  const _KnessetArcPainter({required this.seatPartyIds, required this.parties, required this.hoveredPartyId, required this.isRtl});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2.0;
    final double centerY = size.height - 20.0;

    final List<int> rowCounts = [24, 28, 32, 36];
    final double maxRadius = math.min(size.height * 0.86, (size.width / 2.0) - 16.0);
    final List<double> radii = [
      maxRadius * 0.51,
      maxRadius * 0.67,
      maxRadius * 0.84,
      maxRadius,
    ];
    final double dotRadius = math.max(3.8, maxRadius * 0.032);

    int seatIndex = 0;
    for (int r = 0; r < rowCounts.length; r++) {
      final int count = rowCounts[r];
      final double radius = radii[r];

      for (int i = 0; i < count; i++) {
        if (seatIndex >= seatPartyIds.length) break;

        final double fraction = i / (count - 1);
        final double angle = isRtl ? math.pi * (1.0 - fraction) : math.pi * fraction;

        final double x = centerX + radius * math.cos(angle);
        final double y = centerY - radius * math.sin(angle);

        final partyId = seatPartyIds[seatIndex];
        final party = parties[partyId];
        final Color baseColor = party?.color ?? const Color(0xFFCBD5E1);

        final bool isHighlighted = hoveredPartyId == null || hoveredPartyId == partyId;
        final Paint paint = Paint()..color = isHighlighted ? baseColor : baseColor.withValues(alpha: 0.2)..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), isHighlighted && hoveredPartyId == partyId ? dotRadius + 1.8 : dotRadius, paint);

        if (hoveredPartyId == partyId) {
          final borderPaint = Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 1.5;
          canvas.drawCircle(Offset(x, y), dotRadius + 2.0, borderPaint);
        }

        seatIndex++;
      }
    }

    // Podium / Speaker stand center arc in official navy
    final double podiumRadius = math.max(20.0, maxRadius * 0.22);
    final podiumPaint = Paint()..color = const Color(0xFF0D2F6B)..style = PaintingStyle.stroke..strokeWidth = 2.4;
    canvas.drawArc(Rect.fromCircle(center: Offset(centerX, centerY), radius: podiumRadius), math.pi, math.pi, false, podiumPaint);

    final podiumBasePaint = Paint()..color = const Color(0xFFD4AF37)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawArc(Rect.fromCircle(center: Offset(centerX, centerY), radius: podiumRadius * 0.67), math.pi, math.pi, false, podiumBasePaint);
  }

  @override
  bool shouldRepaint(covariant _KnessetArcPainter oldDelegate) {
    return oldDelegate.hoveredPartyId != hoveredPartyId || oldDelegate.seatPartyIds != seatPartyIds || oldDelegate.isRtl != isRtl;
  }
}
