import 'dart:math';
import 'package:flutter/material.dart';

enum AppLanguage { hebrew, english }

class AppLocalization {
  final AppLanguage language;

  const AppLocalization(this.language);

  bool get isRtl => language == AppLanguage.hebrew;
  TextDirection get textDirection => isRtl ? TextDirection.rtl : TextDirection.ltr;

  static const Map<String, Map<AppLanguage, String>> _strings = {
    'app_title': {AppLanguage.hebrew: 'בחירות 2026 | קלפי וירטואלית', AppLanguage.english: 'Elections 2026 | Virtual Ballot Box'},
    'app_subtitle': {AppLanguage.hebrew: 'הקלפי הוירטואלית של הכנסת ה-26', AppLanguage.english: 'The Virtual Ballot Box of the 26th Knesset'},
    'booth_tab': {AppLanguage.hebrew: 'ההצבעה שלי', AppLanguage.english: 'My Vote'},
    'booth_tab_short': {AppLanguage.hebrew: 'ההצבעה שלי', AppLanguage.english: 'My Vote'},
    'results_tab': {AppLanguage.hebrew: 'תוצאות ומנדטים', AppLanguage.english: 'Results & Seats'},
    'results_tab_short': {AppLanguage.hebrew: 'תוצאות', AppLanguage.english: 'Results'},
    'guide_tab': {AppLanguage.hebrew: 'מדריך לבוחר (שאלות ותשובות)', AppLanguage.english: 'Voter Guide (Q&A)'},
    'guide_tab_short': {AppLanguage.hebrew: 'מדריך לבוחר', AppLanguage.english: 'Guide'},
    'booth_instruction': {AppLanguage.hebrew: 'בחרו את פתק ההצבעה שלכם: לחצו לאישור או גררו ישירות לחריץ הקלפי', AppLanguage.english: 'Choose your ballot slip: Tap to confirm or drag directly into the ballot slot'},
    'slip_info_tooltip': {AppLanguage.hebrew: 'מידע על הרשימה והמצע', AppLanguage.english: 'Party info and platform'},
    'ballot_box_title': {AppLanguage.hebrew: 'תיבת הקלפי', AppLanguage.english: 'Ballot Box'},
    'ballot_box_drop_hint': {AppLanguage.hebrew: 'גררו לכאן את הפתק להצבעה', AppLanguage.english: 'Drop ballot slip here to vote'},
    'ballot_box_release': {AppLanguage.hebrew: 'שחררו לשלשול לקלפי!', AppLanguage.english: 'Release to drop into the ballot box!'},
    'confirm_dialog_title': {AppLanguage.hebrew: 'אישור הצבעה', AppLanguage.english: 'Confirm Vote'},
    'confirm_dialog_body': {AppLanguage.hebrew: 'האם ברצונך להצביע עבור רשימת', AppLanguage.english: 'Are you sure you want to vote for'},
    'confirm_dialog_letters': {AppLanguage.hebrew: 'באותיות', AppLanguage.english: 'with letters'},
    'confirm_dialog_warning': {AppLanguage.hebrew: 'ניתן להצביע פעם אחת בלבד. ההצבעה חשאית ואנונימית לחלוטין.', AppLanguage.english: 'You can only vote once. The vote is strictly secret and anonymous.'},
    'vote_now_btn': {AppLanguage.hebrew: 'שלשל לקלפי', AppLanguage.english: 'Drop in Ballot Box'},
    'cancel_btn': {AppLanguage.hebrew: 'ביטול', AppLanguage.english: 'Cancel'},
    'vote_success_title': {AppLanguage.hebrew: 'הצבעתך נקלטה בהצלחה!', AppLanguage.english: 'Vote Successfully Cast!'},
    'vote_success_body': {AppLanguage.hebrew: 'תודה שהשתתפת בבחירות הווירטואליות. מעבירים אותך לתוצאות האמת...', AppLanguage.english: 'Thank you for participating. Redirecting to live results...'},
    'already_voted_banner': {AppLanguage.hebrew: 'הצבעתך נקלטה במערכת! מציג את תמונת המנדטים העדכנית.', AppLanguage.english: 'Your vote has been counted! Showing the latest seat projections.'},
    'no_votes_yet_title': {AppLanguage.hebrew: 'טרם נקלטו קולות בקלפי הלאומית', AppLanguage.english: 'No votes recorded yet in the national poll'},
    'no_votes_yet_desc': {AppLanguage.hebrew: 'הקלפי הווירטואלית פתוחה כעת להצבעה! הצביעו מאחורי הפרגוד כדי להשפיע ולראות את תמונת המנדטים החיה.', AppLanguage.english: 'The virtual voting booth is open! Cast your vote behind the booth to make an impact and see live seat projections.'},
    'go_to_booth_btn': {AppLanguage.hebrew: 'מעבר לקלפי והצבעה', AppLanguage.english: 'Go to Voting Booth'},
    'window_closed_title': {AppLanguage.hebrew: 'הקלפי סגורה כעת', AppLanguage.english: 'Voting Booth is Currently Closed'},
    'window_closed_body': {AppLanguage.hebrew: 'ההצבעה בקלפי הלאומית הסתיימה ב-27 באוקטובר 2026 בשעה 22:30 (שעון ירושלים). ניתן לצפות בתוצאות האמת הסופיות.', AppLanguage.english: 'Voting in the national poll ended on October 27, 2026 at 22:30 (Jerusalem Time). You can view the final verified results.'},
    'view_results_btn': {AppLanguage.hebrew: 'צפה בתוצאות והתפלגות 📊', AppLanguage.english: 'View Live Projections 📊'},
    'plenum_title': {AppLanguage.hebrew: 'מליאת הכנסת ה-26 (120 מושבים)', AppLanguage.english: '26th Knesset Plenum (120 Seats)'},
    'bloc_comparison_title': {AppLanguage.hebrew: 'מאזן הגושים: קואליציה מול אופוזיציה', AppLanguage.english: 'Bloc Balance: Coalition vs. Opposition'},
    'coalition': {AppLanguage.hebrew: 'קואליציה', AppLanguage.english: 'Coalition'},
    'opposition': {AppLanguage.hebrew: 'אופוזיציה', AppLanguage.english: 'Opposition'},
    'majority_needed': {AppLanguage.hebrew: 'קו הרוב: 61 מנדטים', AppLanguage.english: 'Majority threshold: 61 seats'},
    'seats_unit': {AppLanguage.hebrew: 'מנדטים', AppLanguage.english: 'seats'},
    'ranked_parties_title': {AppLanguage.hebrew: 'חלוקת מנדטים לפי רשימות', AppLanguage.english: 'Seat Allocation by Party'},
    'below_threshold_title': {AppLanguage.hebrew: 'מתחת לאחוז החסימה (פחות מ-3.25%)', AppLanguage.english: 'Below Electoral Threshold (< 3.25%)'},
    'below_threshold_desc': {AppLanguage.hebrew: 'רשימות אלו לא עברו את רף 3.25% מסך הקולות וקולותיהן אינם מזכים במנדט.', AppLanguage.english: 'These parties did not pass the 3.25% threshold and receive no Knesset seats.'},
    'whatsapp_share_btn': {AppLanguage.hebrew: 'שתפו את החברים', AppLanguage.english: 'Share with Friends'},
    'whatsapp_share_text': {AppLanguage.hebrew: 'תארו לכם שיכולנו להצביע דרך הטלפון! 📱 הצבעתי בקלפי הווירטואלית - בואו להשפיע ולראות את תוצאות האמת בלייב 🗳️ https://bhirot2026.web.app', AppLanguage.english: 'Imagine if we could vote from our phones! 📱 I just voted in the Virtual Ballot - cast your vote and see live results 🗳️ https://bhirot2026.web.app'},
    'party_platform_label': {AppLanguage.hebrew: 'תקציר המצע:', AppLanguage.english: 'Platform Summary:'},
    'party_leaders_label': {AppLanguage.hebrew: 'מובילי הרשימה:', AppLanguage.english: 'Key Figures:'},
    'official_links_section': {AppLanguage.hebrew: 'משאבים, מצע וקישורים רשמיים', AppLanguage.english: 'Official Resources, Platform & Links'},
    'link_platform_title': {AppLanguage.hebrew: 'מצע המפלגה הרשמי', AppLanguage.english: 'Official Party Platform'},
    'link_platform_sub': {AppLanguage.hebrew: 'חזון, עקרונות ותוכניות פעולה לכנסת ה-26', AppLanguage.english: 'Vision, core principles, and 2026 plans'},
    'link_candidates_title': {AppLanguage.hebrew: 'רשימת המועמדים לכנסת', AppLanguage.english: 'Official Candidates List'},
    'link_candidates_sub': {AppLanguage.hebrew: 'רשימת המועמדים המאושרת (PDF מאתר המכון לדמוקרטיה)', AppLanguage.english: 'Verified candidate list (PDF via IDI)'},
    'link_haba_bator_title': {AppLanguage.hebrew: 'מי נכנס במנדט הבא? (הבא בתור)', AppLanguage.english: 'Who enters next? (Next in Line)'},
    'link_haba_bator_sub': {AppLanguage.hebrew: 'סימולטור: מי המועמד הבא שייכנס לכנסת אם המפלגה תתחזק', AppLanguage.english: 'Simulator: who enters the Knesset with +1 seat'},
    'link_coalition_game_title': {AppLanguage.hebrew: 'משחק הרכבת קואליציה', AppLanguage.english: 'Coalition Builder Game'},
    'link_coalition_game_sub': {AppLanguage.hebrew: 'סימולטור סקרים: בדקו אילו קואליציות אפשריות להקמה', AppLanguage.english: 'Poll simulator: explore possible government coalitions'},
    'link_website_title': {AppLanguage.hebrew: 'אתר הקמפיין הרשמי', AppLanguage.english: 'Official Campaign Website'},
    'link_website_sub': {AppLanguage.hebrew: 'עדכונים שוטפים, פעילים ומידע ישיר מהמפלגה', AppLanguage.english: 'Direct party news, activists, and updates'},
    'link_idi_title': {AppLanguage.hebrew: 'פרופיל המפלגה במכון לדמוקרטיה', AppLanguage.english: 'Party Dossier on IDI'},
    'link_idi_sub': {AppLanguage.hebrew: 'רקע היסטורי, נתונים ומחקר פוליטי מעמיק', AppLanguage.english: 'Political background, statistics, and research'},
    'vote_for_party_modal_btn': {AppLanguage.hebrew: 'הצבע לרשימה זו', AppLanguage.english: 'Vote for this Party'},
    'party_website_label': {AppLanguage.hebrew: 'לאתר הרשמי של המפלגה', AppLanguage.english: 'Official Party Website'},
    'view_candidates_pdf_btn': {AppLanguage.hebrew: 'לרשימת המועמדים (PDF)', AppLanguage.english: 'Candidates List (PDF)'},
    'view_platform_btn': {AppLanguage.hebrew: 'למצע המפלגה', AppLanguage.english: 'Party Platform'},
    'view_idi_page_btn': {AppLanguage.hebrew: 'לעמוד המפלגה במכון לדמוקרטיה', AppLanguage.english: 'Party Profile on IDI'},
    'official_logo_label': {AppLanguage.hebrew: 'לוגו רשמי', AppLanguage.english: 'Official Logo'},
    'coalition_game_badge': {AppLanguage.hebrew: 'סימולטור', AppLanguage.english: 'Simulator'},
    'coalition_game_title': {AppLanguage.hebrew: 'משחק הרכבת קואליציה', AppLanguage.english: 'Coalition Builder Game'},
    'coalition_game_desc': {AppLanguage.hebrew: 'הרכיבו ממשלה בעצמכם בסימולטור הסקרים: בחרו מפלגות, בדקו שילובים וגלו האם תצליחו לחצות את רף 61 המנדטים.', AppLanguage.english: 'Assemble a government yourself in the poll simulator: choose parties, test combinations, and see if you reach the 61-seat majority.'},
    'coalition_game_btn': {AppLanguage.hebrew: 'למשחק הרכבת קואליציה', AppLanguage.english: 'Play Coalition Builder'},
    'try_coalition_game_btn': {AppLanguage.hebrew: 'הרכיבו קואליציה בעצמכם', AppLanguage.english: 'Build a coalition yourself'},
    'haba_bator_badge': {AppLanguage.hebrew: 'הבא בתור +1', AppLanguage.english: 'Next in Line +1'},
    'haba_bator_title': {AppLanguage.hebrew: 'מי נכנס לכנסת אם המפלגה שלך מקבלת עוד מנדט אחד?', AppLanguage.english: 'Who enters the Knesset if your party gets one more seat?'},
    'haba_bator_desc': {AppLanguage.hebrew: 'גלו מי המועמד הבא בתור בכל רשימה על פי תוצאות המנדטים וסדר המועמדים הרשמי.', AppLanguage.english: 'Discover the next candidate in line for each party based on seat counts and official candidate lists.'},
    'haba_bator_btn': {AppLanguage.hebrew: 'למחשבון "הבא בתור"', AppLanguage.english: 'Open "Next in Line"'},
    'voter_guide_search_hint': {AppLanguage.hebrew: 'חפש שאלה או נושא במדריך לבוחר...', AppLanguage.english: 'Search questions or topics in the voter guide...'},
    'voter_guide_source': {AppLanguage.hebrew: 'מקור המידע: המדריך לבוחר לקראת הבחירות לכנסת', AppLanguage.english: 'Source: The Official Voter Guide for the Knesset Elections'},
    'total_voters_counted': {AppLanguage.hebrew: '', AppLanguage.english: ''},
    'percent_of_votes': {AppLanguage.hebrew: 'מסך הקולות', AppLanguage.english: 'of total votes'},
    'educational_disclaimer': {AppLanguage.hebrew: 'הדמיה חיה של קולות המדגם: אתר זה הינו סקר וסימולטור ציבורי ואינו מהווה תחליף להצבעה בקלפי האמיתית. צאו להצביע!', AppLanguage.english: 'Live simulation of sample votes: This site is a public poll & simulator and does not replace official voting on election day. Go out and vote!'},
    'footer_copyright': {AppLanguage.hebrew: 'האתר נוצר למטרות חינוכיות בלבד ואינו מחליף הצבעה אמיתית. צאו להצביע! | GitHub', AppLanguage.english: 'Created for educational purposes only. Does not replace actual voting. Go vote! | GitHub'},
    'find_polling_station_title': {AppLanguage.hebrew: 'רוצה לדעת איפה הקלפי שלך?', AppLanguage.english: 'Want to know where your polling station is?'},
    'find_polling_station_subtitle': {AppLanguage.hebrew: 'בדיקת מיקום הקלפי המדויק שלך במרשם הבוחרים הרשמי של משרד הפנים (gov.il)', AppLanguage.english: 'Find your official polling station location in the Ministry of Interior registry (gov.il)'},
    'find_polling_station_btn': {AppLanguage.hebrew: 'לבדיקת מיקום הקלפי במשרד הפנים ↗', AppLanguage.english: 'Check on Ministry of Interior (gov.il) ↗'},
    'find_polling_station_badge': {AppLanguage.hebrew: 'שירות ממשלתי רשמי', AppLanguage.english: 'Official Government Service'},
    'legal_terms': {AppLanguage.hebrew: 'תנאי שימוש', AppLanguage.english: 'Terms of Service'},
    'legal_privacy': {AppLanguage.hebrew: 'מדיניות פרטיות', AppLanguage.english: 'Privacy Policy'},
    'legal_disclaimer': {AppLanguage.hebrew: 'הצהרה משפטית', AppLanguage.english: 'Legal Disclaimer'},
  };

  String t(String key) {
    final entry = _strings[key];
    if (entry != null) {
      return entry[language] ?? entry[AppLanguage.hebrew] ?? key;
    }
    return key;
  }

  static String getPartyTranslatedName(String partyId, String defaultName, AppLanguage lang) {
    if (lang == AppLanguage.hebrew) return defaultName;
    const enNames = {
      'likud': 'Likud (Netanyahu)',
      'beyachad': 'Beyachad (Bennett)',
      'yashar': 'Yashar! (Eisenkot)',
      'democrats': 'The Democrats (Yair Golan)',
      'religious_zionism': 'Religious Zionism & Zehut (Smotrich & Feiglin)',
      'otzma_yehudit': 'Otzma Yehudit (Ben Gvir)',
      'shas': 'Shas',
      'yahadut_hatorah': 'United Torah Judaism (UTJ)',
      'yisrael_beytenu': 'Yisrael Beytenu (Liberman)',
      'raam': 'Ra\'am (United Arab List)',
      'joint_list': 'The Joint List',
      'miluimniks': 'The Reservists & Economic Party (Hendel & Zelekha)',
      'amcha_yisrael': 'Amcha Yisrael (Ofer Winter)',
    };
    return enNames[partyId] ?? defaultName;
  }

  static final Random _random = Random();

  List<String> get whatsappShareMessages {
    if (language == AppLanguage.hebrew) {
      return const [
        'תארו לכם שיכולנו להצביע דרך הטלפון! 📱 הצבעתי בקלפי הווירטואלית - בואו להשפיע ולראות את תוצאות האמת בלייב 🗳️ https://bhirot2026.web.app',
        'אני הצבעתי בקלפי הווירטואלית, מה איתך? צאו להשפיע וצפו בתוצאות הבחירות בלייב! 🗳️📊 https://bhirot2026.web.app',
        'צאו להצביע בקלפי הווירטואלית של בחירות 2026! מדגם חי בזמן אמת של מנדטים וגושים 🇮🇱 https://bhirot2026.web.app',
        'צפו בתוצאות הבחירות בלייב בקלפי הווירטואלית! מי מרכיב את הממשלה הבאה? 🏛️⚡ https://bhirot2026.web.app',
        'הקלפי הווירטואלית פתוחה עכשיו! תארו לכם שהיינו מצביעים מהטלפון... הצביעו וראו תוצאות בזמן אמת 🗳️ https://bhirot2026.web.app',
      ];
    } else {
      return const [
        'Imagine if we could vote right from our phones! 📱 I just cast my vote in the Virtual Ballot - join and see live results 🗳️ https://bhirot2026.web.app',
        'I voted in the virtual election booth, what about you? Cast your vote and see live results! 🗳️📊 https://bhirot2026.web.app',
        'Cast your vote in the 2026 Virtual Ballot! Live real-time Knesset seat projections and coalition simulator 🇮🇱 https://bhirot2026.web.app',
        'Watch live election projections in the Virtual Ballot! See who crosses the threshold and forms the government 🏛️⚡ https://bhirot2026.web.app',
        'The Virtual Ballot is open now! Imagine voting from your phone - cast your vote and watch live results 🗳️ https://bhirot2026.web.app',
      ];
    }
  }

  String getRandomWhatsAppShareText([Random? random]) {
    final msgs = whatsappShareMessages;
    final r = random ?? _random;
    return msgs[r.nextInt(msgs.length)];
  }
}
