import 'package:flutter/foundation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  final Map<String, OnDeviceTranslator> _translators = {};

  Future<String> translate(
    String text, {
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (kIsWeb) {
      if (kDebugMode) {
        print('On-device translation not available on web platform');
      }
      return text;
    }

    final translatorKey = '$sourceLanguage-$targetLanguage';
    
    if (!_translators.containsKey(translatorKey)) {
      _translators[translatorKey] = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.values.firstWhere(
          (lang) => lang.bcpCode == sourceLanguage,
          orElse: () => TranslateLanguage.spanish,
        ),
        targetLanguage: TranslateLanguage.values.firstWhere(
          (lang) => lang.bcpCode == targetLanguage,
          orElse: () => TranslateLanguage.english,
        ),
      );
    }

    try {
      final translator = _translators[translatorKey]!;
      return await translator.translateText(text);
    } catch (e) {
      if (kDebugMode) {
        print('Translation error: $e');
      }
      return text;
    }
  }

  Future<void> downloadLanguageModel(String languageCode) async {
    if (kIsWeb) {
      if (kDebugMode) {
        print('Language model download not available on web platform');
      }
      return;
    }

    final modelManager = OnDeviceTranslatorModelManager();
    final language = TranslateLanguage.values.firstWhere(
      (lang) => lang.bcpCode == languageCode,
      orElse: () => TranslateLanguage.spanish,
    );
    
    await modelManager.downloadModel(language.bcpCode);
  }

  Future<bool> checkModelDownloaded(String languageCode) async {
    if (kIsWeb) {
      return false;
    }

    final modelManager = OnDeviceTranslatorModelManager();
    return await modelManager.isModelDownloaded(languageCode);
  }

  void dispose() {
    if (!kIsWeb) {
      for (var translator in _translators.values) {
        translator.close();
      }
    }
    _translators.clear();
  }
}
