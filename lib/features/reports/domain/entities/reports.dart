import 'package:equatable/equatable.dart';

class Balance {
  final double income, expense, remaining;
  const Balance({required this.income, required this.expense, required this.remaining});
}

class SavingsRate {
  final double rate;
  final String message;
  const SavingsRate({required this.rate, required this.message});
}

class Summary {
  final double total, average, highest;
  final int count;
  const Summary({required this.total, required this.average, required this.highest, required this.count});
}

class ByPriority {
  final double alta, baja, altaPct, bajaPct;
  const ByPriority({required this.alta, required this.baja, required this.altaPct, required this.bajaPct});
}

class CategoryItem {
  final String category;
  final String label;
  final double amount;
  final double percentage;
  const CategoryItem({
    required this.category,
    required this.label,
    required this.amount,
    required this.percentage,
  });
}

class ByCategory {
  final List<CategoryItem> items;
  final double total;
  const ByCategory({required this.items, required this.total});
}

class TopExpense {
  final String name, priority;
  final double amount;
  const TopExpense({required this.name, required this.priority, required this.amount});
}

class GroupedExpense {
  final String name;
  final int occurrences;
  final double total;
  final double? average;
  const GroupedExpense({required this.name, required this.occurrences, required this.total, this.average});
}

class GroupedReport {
  final List<GroupedExpense> items;
  final double total;
  const GroupedReport({required this.items, required this.total});
}

class TimePoint {
  final String label;
  final double total;
  const TimePoint({required this.label, required this.total});
}

class Reports extends Equatable {
  final Balance balance;
  final SavingsRate savingsRate;
  final Summary summary;
  final ByPriority byPriority;
  final ByCategory byCategory;
  final List<TopExpense> topExpenses;
  final GroupedReport antExpenses;
  final GroupedReport vampireExpenses;
  final List<TimePoint> overTime;
  final List<TimePoint> byMonth;

  const Reports({
    required this.balance,
    required this.savingsRate,
    required this.summary,
    required this.byPriority,
    required this.byCategory,
    required this.topExpenses,
    required this.antExpenses,
    required this.vampireExpenses,
    required this.overTime,
    required this.byMonth,
  });

  @override
  List<Object?> get props => [balance, savingsRate, summary, byPriority, byCategory,
      topExpenses, antExpenses, vampireExpenses, overTime, byMonth];
}