import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import '../constants/app_config.dart';

class SpeechService {
  // 싱글톤 패턴
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isAvailable => _isInitialized;

  /// 서비스 초기화
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onError: _onError,
        onStatus: _onStatus,
        debugLogging: AppConfig.isDebug,
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('Speech initialization failed: $e');
      return false;
    }
  }

  /// 음성 인식 시작
  Future<void> startListening({
    required Function(String text, bool isFinal) onResult,
    Function(String)? onError,
    String locale = AppConfig.speechLocale,
  }) async {
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) {
        onError?.call('Speech recognition not available');
        return;
      }
    }

    if (_isListening) return;

    _isListening = true;

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      localeId: locale,
      listenFor: Duration(seconds: AppConfig.speechListenDurationSeconds),
      pauseFor: Duration(seconds: AppConfig.speechPauseDurationSeconds),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  /// 음성 인식 중지
  Future<void> stopListening() async {
    if (!_isListening) return;
    await _speech.stop();
    _isListening = false;
  }

  /// 음성 인식 취소
  Future<void> cancelListening() async {
    await _speech.cancel();
    _isListening = false;
  }

  /// 지원 언어 목록
  Future<List<LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) await initialize();
    return _speech.locales();
  }

  void _onError(SpeechRecognitionError error) {
    debugPrint('Speech error: ${error.errorMsg}');
    _isListening = false;
  }

  void _onStatus(String status) {
    debugPrint('Speech status: $status');
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
    }
  }
}
