import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vku_expense_ocr/core/constants/app_constants.dart';
import 'package:vku_expense_ocr/widgets/expense_summary_card.dart';

void main() {
  testWidgets('ExpenseSummaryCard renders merchant, formatted amount, date and triggers onTap',
      (WidgetTester tester) async {
    bool tapped = false;
    final testDate = DateTime(2026, 5, 20);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpenseSummaryCard(
            merchant: 'Highlands Coffee',
            amount: 65000.0,
            date: testDate,
            category: AppConstants.categoryFood,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    // Verify merchant name
    expect(find.text('Highlands Coffee'), findsOneWidget);

    // Verify formatted amount: 65.000 đ
    expect(find.text('65.000 đ'), findsOneWidget);

    // Verify date is rendered: 20/05/2026
    expect(find.text('20/05/2026'), findsOneWidget);

    // Verify category label is rendered: Ăn uống
    expect(find.text(AppConstants.categoryFood), findsOneWidget);

    // Tap on the card
    await tester.tap(find.byType(ExpenseSummaryCard));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}
