import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../services/preferences_service.dart';

/// 학습 라운드 정의
enum LearningRound {
  /// Round 1: 영어 + 번역 전체 표시
  fullView,

  /// Round 2: 영어 부분 모자이크, 터치로 힌트
  wordBlur,

  /// Round 3: 영어 완전 가림, 번역만 표시
  translationOnly,
}

class SentenceDisplay extends StatefulWidget {
  final String sentence;
  final String translation;
  final String? pronunciation;
  final LearningRound round;
  final Function(int)? onHintUsed;
  final bool dismissHint;

  const SentenceDisplay({
    super.key,
    required this.sentence,
    required this.translation,
    this.pronunciation,
    this.round = LearningRound.fullView,
    this.onHintUsed,
    this.dismissHint = false,
  });

  @override
  State<SentenceDisplay> createState() => _SentenceDisplayState();
}

class _SentenceDisplayState extends State<SentenceDisplay> {
  final Set<int> _revealedWords = {};
  final Map<int, Timer> _hideTimers = {};
  bool _showFullSentence = false;
  Timer? _fullSentenceTimer;
  bool _showRound2Hint = false;

  @override
  void initState() {
    super.initState();
    _checkRound2Hint();
  }

  void _checkRound2Hint() {
    if (widget.round == LearningRound.wordBlur &&
        !PreferencesService.isRound2HintShown()) {
      setState(() => _showRound2Hint = true);
    }
  }

  void _dismissRound2Hint() {
    PreferencesService.setRound2HintShown(true);
    setState(() => _showRound2Hint = false);
  }

  // 가려야 할 단어인지 판단 (동사, 명사, 형용사, 부사 등 핵심 단어)
  bool _shouldBlurWord(String word) {
    final lowerWord = word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

    // 유지되는 단어 (관사, 전치사, 인칭대명사, 조동사)
    const keepWords = {
      // 관사
      'a', 'an', 'the',
      // 전치사
      'to', 'for', 'with', 'in', 'on', 'at', 'by', 'of', 'from',
      // 인칭대명사
      'i', 'you', 'he', 'she', 'it', 'we', 'they', 'me', 'him', 'her', 'us',
      'them',
      // 소유대명사
      'my', 'your', 'its', 'our', 'their',
      // 조동사
      'could', 'would', 'should', 'can', 'will', 'may', 'might', 'must',
      // be 동사
      'is', 'am', 'are', 'was', 'were', 'be', 'been', 'being',
      // 기타
      'do', 'does', 'did', 'have', 'has', 'had',
      'and', 'or', 'but', 'so', 'if', 'that', 'this', 'there',
      'not', "don't", "doesn't", "didn't", "can't", "won't",
      'please', 'yes', 'no', 'ok', 'okay',
    };

    return !keepWords.contains(lowerWord) && lowerWord.length > 2;
  }

  void _revealWord(int index) {
    if (widget.round != LearningRound.wordBlur) return;

    setState(() {
      _revealedWords.add(index);
    });

    // 힌트 사용 콜백
    widget.onHintUsed?.call(_revealedWords.length);

    // 기존 타이머 취소
    _hideTimers[index]?.cancel();

    // 2초 후 다시 가림
    _hideTimers[index] = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _revealedWords.remove(index);
        });
      }
    });
  }

  void _revealFullSentence() {
    if (widget.round != LearningRound.translationOnly) return;

    setState(() => _showFullSentence = true);

    // 힌트 사용 콜백 (Round 3에서도 힌트 사용으로 카운트)
    widget.onHintUsed?.call(1);

    _fullSentenceTimer?.cancel();
    _fullSentenceTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showFullSentence = false);
      }
    });
  }

  @override
  void didUpdateWidget(SentenceDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 문장이 바뀌면 힌트 상태 초기화
    if (oldWidget.sentence != widget.sentence) {
      _revealedWords.clear();
      _showFullSentence = false;
      for (final timer in _hideTimers.values) {
        timer.cancel();
      }
      _hideTimers.clear();
      _fullSentenceTimer?.cancel();
    }
    // 라운드가 바뀌면 힌트 체크
    if (oldWidget.round != widget.round) {
      _checkRound2Hint();
    }
    // 외부에서 힌트 닫기 요청
    if (widget.dismissHint && !oldWidget.dismissHint && _showRound2Hint) {
      _dismissRound2Hint();
    }
  }

  @override
  void dispose() {
    for (final timer in _hideTimers.values) {
      timer.cancel();
    }
    _fullSentenceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          child: Padding(
            padding: AppSpacing.cardPaddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Round 표시
                _buildRoundIndicator(context),
                const SizedBox(height: AppSpacing.md),

                // 영어 문장
                _buildSentence(context),

                // 발음 기호 (Round 1에서만)
                if (widget.pronunciation != null &&
                    widget.round == LearningRound.fullView) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '/${widget.pronunciation}/',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],

                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),

                // 번역 (항상 표시)
                Text(
                  widget.translation,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ),
        // Round 2 온보딩 힌트
        if (_showRound2Hint) _buildRound2HintOverlay(context),
      ],
    );
  }

  Widget _buildRound2HintOverlay(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _dismissRound2Hint,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '? 를 터치하면 단어를 확인할 수 있어요',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundIndicator(BuildContext context) {
    final roundNumber = switch (widget.round) {
      LearningRound.fullView => 1,
      LearningRound.wordBlur => 2,
      LearningRound.translationOnly => 3,
    };

    final roundLabel = switch (widget.round) {
      LearningRound.fullView => 'Round 1',
      LearningRound.wordBlur => 'Round 2',
      LearningRound.translationOnly => 'Round 3',
    };

    return Row(
      children: [
        for (int i = 1; i <= 3; i++) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  i <= roundNumber ? AppColors.primary : AppColors.divider,
            ),
          ),
          if (i < 3) const SizedBox(width: 4),
        ],
        const SizedBox(width: AppSpacing.sm),
        Text(
          roundLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildSentence(BuildContext context) {
    switch (widget.round) {
      case LearningRound.fullView:
        return Text(
          widget.sentence,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
        );

      case LearningRound.wordBlur:
        return _buildBlurredSentence(context);

      case LearningRound.translationOnly:
        return _buildHiddenSentence(context);
    }
  }

  Widget _buildBlurredSentence(BuildContext context) {
    final words = widget.sentence.split(' ');
    final textStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          height: 1.6,
        );

    return Wrap(
      spacing: 6,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: List.generate(words.length, (index) {
        final word = words[index];
        final shouldBlur = _shouldBlurWord(word);
        final isRevealed = _revealedWords.contains(index);

        if (!shouldBlur || isRevealed) {
          return Text(word, style: textStyle);
        }

        // Round 3 스타일의 ? 박스
        return GestureDetector(
          onTap: () => _revealWord(index),
          child: Container(
            constraints: BoxConstraints(
              minWidth: 40,
              minHeight: 36,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              '?',
              style: textStyle?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHiddenSentence(BuildContext context) {
    if (_showFullSentence) {
      // 문장 전체 표시
      return AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          widget.sentence,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: AppColors.primary,
              ),
        ),
      );
    }

    return GestureDetector(
      onTap: _revealFullSentence,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app,
              color: AppColors.primary.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
