class LessonCategory {
  final int id;
  final String nameKey; // l10n 키
  final String icon;
  int lessonCount;

  LessonCategory({
    required this.id,
    required this.nameKey,
    required this.icon,
    this.lessonCount = 0,
  });

  factory LessonCategory.fromJson(Map<String, dynamic> json) {
    return LessonCategory(
      id: json['id'] as int,
      nameKey: json['name_key'] as String,
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name_key': nameKey,
    'icon': icon,
  };
}
