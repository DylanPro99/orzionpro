import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class AudioService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  
  AudioRecorder? _recorder;
  AudioPlayer? _player;

  bool _isListening = false;
  bool _isRecording = false;

  bool get isListening => _isListening;
  bool get isRecording => _isRecording;

  AudioService() {
    if (!kIsWeb) {
      _recorder = AudioRecorder();
      _player = AudioPlayer();
    }
  }

  Future<bool> initializeSpeechToText() async {
    if (kIsWeb) {
      if (kDebugMode) {
        print('Speech-to-text not fully supported on web');
      }
      return false;
    }
    
    return await _speech.initialize(
      onStatus: (status) {
        if (kDebugMode) {
          print('Speech status: $status');
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('Speech error: $error');
        }
      },
    );
  }

  Future<void> startListening({
    required Function(String) onResult,
    String localeId = 'es_ES',
  }) async {
    if (kIsWeb) {
      if (kDebugMode) {
        print('Speech-to-text not available on web');
      }
      return;
    }
    
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        _isListening = true;
        await _speech.listen(
          onResult: (result) {
            onResult(result.recognizedWords);
          },
          localeId: localeId,
        );
      }
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  Future<void> speak(String text, {String language = 'es-ES'}) async {
    await _tts.setLanguage(language);
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<String?> startRecording() async {
    if (kIsWeb || _recorder == null) {
      if (kDebugMode) {
        print('Audio recording not available on web');
      }
      return null;
    }
    
    try {
      if (await _recorder!.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _recorder!.start(const RecordConfig(), path: path);
        _isRecording = true;
        return path;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error starting recording: $e');
      }
    }
    return null;
  }

  Future<String?> stopRecording() async {
    if (kIsWeb || _recorder == null) {
      if (kDebugMode) {
        print('Audio recording not available on web');
      }
      return null;
    }
    
    try {
      final path = await _recorder!.stop();
      _isRecording = false;
      return path;
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping recording: $e');
      }
      return null;
    }
  }

  Future<void> playAudio(String path) async {
    if (kIsWeb || _player == null) {
      if (kDebugMode) {
        print('Audio playback from file not available on web');
      }
      return;
    }
    
    try {
      await _player!.play(DeviceFileSource(path));
    } catch (e) {
      if (kDebugMode) {
        print('Error playing audio: $e');
      }
    }
  }

  Future<void> pauseAudio() async {
    if (kIsWeb || _player == null) {
      return;
    }
    
    await _player!.pause();
  }

  Future<void> dispose() async {
    await _speech.cancel();
    await _tts.stop();
    
    if (!kIsWeb) {
      await _recorder?.dispose();
      await _player?.dispose();
    }
  }
}
