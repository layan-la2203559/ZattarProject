import 'package:flutter/material.dart';
import '../data_store.dart';
import '../retro_theme.dart';

class PlanScreen extends StatefulWidget {
  final WalletData store;
  const PlanScreen({super.key, required this.store});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final _limCtrl = TextEditingController();

  @override
  void dispose() {
    _limCtrl.dispose();
    super.dispose();
  }

  void _setLimit() {
    final v = double.tryParse(_limCtrl.text.replaceAll(',', ''));
    if (v == null || v <= 0) {
      showRetroToast(context, '>> ERROR: INVALID LIMIT', color: kRed);
      return;
    }
    widget.store.setSpendingLimit(v);
    _limCtrl.clear();
    showRetroToast(context, '>> LIMIT SET: ${fmtMoney(v)}');
  }

  @override
  Widget build(BuildContext context) {
    final store  = widget.store;
    final spent  = store.monthlySpent;
    final limit  = store.spendingLimit;
    final pct    = store.spendPercent;
    final over   = store.isOverLimit;
    final blocks = (pct / 5).round().clamp(0, 20);
    final col    = over ? kRed : pct > 75 ? kYellow : kGreen;
    final bar    = '[' + '█' * blocks + '░' * (20 - blocks) + ']';

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // ── Set Limit ─────────────────────────────────────────────────────────
        RetroBox(
          title: 'SET MONTHLY LIMIT',
          children: [
            RetroInput(
              controller: _limCtrl,
              hint: 'LIMIT (\$)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            RetroButton(label: 'SET LIMIT', onTap: _setLimit),
            if (limit > 0) ...[
              const SizedBox(height: 8),
              Text('CURRENT LIMIT: ${fmtMoney(limit)}',
                  style: retroStyle(size: 15)),
            ],
          ],
        ),

        // ── Budget Meter ──────────────────────────────────────────────────────
        if (limit > 0)
          RetroBox(
            title: 'BUDGET METER',
            borderColor: col,
            children: [
              Center(
                child: Text('${pct.round()}%',
                    style: retroStyle(size: 58, color: col)),
              ),
              Center(
                child: Text(bar,
                    style: retroStyle(size: 16, color: col)),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('SPENT: ${fmtMoney(spent)}',
                      style: retroStyle(size: 14, color: col)),
                  Text('LIMIT: ${fmtMoney(limit)}',
                      style: retroStyle(size: 14)),
                ],
              ),
              const SizedBox(height: 4),
              Center(
                child: over
                    ? Text(
                        '!! EXCEEDED BY ${fmtMoney(spent - limit)} !!',
                        style: retroStyle(size: 14, color: kRed),
                      )
                    : Text(
                        'REMAINING: ${fmtMoney(limit - spent)}',
                        style: retroStyle(size: 14, color: kDkGreen),
                      ),
              ),
              const SizedBox(height: 12),
              RetroBtnRow(buttons: [
                RetroButton(
                  label: 'RESET MONTH',
                  onTap: () {
                    store.resetMonthlySpend();
                    showRetroToast(context, '>> MONTHLY SPENDING RESET',
                        color: kYellow);
                  },
                  color: kYellow,
                  bgColor: const Color(0xFF1A1400),
                ),
                RetroButton(
                  label: 'CLEAR LIMIT',
                  onTap: () {
                    store.clearLimit();
                    showRetroToast(context, '>> SPENDING LIMIT CLEARED',
                        color: kRed);
                  },
                  color: kRed,
                  bgColor: const Color(0xFF1A0000),
                ),
              ]),
            ],
          ),

        // ── Tips ──────────────────────────────────────────────────────────────
        RetroBox(
          title: 'TIPS',
          borderColor: kDim,
          children: const [
            '► SET A LIMIT THEN SPEND IN WALLET TAB.',
            '► METER TURNS YELLOW AT 75% USED.',
            '► METER TURNS RED WHEN OVER LIMIT.',
            '► RESET AT THE START OF EACH MONTH.',
            '► DATA SAVED TO vault_data.json ON DEVICE.',
          ]
              .map((t) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(t, style: retroStyle(color: kDim, size: 13)),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
