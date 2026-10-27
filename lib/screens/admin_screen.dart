import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/poll_state.dart';

@visibleForTesting
bool? isLocalhostOverride;

bool get isLocalhost {
  if (isLocalhostOverride != null) return isLocalhostOverride!;
  if (kIsWeb) {
    final host = Uri.base.host.toLowerCase();
    return host == 'localhost' || host == '127.0.0.1' || host == '0.0.0.0' || host.startsWith('192.168.') || host.endsWith('.local');
  }
  return !kReleaseMode;
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String? _selectedPartyId;
  final TextEditingController _countController = TextEditingController(text: '50');
  bool _isSimulated = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isLocalhost) {
        final state = Provider.of<PollState>(context, listen: false);
        state.loadAdminStats();
      }
    });
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLocalhost) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.gpp_bad_rounded, color: Color(0xFFDC2626), size: 56),
                const SizedBox(height: 16),
                Text('403 - גישה חסומה', style: GoogleFonts.rubik(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                const SizedBox(height: 10),
                const Text(
                  'עמוד הניהול מוגבל אך ורק לסביבת פיתוח מקומית (localhost) ואינו נגיש בפרודקשן.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('חזרה לקלפי הראשית'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D2F6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final state = Provider.of<PollState>(context);
    final stats = state.adminStats;
    final parties = state.parties;

    if (_selectedPartyId == null && parties.isNotEmpty) {
      _selectedPartyId = parties.keys.first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
          tooltip: 'חזרה לקלפי',
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(6)),
              child: const Text('DEV ONLY', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 11)),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'פאנל ניהול קלפי 2026',
                style: GoogleFonts.rubik(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: state.isLoadingAdminStats
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: state.isLoadingAdminStats ? null : () => state.loadAdminStats(),
            tooltip: 'רענן נתונים',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Localhost Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.security_rounded, color: Color(0xFFB45309), size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'עמוד זה פעיל אך ורק בסביבת Localhost. הוא חסום לחלוטין בפרודקשן (web.app). הנתונים מסונכרנים ישירות מול Firebase Realtime Database.',
                            style: GoogleFonts.rubik(fontSize: 13, color: const Color(0xFF92400E), height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Top Stats Cards (Responsive)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 600;
                      final displayedTotalVotes = stats.totalAggregateVotes > 0 ? stats.totalAggregateVotes : state.votesAggregate.values.fold(0, (a, b) => a + b);
                      final displayedRealVotes = stats.realVotesCount;
                      final displayedSimVotes = stats.simulatedVotesCount > 0 ? stats.simulatedVotesCount : (displayedTotalVotes - displayedRealVotes);
                      final realPercentage = displayedTotalVotes > 0 ? (displayedRealVotes / displayedTotalVotes * 100) : 0.0;
                      final simPercentage = displayedTotalVotes > 0 ? (displayedSimVotes / displayedTotalVotes * 100) : 0.0;
                      if (isNarrow) {
                        return Column(
                          children: [
                            _buildMetricCard(
                              title: 'סה"כ קולות בקלפי',
                              value: '$displayedTotalVotes',
                              subtitle: 'סך כל הקולות ב-RTDB',
                              color: const Color(0xFF0D2F6B),
                              icon: Icons.how_to_vote_rounded,
                            ),
                            const SizedBox(height: 12),
                            _buildMetricCard(
                              title: 'קולות אמיתיים',
                              value: '$displayedRealVotes',
                              subtitle: '${realPercentage.toStringAsFixed(1)}% מכלל המצביעים',
                              color: const Color(0xFF059669),
                              icon: Icons.person_rounded,
                            ),
                            const SizedBox(height: 12),
                            _buildMetricCard(
                              title: 'קולות סימולציה / סיד',
                              value: '$displayedSimVotes',
                              subtitle: '${simPercentage.toStringAsFixed(1)}% סיד וירטואלי',
                              color: const Color(0xFF6366F1),
                              icon: Icons.smart_toy_rounded,
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: 'סה"כ קולות בקלפי',
                              value: '$displayedTotalVotes',
                              subtitle: 'סך כל הקולות ב-RTDB',
                              color: const Color(0xFF0D2F6B),
                              icon: Icons.how_to_vote_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              title: 'קולות אמיתיים',
                              value: '$displayedRealVotes',
                              subtitle: '${realPercentage.toStringAsFixed(1)}% מכלל המצביעים',
                              color: const Color(0xFF059669),
                              icon: Icons.person_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              title: 'קולות סימולציה / סיד',
                              value: '$displayedSimVotes',
                              subtitle: '${simPercentage.toStringAsFixed(1)}% סיד וירטואלי',
                              color: const Color(0xFF6366F1),
                              icon: Icons.smart_toy_rounded,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Batch Vote Generator Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 3))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: const Color(0xFF0D2F6B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.add_chart_rounded, color: Color(0xFF0D2F6B), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Text('הזרקת קולות למפלגה (Batch Injection)', style: GoogleFonts.rubik(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Party Selector
                        Text('בחר מפלגה:', style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            color: const Color(0xFFF8FAFC),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedPartyId,
                              isExpanded: true,
                              items: parties.values.map((p) {
                                return DropdownMenuItem<String>(
                                  value: p.id,
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: p.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                        child: Text(p.ballotLetter, style: TextStyle(fontWeight: FontWeight.bold, color: p.color, fontSize: 13)),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(child: Text(p.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedPartyId = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Vote Count Chips
                        Text('כמות קולות להוספה:', style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [1, 10, 50, 100, 250, 500, 1000].map((countVal) {
                            final isSelected = _countController.text == countVal.toString();
                            return ChoiceChip(
                              label: Text('+$countVal', style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF1E293B))),
                              selected: isSelected,
                              selectedColor: const Color(0xFF0D2F6B),
                              backgroundColor: const Color(0xFFF1F5F9),
                              onSelected: (_) {
                                setState(() => _countController.text = countVal.toString());
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        // Custom count field
                        TextField(
                          controller: _countController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            labelText: 'כמות מותאמת אישית',
                            prefixIcon: const Icon(Icons.numbers_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Simulated Toggle
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('סמן כקולות סימולציה (sim: true)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: const Text('שומר על הפרדה בין קולות מצביעים חיים לבין סימולציה', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          value: _isSimulated,
                          activeColor: const Color(0xFF0D2F6B),
                          onChanged: (val) => setState(() => _isSimulated = val),
                        ),
                        const SizedBox(height: 16),
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: (state.isCastingBatchVotes || _selectedPartyId == null)
                                ? null
                                : () async {
                                    final count = int.tryParse(_countController.text) ?? 0;
                                    if (count <= 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('נא להזין כמות קולות חיובית')));
                                      return;
                                    }
                                    final partyName = parties[_selectedPartyId]?.name ?? _selectedPartyId!;
                                    final success = await state.castBatchVotes(
                                      partyId: _selectedPartyId!,
                                      count: count,
                                      isSimulated: _isSimulated,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(success ? 'נוספו בהצלחה $count קולות ל$partyName!' : 'שגיאה בהוספת קולות ל-RTDB'),
                                          backgroundColor: success ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                        ),
                                      );
                                    }
                                  },
                            icon: state.isCastingBatchVotes
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.send_rounded, size: 18),
                            label: Text(
                              state.isCastingBatchVotes ? 'מזרים קולות...' : 'הזרק קולות עכשיו ל-RTDB',
                              style: GoogleFonts.rubik(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D2F6B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Per-Party Breakdown Table
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 3))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'פילוח קולות לפי מפלגה בזמן אמת',
                                style: GoogleFonts.rubik(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${parties.length} מפלגות רשומות', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...parties.values.map((party) {
                          final totalPartyVotes = (stats.partyVotes[party.id] != null && stats.partyVotes[party.id]! > 0) ? stats.partyVotes[party.id]! : (state.votesAggregate[party.id] ?? 0);
                          final realPartyVotes = stats.partyRealVotes[party.id] ?? 0;
                          final simPartyVotes = stats.partySimulatedVotes[party.id] ?? (totalPartyVotes - realPartyVotes);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: party.color.withValues(alpha: 0.3))),
                                  child: Center(
                                    child: Text(party.ballotLetter, style: GoogleFonts.frankRuhlLibre(fontWeight: FontWeight.bold, color: party.color, fontSize: 15)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(party.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 12,
                                        children: [
                                          Text('סה"כ: $totalPartyVotes', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: Color(0xFF0D2F6B))),
                                          Text('אמיתיים: $realPartyVotes', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: Color(0xFF059669))),
                                          Text('סימולציה: $simPartyVotes', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12.5, color: Color(0xFF64748B))),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Quick +10 button
                                TextButton(
                                  onPressed: state.isCastingBatchVotes
                                      ? null
                                      : () async {
                                          await state.castBatchVotes(partyId: party.id, count: 10, isSimulated: true);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('+10 קולות נוספו ל${party.name}')));
                                          }
                                        },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    backgroundColor: const Color(0xFFEEF2FF),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('+10', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), fontSize: 12)),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Reset Local Voter Status Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.restart_alt_rounded, color: Color(0xFFDC2626), size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('איפוס סטטוס הצבעה של המחשב הנוכחי', style: GoogleFonts.rubik(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF991B1B))),
                              const SizedBox(height: 4),
                              const Text('מאפשר לבדוק את תהליך ההצבעה מחדש מבלי למחוק עוגיות או היסטוריה.', style: TextStyle(fontSize: 12.5, color: Color(0xFF7F1D1D))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            await state.resetMyVote();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ההצבעה המקומית אופסה בהצלחה! ניתן להצביע שוב בקלפי.')));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('אפס הצבעה'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.rubik(fontSize: 26, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 11.5, color: color, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
