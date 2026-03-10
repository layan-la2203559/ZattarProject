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
  String _debtType = 'owe'; // 'owe' | 'owes'

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

  Widget _debtRow(Debt debt, Color col, S s) {
    // Icon: arrow_upward = I owe (money going out), arrow_downward = they owe me (money coming in)
    final icon = debt.type == 'owe'
        ? Icons.arrow_upward    // I owe — money leaving me
        : Icons.arrow_downward; // They owe me — money coming to me

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              // Icon indicator
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
              GestureDetector(
                onTap: () {
                  widget.store.settleDebt(debt.id);
                  showRetroToast(context, s.markedSettled, color: kYellow);
                },
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
            // Type toggle
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
                color: kGreen,
                bgColor: _debtType == 'owes'
                    ? const Color(0xFF004A00)
                    : const Color(0xFF0A1A0A),
              ),
            ]),
            const SizedBox(height: 8),
            RetroButton(label: s.recordDebt, onTap: () => _addDebt(s)),
          ],
        ),

        // ── Legend ────────────────────────────────────────────────────────────
        if (iOwe.isNotEmpty || owesMe.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_upward, color: kRed, size: 14),
                const SizedBox(width: 4),
                Text(s.iOweThem,
                    style: retroStyle(color: kRed, size: 13)),
                const SizedBox(width: 16),
                Icon(Icons.arrow_downward, color: kGreen, size: 14),
                const SizedBox(width: 4),
                Text(s.theyOweMe,
                    style: retroStyle(color: kGreen, size: 13)),
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
            borderColor: kGreen,
            children: owesMe.map((d) => _debtRow(d, kGreen, s)).toList(),
          ),

        // ── Settled ───────────────────────────────────────────────────────────
        if (settled.isNotEmpty)
          RetroBox(
            title: s.settledTitle,
            borderColor: kDim,
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
                  style: retroStyle(color: kDim, size: 17)),
            ),
          ),
      ],
    );
  }
}
