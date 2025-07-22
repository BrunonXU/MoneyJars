# MoneyJars 国际化使用指南

## 🌍 支持的语言

- **中文 (zh)**: 简体中文
- **English (en)**: 英语

## 📁 文件结构

```
lib/l10n/
├── app_localizations.dart         # 主国际化类
├── app_localizations_zh.dart      # 中文本地化
└── app_localizations_en.dart      # 英文本地化
```

## 🚀 使用方法

### 在Widget中使用

```dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle), // "MoneyJars"
      ),
      body: Column(
        children: [
          Text(l10n.jarIncome),     // "收入罐头" / "Income Jar"
          Text(l10n.jarExpense),    // "支出罐头" / "Expense Jar"
          ElevatedButton(
            onPressed: () {},
            child: Text(l10n.actionSave), // "保存" / "Save"
          ),
        ],
      ),
    );
  }
}
```

### 常用文本示例

```dart
// 应用基础
l10n.appTitle           // MoneyJars
l10n.appSubtitle        // 智能记账，轻松理财

// 导航栏
l10n.navHome           // 首页 / Home
l10n.navSettings       // 设置 / Settings

// 罐头相关
l10n.jarIncome         // 收入罐头 / Income Jar
l10n.jarExpense        // 支出罐头 / Expense Jar
l10n.jarComprehensive  // 综合统计 / Comprehensive Stats

// 交易相关
l10n.transactionAmount      // 金额 / Amount
l10n.transactionDescription // 描述 / Description
l10n.transactionAdd         // 添加交易 / Add Transaction

// 操作按钮
l10n.actionSave        // 保存 / Save
l10n.actionCancel      // 取消 / Cancel
l10n.actionDelete      // 删除 / Delete

// 状态信息
l10n.statusLoading     // 加载中... / Loading...
l10n.statusSuccess     // 成功 / Success
l10n.statusError       // 错误 / Error

// 错误信息
l10n.errorInvalidAmount // 请输入有效金额 / Please enter a valid amount
l10n.errorNetwork       // 网络连接失败 / Network connection failed

// 提示信息
l10n.hintSwipeUp       // 向上滑动开始记录收入 / Swipe up to record income
l10n.hintSwipeDown     // 向下滑动开始记录支出 / Swipe down to record expense
l10n.hintNoData        // 暂无数据，开始记录您的第一笔交易吧！ / No data available. Start recording your first transaction!
```

## 🔧 添加新语言

### 1. 创建新的语言文件

例如添加日语支持，创建 `app_localizations_ja.dart`:

```dart
import 'app_localizations.dart';

class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([super.locale = 'ja']);

  @override
  String get appTitle => 'MoneyJars';

  @override
  String get appSubtitle => 'スマート予算、簡単ファイナンス';

  @override
  String get jarIncome => '収入ジャー';

  @override
  String get jarExpense => '支出ジャー';
  
  // ... 其他文本
}
```

### 2. 更新主配置文件

在 `app_localizations.dart` 中：

```dart
static const List<Locale> supportedLocales = <Locale>[
  Locale('zh'),
  Locale('en'),
  Locale('ja'), // 添加日语支持
];

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
    case 'ja': return AppLocalizationsJa(); // 添加日语
  }
  // ...
}
```

### 3. 导入新语言文件

在 `app_localizations.dart` 顶部添加：

```dart
import 'app_localizations_ja.dart';
```

## 🎯 最佳实践

### 1. 文本组织
- 按功能模块组织文本（导航、罐头、交易等）
- 使用清晰的命名约定
- 避免硬编码文本

### 2. 复数形式处理
```dart
// 对于需要复数形式的文本，可以添加参数
String transactionCount(int count) {
  return count == 1 ? '$count transaction' : '$count transactions';
}
```

### 3. 带参数的文本
```dart
String welcomeUser(String userName) {
  return 'Welcome back, $userName!';
}
```

## 📱 设备语言检测

应用会自动检测设备语言：
- 如果设备语言是中文 → 显示中文
- 如果设备语言是英文 → 显示英文
- 如果设备语言不支持 → 默认使用英文

## 🔍 调试技巧

### 1. 强制使用特定语言
```dart
// 在MaterialApp中强制使用中文
MaterialApp(
  locale: const Locale('zh'), // 强制中文
  localizationsDelegates: [...],
  supportedLocales: [...],
  // ...
)
```

### 2. 检查当前语言
```dart
final currentLocale = Localizations.localeOf(context);
print('Current locale: ${currentLocale.languageCode}');
```

## ✅ 完成状态

- ✅ 基础国际化框架
- ✅ 中文本地化文件
- ✅ 英文本地化文件
- ✅ MaterialApp配置
- ✅ 编译测试通过

## 🚀 后续扩展

1. **添加更多语言**: 日语、韩语、法语等
2. **动态语言切换**: 应用内语言设置
3. **日期和货币格式化**: 根据地区格式化
4. **RTL语言支持**: 阿拉伯语、希伯来语等

---
*创建时间: 2025-07-21*  
*作者: Claude Code Assistant*