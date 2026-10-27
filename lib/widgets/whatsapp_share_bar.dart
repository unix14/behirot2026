import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/localization.dart';
import 'whatsapp_icon.dart';

/// Sticky WhatsApp share action bar displayed across all 3 navigation tabs.
class WhatsAppShareBar extends StatelessWidget {
  final AppLocalization l10n;

  const WhatsAppShareBar({super.key, required this.l10n});

  static Future<void> share(BuildContext context, AppLocalization l10n) async {
    final text = Uri.encodeComponent(l10n.getRandomWhatsAppShareText());
    final url = Uri.parse('https://api.whatsapp.com/send?text=$text');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.isRtl ? 'לא ניתן לפתוח וואטסאפ' : 'Could not launch WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFCBD5E1))),
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF25D366), Color(0xFF1EBE5D), Color(0xFF128C7E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x5525D366), blurRadius: 16, offset: Offset(0, 6)),
                  BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
                border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => share(context, l10n),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          padding: const EdgeInsets.all(2.5),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Color(0x28000000), blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          child: const WhatsAppIcon(size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            l10n.t('whatsapp_share_btn'),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rubik(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.2,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
