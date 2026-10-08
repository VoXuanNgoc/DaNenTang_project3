import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../models/receipt.dart';
import '../state/receipt_providers.dart';

class ReceiptDetailScreen extends ConsumerStatefulWidget {
  final int receiptId;

  const ReceiptDetailScreen({
    super.key,
    required this.receiptId,
  });

  @override
  ConsumerState<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends ConsumerState<ReceiptDetailScreen> {
  bool _isRawExpanded = false;

  Future<void> _confirmDelete(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa hóa đơn này khỏi lịch sử chi tiêu không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('XÓA'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(receiptListProvider.notifier).deleteReceipt(widget.receiptId);
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Đã xóa hóa đơn')),
        );
        router.pop();
      }
    }
  }

  Future<void> _showEditDialog(Receipt receipt) async {
    final formKey = GlobalKey<FormState>();
    final merchantCtrl = TextEditingController(text: receipt.merchantName);
    final amountCtrl = TextEditingController(
      text: CurrencyFormatter.formatWithoutSymbol(receipt.amount),
    );
    final noteCtrl = TextEditingController(text: receipt.note ?? '');
    DateTime selectedDate = receipt.date;
    String selectedCategory = receipt.category;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Chỉnh sửa hóa đơn',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: merchantCtrl,
                      decoration: const InputDecoration(labelText: 'Tên cửa hàng *'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Bắt buộc nhập' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Số tiền *', suffixText: 'đ'),
                      validator: (val) {
                        final amt = CurrencyFormatter.parseAmount(val);
                        return (amt == null || amt <= 0) ? 'Số tiền không hợp lệ' : null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Danh mục *'),
                      items: AppConstants.categories.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() => selectedCategory = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Ngày hóa đơn'),
                      subtitle: Text(DateFormatter.formatDate(selectedDate)),
                      trailing: const Icon(Icons.calendar_month_rounded),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setSheetState(() => selectedDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: noteCtrl,
                      decoration: const InputDecoration(labelText: 'Ghi chú'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00695C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final amt = CurrencyFormatter.parseAmount(amountCtrl.text)!;
                        final updated = receipt.copyWith(
                          merchantName: merchantCtrl.text.trim(),
                          amount: amt,
                          category: selectedCategory,
                          date: selectedDate,
                          note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                          updatedAt: DateTime.now(),
                        );
                        await ref.read(receiptListProvider.notifier).updateReceipt(updated);
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã cập nhật hóa đơn')),
                          );
                        }
                      },
                      child: const Text('Lưu thay đổi', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    merchantCtrl.dispose();
    amountCtrl.dispose();
    noteCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final receiptsAsync = ref.watch(receiptListProvider);

    return receiptsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Lỗi: $e')),
      ),
      data: (receipts) {
        Receipt? receipt;
        try {
          receipt = receipts.firstWhere((r) => r.id == widget.receiptId);
        } catch (_) {
          receipt = null;
        }

        if (receipt == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chi tiết hóa đơn')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Không tìm thấy hóa đơn này'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            ),
          );
        }

        final catColor = AppConstants.getCategoryColor(receipt.category, isDark: isDark);
        final catIcon = AppConstants.getCategoryIcon(receipt.category);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chi tiết hóa đơn'),
            actions: [
              IconButton(
                tooltip: 'Chỉnh sửa',
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => _showEditDialog(receipt!),
              ),
              IconButton(
                tooltip: 'Xóa hóa đơn',
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(18.0),
            children: [
              // Hero card with Merchant and Amount
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: catColor.withAlpha(isDark ? 45 : 30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(catIcon, color: catColor, size: 36),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        receipt.merchantName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(receipt.amount),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.tealAccent : const Color(0xFF00695C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: catColor.withAlpha(isDark ? 50 : 25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          receipt.category,
                          style: TextStyle(
                            color: catColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Detail attributes list
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        context,
                        icon: Icons.calendar_today_rounded,
                        label: 'Ngày chi tiêu',
                        value: DateFormatter.formatDate(receipt.date),
                      ),
                      const Divider(height: 1),
                      _buildDetailRow(
                        context,
                        icon: Icons.access_time_rounded,
                        label: 'Ngày tạo ghi chép',
                        value: DateFormatter.formatDateTime(receipt.createdAt),
                      ),
                      if (receipt.note != null && receipt.note!.isNotEmpty) ...[
                        const Divider(height: 1),
                        _buildDetailRow(
                          context,
                          icon: Icons.notes_rounded,
                          label: 'Ghi chú',
                          value: receipt.note!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Receipt Image View
              if (receipt.imagePath != null && File(receipt.imagePath!).existsSync()) ...[
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: const [
                            Icon(Icons.image_outlined, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Ảnh chụp hóa đơn',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Image.file(
                        File(receipt.imagePath!),
                        width: double.infinity,
                        height: 260,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Expandable Raw OCR Text
              if (receipt.rawOcrText != null && receipt.rawOcrText!.isNotEmpty)
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ExpansionTile(
                    initiallyExpanded: _isRawExpanded,
                    onExpansionChanged: (val) => setState(() => _isRawExpanded = val),
                    leading: const Icon(Icons.code_rounded),
                    title: const Text(
                      'Văn bản OCR gốc',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SelectableText(
                          receipt.rawOcrText!,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: isDark ? Colors.tealAccent : const Color(0xFF004D40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: isDark ? Colors.tealAccent : const Color(0xFF00796B)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
