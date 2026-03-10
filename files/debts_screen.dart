import 'package:flutter/material.dart';
import '../data_store.dart';
import '../retro_theme.dart';

class DebtsScreen extends StatefulWidget {
  final WalletData store;
  const DebtsScreen({super.key, required this.store});

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

  void _addDebt() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      showRetroToast(context, '>> ERROR: ENTER A NAME', color: kRed);
      return;
    }
    final v = double.tryParse(_amtCtrl.text.replaceAll(',', ''));
    if (v == null || v <= 0) {
      showRetroToast(context, '>> ERROR: INVALID AMOUNT', color: kRed);
      return;
    }
    widget.store.addDebt(name, v, _debtType);
    _nameCtrl.clear();
    _amtCtrl.clear();
    showRetroToast(context, '>> DEBT RECORD SAVED');
  }

  Widget _debtRow(Debt debt, Color col) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Text('▶ ', style: retroStyle(color: col, size: 15)),
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
                  showRetroToast(context, '>> MARKED AS SETTLED ✓',
                      color: kYellow);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: kYellow),
                    color: const Color(0xFF1A1400),
                  ),
                  child: Text('SETTLE',
                      style: retroStyle(color: kYellow, size: 13)),
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
                  child:
                      Text('DEL', style: retroStyle(color: kRed, size: 13)),
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
    final iOwe   = widget.store.activeIOwe;
    final owesMe = widget.store.activeOwesMe;
    final settled = widget.store.settledDebts;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // ── Add form ──────────────────────────────────────────────────────────
        RetroBox(
          title: 'ADD DEBT RECORD',
          children: [
            RetroInput(controller: _nameCtrl, hint: 'NAME'),
            const SizedBox(height: 8),
            RetroInput(
              controller: _amtCtrl,
              hint: 'AMOUNT (\$)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            // Type toggle
            RetroBtnRow(buttons: [
              RetroButton(
                label: 'I OWE THEM',
                onTap: () => setState(() => _debtType = 'owe'),
                color: kRed,
                bgColor: _debtType == 'owe'
                    ? const Color(0xFF4A0000)
                    : const Color(0xFF1A0000),
              ),
              RetroButton(
                label: 'THEY OWE ME',
                onTap: () => setState(() => _debtType = 'owes'),
                color: kGreen,
                bgColor: _debtType == 'owes'
                    ? const Color(0xFF004A00)
                    : const Color(0xFF0A1A0A),
              ),
            ]),
            const SizedBox(height: 8),
            RetroButton(label: 'RECORD DEBT', onTap: _addDebt),
          ],
        ),

        // ── I Owe ─────────────────────────────────────────────────────────────
        if (iOwe.isNotEmpty)
          RetroBox(
            title: 'I OWE',
            borderColor: kRed,
            children: iOwe.map((d) => _debtRow(d, kRed)).toList(),
          ),

        // ── They Owe Me ───────────────────────────────────────────────────────
        if (owesMe.isNotEmpty)
          RetroBox(
            title: 'THEY OWE ME',
            borderColor: kGreen,
            children: owesMe.map((d) => _debtRow(d, kGreen)).toList(),
          ),

        // ── Settled ───────────────────────────────────────────────────────────
        if (settled.isNotEmpty)
          RetroBox(
            title: 'SETTLED',
            borderColor: kDim,
            children: settled
                .map((d) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(
                              '✓ ${d.name} [${d.type == 'owe' ? 'OWED' : 'LENT'}]',
                              style: retroStyle(color: kDim, size: 14)),
                          const Spacer(),
                          Text(fmtMoney(d.amount),
                              style: retroStyle(color: kDim, size: 14)),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => widget.store.deleteDebt(d.id),
                            child: Text(' X ',
                                style: retroStyle(
                                    color: const Color(0xFF555555), size: 14)),
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
              child: Text('NO DEBT RECORDS_',
                  style: retroStyle(color: kDim, size: 17)),
            ),
          ),
      ],
    );
  }
}
