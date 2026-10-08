import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  TextRecognizer? _textRecognizer;

  OcrService() {
    _initRecognizer();
  }

  void _initRecognizer() {
    try {
      _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    } catch (e) {
      debugPrint('Error initializing TextRecognizer: $e');
    }
  }

  /// Processes the image at [imagePath] and returns the extracted raw OCR text.
  /// Gracefully catches and returns empty/error messages instead of crashing.
  Future<String> recognizeTextFromImagePath(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await _textRecognizer!.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint('OCR Recognition exception: $e');
      rethrow;
    }
  }

  /// Disposes resources held by the ML Kit text recognizer.
  void dispose() {
    try {
      _textRecognizer?.close();
      _textRecognizer = null;
    } catch (e) {
      debugPrint('Error closing TextRecognizer: $e');
    }
  }
}
