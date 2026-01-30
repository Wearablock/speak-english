import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import '../constants/app_config.dart';

/// 음성 인식 초기화 결과
enum SpeechInitResult {
  success,
  permissionDenied,
  notAvailable,
  error,
}

class SpeechService {
  // 싱글톤 패턴
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  SpeechInitResult? _lastInitResult;

  bool get isListening => _isListening;
  bool get isAvailable => _isInitialized;
  SpeechInitResult? get lastInitResult => _lastInitResult;

  /// 서비스 초기화 (권한 요청 포함)
  Future<SpeechInitResult> initialize() async {
    if (_isInitialized) return SpeechInitResult.success;

    try {
      _isInitialized = await _speech.initialize(
        onError: _onError,
        onStatus: _onStatus,
        debugLogging: AppConfig.isDebug,
      );

      if (_isInitialized) {
        _lastInitResult = SpeechInitResult.success;
        return SpeechInitResult.success;
      } else {
        // 초기화 실패 - 권한 거부 또는 기기 미지원
        _lastInitResult = SpeechInitResult.permissionDenied;
        return SpeechInitResult.permissionDenied;
      }
    } catch (e) {
      debugPrint('Speech initialization failed: $e');
      _lastInitResult = SpeechInitResult.error;
      return SpeechInitResult.error;
    }
  }

  /// 권한 상태만 확인 (초기화 없이)
  Future<bool> hasPermission() async {
    return _speech.hasPermission;
  }

  /// 음성 인식 시작
  /// Returns: 시작 성공 여부. 실패 시 onError 콜백 호출
  Future<bool> startListening({
    required Function(String text, bool isFinal) onResult,
    Function(SpeechInitResult)? onPermissionError,
    Function(String)? onError,
    String locale = AppConfig.speechLocale,
  }) async {
    if (!_isInitialized) {
      final result = await initialize();
      if (result != SpeechInitResult.success) {
        onPermissionError?.call(result);
        return false;
      }
    }

    if (_isListening) return true;

    _isListening = true;

    try {
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
      return true;
    } catch (e) {
      debugPrint('Speech listen error: $e');
      _isListening = false;
      onError?.call(e.toString());
      return false;
    }
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
