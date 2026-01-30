import 'package:flutter/material.dart';
import '../../constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../models/lesson.dart';
import '../../models/lesson_category.dart';
import '../../models/user_progress.dart';
import '../../services/lesson_service.dart';
import '../../services/progress_service.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/lesson/lesson_card.dart';
import '../practice/practice_screen.dart';

class LessonListScreen extends StatefulWidget {
  final LessonCategory category;

  const LessonListScreen({
    super.key,
    required this.category,
  });

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  final LessonService _lessonService = LessonService();
  final ProgressService _progressService = ProgressService();

  List<Lesson>? _lessons;
  Map<int, UserProgress>? _progressMap;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_lessons == null) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final locale = Localizations.localeOf(context).toString();
    final lessons = await _lessonService.getLessonsByCategory(
      widget.category.id,
      locale: locale,
    );
    final progress = await _progressService.getAllProgress();

    if (mounted) {
      setState(() {
        _lessons = lessons;
        _progressMap = progress;
      });
    }
  }

  void _startLesson(Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeScreen(lessons: [lesson]),
      ),
    ).then((_) => _loadData());
  }

  String _getCategoryName(BuildContext context, String nameKey) {
    final l10n = AppLocalizations.of(context)!;
    switch (nameKey) {
      case 'category_greetings':
        return l10n.category_greetings;
      case 'category_daily':
        return l10n.category_daily;
      case 'category_business':
        return l10n.category_business;
      case 'category_travel':
        return l10n.category_travel;
      case 'category_shopping':
        return l10n.category_shopping;
      default:
        return nameKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getCategoryName(context, widget.category.nameKey)),
      ),
      body: _lessons == null
          ? const LoadingIndicator()
          : ListView.builder(
              padding: AppSpacing.screenPadding,
              itemCount: _lessons!.length,
              itemBuilder: (context, index) {
                final lesson = _lessons![index];
                final progress = _progressMap?[lesson.id];

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: LessonCard(
                    lesson: lesson,
                    progress: progress,
                    onTap: () => _startLesson(lesson),
                  ),
                );
              },
            ),
    );
  }
}
