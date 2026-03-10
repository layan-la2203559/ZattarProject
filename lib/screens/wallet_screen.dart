import 'package:flutter/material.dart';
import '../data_store.dart';
import '../l10n.dart';
import '../retro_theme.dart';
import '../sounds.dart';

class WalletScreen extends StatefulWidget {
  final WalletData store;
  final bool isArabic;
  const WalletScreen({super.key, required this.store, required this.isArabic});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _amtCtrl  = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _amtCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _add(S s) {
    final v = double.tryParse(_amtCtrl.text.replaceAll(',', ''));
    if (v == null || v <= 0) {
      showRetroToast(context, s.errInvalidAmt, color: kRed);
      return;
    }
    widget.store.addMoney(v, _noteCtrl.text.trim());
    _amtCtrl.clear();
    _noteCtrl.clear();
    SoundEngine.playAdd();
    showRetroToast(context, s.credited(fmtMoney(v)));
  }

  void _remove(S s) {
    final v = double.tryParse(_amtCtrl.text.replaceAll(',', ''));
    if (v == null || v <= 0) {
      showRetroToast(context, s.errInvalidAmt, color: kRed);
      return;
    }
    final success = widget.store.removeMoney(v, _noteCtrl.text.trim());
    if (!success) {
      showRetroToast(context, s.errInsufficientFunds, color: kRed);
      return;
    }
    _amtCtrl.clear();
    _noteCtrl.clear();
    if (widget.store.isOverLimit) {
      SoundEngine.playAlarm();
      showRetroToast(
        context,
        s.limitExceeded(fmtMoney(widget.store.monthlySpent)),
        color: kYellow,
      );
    } else {
      SoundEngine.playRemove();
      showRetroToast(context, s.debited(fmtMoney(v)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s   = S(widget.isArabic);
    final txs = widget.store.transactions;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // ── Transaction form ──────────────────────────────────────────────────
        RetroBox(
          title: s.transaction,
          children: [
            RetroInput(
              controller: _amtCtrl,
              hint: s.amountHint,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: false,
            ),
            const SizedBox(height: 8),
            RetroInput(controller: _noteCtrl, hint: s.memoHint),
            const SizedBox(height: 10),
            RetroBtnRow(buttons: [
              RetroButton(label: s.addBtn, onTap: () => _add(s)),
              RetroButton(
                label: s.removeBtn,
                onTap: () => _remove(s),
                color: kRed,
                bgColor: const Color(0xFF1A0A0A),
              ),
            ]),
          ],
        ),

        // ── Transaction log ───────────────────────────────────────────────────
        RetroBox(
          title: s.txLog,
          children: txs.isEmpty
              ? [
                  Text(s.noRecords,
                      style: retroStyle(color: kDim, size: 16))
                ]
              : txs.take(50).map((tx) {
                  final isAdd = tx.type == 'ADD';
                  final col   = isAdd ? kGreen : kRed;
                  final sign  = isAdd ? '+' : '-';
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Text('[${s.txTypeLabel(tx.type)}] ',
                                style: retroStyle(size: 13, color: col)),
                            Expanded(
                              child: Text(tx.note,
                                  style: retroStyle(
                                      size: 13,
                                      color: const Color(0xFFAAFFAA)),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Text(tx.date,
                                style: retroStyle(size: 11, color: kDim)),
                            const SizedBox(width: 8),
                            Text('$sign${fmtMoney(tx.amount)}',
                                style: retroStyle(size: 13, color: col)),
                          ],
                        ),
                      ),
                      Container(height: 1, color: kDim),
                    ],
                  );
                }).toList(),
        ),
      ],
    );
  }
}
