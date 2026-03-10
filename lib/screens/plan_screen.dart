import 'package:flutter/material.dart';
import '../data_store.dart';
import '../l10n.dart';
import '../retro_theme.dart';

class PlanScreen extends StatefulWidget {
  final WalletData store;
  final bool isArabic;
  const PlanScreen({super.key, required this.store, required this.isArabic});

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

  void _setLimit(S s) {
    final v = double.tryParse(_limCtrl.text.replaceAll(',', ''));
    if (v == null || v <= 0) {
      showRetroToast(context, s.errInvalidLimit, color: kRed);
      return;
    }
    widget.store.setSpendingLimit(v);
    _limCtrl.clear();
    showRetroToast(context, s.limitSet(fmtMoney(v)));
  }

  @override
  Widget build(BuildContext context) {
    final s      = S(widget.isArabic);
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
          title: s.setMonthlyLimit,
          children: [
            RetroInput(
              controller: _limCtrl,
              hint: s.limitHint,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            RetroButton(label: s.setLimitBtn, onTap: () => _setLimit(s)),
            if (limit > 0) ...[
              const SizedBox(height: 8),
              Text(s.currentLimit(fmtMoney(limit)),
                  style: retroStyle(size: 15)),
            ],
          ],
        ),

        // ── Budget Meter ──────────────────────────────────────────────────────
        if (limit > 0)
          RetroBox(
            title: s.budgetMeter,
            borderColor: col,
            children: [
              Center(
                child: Text('${pct.round()}%',
                    style: retroStyle(size: 58, color: col)),
              ),
              Center(
                child: Text(bar, style: retroStyle(size: 16, color: col)),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(s.spentAmt(fmtMoney(spent)),
                      style: retroStyle(size: 14, color: col)),
                  Text(s.limitAmt(fmtMoney(limit)),
                      style: retroStyle(size: 14)),
                ],
              ),
              const SizedBox(height: 4),
              Center(
                child: over
                    ? Text(
                        s.exceededBy(fmtMoney(spent - limit)),
                        style: retroStyle(size: 14, color: kRed),
                      )
                    : Text(
                        s.remaining(fmtMoney(limit - spent)),
                        style: retroStyle(size: 14, color: kDkGreen),
                      ),
              ),
              const SizedBox(height: 12),
              RetroBtnRow(buttons: [
                RetroButton(
                  label: s.resetMonth,
                  onTap: () {
                    store.resetMonthlySpend();
                    showRetroToast(context, s.monthlyReset, color: kYellow);
                  },
                  color: kYellow,
                  bgColor: const Color(0xFF1A1400),
                ),
                RetroButton(
                  label: s.clearLimitBtn,
                  onTap: () {
                    store.clearLimit();
                    showRetroToast(context, s.limitCleared, color: kRed);
                  },
                  color: kRed,
                  bgColor: const Color(0xFF1A0000),
                ),
              ]),
            ],
          ),

        // ── Tips ──────────────────────────────────────────────────────────────
        RetroBox(
          title: s.tipsTitle,
          borderColor: kDim,
          children: s.tips
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
