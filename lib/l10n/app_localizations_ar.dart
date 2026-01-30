// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تحدث الإنجليزية';

  @override
  String get appSubtitle => 'تدريب المحادثة';

  @override
  String get home => 'الرئيسية';

  @override
  String get lessons => 'الدروس';

  @override
  String get progress => 'التقدم';

  @override
  String get settings => 'الإعدادات';

  @override
  String get startPractice => 'ابدأ التدريب';

  @override
  String get continuePractice => 'استمر';

  @override
  String get todayProgress => 'تقدم اليوم';

  @override
  String get streak => 'التتابع';

  @override
  String get days => 'أيام';

  @override
  String get completed => 'مكتمل';

  @override
  String get accuracy => 'الدقة';

  @override
  String get category_greetings => 'التحيات';

  @override
  String get category_daily => 'الحياة اليومية';

  @override
  String get category_business => 'الأعمال';

  @override
  String get category_travel => 'السفر';

  @override
  String get category_shopping => 'التسوق';

  @override
  String get difficulty_beginner => 'مبتدئ';

  @override
  String get difficulty_intermediate => 'متوسط';

  @override
  String get difficulty_advanced => 'متقدم';

  @override
  String get tapToSpeak => 'اضغط للتحدث';

  @override
  String get listening => 'جارٍ الاستماع...';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get next => 'التالي';

  @override
  String get finish => 'إنهاء';

  @override
  String get feedback_perfect => 'ممتاز!';

  @override
  String get feedback_great => 'رائع!';

  @override
  String get feedback_good => 'جيد!';

  @override
  String get feedback_keep_practicing => 'استمر في التدريب!';

  @override
  String get feedback_try_again => 'حاول مرة أخرى!';

  @override
  String get practiceComplete => 'اكتمل التدريب!';

  @override
  String get lessonsCompleted => 'الدروس المكتملة';

  @override
  String get averageAccuracy => 'متوسط الدقة';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystem => 'النظام';

  @override
  String get removeAds => 'إزالة الإعلانات';

  @override
  String get restorePurchase => 'استعادة الشراء';

  @override
  String get premiumActivated => 'مفعل';

  @override
  String get loadingProduct => 'جارٍ التحميل...';

  @override
  String get purchaseFailed => 'فشل الشراء';

  @override
  String get purchasesRestored => 'تم استعادة المشتريات';

  @override
  String get about => 'حول';

  @override
  String get version => 'الإصدار';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get microphonePermission => 'إذن الميكروفون';

  @override
  String get microphonePermissionDesc =>
      'مطلوب الوصول إلى الميكروفون للتعرف على الصوت';

  @override
  String get allow => 'السماح';

  @override
  String get deny => 'رفض';

  @override
  String get errorNoMicrophone => 'الميكروفون غير متاح';

  @override
  String get errorSpeechNotAvailable => 'التعرف على الصوت غير متاح';

  @override
  String get errorNetwork => 'خطأ في الشبكة';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get ok => 'موافق';

  @override
  String get termsAndPolicies => 'الشروط والسياسات';

  @override
  String get support => 'الدعم';

  @override
  String get newLessonsAvailable => 'تتوفر دروس جديدة!';

  @override
  String dataUpdated(String version) {
    return 'تم تحديث الدروس إلى v$version';
  }

  @override
  String get checkingForUpdates => 'جارٍ البحث عن تحديثات...';

  @override
  String get upToDate => 'لديك أحدث إصدار';

  @override
  String get onboardingGoalTitle => 'كم تريد أن تتعلم كل يوم؟';

  @override
  String get onboardingGoalHint => 'يمكنك تغيير هذا في الإعدادات لاحقاً';

  @override
  String get dailyGoal => 'الهدف اليومي';

  @override
  String get setDailyGoal => 'تحديد الهدف';

  @override
  String get goalLight => 'قليل';

  @override
  String get goalNormal => 'عادي';

  @override
  String get goalIntense => 'كثير';

  @override
  String get goalCustom => 'مخصص';

  @override
  String get goalCustomDesc => 'حدد وتيرتك الخاصة';

  @override
  String get recommended => 'موصى به';

  @override
  String get daily => 'يومياً ';

  @override
  String get sentences => ' جمل';

  @override
  String get approximately => '~';

  @override
  String get minutes => ' دقيقة';

  @override
  String get estimatedTime => 'الوقت المقدر';

  @override
  String get start => 'ابدأ';

  @override
  String get confirm => 'تأكيد';

  @override
  String get todayGoal => 'اليوم';

  @override
  String get goalCompleted => 'تم تحقيق الهدف!';

  @override
  String get goalCompletedMessage =>
      'لقد حققت هدف اليوم. هل تريد الاستمرار في التدريب؟';

  @override
  String get microphonePermissionRequired => 'مطلوب إذن الميكروفون';

  @override
  String get microphonePermissionMessage =>
      'يرجى السماح بالوصول إلى الميكروفون في الإعدادات لاستخدام التعرف على الكلام.';

  @override
  String get speechNotAvailable => 'التعرف على الكلام غير متاح';

  @override
  String get speechNotAvailableMessage =>
      'التعرف على الكلام غير متاح على هذا الجهاز.';

  @override
  String get error => 'خطأ';

  @override
  String get speechErrorMessage => 'حدث خطأ أثناء تهيئة التعرف على الكلام.';

  @override
  String get openSettings => 'فتح الإعدادات';
}
