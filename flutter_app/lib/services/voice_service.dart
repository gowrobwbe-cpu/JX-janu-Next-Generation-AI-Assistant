import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  static final VoiceService instance = VoiceService._init();

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isSpeechInitialized = false;
  bool isListening = false;
  bool isSpeaking = false;

  VoiceService._init() {
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage("en-US"); // Default speech language
    await _tts.setPitch(1.3); // Higher pitch for cute anime voice
    await _tts.setSpeechRate(0.95); // Natural conversational rate

    _tts.setStartHandler(() {
      isSpeaking = true;
    });

    _tts.setCompletionHandler(() {
      isSpeaking = false;
    });

    _tts.setErrorHandler((msg) {
      isSpeaking = false;
    });
  }

  Future<bool> initSpeech() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return false;

    _isSpeechInitialized = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          isListening = false;
        }
      },
      onError: (errorNotification) {
        isListening = false;
      },
    );
    return _isSpeechInitialized;
  }

  Future<void> startListening({required Function(String text) onResult}) async {
    if (!_isSpeechInitialized) {
      final ok = await initSpeech();
      if (!ok) return;
    }

    isListening = true;
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult || result.recognizedWords.isNotEmpty) {
          onResult(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      cancelOnError: true,
    );
  }

  Future<void> stopListening() async {
    isListening = false;
    await _speech.stop();
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    isSpeaking = false;
    await _tts.stop();
  }
}
