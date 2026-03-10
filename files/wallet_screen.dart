import 'package:flutter/material.dart';
import '../data_store.dart';
import '../retro_theme.dart';
import '../sounds.dart';

class WalletScreen extends StatefulWidget {
  final WalletData store;
  const WalletScreen({super.key, required this.store});

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

  void _add() {
    final v = double.tryParse(_amtCtrl.text.replaceAll(',', ''));
    if (v == null || v <= 0) {
      showRetroToast(context, '>> ERROR: INVALID AMOUNT', color: kRed);
      return;
    }
    widget.store.addMoney(v, _noteCtrl.text.trim());
    _amtCtrl.clear();
    _noteCtrl.clear();
    SoundEngine.playAdd();
    showRetroToast(context, '>> +${fmtMoney(v)} CREDITED');
  }

  void _remove() {
    final v = double.tryParse(_amtCtrl.text.replaceAll(',', ''));
    if (v == null || v <= 0) {
      showRetroToast(context, '>> ERROR: INVALID AMOUNT', color: kRed);
      return;
    }
    final success = widget.store.removeMoney(v, _noteCtrl.text.trim());
    if (!success) {
      showRetroToast(context, '>> ERROR: INSUFFICIENT FUNDS', color: kRed);
      return;
    }
    _amtCtrl.clear();
    _noteCtrl.clear();
    if (widget.store.isOverLimit) {
      SoundEngine.playAlarm();
      showRetroToast(
        context,
        '!! LIMIT EXCEEDED — ${fmtMoney(widget.store.monthlySpent)} SPENT',
        color: kYellow,
      );
    } else {
      SoundEngine.playRemove();
      showRetroToast(context, '>> -${fmtMoney(v)} DEBITED');
    }
  }

  @override
  Widget build(BuildContext context) {
    final txs = widget.store.transactions;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // ── Transaction form ──────────────────────────────────────────────────
        RetroBox(
          title: 'TRANSACTION',
          children: [
            RetroInput(
              controller: _amtCtrl,
              hint: 'AMOUNT (\$)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: false,
            ),
            const SizedBox(height: 8),
            RetroInput(controller: _noteCtrl, hint: 'MEMO  (OPTIONAL)'),
            const SizedBox(height: 10),
            RetroBtnRow(buttons: [
              RetroButton(label: '+ ADD \$', onTap: _add),
              RetroButton(
                label: '- REMOVE \$',
                onTap: _remove,
                color: kRed,
                bgColor: const Color(0xFF1A0A0A),
              ),
            ]),
          ],
        ),

        // ── Transaction log ───────────────────────────────────────────────────
        RetroBox(
          title: 'TRANSACTION LOG',
          children: txs.isEmpty
              ? [
                  Text('NO RECORDS FOUND_',
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
                            Text('[${tx.type}] ',
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
