import 'package:flutter/material.dart';
import '../data_store.dart';
import '../l10n.dart';
import '../retro_theme.dart';

class DebtsScreen extends StatefulWidget {
  final WalletData store;
  final bool isArabic;
  const DebtsScreen({super.key, required this.store, required this.isArabic});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  final _nameCtrl = TextEditingController();
  final _amtCtrl  = TextEditingController();
  String _debtType = 'owe';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amtCtrl.dispose();
    super.dispose();
  }

  void _addDebt(S s) {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      showRetroToast(context, s.errEnterName, color: kRed);
      return;
    }
    final v = double.tryParse(_amtCtrl.text.replaceAll(',', ''));
    if (v == null || v <= 0) {
      showRetroToast(context, s.errInvalidAmt, color: kRed);
      return;
    }
    widget.store.addDebt(name, v, _debtType);
    _nameCtrl.clear();
    _amtCtrl.clear();
    showRetroToast(context, s.debtSaved);
  }

  /// Shows a dialog asking whether to adjust balance when settling.
  void _showSettleDialog(Debt debt, S s) {
    final palette = AppPalette.of(context).scheme;
    final isOwedToMe = debt.type == 'owes'; // They owe me → +balance
    final iOwe       = debt.type == 'owe';  // I owe them → -balance

    final actionLabel = isOwedToMe
        ? '${s.settleAddBalance} ${fmtMoney(debt.amount)}'
        : '${s.settleDeductBalance} ${fmtMoney(debt.amount)}';
    final actionColor = isOwedToMe ? palette.accent : kRed;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: kBg,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: palette.accent, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('[ ${s.settleDialogTitle} ]',
                  style: retroStyle(size: 18, color: palette.accent)),
              const SizedBox(height: 8),
              Text(
                '${debt.name}  •  ${fmtMoney(debt.amount)}',
                style: retroStyle(size: 16, color: palette.accent),
              ),
              const SizedBox(height: 4),
              Text(
                isOwedToMe ? s.settleOwedMeDesc : s.settleIOweDesc,
                style: retroStyle(size: 13, color: palette.dark),
              ),
              const SizedBox(height: 16),
              // Adjust balance button
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  final ok = widget.store.settleDebtWithBalance(debt.id);
                  if (!ok) {
                    showRetroToast(context, s.errInsufficientFunds, color: kRed);
                  } else {
                    final msg = isOwedToMe
                        ? '${s.settledCredited} ${fmtMoney(debt.amount)}'
                        : '${s.settledDebited} ${fmtMoney(debt.amount)}';
                    showRetroToast(context, msg, color: actionColor);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isOwedToMe
                        ? palette.activeBg
                        : const Color(0xFF1A0000),
                    border: Border.all(color: actionColor, width: 1.5),
                  ),
                  child: Center(
                    child: Text(actionLabel,
                        style: retroStyle(size: 15, color: actionColor)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Settle without balance change
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  widget.store.settleDebt(debt.id);
                  showRetroToast(context, s.markedSettled, color: kYellow);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1400),
                    border: Border.all(color: kYellow, width: 1.5),
                  ),
                  child: Center(
                    child: Text(s.settleNoBalance,
                        style: retroStyle(size: 15, color: kYellow)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Cancel
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: palette.activeBg,
                    border: Border.all(color: palette.dim, width: 1.5),
                  ),
                  child: Center(
                    child: Text(s.cancelBtn,
                        style: retroStyle(size: 15, color: palette.dim)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _debtRow(Debt debt, Color col, S s) {
    final icon = debt.type == 'owe'
        ? Icons.arrow_upward
        : Icons.arrow_downward;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: col),
                  color: col == kRed
                      ? const Color(0xFF1A0000)
                      : const Color(0xFF001A00),
                ),
                child: Icon(icon, color: col, size: 16),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(debt.name, style: retroStyle(color: col, size: 16)),
                    Text(debt.date, style: retroStyle(color: kDim, size: 12)),
                  ],
                ),
              ),
              Text(fmtMoney(debt.amount),
                  style: retroStyle(color: col, size: 15)),
              const SizedBox(width: 6),
              // Settle button — opens dialog
              GestureDetector(
                onTap: () => _showSettleDialog(debt, s),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: kYellow),
                    color: const Color(0xFF1A1400),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: kYellow, size: 13),
                      const SizedBox(width: 3),
                      Text(s.settleBtn,
                          style: retroStyle(color: kYellow, size: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => widget.store.deleteDebt(debt.id),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: kRed),
                    color: const Color(0xFF1A0000),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.delete_outline, color: kRed, size: 13),
                      const SizedBox(width: 3),
                      Text(s.delBtn, style: retroStyle(color: kRed, size: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: kDim),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s       = S(widget.isArabic);
    final palette = AppPalette.of(context).scheme;
    final iOwe    = widget.store.activeIOwe;
    final owesMe  = widget.store.activeOwesMe;
    final settled = widget.store.settledDebts;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // ── Add form ──────────────────────────────────────────────────────────
        RetroBox(
          title: s.addDebtRecord,
          children: [
            RetroInput(controller: _nameCtrl, hint: s.nameHint),
            const SizedBox(height: 8),
            RetroInput(
              controller: _amtCtrl,
              hint: s.amountHint,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            RetroBtnRow(buttons: [
              RetroButton(
                label: s.iOweThem,
                onTap: () => setState(() => _debtType = 'owe'),
                color: kRed,
                bgColor: _debtType == 'owe'
                    ? const Color(0xFF4A0000)
                    : const Color(0xFF1A0000),
              ),
              RetroButton(
                label: s.theyOweMe,
                onTap: () => setState(() => _debtType = 'owes'),
                color: palette.accent,
                bgColor: _debtType == 'owes'
                    ? palette.activeBg
                    : const Color(0xFF0A1A0A),
              ),
            ]),
            const SizedBox(height: 8),
            RetroButton(label: s.recordDebt, onTap: () => _addDebt(s)),
          ],
        ),

        // ── Settlement note ───────────────────────────────────────────────────
        if (iOwe.isNotEmpty || owesMe.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_upward, color: kRed, size: 14),
                    const SizedBox(width: 4),
                    Text(s.iOweThem,
                        style: retroStyle(color: kRed, size: 13)),
                    const SizedBox(width: 16),
                    Icon(Icons.arrow_downward, color: palette.accent, size: 14),
                    const SizedBox(width: 4),
                    Text(s.theyOweMe,
                        style: retroStyle(color: palette.accent, size: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  s.settleHint,
                  style: retroStyle(color: palette.dark, size: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

        // ── I Owe ─────────────────────────────────────────────────────────────
        if (iOwe.isNotEmpty)
          RetroBox(
            title: s.iOweTitle,
            borderColor: kRed,
            children: iOwe.map((d) => _debtRow(d, kRed, s)).toList(),
          ),

        // ── They Owe Me ───────────────────────────────────────────────────────
        if (owesMe.isNotEmpty)
          RetroBox(
            title: s.theyOweMeTitle,
            borderColor: palette.accent,
            children: owesMe.map((d) => _debtRow(d, palette.accent, s)).toList(),
          ),

        // ── Settled ───────────────────────────────────────────────────────────
        if (settled.isNotEmpty)
          RetroBox(
            title: s.settledTitle,
            borderColor: palette.dim,
            children: settled
                .map((d) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: kDim, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${d.name} [${d.type == 'owe' ? s.owedTag : s.lentTag}]',
                            style: retroStyle(color: kDim, size: 14),
                          ),
                          const Spacer(),
                          Text(fmtMoney(d.amount),
                              style: retroStyle(color: kDim, size: 14)),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => widget.store.deleteDebt(d.id),
                            child: const Icon(Icons.close,
                                color: Color(0xFF555555), size: 16),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),

        if (widget.store.debts.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(s.noDebtRecords,
                  style: retroStyle(color: palette.dim, size: 17)),
            ),
          ),
      ],
    );
  }
}
