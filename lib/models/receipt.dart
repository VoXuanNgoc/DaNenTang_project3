class Receipt {
  final int? id;
  final String merchantName;
  final double amount;
  final DateTime date;
  final String category;
  final String? imagePath;
  final String? rawOcrText;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Receipt({
    this.id,
    required this.merchantName,
    required this.amount,
    required this.date,
    required this.category,
    this.imagePath,
    this.rawOcrText,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  Receipt copyWith({
    int? id,
    String? merchantName,
    double? amount,
    DateTime? date,
    String? category,
    String? imagePath,
    String? rawOcrText,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Receipt(
      id: id ?? this.id,
      merchantName: merchantName ?? this.merchantName,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'merchant_name': merchantName,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'image_path': imagePath,
      'raw_ocr_text': rawOcrText,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map['id'] as int?,
      merchantName: map['merchant_name'] as String? ?? 'Không xác định',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] != null
          ? DateTime.tryParse(map['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      category: map['category'] as String? ?? 'Khác',
      imagePath: map['image_path'] as String?,
      rawOcrText: map['raw_ocr_text'] as String?,
      note: map['note'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Receipt(id: $id, merchant: $merchantName, amount: $amount, date: $date, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Receipt &&
        other.id == id &&
        other.merchantName == merchantName &&
        other.amount == amount &&
        other.date == date &&
        other.category == category &&
        other.imagePath == imagePath &&
        other.rawOcrText == rawOcrText &&
        other.note == note;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      merchantName,
      amount,
      date,
      category,
      imagePath,
      rawOcrText,
      note,
    );
  }
}
