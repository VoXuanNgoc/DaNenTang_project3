class CategoryExpense {
  final String category;
  final double totalAmount;
  final int count;
  final double percentage; // 0.0 to 1.0

  const CategoryExpense({
    required this.category,
    required this.totalAmount,
    required this.count,
    this.percentage = 0.0,
  });

  CategoryExpense copyWith({
    String? category,
    double? totalAmount,
    int? count,
    double? percentage,
  }) {
    return CategoryExpense(
      category: category ?? this.category,
      totalAmount: totalAmount ?? this.totalAmount,
      count: count ?? this.count,
      percentage: percentage ?? this.percentage,
    );
  }
}
