import '../constants/app_constants.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

class ParsedReceipt {
  final String? merchantName;
  final double? amount;
  final DateTime? date;
  final String? category;
  final double confidence; // 0.0 to 1.0
  final String rawText;

  const ParsedReceipt({
    this.merchantName,
    this.amount,
    this.date,
    this.category,
    this.confidence = 0.0,
    required this.rawText,
  });

  @override
  String toString() {
    return 'ParsedReceipt(merchant: $merchantName, amount: $amount, date: $date, category: $category, conf: $confidence)';
  }
}

class ReceiptParser {
  /// Keywords indicating the grand total or amount to pay in Vietnamese & English receipts
  static final List<RegExp> _totalKeywords = [
    RegExp(r'(tổng\s*tiền|tong\s*tien)', caseSensitive: false),
    RegExp(r'(tổng\s*cộng|tong\s*cong)', caseSensitive: false),
    RegExp(r'(thanh\s*toán|thanh\s*toan)', caseSensitive: false),
    RegExp(r'(tiền\s*thanh\s*toán|tien\s*thanh\s*toan)', caseSensitive: false),
    RegExp(r'(tiền\s*phải\s*trả|tien\s*phai\s*tra)', caseSensitive: false),
    RegExp(r'(khách\s*phải\s*trả|khach\s*phai\s*tra)', caseSensitive: false),
    RegExp(r'(cộng\s*tiền\s*hàng|cong\s*tien\s*hang)', caseSensitive: false),
    RegExp(r'(số\s*tiền|so\s*tien)', caseSensitive: false),
    RegExp(r'(total\s*amount|grand\s*total|amount\s*due|net\s*amount|total)', caseSensitive: false),
    RegExp(r'(tiền\s*mặt|tien\s*mat|cash)', caseSensitive: false),
  ];

  /// Keywords indicating lines that should NOT be considered as merchant names
  static final List<RegExp> _nonMerchantKeywords = [
    RegExp(r'(hóa\s*đơn|hoa\s*don|phiếu\s*thanh\s*toán|phieu\s*thanh\s*toan|receipt|bill|invoice)', caseSensitive: false),
    RegExp(r'(mã\s*chuyến|ma\s*chuyen|chuyến\s*đi|chuyen\s*di|mã\s*đơn|ma\s*don|mã\s*hđ|ma\s*hd)', caseSensitive: false),
    RegExp(r'(tổng\s*tiền|tong\s*tien|tổng\s*cộng|tong\s*cong|thanh\s*toán|thanh\s*toan|total|amount)', caseSensitive: false),
    RegExp(r'(ngày|date|time|giờ|gio)', caseSensitive: false),
    RegExp(r'(thu\s*ngân|cashier|nhân\s*viên|nhan\s*vien)', caseSensitive: false),
    RegExp(r'(mst|mã\s*số\s*thuế|ma\s*so\s*thue|\btax\b)', caseSensitive: false),
    RegExp(r'(địa\s*chỉ|dia\s*chi|address|\btel\b|\bđt\b|hotline|\bsđt\b)', caseSensitive: false),
    RegExp(r'(\bbàn\b|\bban\b|table|order|\bstt\b)', caseSensitive: false),
    RegExp(r'(wifi|pass|mật\s*khẩu)', caseSensitive: false),
  ];

  /// Category mapping heuristics based on merchant names & line items
  static final Map<String, List<RegExp>> _categoryKeywords = {
    AppConstants.categoryFood: [
      RegExp(r'(coffee|cà\s*phê|ca\s*phe|highlands|phúc\s*long|phuc\s*long|starbucks|the\s*coffee\s*house|trà\s*sữa|tra\s*sua|toco|gong\s*cha)', caseSensitive: false),
      RegExp(r'(quán\s*ăn|quan\s*an|nhà\s*hàng|nha\s*hang|cơm|com|phở|pho|bún|bun|bánh\s*mì|banh\s*mi|lẩu|lau|nướng|nuong|kfc|lotteria|jollibee|pizza|burger|mcdonald)', caseSensitive: false),
      RegExp(r'(ẩm\s*thực|am\s*thuc|bakery|bánh|banh|food|restaurant)', caseSensitive: false),
    ],
    AppConstants.categoryShopping: [
      RegExp(r'(winmart|co\.?opmart|big\s*c|go!?|lotte\s*mart|bách\s*hóa\s*xanh|bach\s*hoa\s*xanh|siêu\s*thị|sieu\s*thi|market|mart)', caseSensitive: false),
      RegExp(r'(circle\s*k|7-eleven|gs25|familymart|ministop)', caseSensitive: false),
      RegExp(r'(thời\s*trang|fashion|quần\s*áo|quan\s*ao|giày|giay|zara|uniqlo|shopee|lazada|tiki)', caseSensitive: false),
      RegExp(r'(cửa\s*hàng|cua\s*hang|shop|store)', caseSensitive: false),
    ],
    AppConstants.categoryTransport: [
      RegExp(r'(grab|be\s*bike|be\s*car|gojek|xanh\s*sm|mai\s*linh|vinasun|taxi)', caseSensitive: false),
      RegExp(r'(xăng\s*dầu|xang\s*dau|petrolimex|pv\s*oil|vé\s*xe|ve\s*xe|vé\s*máy\s*bay|ve\s*may\s*bay|phí\s*cầu\s*đường|bãi\s*đỗ\s*xe)', caseSensitive: false),
    ],
    AppConstants.categoryUtilities: [
      RegExp(r'(tiền\s*điện|tien\s*dien|tiền\s*nước|tien\s*nuoc|internet|viettel|vnpt|fpt|mobifone|vinaphone)', caseSensitive: false),
      RegExp(r'(điện\s*lực|dien\s*luc|cấp\s*nước|cap\s*nuoc|chung\s*cư|phí\s*quản\s*lý)', caseSensitive: false),
    ],
    AppConstants.categoryEntertainment: [
      RegExp(r'(cgv|lotte\s*cinema|bhd|galaxy|cinema|rạp\s*phim|rap\s*phim|game|karaoke|billiards|bowling|vé\s*vào\s*cổng)', caseSensitive: false),
    ],
    AppConstants.categoryHealth: [
      RegExp(r'(nhà\s*thuốc|nha\s*thuoc|pharmacy|long\s*châu|long\s*chau|an\s*khang|pharmacity|bệnh\s*viện|benh\s*vien|phòng\s*khám|phong\s*kham|nha\s*khoa)', caseSensitive: false),
    ],
  };

  /// Parses raw OCR text and extracts receipt details.
  static ParsedReceipt parse(String rawOcrText) {
    if (rawOcrText.trim().isEmpty) {
      return ParsedReceipt(rawText: rawOcrText, confidence: 0.0);
    }

    final lines = rawOcrText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final extractedAmount = _extractAmount(lines);
    final extractedMerchant = _extractMerchant(lines);
    final extractedDate = _extractDate(lines);
    final extractedCategory = _inferCategory(extractedMerchant, lines);

    // Calculate heuristic confidence
    var score = 0.0;
    if (extractedAmount != null && extractedAmount > 0) score += 0.45;
    if (extractedMerchant != null && extractedMerchant.isNotEmpty) score += 0.30;
    if (extractedDate != null) score += 0.25;

    return ParsedReceipt(
      merchantName: extractedMerchant,
      amount: extractedAmount,
      date: extractedDate,
      category: extractedCategory,
      confidence: double.parse(score.toStringAsFixed(2)),
      rawText: rawOcrText,
    );
  }

  /// Extracts the grand total amount using keywords and number matching
  static double? _extractAmount(List<String> lines) {
    // Stage 1: Look for lines that contain total keywords and a number on the same line
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      for (final keyword in _totalKeywords) {
        if (keyword.hasMatch(line)) {
          // Check if number is present on this line
          final numbers = _extractNumbersFromText(line);
          if (numbers.isNotEmpty) {
            // Pick the last number on the line (which is usually the amount)
            return numbers.last;
          }

          // Stage 2: Check the next line (often formatted as keyword\n150.000)
          if (i + 1 < lines.length) {
            final nextLine = lines[i + 1];
            final nextNumbers = _extractNumbersFromText(nextLine);
            if (nextNumbers.isNotEmpty) {
              return nextNumbers.last;
            }
          }
        }
      }
    }

    // Stage 3: If no keyword matched with a number, check for standalone currency lines: e.g. "120.000 đ" or "65.000VND"
    final currencyPattern = RegExp(r'(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{1,2})?|\d+)\s*(?:đ|vnđ|vnd)', caseSensitive: false);
    for (int i = lines.length - 1; i >= 0; i--) {
      final match = currencyPattern.firstMatch(lines[i]);
      if (match != null) {
        final parsed = CurrencyFormatter.parseAmount(match.group(0));
        if (parsed != null && parsed > 0) {
          return parsed;
        }
      }
    }

    // Stage 4: Fallback - pick the largest plausible monetary amount in the latter half of the receipt
    final allNumbers = <double>[];
    for (final line in lines) {
      allNumbers.addAll(_extractNumbersFromText(line));
    }
    // Filter numbers to plausible amounts (e.g. > 1,000 VND and < 100,000,000 VND)
    final plausible = allNumbers.where((n) => n >= 1000 && n <= 500000000).toList();
    if (plausible.isNotEmpty) {
      plausible.sort();
      return plausible.last;
    }

    return null;
  }

  /// Extracts individual candidate numbers from a line of text
  static List<double> _extractNumbersFromText(String text) {
    final results = <double>[];
    // Match numbers with dots/commas: 1.250.000, 150,000, 65.000, 50000
    final numberRegex = RegExp(r'(?:\d{1,3}(?:[.,]\d{3})+(?:[.,]\d{2})?|\d{4,})');
    final matches = numberRegex.allMatches(text);

    for (final m in matches) {
      final candidateStr = m.group(0);
      final parsed = CurrencyFormatter.parseAmount(candidateStr);
      if (parsed != null) {
        results.add(parsed);
      }
    }

    // If no thousands separated number, check for smaller integers with currency or standalone
    if (results.isEmpty) {
      final simpleRegex = RegExp(r'\b\d{2,}\b');
      for (final m in simpleRegex.allMatches(text)) {
        final parsed = double.tryParse(m.group(0)!);
        if (parsed != null && parsed >= 1000) {
          results.add(parsed);
        }
      }
    }

    return results;
  }

  /// Extracts the merchant name from the header lines
  static String? _extractMerchant(List<String> lines) {
    if (lines.isEmpty) return null;

    // Typically merchant names are in the first 4 lines
    final candidateLines = lines.take(5).toList();

    for (final line in candidateLines) {
      final trimmed = line.trim();
      // Skip if too short or too long
      if (trimmed.length < 3 || trimmed.length > 50) continue;

      // Skip lines matching non-merchant keywords (bill, tax, phone, etc.)
      var isNonMerchant = false;
      for (final kw in _nonMerchantKeywords) {
        if (kw.hasMatch(trimmed)) {
          isNonMerchant = true;
          break;
        }
      }
      if (isNonMerchant) continue;

      // Skip if line is purely numeric or date
      if (RegExp(r'^[\d\s\W]+$').hasMatch(trimmed)) continue;

      // Clean leading special symbols
      final cleaned = trimmed.replaceAll(RegExp(r'^[^a-zA-Z0-9À-ỹ]+'), '').trim();
      if (cleaned.isNotEmpty) {
        return cleaned;
      }
    }

    // If not found in first 5 lines, return first non-empty alphanumeric line
    for (final line in lines) {
      if (line.length >= 3 && RegExp(r'[a-zA-ZÀ-ỹ]').hasMatch(line)) {
        var isNonMerchant = false;
        for (final kw in _nonMerchantKeywords) {
          if (kw.hasMatch(line)) {
            isNonMerchant = true;
            break;
          }
        }
        if (!isNonMerchant) {
          return line.trim();
        }
      }
    }

    return null;
  }

  /// Extracts the date from text
  static DateTime? _extractDate(List<String> lines) {
    for (final line in lines) {
      final parsed = DateFormatter.parseDate(line);
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  /// Infers category from merchant name and lines
  static String _inferCategory(String? merchant, List<String> lines) {
    if (merchant != null && merchant.isNotEmpty) {
      for (final entry in _categoryKeywords.entries) {
        for (final regex in entry.value) {
          if (regex.hasMatch(merchant)) {
            return entry.key;
          }
        }
      }
    }

    final fullText = lines.join(' ');
    for (final entry in _categoryKeywords.entries) {
      for (final regex in entry.value) {
        if (regex.hasMatch(fullText)) {
          return entry.key;
        }
      }
    }

    return AppConstants.categoryOther;
  }
}
