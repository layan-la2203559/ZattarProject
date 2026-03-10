/// Simple bilingual string provider — English / Arabic.
class S {
  final bool ar;
  const S(this.ar);

  // Language toggle button label
  String get langBtn => ar ? 'EN' : 'AR';

  // Loading
  String get loading => ar ? 'جار تحميل البيانات...' : 'LOADING VAULT DATA...';

  // Header
  String get subtitle =>
      ar ? '★ نظام المالية الشخصية v2.0 ★' : '★ PERSONAL FINANCE SYSTEM v2.0 ★';

  // Balance bar
  String get balanceLabel => ar ? 'الرصيد:' : 'BALANCE:';
  String get oweLabel     => ar ? 'مديون:  ' : 'OWE:  ';
  String get owedLabel    => ar ? 'دين لي: ' : 'OWED: ';
  String get spentLabel   => ar ? 'أنفق:' : 'SPENT:';
  String get budgetLabel  => ar ? 'الميزانية' : 'BUDGET';
  String get overLimitMsg => ar ? '!! تجاوز الحد !!' : '!! OVER LIMIT !!';

  // Tabs
  String get tabWallet => ar ? 'المحفظة' : 'WALLET';
  String get tabDebts  => ar ? 'الديون'  : 'DEBTS';
  String get tabPlan   => ar ? 'الخطة'   : 'PLAN';

  // ── Wallet screen ────────────────────────────────────────────────────────────
  String get transaction     => ar ? 'معاملة'           : 'TRANSACTION';
  String get amountHint      => ar ? 'المبلغ (\$)'      : 'AMOUNT (\$)';
  String get memoHint        => ar ? 'ملاحظة (اختياري)' : 'MEMO  (OPTIONAL)';
  String get addBtn          => ar ? '+ إضافة \$'       : '+ ADD \$';
  String get removeBtn       => ar ? '- خصم \$'         : '- REMOVE \$';
  String get txLog           => ar ? 'سجل المعاملات'    : 'TRANSACTION LOG';
  String get noRecords       => ar ? 'لا توجد سجلات_'   : 'NO RECORDS FOUND_';
  String get errInvalidAmt   => ar ? '>> خطأ: مبلغ غير صالح'   : '>> ERROR: INVALID AMOUNT';
  String get errInsufficientFunds =>
      ar ? '>> خطأ: رصيد غير كافٍ' : '>> ERROR: INSUFFICIENT FUNDS';

  String credited(String amt) =>
      ar ? '>> +$amt تم الإيداع' : '>> +$amt CREDITED';
  String debited(String amt) =>
      ar ? '>> -$amt تم الخصم' : '>> -$amt DEBITED';
  String limitExceeded(String amt) =>
      ar ? '!! تجاوز الحد — $amt أنفق' : '!! LIMIT EXCEEDED — $amt SPENT';

  String txTypeLabel(String type) {
    if (!ar) return type;
    return type == 'ADD' ? 'إضافة' : 'خصم';
  }

  // ── Debts screen ─────────────────────────────────────────────────────────────
  String get addDebtRecord  => ar ? 'إضافة سجل دين'  : 'ADD DEBT RECORD';
  String get nameHint       => ar ? 'الاسم'           : 'NAME';
  String get iOweThem       => ar ? 'أنا مديون'       : 'I OWE THEM';
  String get theyOweMe      => ar ? 'هم مدينون لي'    : 'THEY OWE ME';
  String get recordDebt     => ar ? 'تسجيل الدين'     : 'RECORD DEBT';
  String get iOweTitle      => ar ? 'أنا مديون'       : 'I OWE';
  String get theyOweMeTitle => ar ? 'هم مدينون لي'    : 'THEY OWE ME';
  String get settledTitle   => ar ? 'مسوّى'           : 'SETTLED';
  String get settleBtn      => ar ? 'تسوية'           : 'SETTLE';
  String get delBtn         => ar ? 'حذف'             : 'DEL';
  String get errEnterName   => ar ? '>> خطأ: أدخل اسماً'       : '>> ERROR: ENTER A NAME';
  String get debtSaved      => ar ? '>> تم حفظ سجل الدين'      : '>> DEBT RECORD SAVED';
  String get markedSettled  => ar ? '>> تم التسوية ✓'           : '>> MARKED AS SETTLED ✓';
  String get noDebtRecords  => ar ? 'لا توجد ديون_'             : 'NO DEBT RECORDS_';
  String get owedTag        => ar ? 'مديون' : 'OWED';
  String get lentTag        => ar ? 'أقرضت' : 'LENT';

  // ── Plan screen ──────────────────────────────────────────────────────────────
  String get setMonthlyLimit => ar ? 'تحديد الحد الشهري' : 'SET MONTHLY LIMIT';
  String get limitHint       => ar ? 'الحد (\$)'         : 'LIMIT (\$)';
  String get setLimitBtn     => ar ? 'تحديد'             : 'SET LIMIT';
  String get budgetMeter     => ar ? 'مقياس الميزانية'   : 'BUDGET METER';
  String get resetMonth      => ar ? 'إعادة تعيين الشهر' : 'RESET MONTH';
  String get clearLimitBtn   => ar ? 'مسح الحد'          : 'CLEAR LIMIT';
  String get tipsTitle       => ar ? 'نصائح'             : 'TIPS';
  String get errInvalidLimit => ar ? '>> خطأ: حد غير صالح'              : '>> ERROR: INVALID LIMIT';
  String get monthlyReset    => ar ? '>> تم إعادة تعيين الإنفاق الشهري' : '>> MONTHLY SPENDING RESET';
  String get limitCleared    => ar ? '>> تم مسح حد الإنفاق'             : '>> SPENDING LIMIT CLEARED';

  String currentLimit(String amt) =>
      ar ? 'الحد الحالي: $amt' : 'CURRENT LIMIT: $amt';
  String spentAmt(String amt)  => ar ? 'أنفق: $amt'   : 'SPENT: $amt';
  String limitAmt(String amt)  => ar ? 'الحد: $amt'   : 'LIMIT: $amt';
  String exceededBy(String amt) => ar ? '!! تجاوز بـ $amt !!' : '!! EXCEEDED BY $amt !!';
  String remaining(String amt) => ar ? 'المتبقي: $amt' : 'REMAINING: $amt';
  String limitSet(String amt)  => ar ? '>> تم تحديد الحد: $amt' : '>> LIMIT SET: $amt';

  List<String> get tips => ar
      ? [
          '► حدّد حداً ثم أنفق من تبويب المحفظة.',
          '► يتحول المقياس للأصفر عند 75% من الاستخدام.',
          '► يتحول المقياس للأحمر عند تجاوز الحد.',
          '► أعد التعيين في بداية كل شهر.',
          '► البيانات محفوظة في vault_data.json على الجهاز.',
        ]
      : [
          '► SET A LIMIT THEN SPEND IN WALLET TAB.',
          '► METER TURNS YELLOW AT 75% USED.',
          '► METER TURNS RED WHEN OVER LIMIT.',
          '► RESET AT THE START OF EACH MONTH.',
          '► DATA SAVED TO vault_data.json ON DEVICE.',
        ];
}
