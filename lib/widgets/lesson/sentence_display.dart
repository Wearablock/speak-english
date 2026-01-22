import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';

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

  const SentenceDisplay({
    super.key,
    required this.sentence,
    required this.translation,
    this.pronunciation,
    this.round = LearningRound.fullView,
    this.onHintUsed,
  });

  @override
  State<SentenceDisplay> createState() => _SentenceDisplayState();
}

class _SentenceDisplayState extends State<SentenceDisplay> {
  final Set<int> _revealedWords = {};
  final Map<int, Timer> _hideTimers = {};

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
      'i', 'you', 'he', 'she', 'it', 'we', 'they', 'me', 'him', 'her', 'us', 'them',
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

  @override
  void didUpdateWidget(SentenceDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 문장이 바뀌면 힌트 상태 초기화
    if (oldWidget.sentence != widget.sentence) {
      _revealedWords.clear();
      for (final timer in _hideTimers.values) {
        timer.cancel();
      }
      _hideTimers.clear();
    }
  }

  @override
  void dispose() {
    for (final timer in _hideTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPaddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Round 표시
            _buildRoundIndicator(context),
            const SizedBox(height: AppSpacing.sm),

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
              color: i <= roundNumber
                  ? AppColors.primary
                  : AppColors.divider,
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
          height: 1.4,
        );

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: List.generate(words.length, (index) {
        final word = words[index];
        final shouldBlur = _shouldBlurWord(word);
        final isRevealed = _revealedWords.contains(index);

        if (!shouldBlur || isRevealed) {
          return Text(word, style: textStyle);
        }

        // 모자이크 처리된 단어 (터치 가능)
        return GestureDetector(
          onTap: () => _revealWord(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '█' * (word.length > 6 ? 6 : word.length),
              style: textStyle?.copyWith(
                color: AppColors.primary.withValues(alpha: 0.4),
                letterSpacing: 2,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHiddenSentence(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Text(
          '?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ),
    );
  }
}
