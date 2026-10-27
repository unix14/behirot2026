import 'dart:async';
import 'package:flutter/material.dart';
import '../models/admin_stats.dart';
import '../models/party.dart';
import 'electoral_calculator.dart';
import 'firebase_service.dart';
import 'localization.dart';

class PollState extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService.instance;

  bool _isLoading = true;
  bool _hasVoted = false;
  AppLanguage _language = AppLanguage.hebrew;
  int _currentTabIndex = 0; // 0 = Booth/Locked, 1 = Results, 2 = Q&A

  Map<String, dynamic> _config = {};
  Map<String, Party> _parties = {};
  Map<String, int> _votesAggregate = {};
  ElectoralResult _electoralResult = ElectoralResult.empty();

  Party? _selectedPartyForConfirmation;
  bool _isSubmittingVote = false;

  AdminStats _adminStats = AdminStats.empty();
  bool _isLoadingAdminStats = false;
  bool _isCastingBatchVotes = false;

  StreamSubscription? _configSub;
  StreamSubscription? _partiesSub;
  StreamSubscription? _votesSub;
  Timer? _countdownTimer;

  bool get isLoading => _isLoading;
  bool get hasVoted => _hasVoted;
  AppLanguage get language => _language;
  AppLocalization get l10n => AppLocalization(_language);
  int get currentTabIndex => _currentTabIndex;

  Map<String, dynamic> get config => _config;
  Map<String, Party> get parties => _parties;
  Map<String, int> get votesAggregate => _votesAggregate;
  ElectoralResult get electoralResult => _electoralResult;
  Party? get selectedPartyForConfirmation => _selectedPartyForConfirmation;
  bool get isSubmittingVote => _isSubmittingVote;

  AdminStats get adminStats => _adminStats;
  bool get isLoadingAdminStats => _isLoadingAdminStats;
  bool get isCastingBatchVotes => _isCastingBatchVotes;

  PollState() {
    _init();
  }

  Future<void> _init() async {
    _loadDefaultParties();
    try {
      await _firebaseService.initialize();
      _hasVoted = await _firebaseService.hasUserVoted();
      if (_hasVoted) {
        _currentTabIndex = 1; // Direct to results if already voted
      }

      _configSub = _firebaseService.configStream().listen((conf) {
        _config = conf;
        notifyListeners();
      });

      _partiesSub = _firebaseService.partiesStream().listen((partiesMap) {
        if (partiesMap.isNotEmpty) {
          _parties = partiesMap;
          _recalculate();
        }
      });

      _votesSub = _firebaseService.votesAggregateStream().listen((votesMap) {
        if (votesMap.isNotEmpty) {
          _votesAggregate = votesMap;
          _recalculate();
          loadAdminStats();
        }
      });

      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        notifyListeners();
      });
    } catch (e) {
      debugPrint('PollState._init exception: $e');
    } finally {
      _isLoading = false;
      _recalculate();
    }
  }

  void _loadDefaultParties() {
    _parties = {
      'likud': const Party(id: 'likud', ballotLetter: 'מחל', name: 'הליכוד בהנהגת בנימין נתניהו לראשות הממשלה', platform: 'מפלגת שלטון לאומית-ליברלית. ביטחון לאומי, כלכלת שוק חופשי, ריבונות וחיזוק מעמד ישראל בעולם.', website: 'https://likud.org.il', platformUrl: 'https://www.likud.org.il/#values', candidatesPdfUrl: 'https://www.idi.org.il/media/32314/הליכוד.pdf', idiUrl: 'https://www.idi.org.il/policy/parties-and-elections/parties/likud/', logoUrl: 'https://www.idi.org.il/media/31362/הליכוד-לוגו-1290-על-860.png', keyFigures: ['בנימין נתניהו', 'יואב קיש', 'אמיר אוחנה', 'יריב לוין', 'אלי כהן'], bloc: PartyBloc.coalition, color: Color(0xFF1565C0)),
      'beyachad': const Party(id: 'beyachad', ballotLetter: 'רק', name: 'ביחד בראשות נפתלי בנט', platform: 'רשימת מרכז-ימין מאחדת. שיקום הכלכלה, ביטחון לאומי יציב, אחדות חברתית והסכמות רחבות.', website: 'https://be-yahad.org.il', platformUrl: 'https://be-yahad.org.il/plans/?bennett_plans_cat=198%2C199%2C203%2C204', candidatesPdfUrl: 'https://www.idi.org.il/media/32309/ביחד.pdf', idiUrl: 'https://www.idi.org.il/policy/parties-and-elections/parties/beyachad/', logoUrl: 'https://www.idi.org.il/media/32300/ביחד-לוגו-1290-על-860.png', keyFigures: ['נפתלי בנט', 'יאיר לפיד', 'מתן כהנא', 'מירב כהן'], bloc: PartyBloc.opposition, color: Color(0xFF0284C7)),
      'yashar': const Party(id: 'yashar', ballotLetter: 'דרך', name: 'ישר! עם איזנקוט לראשות הממשלה מאחדים את ישראל', platform: 'ממלכתיות, יושרה ציבורית, תפיסת ביטחון לאומית כוללת וחיזוק השירות והשוויון בנטל.', website: 'https://yasharwitheisenkot.com', platformUrl: 'https://yasharwitheisenkot.com/principles/', candidatesPdfUrl: 'https://www.idi.org.il/media/32324/ישר.pdf', idiUrl: 'https://www.idi.org.il/policy/parties-and-elections/parties/yashar/', logoUrl: 'https://www.idi.org.il/media/30812/ישר-לוגו-1290-על-860.png', keyFigures: ['גדי איזנקוט', 'חילי טרופר', 'אורית פרקש-הכהן', 'מתן וילנאי'], bloc: PartyBloc.opposition, color: Color(0xFF2563EB)),
      'democrats': const Party(id: 'democrats', ballotLetter: 'אמת', name: 'הדמוקרטים בראשות יאיר גולן', platform: 'איחוד העבודה ומרצ. שמאל ציוני ודמוקרטי, עצמאות מערכת המשפט, צדק חברתי, שוויון ושלום.', website: 'https://democrats.org.il', platformUrl: 'https://yes.democrats.org.il', candidatesPdfUrl: 'https://www.idi.org.il/media/32313/הדמוקרטים.pdf', idiUrl: 'https://www.idi.org.il/policy/parties-and-elections/parties/democrats/', logoUrl: 'https://www.idi.org.il/media/32301/הדמוקרטים-לוגו-1290-על-860.png', keyFigures: ['יאיר גולן', 'גלעד קריב', 'נעמה לזימי', 'מוסי רז'], bloc: PartyBloc.opposition, color: Color(0xFFDC2626)),
      'religious_zionism': const Party(id: 'religious_zionism', ballotLetter: 'ט', name: 'הציונות הדתית וזהות בראשות סמוטריץ ופייגלין', platform: 'ימין אידאולוגי דתי-לאומי. שלמות הארץ, חיזוק ההתיישבות, זהות יהודית ורפורמות כלכליות.', website: 'https://zionutdatit.org.il', platformUrl: 'https://zionutdatit.org.il/%D7%9E%D7%A6%D7%A2-%D7%94%D7%9E%D7%A4%D7%9C%D7%92%D7%94/', candidatesPdfUrl: 'https://www.idi.org.il/media/32318/הציונות-הדתית.pdf', idiUrl: 'https://www.idi.org.il/policy/parties-and-elections/parties/the-religious-zionism/', logoUrl: 'https://www.idi.org.il/media/32302/הציונות-הדתית-לוגו-1290-על-860.png', keyFigures: ['בצלאל סמוטריץ', 'משה פייגלין', 'אופיר סופר', 'אורית סטרוק', 'שמחה רוטמן'], bloc: PartyBloc.coalition, color: Color(0xFF0284C7)),
      'otzma_yehudit': const Party(id: 'otzma_yehudit', ballotLetter: 'ב', name: 'עוצמה יהודית בראשות איתמר בן גביר', platform: 'ימין לאומי תקיף. משילות, ביטחון פנים, שינוי הוראות פתיחה באש וחיזוק הריבונות.', website: 'https://ozma-yehudit.com', platformUrl: 'https://ozma-yehudit.com', candidatesPdfUrl: 'https://www.idi.org.il/media/32332/עוצמה-יהודית.pdf', idiUrl: 'https://www.idi.org.il/policy/parties-and-elections/parties/otzma-yehudit/', logoUrl: 'https://www.idi.org.il/media/30814/עוצמה-יהודית-לוגו-1290-על-860.png', keyFigures: ['איתמר בן גביר', 'יצחק וסרלאוף', 'אלמוג כהן', 'צביקה פוגל'], bloc: PartyBloc.coalition, color: Color(0xFFC0392B)),
      'shas': const Party(id: 'shas', ballotLetter: 'שס', name: 'ש״ס התאחדות הספרדים', platform: 'תנועה ספרדית תורנית. ערבות הדדית, סיוע סוציאלי לשכבות החלשות, מסורת ישראל וחינוך תורני.', website: 'https://shas.org.il', platformUrl: 'https://shas.org.il', candidatesPdfUrl: 'https://www.idi.org.il/media/32339/שס.pdf', idiUrl: 'https://www.idi.org.il/policy/parties-and-elections/parties/shas/', logoUrl: 'https://www.idi.org.il/media/30815/שס-לוגו-1290-על-860.png', keyFigures: ['אריה דרעי', 'יעקב מרגי', 'מיכאל מלכיאלי', 'חיים ביטון'], bloc: PartyBloc.coalition, color: Color(0xFF334155)),
      'yahadut_hatorah': const Party(id: 'yahadut_hatorah', ballotLetter: 'ג', name: 'יהדות התורה והשבת אגודת ישראל - דגל התורה', platform: 'יהדות חרדית אשכנזית. שימור מעמד לומדי התורה, קדושת השבת, סטטוס-קוו דתי ודיור בר-השגה.', website: 'https://utj.org.il', platformUrl: 'https://utj.org.il', candidatesPdfUrl: 'https://www.idi.org.il/media/32323/יהדות-התורה.pdf', idiUrl: 'https://www.idi.org.il/policy/parties-and-elections/parties/yahadut-hatorah/', logoUrl: 'https://www.idi.org.il/media/30808/יהדות-התורה-לוגו-1290-על-860.png', keyFigures: ['יצחק גולדקנופף', 'משה גפני', 'מאיר פרוש', 'יעקב אשר'], bloc: PartyBloc.coalition, color: Color(0xFF1E3A8A)),
      'yisrael_beytenu': const Party(id: 'yisrael_beytenu', ballotLetter: 'ל', name: 'ישראל ביתנו בראשות ליברמן', platform: 'ימין חילוני וליברלי. שוויון מלא בחובות ובזכויות, גיוס לכולם, ביטחון תקיף וכלכלה צומחת.', website: 'https://beytenu.org.il', platformUrl: 'https://beytenu.org.il/party-platform/', candidatesPdfUrl: 'https://www.idi.org.il/media/32325/ישראל-ביתנו.pdf', idiUrl: 'https://www.idi.org.il/policy/parties-and-elections/parties/yisrael-beytenu/', logoUrl: 'https://www.idi.org.il/media/32299/ישראל-ביתנו-לוגו-1290-על-860.png', keyFigures: ['אביגדור ליברמן', 'עודד פורר', 'יוליה מלינובסקי', 'אלכס קושניר'], bloc: PartyBloc.opposition, color: Color(0xFF0288D1)),
      'raam': const Party(id: 'raam', ballotLetter: 'עם', name: 'רע״מ - הרשימה הערבית המאוחדת', platform: 'השתלבות אזרחית, מאבק בפשיעה ובאלימות בחברה הערבית, תכנון ובנייה ופיתוח תשתיות.', website: 'https://raam.org.il', platformUrl: 'https://raam.org.il', candidatesPdfUrl: 'https://www.idi.org.il/media/32337/רעמ.pdf', idiUrl: 'https://www.idi.org.il/policy/parties-and-elections/parties/raam/', logoUrl: 'https://www.idi.org.il/media/30805/%D7%A8%D7%A2%D7%9E-%D7%9C%D7%95%D7%92%D7%95-1290-%D7%A2%D7%9C-860.png', keyFigures: ['מנסור עבאס', 'וליד טאהא', 'אימאן חטיב-יאסין', 'יאסר חוג\'יראת'], bloc: PartyBloc.undecided, color: Color(0xFF15803D)),
      'joint_list': const Party(id: 'joint_list', ballotLetter: 'ודם', name: 'הרשימה המשותפת (חד״ש-תע״ל-בל״ד)', platform: 'חזית לשלום, שוויון לאומי ואזרחי מלא, סיום הכיבוש, צדק חברתי וזכויות עובדים.', website: 'https://jointlist.org.il', platformUrl: 'https://jointlist.org.il/he/economic-plan/', candidatesPdfUrl: 'https://www.idi.org.il/media/32320/הרשימה-המשותפת.pdf', idiUrl: 'https://www.idi.org.il/policy/parties-and-elections/parties/joint-arab-list/', logoUrl: 'https://www.idi.org.il/media/32482/%D7%94%D7%9E%D7%A9%D7%95%D7%AA%D7%A4%D7%AA-%D7%9C%D7%95%D7%92%D7%95-1290-%D7%A2%D7%9C-860.png', keyFigures: ['איימן עודה', 'אחמד טיבי', 'סאמי אבו שחאדה', 'עאידה תומא סלימאן'], bloc: PartyBloc.opposition, color: Color(0xFFBE185D)),
      'miluimniks': const Party(id: 'miluimniks', ballotLetter: 'די', name: 'המילואימניקים והכלכלית בראשות יועז הנדל וירון זליכה', platform: 'מפלגת משרתי המילואים ויוקר המחיה. עדיפות למשרתים, פירוק מונופולים, ורפורמות כלכליות וחברתיות.', website: 'https://www.themiluimnikim.org.il', platformUrl: 'https://www.themiluimnikim.org.il/platform/#platform-base', candidatesPdfUrl: 'https://www.idi.org.il/media/32315/המילואימניקים-והכלכלית.pdf', idiUrl: 'https://www.idi.org.il/policy/parties-and-elections/parties/miluimniks/', logoUrl: 'https://www.idi.org.il/media/32483/%D7%94%D7%9E%D7%99%D7%9C%D7%95%D7%90%D7%99%D7%9E%D7%A0%D7%99%D7%A7%D7%99%D7%9D-%D7%95%D7%94%D7%9B%D7%9C%D7%9B%D7%9C%D7%99%D7%AA-%D7%9C%D7%95%D7%92%D7%95-1290-%D7%A2%D7%9C-860.png', keyFigures: ['יועז הנדל', 'פרופ\' ירון זליכה', 'הדר מילר'], bloc: PartyBloc.opposition, color: Color(0xFF4D7C0F)),
      'amcha_yisrael': const Party(id: 'amcha_yisrael', ballotLetter: 'ך', name: 'עמך ישראל בראשות עופר וינטר', platform: 'ימין מסורתי חברתי. חיזוק הזהות היהודית, חיזוק הפריפריה, ערבות הדדית ומשילות.', website: 'https://amchaisrael.co.il', platformUrl: 'https://amchaisrael.co.il/foundations', candidatesPdfUrl: 'https://www.idi.org.il/media/32333/עמך-ישראל.pdf', idiUrl: 'https://www.idi.org.il/policy/parties-and-elections/parties/amcha-yisrael/', logoUrl: 'https://www.idi.org.il/media/32290/%D7%A2%D7%9E%D7%9A-%D7%99%D7%A9%D7%A8%D7%90%D7%9C-%D7%9C%D7%95%D7%92%D7%95-1290-%D7%A2%D7%9C-860.png', keyFigures: ['עופר וינטר', 'אסתר ירמיאס', 'עמיחי שיקלי'], bloc: PartyBloc.coalition, color: Color(0xFF7E22CE)),
    };
    _votesAggregate = {'likud': 0, 'beyachad': 0, 'democrats': 0, 'shas': 0, 'yisrael_beytenu': 0, 'otzma_yehudit': 0, 'yahadut_hatorah': 0, 'yashar': 0, 'religious_zionism': 0, 'raam': 0, 'joint_list': 0, 'miluimniks': 0, 'amcha_yisrael': 0};
  }

  void _recalculate() {
    _electoralResult = ElectoralCalculator.calculateSeats(_votesAggregate, partiesMap: _parties);
    notifyListeners();
  }

  // Voting window is active until 22:30 Jerusalem time on October 27, 2026 (20:30 UTC)
  static final DateTime votingDeadlineUtc = DateTime.utc(2026, 10, 27, 20, 30, 0);

  bool get isVotingWindowOpen {
    return DateTime.now().toUtc().isBefore(votingDeadlineUtc);
  }

  Duration get timeUntilWindowCloses {
    final nowUtc = DateTime.now().toUtc();
    if (nowUtc.isAfter(votingDeadlineUtc)) {
      return Duration.zero;
    }
    return votingDeadlineUtc.difference(nowUtc);
  }

  void toggleLanguage() {
    _language = _language == AppLanguage.hebrew ? AppLanguage.english : AppLanguage.hebrew;
    notifyListeners();
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void selectPartyForConfirmation(Party? party) {
    _selectedPartyForConfirmation = party;
    notifyListeners();
  }

  Future<bool> castVote(String partyId) async {
    if (_hasVoted || _isSubmittingVote) return false;
    _isSubmittingVote = true;
    notifyListeners();

    final success = await _firebaseService.submitVote(partyId);
    if (success) {
      _hasVoted = true;
      _votesAggregate[partyId] = (_votesAggregate[partyId] ?? 0) + 1;
      _recalculate();
      loadAdminStats();
      _selectedPartyForConfirmation = null;
      _currentTabIndex = 1; // Transition smoothly to results screen
    }
    _isSubmittingVote = false;
    notifyListeners();
    return success;
  }

  Future<void> loadAdminStats() async {
    _isLoadingAdminStats = true;
    notifyListeners();
    try {
      _adminStats = await _firebaseService.fetchDetailedVoteStats();
      if (_adminStats.totalAggregateVotes == 0 && _votesAggregate.isNotEmpty) {
        final int aggTotal = _votesAggregate.values.fold(0, (a, b) => a + b);
        if (aggTotal > 0) {
          _adminStats = AdminStats(
            totalAggregateVotes: aggTotal,
            realVotesCount: _adminStats.realVotesCount,
            simulatedVotesCount: aggTotal - _adminStats.realVotesCount,
            partyVotes: Map<String, int>.from(_votesAggregate),
            partyRealVotes: _adminStats.partyRealVotes,
            partySimulatedVotes: Map<String, int>.from(_votesAggregate),
          );
        }
      }
    } catch (e) {
      debugPrint('loadAdminStats error: $e');
    } finally {
      _isLoadingAdminStats = false;
      notifyListeners();
    }
  }

  Future<bool> castBatchVotes({required String partyId, required int count, required bool isSimulated}) async {
    _isCastingBatchVotes = true;
    notifyListeners();
    try {
      final success = await _firebaseService.castBatchVotes(partyId: partyId, count: count, isSimulated: isSimulated);
      if (success) {
        await loadAdminStats();
      }
      return success;
    } catch (e) {
      debugPrint('castBatchVotes error: $e');
      return false;
    } finally {
      _isCastingBatchVotes = false;
      notifyListeners();
    }
  }

  Future<void> resetMyVote() async {
    await _firebaseService.resetLocalVoterStatus();
    _hasVoted = false;
    _currentTabIndex = 0;
    notifyListeners();
    await loadAdminStats();
  }

  @visibleForTesting
  void setHasVotedForTesting(bool value) {
    _hasVoted = value;
    notifyListeners();
  }

  @visibleForTesting
  void setIsLoadingForTesting(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _configSub?.cancel();
    _partiesSub?.cancel();
    _votesSub?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
