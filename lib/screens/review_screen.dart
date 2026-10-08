import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../core/parsers/receipt_parser.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../models/receipt.dart';
import '../state/receipt_providers.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final ParsedReceipt? parsedReceipt;
  final String? imagePath;

  const ReviewScreen({
    super.key,
    this.parsedReceipt,
    this.imagePath,
  });

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _merchantController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late FocusNode _merchantFocus;
  late FocusNode _amountFocus;
  late FocusNode _noteFocus;

  late DateTime _selectedDate;
  late String _selectedCategory;
  bool _isSaving = false;
  bool _isRawTextExpanded = false;

  @override
  void initState() {
    super.initState();
    final p = widget.parsedReceipt;

    _merchantController = TextEditingController(text: p?.merchantName ?? '');
    _amountController = TextEditingController(
      text: p?.amount != null ? CurrencyFormatter.formatWithoutSymbol(p!.amount!) : '',
    );
    _noteController = TextEditingController();

    _merchantFocus = FocusNode();
    _amountFocus = FocusNode();
    _noteFocus = FocusNode();

    _selectedDate = p?.date ?? DateTime.now();
    _selectedCategory = p?.category ?? AppConstants.categoryOther;
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _noteController.dispose();

    _merchantFocus.dispose();
    _amountFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'CHỌN NGÀY HÓA ĐƠN',
      cancelText: 'HỦY',
      confirmText: 'CHỌN',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveReceipt() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final parsedAmount = CurrencyFormatter.parseAmount(_amountController.text);
    if (parsedAmount == null || parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số tiền hợp lệ lớn hơn 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now();
      final receipt = Receipt(
        merchantName: _merchantController.text.trim(),
        amount: parsedAmount,
        date: _selectedDate,
        category: _selectedCategory,
        imagePath: widget.imagePath,
        rawOcrText: widget.parsedReceipt?.rawText,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(receiptListProvider.notifier).addReceipt(receipt);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Đã lưu hóa đơn thành công!'),
            ],
          ),
          backgroundColor: const Color(0xFF00796B),
        ),
      );

      // Return to Dashboard
      context.go('/');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lưu hóa đơn: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final confidence = widget.parsedReceipt?.confidence ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem lại hóa đơn'),
        actions: [
          IconButton(
            tooltip: 'Hủy bỏ',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Confidence Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: confidence >= 0.7
                      ? Colors.green.withAlpha(25)
                      : confidence >= 0.4
                          ? Colors.orange.withAlpha(25)
                          : Colors.grey.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: confidence >= 0.7
                        ? Colors.green.shade400
                        : confidence >= 0.4
                            ? Colors.orange.shade400
                            : Colors.grey.shade400,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      confidence >= 0.7
                          ? Icons.verified_rounded
                          : Icons.info_outline_rounded,
                      color: confidence >= 0.7
                          ? Colors.green
                          : confidence >= 0.4
                              ? Colors.orange
                              : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Độ tin cậy trích xuất: ${(confidence * 100).toInt()}% • Vui lòng kiểm tra và chỉnh sửa nếu cần.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Image Preview Thumbnail
              if (widget.imagePath != null)
                Container(
                  height: 160,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(widget.imagePath!),
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(178),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.photo_camera_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text('Ảnh đã quét', style: TextStyle(color: Colors.white, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Merchant Name Field
              Text(
                'Tên cửa hàng / Đơn vị cung cấp *',
                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _merchantController,
                focusNode: _merchantFocus,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'VD: Highlands Coffee, WinMart, Grab...',
                  prefixIcon: Icon(Icons.storefront_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập tên cửa hàng';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Total Amount Field
              Text(
                'Tổng tiền (VNĐ) *',
                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountController,
                focusNode: _amountFocus,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'VD: 65.000',
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                  suffixText: 'đ',
                  suffixStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.tealAccent : const Color(0xFF00796B),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập tổng tiền hóa đơn';
                  }
                  final amount = CurrencyFormatter.parseAmount(val);
                  if (amount == null || amount <= 0) {
                    return 'Số tiền phải là số hợp lệ lớn hơn 0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Date Picker & Category Dropdown
              Row(
                children: [
                  // Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ngày hóa đơn *',
                          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.calendar_today_rounded, size: 20),
                            ),
                            child: Text(
                              DateFormatter.formatDate(_selectedDate),
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Danh mục *',
                          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.category_rounded, size: 20),
                          ),
                          items: AppConstants.categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    AppConstants.getCategoryIcon(cat),
                                    size: 16,
                                    color: AppConstants.getCategoryColor(cat, isDark: isDark),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(cat, style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCategory = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Note Field
              Text(
                'Ghi chú thêm',
                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _noteController,
                focusNode: _noteFocus,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'VD: Ăn trưa cùng nhóm bạn, đồ dùng sinh hoạt...',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),

              const SizedBox(height: 20),

              // Collapsible Raw OCR Text
              if (widget.parsedReceipt?.rawText != null &&
                  widget.parsedReceipt!.rawText.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2630) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.grey.shade300,
                    ),
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: _isRawTextExpanded,
                    onExpansionChanged: (val) {
                      setState(() {
                        _isRawTextExpanded = val;
                      });
                    },
                    leading: const Icon(Icons.code_rounded, size: 20),
                    title: const Text(
                      'Văn bản OCR gốc (Debug/Kiểm tra)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: SelectableText(
                          widget.parsedReceipt!.rawText,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: isDark ? Colors.tealAccent : Colors.teal.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Save Button
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveReceipt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00695C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  _isSaving ? 'Đang lưu...' : 'Lưu hóa đơn',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: _isSaving ? null : () => context.pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Hủy'),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
