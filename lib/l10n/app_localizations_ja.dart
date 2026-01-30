// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '英語を話そう';

  @override
  String get appSubtitle => 'スピーキング練習';

  @override
  String get home => 'ホーム';

  @override
  String get lessons => 'レッスン';

  @override
  String get progress => '進捗';

  @override
  String get settings => '設定';

  @override
  String get startPractice => '練習開始';

  @override
  String get continuePractice => '続きから練習';

  @override
  String get todayProgress => '今日の進捗';

  @override
  String get streak => '連続学習';

  @override
  String get days => '日';

  @override
  String get completed => '完了';

  @override
  String get accuracy => '正確度';

  @override
  String get category_greetings => 'あいさつ';

  @override
  String get category_daily => '日常生活';

  @override
  String get category_business => 'ビジネス';

  @override
  String get category_travel => '旅行';

  @override
  String get category_shopping => 'ショッピング';

  @override
  String get difficulty_beginner => '初級';

  @override
  String get difficulty_intermediate => '中級';

  @override
  String get difficulty_advanced => '上級';

  @override
  String get tapToSpeak => 'タップして話す';

  @override
  String get listening => '聞いています...';

  @override
  String get tryAgain => 'もう一度';

  @override
  String get next => '次へ';

  @override
  String get finish => '完了';

  @override
  String get feedback_perfect => '完璧！';

  @override
  String get feedback_great => '素晴らしい！';

  @override
  String get feedback_good => 'いいね！';

  @override
  String get feedback_keep_practicing => '練習を続けよう！';

  @override
  String get feedback_try_again => 'もう一度！';

  @override
  String get practiceComplete => '練習完了！';

  @override
  String get lessonsCompleted => '完了したレッスン';

  @override
  String get averageAccuracy => '平均正確度';

  @override
  String get language => '言語';

  @override
  String get theme => 'テーマ';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeSystem => 'システム';

  @override
  String get removeAds => '広告を削除';

  @override
  String get restorePurchase => '購入を復元';

  @override
  String get premiumActivated => '有効';

  @override
  String get loadingProduct => '読み込み中...';

  @override
  String get purchaseFailed => '購入に失敗しました';

  @override
  String get purchasesRestored => '購入が復元されました';

  @override
  String get about => 'アプリについて';

  @override
  String get version => 'バージョン';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfService => '利用規約';

  @override
  String get microphonePermission => 'マイクの許可';

  @override
  String get microphonePermissionDesc => '音声認識にはマイクへのアクセスが必要です';

  @override
  String get allow => '許可';

  @override
  String get deny => '拒否';

  @override
  String get errorNoMicrophone => 'マイクが利用できません';

  @override
  String get errorSpeechNotAvailable => '音声認識が利用できません';

  @override
  String get errorNetwork => 'ネットワークエラーが発生しました';

  @override
  String get retry => '再試行';

  @override
  String get cancel => 'キャンセル';

  @override
  String get ok => 'OK';

  @override
  String get termsAndPolicies => '利用規約とポリシー';

  @override
  String get support => 'サポート';

  @override
  String get newLessonsAvailable => '新しいレッスンがあります！';

  @override
  String dataUpdated(String version) {
    return 'レッスンがv$versionに更新されました';
  }

  @override
  String get checkingForUpdates => '更新を確認中...';

  @override
  String get upToDate => '最新バージョンです';

  @override
  String get onboardingGoalTitle => '1日にどれくらい学習しますか？';

  @override
  String get onboardingGoalHint => '後から設定で変更できます';

  @override
  String get dailyGoal => '1日の学習量';

  @override
  String get setDailyGoal => '学習量を設定';

  @override
  String get goalLight => '少し';

  @override
  String get goalNormal => '普通';

  @override
  String get goalIntense => 'たくさん';

  @override
  String get goalCustom => 'カスタム';

  @override
  String get goalCustomDesc => '自由に設定';

  @override
  String get recommended => 'おすすめ';

  @override
  String get daily => '1日 ';

  @override
  String get sentences => '文';

  @override
  String get approximately => '約';

  @override
  String get minutes => '分';

  @override
  String get estimatedTime => '予想時間';

  @override
  String get start => '始める';

  @override
  String get confirm => '確認';

  @override
  String get todayGoal => '今日';

  @override
  String get goalCompleted => '目標達成！';

  @override
  String get goalCompletedMessage => '今日の目標を達成しました。もっと練習しますか？';

  @override
  String get microphonePermissionRequired => 'マイクの許可が必要です';

  @override
  String get microphonePermissionMessage =>
      '音声認識を使用するには、設定でマイクへのアクセスを許可してください。';

  @override
  String get speechNotAvailable => '音声認識が利用できません';

  @override
  String get speechNotAvailableMessage => 'このデバイスでは音声認識を使用できません。';

  @override
  String get error => 'エラー';

  @override
  String get speechErrorMessage => '音声認識の初期化中にエラーが発生しました。';

  @override
  String get openSettings => '設定を開く';
}
