import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data_store.dart';
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

class VaultApp extends StatelessWidget {
  final WalletData store;
  const VaultApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VAULT-O-MATIC',
      debugShowCheckedModeBanner: false,
      theme: buildRetroTheme(),
      home: HomeShell(store: store),
    );
  }
}

// ── Home Shell ─────────────────────────────────────────────────────────────────
class HomeShell extends StatefulWidget {
  final WalletData store;
  const HomeShell({super.key, required this.store});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  static const _tabs = ['WALLET', 'DEBTS', 'PLAN'];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        if (!widget.store.loaded) {
          return Scaffold(
            body: Center(
              child: Text('LOADING VAULT DATA...',
                  style: retroStyle(size: 20)),
            ),
          );
        }

        final store = widget.store;
        final iOweTotal   = store.iOweTotal;
        final owesMeTotal = store.owesMeTotal;
        final hasLimit    = store.spendingLimit > 0;
        final over        = store.isOverLimit;
        final pct         = store.spendPercent;
        final col         = over ? kRed : pct > 75 ? kYellow : kGreen;
        final blocks      = (pct / 5).round().clamp(0, 20);
        final bar         = '[' + '█' * blocks + '░' * (20 - blocks) + ']';

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ─────────────────────────────────────────────────────
                Container(
                  color: kBg,
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 6),
                  child: Column(
                    children: [
                      Text(
                        '★ PERSONAL FINANCE SYSTEM v2.0 ★',
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
                ),

                // ── Balance bar ────────────────────────────────────────────────
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
                                Text('BALANCE:',
                                    style:
                                        retroStyle(size: 12, color: kDkGreen)),
                                Text(fmtMoney(store.balance),
                                    style: retroStyle(size: 28)),
                              ],
                            ),
                          ),
                          // Owe / Owed
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('OWE:  ${fmtMoney(iOweTotal)}',
                                  style: retroStyle(size: 13, color: kRed)),
                              Text('OWED: ${fmtMoney(owesMeTotal)}',
                                  style: retroStyle(size: 13, color: kGreen)),
                              if (hasLimit)
                                Text(
                                  'SPENT:${fmtMoney(store.monthlySpent)}',
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
                              'BUDGET [${pct.round()}%]'
                              '${over ? '  !! OVER LIMIT !!' : ''}',
                              style: retroStyle(size: 12, color: col),
                            ),
                          ],
                        ),
                        Text(bar, style: retroStyle(size: 14, color: col)),
                      ],
                    ],
                  ),
                ),

                // ── Tab bar ────────────────────────────────────────────────────
                Container(
                  color: kBg,
                  child: Row(
                    children: List.generate(_tabs.length, (i) {
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
                                right: BorderSide(color: kDim, width: 0.5),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                active ? '► ${_tabs[i]}' : _tabs[i],
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

                // ── Screen content ─────────────────────────────────────────────
                Expanded(
                  child: IndexedStack(
                    index: _tab,
                    children: [
                      WalletScreen(store: store),
                      DebtsScreen(store: store),
                      PlanScreen(store: store),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
