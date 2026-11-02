import '../../domain/entities/reports.dart';

class ReportsModel extends Reports {
  const ReportsModel({
    required super.balance,
    required super.savingsRate,
    required super.summary,
    required super.byPriority,
    required super.byCategory,
    required super.topExpenses,
    required super.antExpenses,
    required super.vampireExpenses,
    required super.overTime,
    required super.byMonth,
  });

  factory ReportsModel.fromJson(Map<String, dynamic> j) {
    double d(dynamic v) => (v as num?)?.toDouble() ?? 0;
    int iv(dynamic v) => (v as num?)?.toInt() ?? 0;

    final b = j['balance'] ?? {};
    final sr = j['savingsRate'] ?? {};
    final s = j['summary'] ?? {};
    final bp = j['byPriority'] ?? {};
    final bc = j['byCategory'] ?? {};
    final ant = j['antExpenses'] ?? {};
    final vamp = j['vampireExpenses'] ?? {};

    GroupedReport grouped(Map g) {
      final items = ((g['items'] ?? []) as List).map((e) => GroupedExpense(
        name: e['name'] ?? '',
        occurrences: iv(e['occurrences']),
        total: d(e['total']),
        average: e['average'] != null ? d(e['average']) : null,
      )).toList();
      return GroupedReport(items: items, total: d(g['total']));
    }

    ByCategory category(Map c) {
      final items = ((c['items'] ?? []) as List).map((e) => CategoryItem(
        category: e['category'] ?? 'otros',
        label: e['label'] ?? 'Otros',
        amount: d(e['amount']),
        percentage: d(e['percentage']),
      )).toList();
      return ByCategory(items: items, total: d(c['total']));
    }

    List<TimePoint> timeline(dynamic list, String key) {
      return ((list ?? []) as List).map((e) =>
        TimePoint(label: e[key] ?? '', total: d(e['total']))).toList();
    }

    return ReportsModel(
      balance: Balance(income: d(b['income']), expense: d(b['expense']), remaining: d(b['remaining'])),
      savingsRate: SavingsRate(rate: d(sr['rate']), message: sr['message'] ?? ''),
      summary: Summary(total: d(s['total']), average: d(s['average']), highest: d(s['highest']), count: iv(s['count'])),
      byPriority: ByPriority(alta: d(bp['alta']), baja: d(bp['baja']), altaPct: d(bp['altaPct']), bajaPct: d(bp['bajaPct'])),
      byCategory: category(bc),
      topExpenses: ((j['topExpenses'] ?? []) as List).map((e) =>
        TopExpense(name: e['name'] ?? '', priority: e['priority'] ?? 'baja', amount: d(e['amount']))).toList(),
      antExpenses: grouped(ant),
      vampireExpenses: grouped(vamp),
      overTime: timeline(j['overTime'], 'date'),
      byMonth: timeline(j['byMonth'], 'month'),
    );
  }
}