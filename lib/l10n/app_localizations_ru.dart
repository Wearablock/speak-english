// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Говори по-английски';

  @override
  String get appSubtitle => 'Практика разговорной речи';

  @override
  String get home => 'Главная';

  @override
  String get lessons => 'Уроки';

  @override
  String get progress => 'Прогресс';

  @override
  String get settings => 'Настройки';

  @override
  String get startPractice => 'Начать практику';

  @override
  String get continuePractice => 'Продолжить';

  @override
  String get todayProgress => 'Прогресс сегодня';

  @override
  String get streak => 'Серия';

  @override
  String get days => 'дней';

  @override
  String get completed => 'Завершено';

  @override
  String get accuracy => 'Точность';

  @override
  String get category_greetings => 'Приветствия';

  @override
  String get category_daily => 'Повседневная жизнь';

  @override
  String get category_business => 'Бизнес';

  @override
  String get category_travel => 'Путешествия';

  @override
  String get category_shopping => 'Покупки';

  @override
  String get difficulty_beginner => 'Начинающий';

  @override
  String get difficulty_intermediate => 'Средний';

  @override
  String get difficulty_advanced => 'Продвинутый';

  @override
  String get tapToSpeak => 'Нажмите, чтобы говорить';

  @override
  String get listening => 'Слушаю...';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get next => 'Далее';

  @override
  String get finish => 'Завершить';

  @override
  String get feedback_perfect => 'Отлично!';

  @override
  String get feedback_great => 'Прекрасно!';

  @override
  String get feedback_good => 'Хорошо!';

  @override
  String get feedback_keep_practicing => 'Продолжайте практиковаться!';

  @override
  String get feedback_try_again => 'Попробуйте ещё раз!';

  @override
  String get practiceComplete => 'Практика завершена!';

  @override
  String get lessonsCompleted => 'Уроков завершено';

  @override
  String get averageAccuracy => 'Средняя точность';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Тема';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeSystem => 'Системная';

  @override
  String get removeAds => 'Убрать рекламу';

  @override
  String get restorePurchase => 'Восстановить покупку';

  @override
  String get premiumActivated => 'Активировано';

  @override
  String get loadingProduct => 'Загрузка...';

  @override
  String get purchaseFailed => 'Ошибка покупки';

  @override
  String get purchasesRestored => 'Покупки восстановлены';

  @override
  String get about => 'О приложении';

  @override
  String get version => 'Версия';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsOfService => 'Условия использования';

  @override
  String get microphonePermission => 'Доступ к микрофону';

  @override
  String get microphonePermissionDesc =>
      'Для распознавания речи необходим доступ к микрофону';

  @override
  String get allow => 'Разрешить';

  @override
  String get deny => 'Отклонить';

  @override
  String get errorNoMicrophone => 'Микрофон недоступен';

  @override
  String get errorSpeechNotAvailable => 'Распознавание речи недоступно';

  @override
  String get errorNetwork => 'Ошибка сети';

  @override
  String get retry => 'Повторить';

  @override
  String get cancel => 'Отмена';

  @override
  String get ok => 'OK';

  @override
  String get termsAndPolicies => 'Условия и политики';

  @override
  String get support => 'Поддержка';

  @override
  String get newLessonsAvailable => 'Доступны новые уроки!';

  @override
  String dataUpdated(String version) {
    return 'Уроки обновлены до v$version';
  }

  @override
  String get checkingForUpdates => 'Проверка обновлений...';

  @override
  String get upToDate => 'Уже последняя версия';

  @override
  String get onboardingGoalTitle => 'Сколько вы хотите учиться каждый день?';

  @override
  String get onboardingGoalHint => 'Вы можете изменить это в настройках позже';

  @override
  String get dailyGoal => 'Ежедневная цель';

  @override
  String get setDailyGoal => 'Установить цель';

  @override
  String get goalLight => 'Мало';

  @override
  String get goalNormal => 'Обычно';

  @override
  String get goalIntense => 'Много';

  @override
  String get goalCustom => 'Свой вариант';

  @override
  String get goalCustomDesc => 'Настройте свой темп';

  @override
  String get recommended => 'Рекомендуется';

  @override
  String get daily => 'Ежедневно ';

  @override
  String get sentences => ' предложений';

  @override
  String get approximately => '~';

  @override
  String get minutes => ' мин';

  @override
  String get estimatedTime => 'Примерное время';

  @override
  String get start => 'Начать';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get todayGoal => 'Сегодня';

  @override
  String get goalCompleted => 'Цель достигнута!';

  @override
  String get goalCompletedMessage =>
      'Вы достигли сегодняшней цели. Хотите продолжить практику?';

  @override
  String get microphonePermissionRequired => 'Требуется разрешение на микрофон';

  @override
  String get microphonePermissionMessage =>
      'Пожалуйста, разрешите доступ к микрофону в Настройках для использования распознавания речи.';

  @override
  String get speechNotAvailable => 'Распознавание речи недоступно';

  @override
  String get speechNotAvailableMessage =>
      'Распознавание речи недоступно на этом устройстве.';

  @override
  String get error => 'Ошибка';

  @override
  String get speechErrorMessage =>
      'Произошла ошибка при инициализации распознавания речи.';

  @override
  String get openSettings => 'Открыть Настройки';
}
