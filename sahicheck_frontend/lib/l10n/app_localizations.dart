import 'package:flutter/material.dart';

/// Simple English + Urdu localization (no extra languages).
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('ur'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _strings = {
    'en': {
      'app_title': 'SahiCheck',
      'tagline': 'The Guardian of Digital Authenticity',
      'welcome_back': 'Welcome back',
      'welcome_subtitle':
          'Your digital guardian is active. Choose a module to verify information.',
      'fake_news': 'Fake News Detection',
      'fake_news_desc': 'Analyze news articles for credibility',
      'live_news': 'Live News Verify',
      'live_news_desc': 'RSS tech news with ML verification',
      'phishing': 'Phishing Detection',
      'phishing_desc': 'Scan URLs for malicious links',
      'fraud': 'Fraud Detection',
      'fraud_desc': 'Verify financial transactions',
      'integration_test': 'Integration Test',
      'integration_test_desc': 'Test API connections',
      'open': 'Open',
      'system_status': 'System Status',
      'backend': 'Backend',
      'ml_models': 'ML Models',
      'database': 'Database',
      'settings': 'Settings',
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'display_name': 'Display Name',
      'email': 'Email',
      'language': 'Language',
      'english': 'English',
      'urdu': 'Urdu',
      'save': 'Save',
      'cancel': 'Cancel',
      'sign_out': 'Sign Out',
      'login': 'Login',
      'sign_up': 'Sign Up',
      'create_account': 'Create Account',
      'full_name': 'Full Name',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'no_account': "Don't have an account?",
      'have_account': 'Already have an account?',
      'join_community': 'Join the community of digital guardians today',
      'profile_updated': 'Profile updated successfully',
      'enter_name': 'Please enter your name',
      'email_readonly': 'Email cannot be changed here',
      'analyze_article': 'Analyze Article',
      'article_title': 'Article Title',
      'article_content': 'Article Content',
      'check_url': 'Check URL',
      'enter_url': 'Enter a URL to check for phishing',
      'search_headlines': 'Search headlines...',
      'verify_ml': 'Verify with ML',
      'fake_detected': 'FAKE NEWS DETECTED',
      'real_news': 'REAL NEWS',
      'confidence': 'Confidence',
    },
    'ur': {
      'app_title': 'صحی چیک',
      'tagline': 'ڈیجیٹل صداقت کا محافظ',
      'welcome_back': 'خوش آمدید',
      'welcome_subtitle':
          'آپ کا ڈیجیٹل محافظ فعال ہے۔ تصدیق کے لیے کوئی ماڈیول منتخب کریں۔',
      'fake_news': 'جعلی خبر کی شناخت',
      'fake_news_desc': 'خبروں کی صداقت کا تجزیہ کریں',
      'live_news': 'لائیو خبر کی تصدیق',
      'live_news_desc': 'ٹیک خبریں + مشین لرننگ چیک',
      'phishing': 'فشنگ کی شناخت',
      'phishing_desc': 'نقصان دہ لنکس کی جانچ کریں',
      'fraud': 'فراڈ کی شناخت',
      'fraud_desc': 'مالی لین دین کی تصدیق',
      'integration_test': 'انٹیگریشن ٹیسٹ',
      'integration_test_desc': 'API کنکشن ٹیسٹ کریں',
      'open': 'کھولیں',
      'system_status': 'سسٹم کی حیثیت',
      'backend': 'بیک اینڈ',
      'ml_models': 'ML ماڈلز',
      'database': 'ڈیٹا بیس',
      'settings': 'ترتیبات',
      'profile': 'پروفائل',
      'edit_profile': 'پروفائل میں ترمیم',
      'display_name': 'نام',
      'email': 'ای میل',
      'language': 'زبان',
      'english': 'انگریزی',
      'urdu': 'اردو',
      'save': 'محفوظ کریں',
      'cancel': 'منسوخ',
      'sign_out': 'سائن آؤٹ',
      'login': 'لاگ ان',
      'sign_up': 'سائن اپ',
      'create_account': 'اکاؤنٹ بنائیں',
      'full_name': 'پورا نام',
      'password': 'پاس ورڈ',
      'confirm_password': 'پاس ورڈ کی تصدیق',
      'no_account': 'اکاؤنٹ نہیں ہے؟',
      'have_account': 'پہلے سے اکاؤنٹ ہے؟',
      'join_community': 'آج ہی ڈیجیٹل محافظوں کی کمیونٹی میں شامل ہوں',
      'profile_updated': 'پروفائل کامیابی سے اپ ڈیٹ ہو گئی',
      'enter_name': 'براہ کرم اپنا نام درج کریں',
      'email_readonly': 'ای میل یہاں تبدیل نہیں ہو سکتی',
      'analyze_article': 'مضمون کا تجزیہ',
      'article_title': 'خبر کا عنوان',
      'article_content': 'خبر کا متن',
      'check_url': 'URL چیک کریں',
      'enter_url': 'فشنگ کی جانچ کے لیے URL درج کریں',
      'search_headlines': 'سرخی تلاش کریں...',
      'verify_ml': 'ML سے تصدیق',
      'fake_detected': 'جعلی خبر پائی گئی',
      'real_news': 'حقیقی خبر',
      'confidence': 'اعتماد',
    },
  };

  String _t(String key) {
    return _strings[locale.languageCode]?[key] ??
        _strings['en']![key] ??
        key;
  }

  String get appTitle => _t('app_title');
  String get tagline => _t('tagline');
  String get welcomeBack => _t('welcome_back');
  String get welcomeSubtitle => _t('welcome_subtitle');
  String get fakeNews => _t('fake_news');
  String get fakeNewsDesc => _t('fake_news_desc');
  String get liveNews => _t('live_news');
  String get liveNewsDesc => _t('live_news_desc');
  String get phishing => _t('phishing');
  String get phishingDesc => _t('phishing_desc');
  String get fraud => _t('fraud');
  String get fraudDesc => _t('fraud_desc');
  String get integrationTest => _t('integration_test');
  String get integrationTestDesc => _t('integration_test_desc');
  String get open => _t('open');
  String get systemStatus => _t('system_status');
  String get backend => _t('backend');
  String get mlModels => _t('ml_models');
  String get database => _t('database');
  String get settings => _t('settings');
  String get profile => _t('profile');
  String get editProfile => _t('edit_profile');
  String get displayName => _t('display_name');
  String get email => _t('email');
  String get language => _t('language');
  String get english => _t('english');
  String get urdu => _t('urdu');
  String get save => _t('save');
  String get cancel => _t('cancel');
  String get signOut => _t('sign_out');
  String get login => _t('login');
  String get signUp => _t('sign_up');
  String get createAccount => _t('create_account');
  String get fullName => _t('full_name');
  String get password => _t('password');
  String get confirmPassword => _t('confirm_password');
  String get noAccount => _t('no_account');
  String get haveAccount => _t('have_account');
  String get joinCommunity => _t('join_community');
  String get profileUpdated => _t('profile_updated');
  String get enterName => _t('enter_name');
  String get emailReadonly => _t('email_readonly');
  String get analyzeArticle => _t('analyze_article');
  String get articleTitle => _t('article_title');
  String get articleContent => _t('article_content');
  String get checkUrl => _t('check_url');
  String get enterUrl => _t('enter_url');
  String get searchHeadlines => _t('search_headlines');
  String get verifyMl => _t('verify_ml');
  String get fakeDetected => _t('fake_detected');
  String get realNews => _t('real_news');
  String get confidence => _t('confidence');

  bool get isUrdu => locale.languageCode == 'ur';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ur'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
