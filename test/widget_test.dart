import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vku_expense_ocr/core/constants/app_constants.dart';
import 'package:vku_expense_ocr/main.dart';

void main() {
  testWidgets('App root initializes properly with VkuExpenseOcrApp', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: VkuExpenseOcrApp(),
      ),
    );

    // Initial frame verify
    expect(find.text(AppConstants.appTitle), findsWidgets);
  });
}
