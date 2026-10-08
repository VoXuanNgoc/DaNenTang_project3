import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../core/parsers/receipt_parser.dart';
import '../services/ocr_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final OcrService _ocrService = OcrService();

  File? _selectedImage;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _pickAndProcessImage(ImageSource source) async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (pickedFile == null) {
        // User cancelled picker
        return;
      }

      final file = File(pickedFile.path);
      setState(() {
        _selectedImage = file;
        _isProcessing = true;
      });

      // Execute on-device ML Kit OCR
      final rawOcrText = await _ocrService.recognizeTextFromImagePath(file.path);

      if (!mounted) return;

      if (rawOcrText.trim().isEmpty) {
        setState(() {
          _isProcessing = false;
          _errorMessage =
              'Không tìm thấy văn bản trong hình ảnh. Vui lòng chụp rõ nét hơn hoặc nhập thông tin thủ công.';
        });
        return;
      }

      // Parse OCR text using regex & heuristics
      final parsed = ReceiptParser.parse(rawOcrText);

      setState(() {
        _isProcessing = false;
      });

      // Navigate to Review & Verification screen
      if (mounted) {
        context.push(
          '/review',
          extra: {
            'parsed': parsed,
            'imagePath': file.path,
          },
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage =
            'Có lỗi xảy ra trong quá trình nhận diện OCR: $e. Bạn có thể nhập thông tin thủ công.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét hóa đơn OCR'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instruction banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2630) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF004D40) : const Color(0xFFE0F2F1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.document_scanner_rounded,
                        color: Color(0xFF00796B),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nhận diện trên thiết bị',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sử dụng Google ML Kit OCR để tự động trích xuất cửa hàng, số tiền và ngày lập hóa đơn.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Image Preview or Scan Target Box
              Container(
                height: 280,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF19202A) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.teal.shade700 : const Color(0xFF80CBC4),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _isProcessing
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFF00796B),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Đang xử lý hình ảnh...',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Đang chạy mô hình ML Kit OCR trên thiết bị',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _selectedImage != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton.filled(
                                  onPressed: () {
                                    setState(() {
                                      _selectedImage = null;
                                      _errorMessage = null;
                                    });
                                  },
                                  icon: const Icon(Icons.close_rounded, size: 20),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.black54,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 64,
                                  color: isDark ? Colors.tealAccent : const Color(0xFF00796B),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Chụp ảnh hoặc chọn hóa đơn',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Đảm bảo hình ảnh rõ nét và đủ ánh sáng',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark ? Colors.white54 : Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.red, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Capture Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : () => _pickAndProcessImage(ImageSource.camera),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00695C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text(
                        'Chụp ảnh',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : () => _pickAndProcessImage(ImageSource.gallery),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.photo_library_rounded),
                      label: const Text(
                        'Chọn từ thư viện',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Fallback manual entry button
              TextButton.icon(
                onPressed: () => context.push('/add'),
                icon: const Icon(Icons.edit_note_rounded, size: 20),
                label: const Text('Nhập thông tin hóa đơn thủ công'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
