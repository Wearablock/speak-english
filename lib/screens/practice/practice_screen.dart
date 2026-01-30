import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_colors.dart';
import '../../models/lesson.dart';
import '../../services/ad_service.dart';
import '../../services/speech_service.dart';
import '../../services/progress_service.dart';
import '../../services/sound_service.dart';
import '../../utils/text_similarity.dart';
import '../../widgets/speech/speech_button.dart';
import '../../widgets/speech/speech_result_card.dart';
import '../../widgets/lesson/sentence_display.dart';
import '../../widgets/lesson/accuracy_indicator.dart';
import 'practice_result_screen.dart';

/// 라운드별 결과
class RoundResult {
  final int round;
  final double accuracy;
  final int hintsUsed;

  RoundResult({
    required this.round,
    required this.accuracy,
    this.hintsUsed = 0,
  });

  bool get passed => accuracy >= 0.8;
}

class PracticeScreen extends StatefulWidget {
  final List<Lesson> lessons;

  const PracticeScreen({
    super.key,
    required this.lessons,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final SpeechService _speechService = SpeechService();
  final ProgressService _progressService = ProgressService();
  final SoundService _soundService = SoundService();
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    // 세션 시작 시 광고 카운터 리셋
    _adService.resetLessonCounter();
  }

  int _currentIndex = 0;
  int _currentRound = 1; // 1, 2, 3
  bool _isListening = false;
  String _recognizedText = '';
  double? _accuracy;
  int _hintsUsed = 0;

  // 라운드별 결과 저장
  final List<RoundResult> _currentLessonResults = [];
  final List<double> _sessionAccuracies = [];

  Lesson get _currentLesson => widget.lessons[_currentIndex];
  bool get _hasNext => _currentIndex < widget.lessons.length - 1;

  LearningRound get _learningRound => switch (_currentRound) {
        1 => LearningRound.fullView,
        2 => LearningRound.wordBlur,
        3 => LearningRound.translationOnly,
        _ => LearningRound.fullView,
      };

  void _startListening() async {
    setState(() {
      _recognizedText = '';
      _accuracy = null;
    });

    final success = await _speechService.startListening(
      onResult: (text, isFinal) {
        setState(() {
          _recognizedText = text;
        });

        if (isFinal && text.isNotEmpty) {
          _evaluateResult(text);
        }
      },
      onPermissionError: (result) {
        _showPermissionDialog(result);
      },
      onError: (error) {
        debugPrint('Speech error: $error');
        setState(() => _isListening = false);
      },
    );

    if (success) {
      _soundService.playRecordStart();
      setState(() {
        _isListening = true;
      });
    }
  }

  void _showPermissionDialog(SpeechInitResult result) {
    final l10n = AppLocalizations.of(context)!;

    String title;
    String message;

    switch (result) {
      case SpeechInitResult.permissionDenied:
        title = l10n.microphonePermissionRequired;
        message = l10n.microphonePermissionMessage;
        break;
      case SpeechInitResult.notAvailable:
        title = l10n.speechNotAvailable;
        message = l10n.speechNotAvailableMessage;
        break;
      default:
        title = l10n.error;
        message = l10n.speechErrorMessage;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          if (result == SpeechInitResult.permissionDenied)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _openAppSettings();
              },
              child: Text(l10n.openSettings),
            ),
        ],
      ),
    );
  }

  Future<void> _openAppSettings() async {
    // iOS 설정 앱 열기
    final uri = Uri.parse('app-settings:');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _stopListening() async {
    await _speechService.stopListening();
    setState(() => _isListening = false);

    if (_recognizedText.isNotEmpty && _accuracy == null) {
      _evaluateResult(_recognizedText);
    }
  }

  void _evaluateResult(String spokenText) async {
    final accuracy = TextSimilarity.calculate(
      spokenText,
      _currentLesson.sentence,
    );

    setState(() {
      _accuracy = accuracy;
      _isListening = false;
    });

    // 라운드 결과 저장
    _currentLessonResults.add(RoundResult(
      round: _currentRound,
      accuracy: accuracy,
      hintsUsed: _currentRound == 2 ? _hintsUsed : 0,
    ));
  }

  void _onHintUsed(int totalHints) {
    setState(() {
      _hintsUsed = totalHints;
    });
  }

  void _nextRound() {
    if (_accuracy == null) return;

    final passed = _accuracy! >= 0.8;

    if (passed && _currentRound < 3) {
      // 성공: 다음 라운드로
      setState(() {
        _currentRound++;
        _recognizedText = '';
        _accuracy = null;
        _hintsUsed = 0;
      });
    } else if (passed && _currentRound == 3) {
      // Round 3 성공: 다음 레슨으로
      _completeLessonAndNext();
    } else {
      // 실패: 같은 라운드 재시도
      setState(() {
        _recognizedText = '';
        _accuracy = null;
      });
    }
  }

  void _skipToNextLesson() {
    // 현재 레슨 스킵 (최종 정확도는 마지막 시도 기준)
    _completeLessonAndNext();
  }

  void _completeLessonAndNext() async {
    // 최종 정확도 계산 (Round 3 정확도 - 힌트 페널티)
    final finalAccuracy = _calculateFinalAccuracy();

    // 결과 저장
    _progressService.saveResult(_currentLesson.id, finalAccuracy);
    _sessionAccuracies.add(finalAccuracy);

    if (!_hasNext) {
      // 세션 완료 시 전면 광고 표시
      await _adService.showInterstitialAd();

      if (!mounted) return;

      // 결과 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PracticeResultScreen(
            lessons: widget.lessons,
            accuracies: _sessionAccuracies,
          ),
        ),
      );
      return;
    }

    // 레슨 완료 시 광고 트리거 (3개마다 전면 광고)
    await _adService.onLessonCompleted();

    if (!mounted) return;

    // 다음 레슨으로
    setState(() {
      _currentIndex++;
      _currentRound = 1;
      _recognizedText = '';
      _accuracy = null;
      _hintsUsed = 0;
      _currentLessonResults.clear();
    });
  }

  double _calculateFinalAccuracy() {
    if (_currentLessonResults.isEmpty) return 0.0;

    // Round 3 결과가 있으면 사용, 없으면 마지막 결과 사용
    final round3Results =
        _currentLessonResults.where((r) => r.round == 3).toList();
    final baseAccuracy = round3Results.isNotEmpty
        ? round3Results.last.accuracy
        : _currentLessonResults.last.accuracy;

    // 힌트 페널티 계산 (Round 2에서 사용한 힌트당 2% 감점)
    final round2Results =
        _currentLessonResults.where((r) => r.round == 2).toList();
    final totalHints =
        round2Results.fold(0, (sum, r) => sum + r.hintsUsed);
    final hintPenalty = totalHints * 0.02;

    return max(0.0, baseAccuracy - hintPenalty);
  }

  void _retryRound() {
    setState(() {
      _recognizedText = '';
      _accuracy = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentIndex + 1} / ${widget.lessons.length}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              // 진행 바
              LinearProgressIndicator(
                value: (_currentIndex + 1) / widget.lessons.length,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 문장 표시 (Round에 따라 다르게)
              SentenceDisplay(
                sentence: _currentLesson.sentence,
                translation: _currentLesson.getTranslation(
                  Localizations.localeOf(context).toString(),
                ),
                pronunciation: _currentLesson.pronunciation,
                round: _learningRound,
                onHintUsed: _onHintUsed,
                dismissHint: _isListening,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 인식 결과 또는 정확도
              Expanded(
                child: _accuracy != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AccuracyIndicator(accuracy: _accuracy!),
                            const SizedBox(height: AppSpacing.md),
                            _buildResultMessage(context, l10n),
                          ],
                        ),
                      )
                    : Center(
                        child: SpeechResultCard(
                          recognizedText: _recognizedText,
                          accuracy: null,
                        ),
                      ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 버튼 영역
              _buildButtons(context, l10n),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultMessage(BuildContext context, AppLocalizations l10n) {
    final passed = _accuracy! >= 0.8;

    if (passed) {
      if (_currentRound < 3) {
        return Text(
          'Round $_currentRound 성공! 다음 라운드로 이동합니다.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.success,
              ),
        );
      } else {
        return Text(
          '학습 완료!',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
        );
      }
    } else {
      return Text(
        '다시 시도해보세요.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.warning,
            ),
      );
    }
  }

  Widget _buildButtons(BuildContext context, AppLocalizations l10n) {
    if (_accuracy == null) {
      // 음성 입력 중
      return Column(
        children: [
          Center(
            child: SpeechButton(
              isListening: _isListening,
              onPressed: _isListening ? _stopListening : _startListening,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _isListening ? l10n.listening : l10n.tapToSpeak,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    final passed = _accuracy! >= 0.8;

    if (passed) {
      // 성공 시
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _nextRound,
          child: Text(_currentRound < 3
              ? 'Round ${_currentRound + 1}로 이동'
              : (_hasNext ? l10n.next : l10n.finish)),
        ),
      );
    } else {
      // 실패 시
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _skipToNextLesson,
              child: const Text('건너뛰기'),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: ElevatedButton(
              onPressed: _retryRound,
              child: Text(l10n.tryAgain),
            ),
          ),
        ],
      );
    }
  }
}
