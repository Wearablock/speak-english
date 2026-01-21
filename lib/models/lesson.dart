class Lesson {
  final int id;
  final String sentence;
  final String translation;
  final String? pronunciation;
  final int categoryId;
  final int difficulty; // 1: 초급, 2: 중급, 3: 고급

  const Lesson({
    required this.id,
    required this.sentence,
    required this.translation,
    this.pronunciation,
    required this.categoryId,
    required this.difficulty,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as int,
      sentence: json['sentence'] as String,
      translation: json['translation'] as String,
      pronunciation: json['pronunciation'] as String?,
      categoryId: json['category_id'] as int,
      difficulty: json['difficulty'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sentence': sentence,
    'translation': translation,
    'pronunciation': pronunciation,
    'category_id': categoryId,
    'difficulty': difficulty,
  };
}
