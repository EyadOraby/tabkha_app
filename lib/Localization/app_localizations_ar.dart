// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get hello => 'مرحبًا';

  @override
  String get forgot => 'نسيت';

  @override
  String get password => 'كلمة المرور';

  @override
  String get troubleLoggingIn => 'هل تواجه مشكلة في تسجيل الدخول؟';

  @override
  String get enterEmailForPasswordReset =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيين كلمة المرور.';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get pleaseEnterYourEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get pleaseEnterValidEmail => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get returnToLoginPage => 'العودة إلى صفحة تسجيل الدخول';

  @override
  String get pleaseEnterYourPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get dontHaveAnAccount => 'ليس لديك حساب؟';

  @override
  String get createAnAccount => 'إنشاء حساب';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get createYour => 'أنشئ';

  @override
  String get account => 'حسابك';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get pleaseEnterYourName => 'يرجى إدخال اسمك';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get pleaseEnterYourUserName => 'يرجى إدخال اسم المستخدم';

  @override
  String get repeatPassword => 'أعد إدخال كلمة المرور';

  @override
  String get pleaseConfirmYourPassword => 'يرجى تأكيد كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get location => 'الموقع';

  @override
  String get searchHere => 'ابحث هنا';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get whatToCook => 'ماذا تريد أن تطبخ اليوم؟';

  @override
  String get searchRecipes => 'ابحث عن وصفة';

  @override
  String get categories => 'الأقسام';

  @override
  String popularIn(String category) {
    return 'الأشهر في $category';
  }

  @override
  String resultsFor(String query) {
    return 'نتائج “$query”';
  }

  @override
  String get noRecipesFound => 'لا توجد وصفات. جرّب بحثًا آخر.';

  @override
  String get couldNotLoadRecipes =>
      'تعذّر تحميل الوصفات. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get ingredients => 'المكونات';

  @override
  String get steps => 'الخطوات';

  @override
  String get continueAsGuest => 'المتابعة كضيف';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get addToFavorites => 'أضف إلى المفضلة';

  @override
  String get removeFromFavorites => 'أزل من المفضلة';

  @override
  String get recipeNotFound => 'هذه الوصفة لم تعد متاحة.';
}
