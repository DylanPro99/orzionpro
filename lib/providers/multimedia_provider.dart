import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/ocr_service.dart';
import '../services/translation_service.dart';

class MultimediaProvider with ChangeNotifier {
  final AudioService _audioService = AudioService();
  final OCRService _ocrService = OCRService();
  final TranslationService _translationService = TranslationService();

  bool _isListening = false;
  bool _isRecording = false;
  bool _isSpeaking = false;
  String _recognizedText = '';
  String? _currentRecordingPath;

  bool get isListening => _isListening;
  bool get isRecording => _isRecording;
  bool get isSpeaking => _isSpeaking;
  String get recognizedText => _recognizedText;
  String? get currentRecordingPath => _currentRecordingPath;

  Future<void> startListening({
    required Function(String) onResult,
    String locale = 'es_ES',
  }) async {
    await _audioService.initializeSpeechToText();
    await _audioService.startListening(
      onResult: (text) {
        _recognizedText = text;
        onResult(text);
        notifyListeners();
      },
      localeId: locale,
    );
    _isListening = true;
    notifyListeners();
  }

  Future<void> stopListening() async {
    await _audioService.stopListening();
    _isListening = false;
    notifyListeners();
  }

  Future<void> speak(String text, {String language = 'es-ES'}) async {
    _isSpeaking = true;
    notifyListeners();
    
    await _audioService.speak(text, language: language);
    
    _isSpeaking = false;
    notifyListeners();
  }

  Future<void> stopSpeaking() async {
    await _audioService.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  Future<void> startRecording() async {
    final path = await _audioService.startRecording();
    if (path != null) {
      _currentRecordingPath = path;
      _isRecording = true;
      notifyListeners();
    }
  }

  Future<String?> stopRecording() async {
    final path = await _audioService.stopRecording();
    _isRecording = false;
    _currentRecordingPath = null;
    notifyListeners();
    return path;
  }

  Future<void> playAudio(String path) async {
    await _audioService.playAudio(path);
  }

  Future<void> pauseAudio() async {
    await _audioService.pauseAudio();
  }

  Future<String> extractTextFromImage(String imagePath) async {
    try {
      return await _ocrService.extractTextFromImage(imagePath);
    } catch (e) {
      print('Error extracting text: $e');
      return '';
    }
  }

  Future<String> translateText(
    String text, {
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    return await _translationService.translate(
      text,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
  }

  Future<void> downloadLanguageModel(String languageCode) async {
    await _translationService.downloadLanguageModel(languageCode);
  }

  Future<bool> isLanguageModelDownloaded(String languageCode) async {
    return await _translationService.checkModelDownloaded(languageCode);
  }

  @override
  void dispose() {
    _audioService.dispose();
    _ocrService.dispose();
    _translationService.dispose();
    super.dispose();
  }
}
