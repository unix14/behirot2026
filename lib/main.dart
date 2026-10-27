import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/admin_screen.dart';
import 'screens/results_screen.dart';
import 'screens/voting_booth_screen.dart';
import 'services/localization.dart';
import 'services/poll_state.dart';
import 'widgets/app_footer.dart';
import 'widgets/app_icon.dart';
import 'widgets/ballot_slip.dart';
import 'widgets/voter_guide_accordion.dart';
import 'widgets/whatsapp_share_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(
    ChangeNotifierProvider(
      create: (_) => PollState(),
      child: const BehirotApp(),
    ),
  );
}

class BehirotApp extends StatelessWidget {
  const BehirotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<PollState>(context);
    final l10n = state.l10n;

    return MaterialApp(
      title: 'בחירות 2026 | קלפי וירטואלית | bhirot2026',
      navigatorKey: BallotSlipWidget.navigatorKey,
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad, PointerDeviceKind.stylus},
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        primaryColor: const Color(0xFF0D2F6B),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0D2F6B),
          secondary: Color(0xFF1E88E5),
          surface: Colors.white,
          onSurface: Color(0xFF0F172A),
        ),
        textTheme: GoogleFonts.rubikTextTheme(ThemeData.light().textTheme),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) {
        final rawName = settings.name ?? '/';
        final cleanPath = rawName.replaceAll('#/', '/').replaceAll('#', '').split('?').first;
        if (cleanPath == '/admin' || cleanPath == 'admin') {
          return MaterialPageRoute(
            builder: (context) => const AdminScreen(),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (context) => Directionality(textDirection: l10n.textDirection, child: const HomeScreen()),
          settings: settings,
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<PollState>(context);
    final l10n = state.l10n;

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isMobile ? 66 : 76),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0D2F6B),
            boxShadow: [BoxShadow(color: Color(0x26000000), blurRadius: 10, offset: Offset(0, 3))],
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
                    child: Row(
                      children: [
                        // App Icon (Ballot box emoji without background)
                        AppIcon(width: isMobile ? 32 : 38, height: isMobile ? 32 : 38),
                        SizedBox(width: isMobile ? 10 : 14),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.t('app_title'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.rubik(fontSize: isMobile ? 16.5 : 20, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.2),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                l10n.t('app_subtitle'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: isMobile ? 11 : 12, color: const Color(0xFFE2E8F0), fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        // Language toggle button
                        OutlinedButton(
                          onPressed: () => state.toggleLanguage(),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 10, vertical: isMobile ? 4 : 5),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            side: const BorderSide(color: Color(0xFFD4AF37), width: 1.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                          ),
                          child: Text(
                            state.language == AppLanguage.hebrew ? 'EN' : 'עברית',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: isMobile ? 11 : 12),
                          ),
                        ),
                        if (isLocalhost) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => Navigator.of(context).pushNamed('/admin'),
                            tooltip: 'ניהול קלפי (Localhost)',
                            icon: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFD4AF37), size: 22),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Stately Gold Stripe
                Container(height: 3, width: double.infinity, color: const Color(0xFFD4AF37)),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            children: [
              // Stately Segmented Navigation bar
              Container(
                margin: EdgeInsets.fromLTRB(isMobile ? 12 : 16, isMobile ? 8 : 14, isMobile ? 12 : 16, 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildNavTab(
                        context: context,
                        index: 0,
                        label: isMobile ? l10n.t('booth_tab_short') : l10n.t('booth_tab'),
                        icon: Icons.how_to_vote_outlined,
                        isSelected: state.currentTabIndex == 0,
                        onTap: () => state.setTabIndex(0),
                        isMobile: isMobile,
                      ),
                    ),
                    Expanded(
                      child: _buildNavTab(
                        context: context,
                        index: 1,
                        label: isMobile ? l10n.t('results_tab_short') : l10n.t('results_tab'),
                        icon: Icons.pie_chart_outline_rounded,
                        isSelected: state.currentTabIndex == 1,
                        onTap: () => state.setTabIndex(1),
                        isMobile: isMobile,
                      ),
                    ),
                    Expanded(
                      child: _buildNavTab(
                        context: context,
                        index: 2,
                        label: isMobile ? l10n.t('guide_tab_short') : l10n.t('guide_tab'),
                        icon: Icons.menu_book_rounded,
                        isSelected: state.currentTabIndex == 2,
                        onTap: () => state.setTabIndex(2),
                        isMobile: isMobile,
                      ),
                    ),
                  ],
                ),
              ),

              // Active Tab Content
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D2F6B)))
                    : IndexedStack(
                        index: state.currentTabIndex,
                        children: [
                          const VotingBoothScreen(),
                          const ResultsScreen(),
                          SingleChildScrollView(
                            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.menu_book_rounded, color: Color(0xFF0D2F6B), size: 24),
                                    const SizedBox(width: 10),
                                    Text(l10n.t('guide_tab'), style: GoogleFonts.rubik(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                VoterGuideAccordion(l10n: l10n),
                                const SizedBox(height: 24),
                                AppFooter(l10n: l10n, showEducationalBanner: true),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),

              // Sticky WhatsApp Share Bar visible on ALL 3 toggle states!
              WhatsAppShareBar(l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavTab({required BuildContext context, required int index, required String label, required IconData icon, required bool isSelected, required VoidCallback onTap, bool isMobile = false}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: isMobile ? 8.5 : 10.5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D2F6B) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? const [BoxShadow(color: Color(0x330D2F6B), blurRadius: 6, offset: Offset(0, 2))] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isMobile ? 16 : 18, color: isSelected ? Colors.white : const Color(0xFF475569)),
            SizedBox(width: isMobile ? 5 : 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: isMobile ? 12 : 13.5, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.white : const Color(0xFF475569)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
