import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/localization.dart';

class AppFooter extends StatelessWidget {
  final AppLocalization l10n;
  final bool showEducationalBanner;

  const AppFooter({
    super.key,
    required this.l10n,
    this.showEducationalBanner = true,
  });

  void _showLegalDialog(BuildContext context, String type) {
    String title = '';
    String content = '';

    if (type == 'privacy') {
      title = l10n.t('legal_privacy');
      content = l10n.isRtl
          ? 'מדיניות פרטיות - הקלפי הוירטואלית 2026\n\n'
            '1. אנונימיות מלאה: האתר אינו אוסף, אינו שומר ואינו מעביר שום פרט מזהה אישי (לרבות שם, מספר תעודת זהות, כתובת IP או מיקום גאוגרפי).\n'
            '2. מזהה מכשיר אנונימי: לצורך מניעת הצבעות כפולות במדגם, נשמר במכשירך מזהה אנונימי מקרי (UUID) בלבד בזיכרון המקומי (Local Storage).\n'
            '3. שקיפות נתונים: קולות ההצבעה נספרים באופן אגרגטיבי בלבד ומסונכרנים בזמן אמת ללא שום זיקה למזהה אנושי כלשהו.\n'
            '4. ללא שימוש מסחרי: האתר אינו כולל פרסומות, אינו עושה שימוש בקובצי Cookie למטרות שיווקיות ואינו מוכר מידע לצדדים שלישיים.'
          : 'Privacy Policy - The Virtual Ballot Box 2026\n\n'
            '1. Complete Anonymity: This site does not collect, store, or transmit any personally identifiable information (including names, IDs, IP addresses, or location data).\n'
            '2. Anonymous Device Identifier: To prevent duplicate voting in the poll, a random anonymous UUID is stored in local storage.\n'
            '3. Data Transparency: Votes are counted in aggregate only with zero connection to human identity.\n'
            '4. Non-Commercial: No advertisements, no marketing cookies, no data selling.';
    } else if (type == 'terms') {
      title = l10n.t('legal_terms');
      content = l10n.isRtl
          ? 'תנאי שימוש - הקלפי הוירטואלית 2026\n\n'
            '1. מהות האתר: אתר זה הינו סימולטור וסקר אזרחי חי, שנוצר למטרות חינוכיות, מחקריות ותרבותיות בלבד.\n'
            '2. אינו מחליף הצבעה רשמית: האתר אינו פלטפורמת הצבעה רשמית ואינו מהווה תחליף להצבעה פיזית בקלפי ביום הבחירות.\n'
            '3. אי-תלות פוליטית: המיזם הינו עצמאי, ללא כוונת רווח, ואינו משויך או ממומן על ידי אף מפלגה, גוף פוליטי או גורם ממשלתי כלשהו.\n'
            '4. הגבלת אחריות: התוצאות, התחזיות וחלוקת המנדטים מייצגים מדגם משתמשים בלבד ואינם מהווים ייעוץ פוליטי או הבטחה לתוצאות האמת.'
          : 'Terms of Service - The Virtual Ballot Box 2026\n\n'
            '1. Purpose: This site is a live civic simulator and poll created solely for educational and research purposes.\n'
            '2. Not Official Voting: This platform does not replace voting at an official polling station on election day.\n'
            '3. Independence: Independent, non-profit, not affiliated with or funded by any political party or government body.\n'
            '4. Limitation of Liability: Projections represent sample votes only and do not constitute political guidance or prediction guarantees.';
    } else {
      title = l10n.t('legal_disclaimer');
      content = l10n.isRtl
          ? 'הבהרה והצהרה משפטית\n\n'
            'מיזם זה פותח כפרויקט קוד פתוח עצמאי לרווחת הציבור.\n'
            'כל הסמלים, שמות המפלגות והלוגואים הינם קניינם הרוחני של בעליהם החוקיים ומוצגים לצורכי זיהוי הוגן במסגרת סיקור אזרחי וחינוכי.\n'
            'לשאלות, הבהרות או פניות: github.com/unix14'
          : 'Legal Disclaimer\n\n'
            'This project is developed as an independent open-source civic initiative for public benefit.\n'
            'All party emblems, logos, and trademarks belong to their respective owners and are displayed for fair identification purposes.\n'
            'For inquiries: github.com/unix14';
    }

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: l10n.textDirection,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: GoogleFonts.rubik(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF0F172A))),
          content: SingleChildScrollView(
            child: Text(content, style: const TextStyle(fontSize: 13.5, height: 1.5, color: Color(0xFF334155))),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.isRtl ? 'סגור' : 'Close', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D2F6B))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalButton(BuildContext context, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600, decoration: TextDecoration.underline, decorationColor: Color(0xFFCBD5E1)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showEducationalBanner)
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFCBD5E1)),
              boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2F6B).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.campaign_rounded, color: Color(0xFF0D2F6B), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.t('educational_disclaimer'),
                    style: const TextStyle(fontSize: 13, height: 1.45, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        // Copyright text & GitHub link in semi grey-whitish
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            Text(
              l10n.isRtl
                  ? 'האתר נוצר למטרות חינוכיות בלבד ואינו מחליף הצבעה אמיתית. צאו להצביע! | '
                  : 'Created for educational purposes only. Does not replace actual voting. Go vote! | ',
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            InkWell(
              onTap: () async {
                final uri = Uri.parse('https://github.com/unix14');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text(
                'GitHub',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Legal links row
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            _buildLegalButton(context, l10n.t('legal_terms'), () => _showLegalDialog(context, 'terms')),
            const Text('•', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
            _buildLegalButton(context, l10n.t('legal_privacy'), () => _showLegalDialog(context, 'privacy')),
            const Text('•', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
            _buildLegalButton(context, l10n.t('legal_disclaimer'), () => _showLegalDialog(context, 'disclaimer')),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
