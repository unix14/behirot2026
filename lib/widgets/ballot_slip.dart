import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/party.dart';
import '../services/localization.dart';
import 'party_info_modal.dart';

class BallotSlipWidget extends StatelessWidget {
  final Party party;
  final AppLocalization l10n;
  final VoidCallback onTap;
  final bool isDraggable;
  final bool canVote;
  final double? width;
  final double? height;

  const BallotSlipWidget({
    super.key,
    required this.party,
    required this.l10n,
    required this.onTap,
    this.isDraggable = true,
    this.canVote = true,
    this.width,
    this.height,
  });

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Widget _buildPaperContent(BuildContext context, {bool isGhost = false}) {
    final double cardWidth = width ?? 140;
    final double cardHeight = height ?? 155;
    final bool isCompact = cardWidth < 125;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F6),
        borderRadius: BorderRadius.circular(isCompact ? 7 : 8),
        border: Border.all(color: const Color(0xFFD6D3D1), width: isCompact ? 1.0 : 1.2),
        boxShadow: isGhost ? [] : [
          BoxShadow(color: const Color(0x1F000000), blurRadius: isCompact ? 5 : 8, offset: Offset(isCompact ? 1 : 2, isCompact ? 2 : 4)),
          const BoxShadow(color: Color(0x0F000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Stack(
        children: [
          // Main ballot slip content
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 5 : 10, vertical: isCompact ? 8 : 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Text(
                    party.ballotLetter,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.frankRuhlLibre(fontSize: isCompact ? (party.ballotLetter.length > 2 ? 24 : (party.ballotLetter.length == 2 ? 28 : 34)) : (party.ballotLetter.length > 2 ? 38 : 46), fontWeight: FontWeight.w900, color: const Color(0xFF1C1917), height: 1.0, letterSpacing: isCompact ? 0.5 : 1.0),
                  ),
                  const Spacer(flex: 1),
                  Container(height: 1, width: isCompact ? 24 : 36, color: const Color(0xFFD6D3D1)),
                  SizedBox(height: isCompact ? 4 : 6),
                  Text(
                    AppLocalization.getPartyTranslatedName(party.id, party.name, l10n.language),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.frankRuhlLibre(fontSize: isCompact ? 9.5 : 11, fontWeight: FontWeight.w700, color: const Color(0xFF44403C), height: 1.15),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
          // Party Color Bottom Stripe
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: isCompact ? 3.0 : 3.5,
              decoration: BoxDecoration(color: party.color, borderRadius: BorderRadius.vertical(bottom: Radius.circular(isCompact ? 6 : 7))),
            ),
          ),
          // Tap to vote InkWell
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(isCompact ? 7 : 8),
                onTap: onTap,
              ),
            ),
          ),
          // Prominent Info button
          Positioned(
            top: isCompact ? 2 : 4,
            left: l10n.isRtl ? null : (isCompact ? 2 : 4),
            right: l10n.isRtl ? (isCompact ? 2 : 4) : null,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => PartyInfoModal.show(context, party: party, l10n: l10n, onVoteTap: canVote ? onTap : null),
                child: Container(
                  width: isCompact ? 30 : 38,
                  height: isCompact ? 30 : 38,
                  alignment: Alignment.center,
                  child: Container(
                    width: isCompact ? 18 : 22,
                    height: isCompact ? 18 : 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D2F6B).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0D2F6B).withValues(alpha: 0.2)),
                    ),
                    child: Icon(Icons.info_outline_rounded, size: isCompact ? 11 : 14, color: const Color(0xFF0D2F6B)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget paper = _buildPaperContent(context);

    if (!isDraggable) {
      return paper;
    }

    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return LongPressDraggable<Party>(
        data: party,
        delay: const Duration(milliseconds: 200),
        hapticFeedbackOnStart: true,
        feedback: Transform.rotate(
          angle: -0.06,
          child: Material(color: Colors.transparent, child: _buildPaperContent(context)),
        ),
        childWhenDragging: Opacity(
          opacity: 0.35,
          child: _buildPaperContent(context, isGhost: true),
        ),
        child: paper,
      );
    }

    return Draggable<Party>(
      data: party,
      feedback: Transform.rotate(
        angle: -0.06,
        child: Material(color: Colors.transparent, child: _buildPaperContent(context)),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _buildPaperContent(context, isGhost: true),
      ),
      child: paper,
    );
  }
}
