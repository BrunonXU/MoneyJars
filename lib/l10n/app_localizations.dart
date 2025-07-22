import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

/// 应用国际化管理类
/// 支持中文（zh）和英文（en）
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = Intl.canonicalizedLocale(locale);

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// 支持的语言列表
  static const List<Locale> supportedLocales = <Locale>[
    Locale('zh'),
    Locale('en'),
  ];

  // 应用基础文本
  String get appTitle;
  String get appSubtitle;
  
  // 导航栏
  String get navHome;
  String get navHelp;
  String get navStatistics;
  String get navPersonalization;
  String get navSettings;
  
  // 罐头相关
  String get jarIncome;
  String get jarExpense; 
  String get jarComprehensive;
  String get jarSettings;
  String get jarDetail;
  
  // 交易相关
  String get transactionAmount;
  String get transactionDescription;
  String get transactionCategory;
  String get transactionDate;
  String get transactionAdd;
  String get transactionEdit;
  String get transactionDelete;
  
  // 统计相关
  String get statsTotal;
  String get statsCount;
  String get statsAverage;
  String get statsChart;
  String get statsList;
  
  // 操作相关
  String get actionSave;
  String get actionCancel;
  String get actionDelete;
  String get actionEdit;
  String get actionAdd;
  String get actionConfirm;
  String get actionRetry;
  
  // 状态信息
  String get statusLoading;
  String get statusSuccess;
  String get statusError;
  String get statusEmpty;
  
  // 错误信息
  String get errorInvalidAmount;
  String get errorInvalidInput;
  String get errorNetwork;
  String get errorUnknown;
  
  // 提示信息
  String get hintSwipeUp;
  String get hintSwipeDown;
  String get hintNoData;
  String get hintSearchDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue on GitHub with a '
    'reproducible sample app and the exact error message you are seeing.'
  );
}