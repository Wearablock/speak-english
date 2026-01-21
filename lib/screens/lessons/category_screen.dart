import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/app_spacing.dart';
import '../../models/lesson_category.dart';
import '../../services/lesson_service.dart';
import '../../widgets/common/loading_indicator.dart';
import 'lesson_list_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final LessonService _lessonService = LessonService();
  List<LessonCategory>? _categories;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _lessonService.getCategories();
    if (mounted) {
      setState(() => _categories = categories);
    }
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'handshake':
        return PhosphorIcons.handshake(PhosphorIconsStyle.fill);
      case 'sun':
        return PhosphorIcons.sun(PhosphorIconsStyle.fill);
      case 'briefcase':
        return PhosphorIcons.briefcase(PhosphorIconsStyle.fill);
      case 'airplane':
        return PhosphorIcons.airplane(PhosphorIconsStyle.fill);
      case 'shopping_cart':
        return PhosphorIcons.shoppingCart(PhosphorIconsStyle.fill);
      default:
        return PhosphorIcons.folder(PhosphorIconsStyle.fill);
    }
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.lessons),
      ),
      body: _categories == null
          ? const LoadingIndicator()
          : ListView.builder(
              padding: AppSpacing.screenPadding,
              itemCount: _categories!.length,
              itemBuilder: (context, index) {
                final category = _categories![index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListTile(
                    leading: Icon(
                      _getCategoryIcon(category.icon),
                      size: 32,
                    ),
                    title: Text(_getCategoryName(context, category.nameKey)),
                    subtitle: Text('${category.lessonCount} lessons'),
                    trailing: Icon(
                      PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LessonListScreen(category: category),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
