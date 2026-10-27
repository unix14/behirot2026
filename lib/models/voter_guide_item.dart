import 'package:flutter/material.dart';

class VoterGuideItem {
  final String id;
  final String questionHe;
  final String questionEn;
  final String answerHe;
  final String answerEn;
  final IconData icon;

  const VoterGuideItem({required this.id, required this.questionHe, required this.questionEn, required this.answerHe, required this.answerEn, required this.icon});

  static const List<VoterGuideItem> allItems = [
    VoterGuideItem(
      id: 'where_vote',
      questionHe: 'איפה אני מצביע?',
      questionEn: 'Where do I vote?',
      answerHe: 'כל בוחר משויך לקלפי מסוימת בהתאם לכתובת הרשומה במרשם האוכלוסין. ניתן לאתר את הקלפי המדויקת באמצעות השירות הממשלתי לאיתור מקום קלפי או באתר ועדת הבחירות המרכזית. ה"הודעה לבוחר" כוללת את מספר הקלפי והכתובת, אך אין חובה להביאה לקלפי והיא אינה מהווה אמצעי זיהוי.',
      answerEn: 'Every voter is assigned to a specific polling station based on their address in the Population Registry. You can locate your exact station using the government polling station locator or the Central Elections Committee website. The "Voter Notice" contains your polling station number and address, but you are not required to bring it and it does not serve as an ID.',
      icon: Icons.location_on_outlined,
    ),
    VoterGuideItem(
      id: 'change_station',
      questionHe: 'אפשר להחליף קלפי?',
      questionEn: 'Can I vote at a different polling station?',
      answerHe: 'ברוב המקרים לא. החוק קובע שכל בוחר מצביע אך ורק בקלפי שאליה הוא משויך, ואי אפשר לבחור קלפי אחרת מטעמי נוחות או קרבה לעבודה. החריגים הקבועים בחוק כוללים: חיילים, שוטרים, מאושפזים בבתי חולים, אסירים ובוחרים המוגבלים בניידות (המצביעים במעטפה כפולה).',
      answerEn: 'In most cases, no. By law, voters must vote exclusively at their designated station, not at any station closer to work or home. Exceptions apply to soldiers, police officers, hospitalized patients, prisoners, and voters with mobility disabilities (who vote using a double envelope).',
      icon: Icons.swap_horiz_rounded,
    ),
    VoterGuideItem(
      id: 'double_envelope',
      questionHe: 'מה זה בכלל "מעטפה כפולה"?',
      questionEn: 'What is a "Double Envelope"?',
      answerHe: 'כאשר בוחר מצביע שלא בקלפי המקורית שלו (למשל חיילים או מוגבלי ניידות), פתק ההצבעה מוכנס למעטפה רגילה, וזו מוכנסת למעטפה חיצונית שעליה נרשמים פרטי הבוחר. ועדת הבחירות בודקת שהבוחר לא הצביע פעמיים, מפרידה לחלוטין את המעטפה הפנימית מהחיצונית, וסופרת את הקול בחשאיות מלאה.',
      answerEn: 'When voting away from your designated station (e.g. soldiers or individuals with mobility impairments), your ballot is placed inside a standard envelope, which is then sealed inside an outer envelope with your identifying details. The Elections Committee verifies you did not vote twice, detaches the outer envelope to ensure complete ballot secrecy, and counts the vote.',
      icon: Icons.mark_email_read_outlined,
    ),
    VoterGuideItem(
      id: 'hospitalized',
      questionHe: 'אני חולה או מאושפז ביום הבחירות. מה עושים?',
      questionEn: 'What if I am sick or hospitalized on election day?',
      answerHe: 'בוחר המאושפז בבית חולים ביום הבחירות רשאי להצביע בקלפי למאושפזים בבית החולים שבו הוא שוהה, בהצגת אישור אשפוז ותעודה מזהה (הקלפיות בבתי חולים פועלות בין 08:00 ל-20:00). מי שנמצא באשפוז יום או חולה בבית אינו זכאי להצבעה בקלפי מאושפזים ומצביע בקלפי הרגילה שלו.',
      answerEn: 'A voter hospitalized on Election Day may vote at a special hospital polling station by presenting a hospitalization confirmation and an ID (hospital stations operate from 08:00 to 20:00). Day-hospitalization patients and those recovering at home must vote at their standard polling station.',
      icon: Icons.local_hospital_outlined,
    ),
    VoterGuideItem(
      id: 'disability_accessible',
      questionHe: 'ומה אם אני אדם עם מוגבלות?',
      questionEn: 'What if I have a disability or mobility impairment?',
      answerHe: 'בוחרים המוגבלים בניידות שאינם יכולים להגיע לקלפי המשויכת להם זכאים להצביע בכל "קלפי נגישה מיוחדת" באמצעות מעטפה כפולה (אם המוגבלות אינה ניכרת, חותמים על הצהרה). בוחר שאינו מסוגל פיזית לבצע את ההצבעה בעצמו רשאי להיעזר במלווה מאחורי הפרגוד (למעט מנהל/עובד מוסד האשפוז, ומלווה אחד לעד 2 בוחרים).',
      answerEn: 'Voters with mobility limitations unable to access their assigned station may vote at any specially designated accessible polling station using a double envelope. A voter physically incapable of placing the ballot may be accompanied behind the partition by an assistant (who may assist up to two voters, excluding hospital/care facility staff).',
      icon: Icons.accessible_forward_rounded,
    ),
    VoterGuideItem(
      id: 'voting_hours',
      questionHe: 'עד מתי אפשר להצביע? מהן שעות הפתיחה?',
      questionEn: 'What are the voting hours?',
      answerHe: 'במרבית הקלפיות ההצבעה נפתחת בשעה 07:00 ונסגרת בשעה 22:00. ביישובים קטנים (עד 350 בעלי זכות בחירה), בבתי חולים ובבתי סוהר, שעות ההצבעה הן 08:00 עד 20:00.',
      answerEn: 'At most polling stations, voting opens at 07:00 and closes at 22:00. In smaller localities (up to 350 eligible voters), hospitals, and correctional facilities, polling hours are 08:00 to 20:00.',
      icon: Icons.access_time_filled_rounded,
    ),
    VoterGuideItem(
      id: 'last_minute',
      questionHe: 'מה קורה אם הגעתי לקלפי ממש ברגע האחרון?',
      questionEn: 'What happens if I arrive at the polling station at the last minute?',
      answerHe: 'החוק קובע במפורש: מי שהגיע למתחם הקלפי לפני שעת הסגירה (22:00) זכאי להצביע, גם אם נוצר תור וההצבעה בפועל מתעכבת מעבר לשעת הסגירה. לא ישלחו אתכם הביתה אם הגעתם בזמן!',
      answerEn: 'The law clearly stipulates: Any voter who arrives at the polling place before closing time (22:00) is legally entitled to cast their vote, even if a queue forms and voting takes place after the closing hour.',
      icon: Icons.hourglass_bottom_rounded,
    ),
    VoterGuideItem(
      id: 'work_on_election_day',
      questionHe: 'אני עובד ביום הבחירות. אני עדיין יכול להצביע?',
      questionEn: 'I am working on election day. Can I still vote?',
      answerHe: 'כן בהחלט. יום הבחירות לכנסת הוא יום שבתון רשמי. במקומות עבודה הפועלים כסדרם (שירותי חירום, תחבורה וכו\'), על המעסיק חלה חובה חוקית לאפשר לכל עובד לצאת בשעות העבודה ולממש את זכות ההצבעה.',
      answerEn: 'Yes, absolutely. Knesset Election Day is an official national holiday (Shabbaton). In workplaces authorized to operate (emergency services, transport, etc.), employers are legally obligated to allow employees time off during work hours to cast their vote.',
      icon: Icons.work_outline_rounded,
    ),
    VoterGuideItem(
      id: 'lost_id',
      questionHe: 'איבדתי את תעודת הזהות. איך אפשר להזדהות?',
      questionEn: 'I lost my National ID card. What documents can I use?',
      answerHe: 'ניתן להצביע גם ללא תעודת זהות באמצעות אחד מהמסמכים הבאים בתוקף: רישיון נהיגה ישראלי בתוקף עם תמונה, דרכון ישראלי בתוקף, או תעודת חוגר / קצין צבאית אישית בתוקף. שימו לב: הודעה לבוחר אינה מהווה אמצעי זיהוי.',
      answerEn: 'You can vote without a Teudat Zehut by presenting one of the following valid photo IDs: a valid Israeli driver\'s license, a valid Israeli passport, or a valid military ID card (Hoger/Officer). Note: The voter notification slip cannot be used as an identification document.',
      icon: Icons.badge_outlined,
    ),
    VoterGuideItem(
      id: 'slips_in_envelope',
      questionHe: 'כמה פתקים שמים במעטפה?',
      questionEn: 'How many slips go into the ballot envelope?',
      answerHe: 'פתק אחד בלבד! בתא ההצבעה בוחרים את הפתק עם אותיות המפלגה ומכניסים למעטפה. אם הוכנסו בטעות עד 3 פתקים זהים של אותה רשימה, הקול ייספר כקול אחד כשר. אך אם הוכנסו פתקים של רשימות שונות, הקול נפסל מיד.',
      answerEn: 'Exactly one slip! Select the slip carrying the chosen party letters and seal it inside. If up to 3 identical slips for the exact same party are placed by mistake, it is counted as a single valid vote. However, slips for different parties will disqualify the vote completely.',
      icon: Icons.insert_drive_file_outlined,
    ),
    VoterGuideItem(
      id: 'invalid_votes',
      questionHe: 'אילו קולות נפסלים?',
      questionEn: 'Which ballots are considered invalid (disqualified)?',
      answerHe: 'קול ייפסל במקרים הבאים: מעטפה ובה פתקים של רשימות שונות, יותר מ-3 פתקים זהים, פתק ריק לחלוטין (פתק לבן שלא נכתב עליו דבר), פתק או מעטפה שיש עליהם סימן או ציור העלול לזהות את המצביע, מעטפה שאינה רשמית, או חפץ זר שהוכנס לתוך המעטפה.',
      answerEn: 'A ballot is disqualified if: multiple different party slips are in one envelope, more than 3 identical slips are enclosed, a completely blank slip is submitted, any distinguishing mark or scribble that could identify the voter is present, an unauthorized envelope is used, or a foreign object is placed inside.',
      icon: Icons.cancel_outlined,
    ),
    VoterGuideItem(
      id: 'white_slip',
      questionHe: 'מהו מעמדו של "פתק לבן"?',
      questionEn: 'What is the rule regarding a "White Slip"?',
      answerHe: 'פתק לבן ריק לחלוטין הוא קול פסול ואינו נספר כמחאה. פתק לבן נועד אך ורק למקרה שבו אזלו הפתקים המודפסים של מפלגה מסוימת בתא ההצבעה - במצב כזה מותר לכתוב על הפתק הלבן בעט כחול את אותיות הרשימה בלבד.',
      answerEn: 'A completely blank white slip is an invalid vote and is not counted as a protest vote. Blank slips are provided exclusively in case pre-printed party slips have run out — in which case the voter writes the party letters clearly in blue pen.',
      icon: Icons.article_outlined,
    ),
    VoterGuideItem(
      id: 'missing_slip',
      questionHe: 'מה עושים אם הפתק של המפלגה שלי חסר?',
      questionEn: 'What if the slip of my preferred party is missing?',
      answerHe: 'אין לוותר על ההצבעה ולא לבחור במפלגה אחרת! יש לצאת ולפנות למזכיר ועדת הקלפי כדי שימלא את מלאי הפתקים בתא. בנוסף, באפשרותכם לקחת פתק לבן ריק ולכתוב עליו בעט כחול בכתב יד את האות או האותיות המדויקות של המפלגה.',
      answerEn: 'Do not settle or choose another party! Notify the polling committee secretary immediately to restock the compartment. Alternatively, you may take a blank white slip and write the official approved party letters by hand using a blue pen.',
      icon: Icons.search_off_rounded,
    ),
    VoterGuideItem(
      id: 'wrinkled_slip',
      questionHe: 'הפתק התקמט. האם הקול נפסל?',
      questionEn: 'The paper slip got crumpled. Is my vote disqualified?',
      answerHe: 'לא בהכרח. קימוט או קיפול מקרי אינם עילת פסילה אוטומטית. עם זאת, קיפול בעל תבנית מכוונת או סימון חריג עלולים להיחשב סימן מזהה ולהביא לפסילה על ידי ועדת הקלפי. מומלץ לקחת פתק חלק ונקי כדי למנוע ספק.',
      answerEn: 'Not necessarily. Accidental creasing or slight folding is not grounds for automatic disqualification. However, intentional origami-like folds or distinguishing markings may be deemed identifying signs by the committee. It is always safest to pick a crisp, clean slip.',
      icon: Icons.note_rounded,
    ),
    VoterGuideItem(
      id: 'envelope_sealing',
      questionHe: 'האם חייבים להדביק את המעטפה?',
      questionEn: 'Do I have to seal/glue the envelope?',
      answerHe: 'לא! אין כל חובה חוקית להדביק את מעטפת ההצבעה, ואסור למזכיר הקלפי לדרוש זאת מכם. פשוט מכניסים את הפתק למעטפה כך שלא יבצבץ החוצה ומשלשלים לקלפי.',
      answerEn: 'No! There is no legal obligation to glue or wet-seal the ballot envelope, and the election committee cannot demand you do so. Simply place the slip neatly inside so it does not protrude.',
      icon: Icons.drafts_outlined,
    ),
    VoterGuideItem(
      id: 'final_step',
      questionHe: 'איך מסיימים את ההצבעה?',
      questionEn: 'How is the voting process completed?',
      answerHe: 'לאחר בחירת הפתק מאחורי הפרגוד והכנסתו למעטפה, יוצאים חזרה אל ועדת הקלפי ומשלשלים בעצמכם את המעטפה לתוך חריץ תיבת הקלפי הכחולה. מקבלים בחזרה את תעודת הזהות ומשם הדרך פתוחה לחגוג את יום השבתון!',
      answerEn: 'After choosing your slip behind the partition and placing it in the envelope, step out to the committee table and drop the envelope yourself into the blue ballot box slot. Retrieve your ID document, and your civic duty is complete!',
      icon: Icons.how_to_vote_rounded,
    ),
    VoterGuideItem(
      id: 'counting_and_results',
      questionHe: 'מתי סופרים את הקולות ומתי מתפרסמות התוצאות?',
      questionEn: 'When are votes counted and when are results published?',
      answerHe: 'ספירת הקולות מתחילה מיד עם סגירת הקלפיות ב-22:00 בלילה. תוצאות ראשוניות מתפרסמות במהלך הלילה והבוקר שלמחרת. ספירת המעטפות הכפולות נמשכת בימים הבאים, והתוצאות הרשמיות והסופיות מאושרות ומפורסמות ברשומות בתוך 8 ימים מיום הבחירות.',
      answerEn: 'Vote counting commences immediately when polling stations close at 22:00. Preliminary results emerge through the night and following morning. Double envelopes are verified and tallied over subsequent days, with official results finalized within 8 days.',
      icon: Icons.analytics_outlined,
    ),
  ];
}
