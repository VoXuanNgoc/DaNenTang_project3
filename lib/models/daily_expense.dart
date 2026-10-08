class DailyExpense {
  final DateTime date;
  final double totalAmount;
  final String label; // e.g. "T2", "15/05"

  const DailyExpense({
    required this.date,
    required this.totalAmount,
    required this.label,
  });
}
