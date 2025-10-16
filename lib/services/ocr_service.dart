import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  TextRecognizer? _textRecognizer;

  OCRService() {
    if (!kIsWeb) {
      _textRecognizer = TextRecognizer();
    }
  }

  Future<String> extractTextFromImage(String imagePath) async {
    if (kIsWeb || _textRecognizer == null) {
      if (kDebugMode) {
        print('OCR not available on web platform');
      }
      return '';
    }

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer!.processImage(inputImage);
      
      return recognizedText.text;
    } catch (e) {
      if (kDebugMode) {
        print('Error extracting text: $e');
      }
      return '';
    }
  }

  Future<List<TextBlock>> extractTextBlocks(String imagePath) async {
    if (kIsWeb || _textRecognizer == null) {
      if (kDebugMode) {
        print('OCR not available on web platform');
      }
      return [];
    }

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer!.processImage(inputImage);
      
      return recognizedText.blocks;
    } catch (e) {
      if (kDebugMode) {
        print('Error extracting text blocks: $e');
      }
      return [];
    }
  }

  void dispose() {
    if (!kIsWeb) {
      _textRecognizer?.close();
    }
  }
}
