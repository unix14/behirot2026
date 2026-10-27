import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/party.dart';
import '../services/localization.dart';
import 'israel_emblem.dart';

class BallotBoxWidget extends StatefulWidget {
  final AppLocalization l10n;
  final Function(Party party) onSlipDropped;
  final bool isSubmitting;
  final bool isLocked;

  const BallotBoxWidget({
    super.key,
    required this.l10n,
    required this.onSlipDropped,
    this.isSubmitting = false,
    this.isLocked = false,
  });

  @override
  State<BallotBoxWidget> createState() => BallotBoxWidgetState();
}

class BallotBoxWidgetState extends State<BallotBoxWidget> with SingleTickerProviderStateMixin {
  bool _isHoveringDropZone = false;
  late AnimationController _dropController;
  late Animation<double> _dropAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  Party? _animatingParty;

  @override
  void initState() {
    super.initState();
    _dropController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _dropAnimation = Tween<double>(begin: -100.0, end: 35.0).animate(CurvedAnimation(parent: _dropController, curve: Curves.easeInCubic));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(CurvedAnimation(parent: _dropController, curve: Curves.easeIn));
    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.08).animate(CurvedAnimation(parent: _dropController, curve: Curves.easeInOut));
  }

  Future<void> animateVoteDrop(Party party) async {
    if (!mounted) return;
    setState(() {
      _animatingParty = party;
    });
    HapticFeedback.heavyImpact();
    await _dropController.forward(from: 0.0);
    if (mounted) {
      setState(() {
        _animatingParty = null;
      });
    }
  }

  @override
  void dispose() {
    _dropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<Party>(
      onWillAcceptWithDetails: (details) {
        setState(() => _isHoveringDropZone = true);
        HapticFeedback.selectionClick();
        return true;
      },
      onLeave: (data) {
        setState(() => _isHoveringDropZone = false);
      },
      onAcceptWithDetails: (details) {
        setState(() => _isHoveringDropZone = false);
        if (widget.isLocked) {
          HapticFeedback.vibrate();
        }
        widget.onSlipDropped(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final bool highlight = _isHoveringDropZone || candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(maxWidth: 360),
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: highlight ? [const Color(0xFF1E88E5), const Color(0xFF0D2F6B)] : [const Color(0xFF1565C0), const Color(0xFF082554)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: highlight ? const Color(0xFFFFD54F) : const Color(0xFFD4AF37), width: highlight ? 3.0 : 2.0),
            boxShadow: [
              BoxShadow(color: highlight ? const Color(0xFFFFD54F).withValues(alpha: 0.4) : const Color(0x33000000), blurRadius: highlight ? 24 : 14, offset: const Offset(0, 8)),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Metallic top rim
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const IsraelEmblem(height: 54),
                    const SizedBox(height: 6),
                    Text(widget.l10n.t('ballot_box_title'), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3)),
                    const SizedBox(height: 12),
                    // The physical slot ("חריץ הקלפי")
                    Container(
                      width: 210,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF061426),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: highlight ? const Color(0xFFFFD54F) : const Color(0xFF90CAF9), width: 1.8),
                        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: Center(
                        child: Container(
                          width: 175,
                          height: 5,
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(3)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                        color: widget.isLocked ? const Color(0xFFFFD54F) : (highlight ? const Color(0xFFFFD54F) : const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        widget.isLocked
                            ? (widget.l10n.isRtl ? 'הצבעתך נקלטה! הקלפי נעולה עבורך 🔒' : 'Your vote is recorded! Booth is locked 🔒')
                            : (highlight ? widget.l10n.t('ballot_box_release') : widget.l10n.t('ballot_box_drop_hint')),
                      ),
                    ),
                  ],
                ),
              ),
              if (_animatingParty != null)
                AnimatedBuilder(
                  animation: _dropController,
                  builder: (context, child) {
                    return Positioned(
                      top: _dropAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Opacity(
                            opacity: (1.0 - _dropController.value * 0.75).clamp(0.0, 1.0),
                            child: Container(
                              width: 100,
                              height: 110,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF9F6),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFD6D3D1)),
                                boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4))],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _animatingParty!.ballotLetter,
                                style: GoogleFonts.frankRuhlLibre(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              if (widget.isSubmitting)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(18)),
                    child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
