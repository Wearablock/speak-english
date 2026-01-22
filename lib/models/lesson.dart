class Lesson {
  final int id;
  final String sentence;
  final Map<String, String> translations;
  final String? pronunciation;
  final int categoryId;
  final int difficulty; // 1: 초급, 2: 중급, 3: 고급

  const Lesson({
    required this.id,
    required this.sentence,
    required this.translations,
    this.pronunciation,
    required this.categoryId,
    required this.difficulty,
  });

  /// 현재 로케일에 맞는 번역 반환
  /// fallback: en -> sentence
  String getTranslation(String localeCode) {
    // 직접 매칭 시도
    if (translations.containsKey(localeCode)) {
      return translations[localeCode]!;
    }

    // zh-TW, zh_TW 등 중국어 번체 처리
    if (localeCode.startsWith('zh') &&
        (localeCode.contains('TW') || localeCode.contains('Hant'))) {
      return translations['zh-TW'] ?? translations['zh-CN'] ?? translations['en'] ?? sentence;
    }

    // zh, zh-CN, zh_CN 등 중국어 간체 처리
    if (localeCode.startsWith('zh')) {
      return translations['zh-CN'] ?? translations['zh-TW'] ?? translations['en'] ?? sentence;
    }

    // 언어 코드만 추출하여 재시도 (예: "en-US" -> "en")
    final baseLanguage = localeCode.split(RegExp(r'[-_]')).first;
    if (translations.containsKey(baseLanguage)) {
      return translations[baseLanguage]!;
    }

    return translations['en'] ?? sentence;
  }

  /// 하위 호환성을 위한 translation getter (기본값: 한국어)
  String get translation => translations['ko'] ?? translations['en'] ?? sentence;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    // 다국어 translations 또는 기존 단일 translation 지원
    Map<String, String> translations = {};

    if (json['translations'] != null) {
      // 새 형식: translations 객체
      translations = Map<String, String>.from(json['translations']);
    } else if (json['translation'] != null) {
      // 기존 형식: 단일 translation (한국어로 간주)
      translations = {'ko': json['translation'] as String};
    }

    return Lesson(
      id: json['id'] as int,
      sentence: json['sentence'] as String,
      translations: translations,
      pronunciation: json['pronunciation'] as String?,
      categoryId: json['category_id'] as int,
      difficulty: json['difficulty'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sentence': sentence,
    'translations': translations,
    'pronunciation': pronunciation,
    'category_id': categoryId,
    'difficulty': difficulty,
  };
}
