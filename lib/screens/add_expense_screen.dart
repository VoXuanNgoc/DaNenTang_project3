import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../models/receipt.dart';
import '../state/receipt_providers.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _merchantController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final FocusNode _merchantFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();
  final FocusNode _noteFocus = FocusNode();

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = AppConstants.categoryFood;
  String? _imagePath;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

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
      helpText: 'CHỌN NGÀY CHI TIÊU',
      cancelText: 'HỦY',
      confirmText: 'CHỌN',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (file != null) {
        setState(() {
          _imagePath = file.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chọn ảnh: $e')),
        );
      }
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final parsedAmount = CurrencyFormatter.parseAmount(_amountController.text);
    if (parsedAmount == null || parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số tiền phải lớn hơn 0'),
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
        imagePath: _imagePath,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(receiptListProvider.notifier).addReceipt(receipt);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm chi tiêu thành công!'),
          backgroundColor: Color(0xFF00796B),
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lưu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm chi tiêu thủ công'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Merchant Name Field
              Text(
                'Tên cửa hàng / Dịch vụ *',
                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _merchantController,
                focusNode: _merchantFocus,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'VD: Phở Hà Nội, Highlands Coffee, Circle K...',
                  prefixIcon: Icon(Icons.storefront_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập tên cửa hàng hoặc dịch vụ';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Amount Field
              Text(
                'Số tiền chi tiêu (VNĐ) *',
                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountController,
                focusNode: _amountFocus,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'VD: 50.000',
                  prefixIcon: const Icon(Icons.payments_rounded),
                  suffixText: 'đ',
                  suffixStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.tealAccent : const Color(0xFF00796B),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  final amt = CurrencyFormatter.parseAmount(val);
                  if (amt == null || amt <= 0) {
                    return 'Số tiền phải là số hợp lệ lớn hơn 0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Date & Category Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ngày chi tiêu *',
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
                'Ghi chú',
                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _noteController,
                focusNode: _noteFocus,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Ghi chú chi tiết về khoản chi...',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),

              const SizedBox(height: 18),

              // Optional Receipt Image Picker
              Text(
                'Hình ảnh hóa đơn (tùy chọn)',
                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              if (_imagePath != null)
                Stack(
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.file(
                        File(_imagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton.filled(
                        onPressed: () {
                          setState(() {
                            _imagePath = null;
                          });
                        },
                        icon: const Icon(Icons.close_rounded, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: const Text('Chụp ảnh'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined, size: 18),
                        label: const Text('Chọn ảnh'),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 28),

              // Save Button
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveExpense,
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
                    : const Icon(Icons.check_rounded),
                label: Text(
                  _isSaving ? 'Đang lưu...' : 'Thêm chi tiêu',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
