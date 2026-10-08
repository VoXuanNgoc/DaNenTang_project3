import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vku_expense_ocr/screens/add_expense_screen.dart';

void main() {
  testWidgets('AddExpenseScreen validates required merchant and amount fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AddExpenseScreen(),
        ),
      ),
    );

    // Initial render: no error messages shown yet
    expect(find.text('Vui lòng nhập tên cửa hàng hoặc dịch vụ'), findsNothing);
    expect(find.text('Vui lòng nhập số tiền'), findsNothing);

    // Tap "Thêm chi tiêu" button with empty fields
    final submitButton = find.text('Thêm chi tiêu');
    expect(submitButton, findsOneWidget);

    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Verification: validation error messages are now displayed
    expect(find.text('Vui lòng nhập tên cửa hàng hoặc dịch vụ'), findsOneWidget);
    expect(find.text('Vui lòng nhập số tiền'), findsOneWidget);
  });
}
