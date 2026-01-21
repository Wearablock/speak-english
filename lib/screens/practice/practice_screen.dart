import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/app_spacing.dart';
import '../../models/lesson.dart';
import '../../services/speech_service.dart';
import '../../services/progress_service.dart';
import '../../utils/text_similarity.dart';
import '../../widgets/speech/speech_button.dart';
import '../../widgets/speech/speech_result_card.dart';
import '../../widgets/lesson/sentence_display.dart';
import '../../widgets/lesson/accuracy_indicator.dart';
import 'practice_result_screen.dart';

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

  int _currentIndex = 0;
  bool _isListening = false;
  String _recognizedText = '';
  double? _accuracy;
  final List<double> _sessionAccuracies = [];

  Lesson get _currentLesson => widget.lessons[_currentIndex];
  bool get _hasNext => _currentIndex < widget.lessons.length - 1;

  void _startListening() async {
    setState(() {
      _isListening = true;
      _recognizedText = '';
      _accuracy = null;
    });

    await _speechService.startListening(
      onResult: (text, isFinal) {
        setState(() {
          _recognizedText = text;
        });

        if (isFinal && text.isNotEmpty) {
          _evaluateResult(text);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
      },
    );
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

    // 결과 저장
    await _progressService.saveResult(_currentLesson.id, accuracy);
    _sessionAccuracies.add(accuracy);
  }

  void _nextLesson() {
    if (!_hasNext) {
      // 세션 완료
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

    setState(() {
      _currentIndex++;
      _recognizedText = '';
      _accuracy = null;
    });
  }

  void _retryLesson() {
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

              // 문장 표시
              SentenceDisplay(
                sentence: _currentLesson.sentence,
                translation: _currentLesson.translation,
                pronunciation: _currentLesson.pronunciation,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 인식 결과 또는 정확도
              Expanded(
                child: _accuracy != null
                    ? Center(
                        child: AccuracyIndicator(accuracy: _accuracy!),
                      )
                    : SpeechResultCard(
                        recognizedText: _recognizedText,
                        accuracy: null,
                      ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 버튼 영역
              if (_accuracy == null) ...[
                // 음성 버튼
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
              ] else ...[
                // 결과 후 버튼들
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _retryLesson,
                        child: Text(l10n.tryAgain),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _nextLesson,
                        child: Text(_hasNext ? l10n.next : l10n.finish),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
