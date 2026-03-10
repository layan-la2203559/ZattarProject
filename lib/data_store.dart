import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

// ── Formatters ─────────────────────────────────────────────────────────────────
final _currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
String fmtMoney(double n) => _currencyFmt.format(n);
String today() => DateFormat('MM/dd/yyyy').format(DateTime.now());

// ── Models ─────────────────────────────────────────────────────────────────────
class Transaction {
  final String id;
  final String type; // 'ADD' or 'SUB'
  final double amount;
  final String note;
  final String date;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.note,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> j) => Transaction(
        id: j['id'].toString(),
        type: j['type'],
        amount: (j['amount'] as num).toDouble(),
        note: j['note'],
        date: j['date'],
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'type': type, 'amount': amount, 'note': note, 'date': date};
}

class Debt {
  final String id;
  final String name;
  final double amount;
  final String type; // 'owe' | 'owes'
  bool settled;
  final String date;

  Debt({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    this.settled = false,
    required this.date,
  });

  factory Debt.fromJson(Map<String, dynamic> j) => Debt(
        id: j['id'].toString(),
        name: j['name'],
        amount: (j['amount'] as num).toDouble(),
        type: j['type'],
        settled: j['settled'] ?? false,
        date: j['date'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'type': type,
        'settled': settled,
        'date': date,
      };
}

// ── Store ──────────────────────────────────────────────────────────────────────
class WalletData extends ChangeNotifier {
  double balance = 0.0;
  List<Transaction> transactions = [];
  List<Debt> debts = [];
  double spendingLimit = 0.0;
  double monthlySpent = 0.0;

  File? _file;
  bool loaded = false;

  // Derived getters
  double get iOweTotal => debts
      .where((d) => d.type == 'owe' && !d.settled)
      .fold(0.0, (s, d) => s + d.amount);

  double get owesMeTotal => debts
      .where((d) => d.type == 'owes' && !d.settled)
      .fold(0.0, (s, d) => s + d.amount);

  bool get isOverLimit => spendingLimit > 0 && monthlySpent > spendingLimit;

  double get spendPercent =>
      spendingLimit > 0 ? (monthlySpent / spendingLimit * 100).clamp(0, 100) : 0;

  List<Debt> get activeIOwe =>
      debts.where((d) => d.type == 'owe' && !d.settled).toList();
  List<Debt> get activeOwesMe =>
      debts.where((d) => d.type == 'owes' && !d.settled).toList();
  List<Debt> get settledDebts => debts.where((d) => d.settled).toList();

  // ── Persistence ──────────────────────────────────────────────────────────────
  Future<void> load() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _file = File('${dir.path}/vault_data.json');
      if (await _file!.exists()) {
        final raw = jsonDecode(await _file!.readAsString());
        balance = (raw['balance'] as num? ?? 0).toDouble();
        spendingLimit = (raw['spending_limit'] as num? ?? 0).toDouble();
        monthlySpent = (raw['monthly_spent'] as num? ?? 0).toDouble();
        transactions = ((raw['transactions'] as List?) ?? [])
            .map((e) => Transaction.fromJson(e))
            .toList();
        debts = ((raw['debts'] as List?) ?? [])
            .map((e) => Debt.fromJson(e))
            .toList();
      }
    } catch (_) {
      // Start fresh on any error
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    _file ??= File(
        '${(await getApplicationDocumentsDirectory()).path}/vault_data.json');
    await _file!.writeAsString(jsonEncode({
      'balance': balance,
      'spending_limit': spendingLimit,
      'monthly_spent': monthlySpent,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'debts': debts.map((d) => d.toJson()).toList(),
    }));
  }

  // ── Wallet actions ────────────────────────────────────────────────────────────
  void addMoney(double amount, String note) {
    balance += amount;
    transactions.insert(
        0,
        Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: 'ADD',
          amount: amount,
          note: note.isEmpty ? 'DEPOSIT' : note.toUpperCase(),
          date: today(),
        ));
    _save();
    notifyListeners();
  }

  /// Returns true if successful, false if insufficient funds.
  bool removeMoney(double amount, String note) {
    if (amount > balance) return false;
    balance -= amount;
    monthlySpent += amount;
    transactions.insert(
        0,
        Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: 'SUB',
          amount: amount,
          note: note.isEmpty ? 'WITHDRAWAL' : note.toUpperCase(),
          date: today(),
        ));
    _save();
    notifyListeners();
    return true;
  }

  // ── Debt actions ──────────────────────────────────────────────────────────────
  void addDebt(String name, double amount, String type) {
    debts.add(Debt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.toUpperCase(),
      amount: amount,
      type: type,
      date: today(),
    ));
    _save();
    notifyListeners();
  }

  void settleDebt(String id) {
    debts.firstWhere((d) => d.id == id).settled = true;
    _save();
    notifyListeners();
  }

  void deleteDebt(String id) {
    debts.removeWhere((d) => d.id == id);
    _save();
    notifyListeners();
  }

  // ── Plan actions ──────────────────────────────────────────────────────────────
  void setSpendingLimit(double limit) {
    spendingLimit = limit;
    monthlySpent = 0;
    _save();
    notifyListeners();
  }

  void resetMonthlySpend() {
    monthlySpent = 0;
    _save();
    notifyListeners();
  }

  void clearLimit() {
    spendingLimit = 0;
    monthlySpent = 0;
    _save();
    notifyListeners();
  }
}
