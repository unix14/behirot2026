import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/localization.dart';

class FindPollingStationCard extends StatelessWidget {
  final AppLocalization l10n;

  const FindPollingStationCard({super.key, required this.l10n});

  static const String bocharimUrl = 'https://www.gov.il/apps/moin/bocharim/';

  Future<void> _openBocharimUrl() async {
    final uri = Uri.parse(bocharimUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2F6B), Color(0xFF1E40AF), Color(0xFF1D4ED8)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x260D2F6B), blurRadius: 12, offset: Offset(0, 4))],
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _openBocharimUrl,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_user_rounded, color: Color(0xFF0F172A), size: 14),
                          const SizedBox(width: 5),
                          Text(
                            l10n.t('find_polling_station_badge'),
                            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.open_in_new_rounded, color: Colors.white70, size: 18),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30, width: 1.2),
                      ),
                      child: const Center(
                        child: Icon(Icons.location_on_rounded, color: Color(0xFFFEF08A), size: 26),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.t('find_polling_station_title'),
                            style: GoogleFonts.rubik(fontSize: 17.5, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.t('find_polling_station_subtitle'),
                            style: const TextStyle(fontSize: 12.5, color: Color(0xFFE2E8F0), height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openBocharimUrl,
                    icon: const Icon(Icons.search_rounded, size: 18),
                    label: Text(
                      l10n.t('find_polling_station_btn'),
                      style: GoogleFonts.rubik(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0D2F6B),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
