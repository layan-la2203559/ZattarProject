import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data_store.dart';
import 'l10n.dart';
import 'retro_theme.dart';
import 'sounds.dart';
import 'screens/wallet_screen.dart';
import 'screens/debts_screen.dart';
import 'screens/plan_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: kBg,
    statusBarIconBrightness: Brightness.light,
  ));

  final store = WalletData();
  await store.load();

  runApp(VaultApp(store: store));
}

class VaultApp extends StatefulWidget {
  final WalletData store;
  const VaultApp({super.key, required this.store});

  @override
  State<VaultApp> createState() => _VaultAppState();
}

class _VaultAppState extends State<VaultApp> {
  bool _isArabic = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VAULT-O-MATIC',
      debugShowCheckedModeBanner: false,
      theme: buildRetroTheme(),
      locale: Locale(_isArabic ? 'ar' : 'en'),
      home: HomeShell(
        store: widget.store,
        isArabic: _isArabic,
        onToggleLanguage: () => setState(() => _isArabic = !_isArabic),
      ),
    );
  }
}

// ── Home Shell ─────────────────────────────────────────────────────────────────
class HomeShell extends StatefulWidget {
  final WalletData store;
  final bool isArabic;
  final VoidCallback onToggleLanguage;

  const HomeShell({
    super.key,
    required this.store,
    required this.isArabic,
    required this.onToggleLanguage,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final s = S(widget.isArabic);

    return Directionality(
      textDirection:
          widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: AnimatedBuilder(
        animation: widget.store,
        builder: (context, _) {
          if (!widget.store.loaded) {
            return Scaffold(
              body: Center(
                child: Text(s.loading, style: retroStyle(size: 20)),
              ),
            );
          }

          final store       = widget.store;
          final iOweTotal   = store.iOweTotal;
          final owesMeTotal = store.owesMeTotal;
          final hasLimit    = store.spendingLimit > 0;
          final over        = store.isOverLimit;
          final pct         = store.spendPercent;
          final col         = over ? kRed : pct > 75 ? kYellow : kGreen;
          final blocks      = (pct / 5).round().clamp(0, 20);
          final bar         = '[' + '█' * blocks + '░' * (20 - blocks) + ']';

          final tabs = [s.tabWallet, s.tabDebts, s.tabPlan];

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  // ── Header ───────────────────────────────────────────────────
                  Container(
                    color: kBg,
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              s.subtitle,
                              style: retroStyle(size: 11, color: kDkGreen),
                            ),
                            const SizedBox(height: 2),
                            Text('VAULT-O-MATIC',
                                style: retroStyle(size: 36, color: kGreen)),
                            Text(
                              '══════════════════════════════════',
                              style: retroStyle(size: 12, color: kDim),
                            ),
                          ],
                        ),
                        // Language toggle button
                        Positioned(
                          top: 4,
                          right: widget.isArabic ? null : 10,
                          left: widget.isArabic ? 10 : null,
                          child: GestureDetector(
                            onTap: widget.onToggleLanguage,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: kDkGreen),
                                color: const Color(0xFF0A1A0A),
                              ),
                              child: Text(
                                s.langBtn,
                                style: retroStyle(size: 13, color: kDkGreen),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Balance bar ──────────────────────────────────────────────
                  Container(
                    color: const Color(0xFF0F120F),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Balance
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.balanceLabel,
                                      style: retroStyle(
                                          size: 12, color: kDkGreen)),
                                  Text(fmtMoney(store.balance),
                                      style: retroStyle(size: 28)),
                                ],
                              ),
                            ),
                            // Owe / Owed
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${s.oweLabel}${fmtMoney(iOweTotal)}',
                                    style: retroStyle(
                                        size: 13, color: kRed)),
                                Text('${s.owedLabel}${fmtMoney(owesMeTotal)}',
                                    style: retroStyle(
                                        size: 13, color: kGreen)),
                                if (hasLimit)
                                  Text(
                                    '${s.spentLabel}${fmtMoney(store.monthlySpent)}',
                                    style: retroStyle(
                                        size: 13,
                                        color: over ? kRed : kYellow),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        // Budget bar
                        if (hasLimit) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                '${s.budgetLabel} [${pct.round()}%]'
                                '${over ? '  ${s.overLimitMsg}' : ''}',
                                style: retroStyle(size: 12, color: col),
                              ),
                            ],
                          ),
                          Text(bar, style: retroStyle(size: 14, color: col)),
                        ],
                      ],
                    ),
                  ),

                  // ── Tab bar ──────────────────────────────────────────────────
                  Container(
                    color: kBg,
                    child: Row(
                      children: List.generate(tabs.length, (i) {
                        final active = i == _tab;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (i != _tab) {
                                SoundEngine.playTab();
                                setState(() => _tab = i);
                              }
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: active ? kGreen : kBg,
                                border: Border(
                                  bottom: BorderSide(
                                      color: active ? kGreen : kDim,
                                      width: 2),
                                  right: BorderSide(
                                      color: kDim, width: 0.5),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  active ? '► ${tabs[i]}' : tabs[i],
                                  style: retroStyle(
                                    size: 15,
                                    color: active ? kBg : kGreen,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // ── Screen content ───────────────────────────────────────────
                  Expanded(
                    child: IndexedStack(
                      index: _tab,
                      children: [
                        WalletScreen(store: store, isArabic: widget.isArabic),
                        DebtsScreen(store: store, isArabic: widget.isArabic),
                        PlanScreen(store: store, isArabic: widget.isArabic),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
