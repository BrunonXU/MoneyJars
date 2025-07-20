# MoneyJars 架构迁移指南

## 📋 迁移概述
本文档详细说明了从现有架构迁移到商业级架构的完整方案，包括新的目录结构和文件映射关系。

## 🏗️ 新架构目录结构

```
lib/
├── app/                              # 🎯 应用程序配置层
│   ├── app.dart                      # 应用程序主入口（从main.dart迁移）
│   ├── routes/                       # 📍 路由管理
│   │   ├── app_routes.dart           # 路由定义和命名
│   │   ├── route_guards.dart         # 路由守卫（权限控制）
│   │   └── route_transitions.dart    # 页面转场动画定义
│   └── theme/                        # 🎨 主题管理
│       ├── app_theme.dart            # 主题配置（从app_constants.dart提取）
│       ├── app_colors.dart           # 颜色定义（从app_constants.dart提取）
│       └── app_typography.dart       # 字体样式定义
│
├── core/                             # 💎 核心业务层（独立于UI）
│   ├── domain/                       # 🏛️ 领域层（业务逻辑）
│   │   ├── entities/                 # 📦 实体定义
│   │   │   ├── transaction.dart      # 交易实体（从transaction_record_hive.dart重构）
│   │   │   ├── category.dart         # 分类实体（新建）
│   │   │   ├── jar_config.dart       # 罐头配置实体（新建）
│   │   │   └── user_settings.dart    # 用户设置实体（新建）
│   │   ├── repositories/             # 📚 仓库接口（抽象）
│   │   │   ├── transaction_repository.dart  # 交易仓库接口
│   │   │   ├── category_repository.dart     # 分类仓库接口
│   │   │   └── settings_repository.dart     # 设置仓库接口
│   │   └── usecases/                 # ⚡ 用例（业务规则）
│   │       ├── transaction/          # 交易相关用例
│   │       │   ├── add_transaction.dart     # 添加交易
│   │       │   ├── update_transaction.dart  # 更新交易
│   │       │   ├── delete_transaction.dart  # 删除交易
│   │       │   └── get_transactions.dart    # 获取交易列表
│   │       ├── statistics/           # 统计相关用例
│   │       │   ├── calculate_totals.dart    # 计算总额
│   │       │   ├── get_category_stats.dart  # 分类统计
│   │       │   └── generate_reports.dart    # 生成报表
│   │       └── jar/                  # 罐头相关用例
│   │           ├── update_jar_settings.dart # 更新罐头设置
│   │           └── calculate_progress.dart  # 计算进度
│   │
│   ├── data/                         # 💾 数据层
│   │   ├── repositories/             # 📂 仓库实现
│   │   │   ├── transaction_repository_impl.dart  # 交易仓库实现
│   │   │   ├── category_repository_impl.dart     # 分类仓库实现
│   │   │   └── settings_repository_impl.dart     # 设置仓库实现
│   │   ├── datasources/              # 🗄️ 数据源
│   │   │   ├── local/                # 本地数据源
│   │   │   │   ├── hive_datasource.dart        # Hive数据源（从storage_service.dart迁移）
│   │   │   │   ├── preferences_datasource.dart  # SharedPreferences数据源
│   │   │   │   └── cache_manager.dart          # 缓存管理器
│   │   │   └── remote/               # 远程数据源（未来扩展）
│   │   │       ├── api_client.dart              # API客户端
│   │   │       └── cloud_datasource.dart        # 云端数据源
│   │   └── models/                   # 📊 数据模型
│   │       ├── transaction_model.dart           # 交易数据模型
│   │       ├── category_model.dart              # 分类数据模型
│   │       └── jar_settings_model.dart         # 罐头设置模型
│   │
│   └── error/                        # ⚠️ 错误处理
│       ├── exceptions.dart           # 异常定义
│       ├── failures.dart             # 失败类型
│       └── error_handler.dart        # 错误处理器
│
├── features/                         # 🎨 功能模块（按业务划分）
│   ├── jars/                         # 🍯 罐头功能模块
│   │   ├── presentation/             # 🖼️ 表现层
│   │   │   ├── pages/                # 📄 页面
│   │   │   │   ├── jars_home_page.dart         # 罐头主页（从home_screen.dart迁移主体）
│   │   │   │   ├── income_jar_view.dart        # 收入罐头视图（从home_screen.dart提取）
│   │   │   │   ├── expense_jar_view.dart       # 支出罐头视图（从home_screen.dart提取）
│   │   │   │   ├── summary_jar_view.dart       # 综合罐头视图（从home_screen.dart提取）
│   │   │   │   └── jar_detail_page.dart        # 罐头详情页（从jar_detail_page.dart迁移）
│   │   │   ├── widgets/              # 🧩 组件
│   │   │   │   ├── jar_3d_visual.dart         # 3D罐头效果（从money_jar_widget.dart迁移）
│   │   │   │   ├── jar_progress_bar.dart      # 进度条（从money_jar_widget.dart提取）
│   │   │   │   ├── coin_animation.dart        # 金币动画（从money_jar_widget.dart提取）
│   │   │   │   ├── jar_settings_button.dart   # 设置按钮（从jar_settings_dialog.dart提取）
│   │   │   │   └── swipe_hint.dart            # 滑动提示（从swipe_hint_widget.dart迁移）
│   │   │   └── providers/            # 🔄 状态管理
│   │   │       ├── jars_provider.dart         # 罐头状态管理（新建）
│   │   │       └── jar_animation_provider.dart # 动画状态管理（新建）
│   │   └── domain/                   # 🧮 领域逻辑
│   │       ├── jar_calculator.dart   # 罐头计算逻辑（新建）
│   │       └── jar_validator.dart    # 罐头验证逻辑（新建）
│   │
│   ├── transaction_input/            # 📝 交易输入模块
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── transaction_input_page.dart # 交易输入主页（整合三个输入组件）
│   │   │   │   └── input_mode_selector.dart    # 输入模式选择器（新建）
│   │   │   ├── widgets/
│   │   │   │   ├── amount_input/               # 💰 金额输入
│   │   │   │   │   ├── amount_field.dart       # 金额输入框（从transaction_input_widget.dart提取）
│   │   │   │   │   ├── calculator_pad.dart     # 计算器键盘（新建）
│   │   │   │   │   └── amount_formatter.dart   # 金额格式化（新建）
│   │   │   │   ├── category_selector/          # 🏷️ 分类选择
│   │   │   │   │   ├── drag_selector.dart      # 拖拽选择（从drag_record_input.dart核心部分）
│   │   │   │   │   ├── ring_chart.dart         # 环状图（从enhanced_pie_chart.dart迁移）
│   │   │   │   │   ├── category_creator.dart   # 创建分类（从drag_record_input.dart提取）
│   │   │   │   │   └── category_list.dart      # 分类列表（新建）
│   │   │   │   └── animations/                 # ✨ 动画效果
│   │   │   │       ├── drag_feedback.dart      # 拖拽反馈（从drag_record_input.dart提取）
│   │   │   │       ├── success_animation.dart  # 成功动画（从drag_record_input.dart提取）
│   │   │   │       └── hover_effects.dart      # 悬停效果（从drag_record_input.dart提取）
│   │   │   └── providers/
│   │   │       ├── input_provider.dart         # 输入状态管理（新建）
│   │   │       └── drag_state_provider.dart    # 拖拽状态管理（新建）
│   │   └── domain/
│   │       ├── input_validator.dart   # 输入验证（新建）
│   │       ├── category_manager.dart  # 分类管理（新建）
│   │       └── drag_calculator.dart   # 拖拽计算（从drag_record_input.dart提取）
│   │
│   ├── statistics/                   # 📊 统计分析模块
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── statistics_page.dart        # 统计页面（从statistics_page.dart迁移）
│   │   │   │   ├── detail_report_page.dart     # 详细报表页（新建）
│   │   │   │   └── category_analysis_page.dart # 分类分析页（新建）
│   │   │   └── widgets/
│   │   │       ├── charts/                     # 📈 图表组件
│   │   │       │   ├── pie_chart.dart          # 饼图（从category_chart_widget.dart迁移）
│   │   │       │   ├── line_chart.dart         # 折线图（新建）
│   │   │       │   ├── bar_chart.dart          # 柱状图（新建）
│   │   │       │   └── chart_legend.dart       # 图例（新建）
│   │   │       └── reports/                    # 📑 报表组件
│   │   │           ├── monthly_report.dart     # 月度报表（新建）
│   │   │           ├── category_report.dart    # 分类报表（新建）
│   │   │           └── trend_report.dart       # 趋势报表（新建）
│   │   └── domain/
│   │       ├── statistics_engine.dart # 统计引擎（新建）
│   │       └── report_generator.dart  # 报表生成器（新建）
│   │
│   ├── settings/                     # ⚙️ 设置模块
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── settings_page.dart          # 设置页面（从settings_page.dart迁移）
│   │   │   │   ├── jar_settings_page.dart      # 罐头设置页（从jar_settings_dialog.dart迁移）
│   │   │   │   ├── category_settings_page.dart # 分类设置页（新建）
│   │   │   │   └── backup_restore_page.dart    # 备份恢复页（新建）
│   │   │   └── widgets/
│   │   │       ├── settings_tile.dart          # 设置项组件（新建）
│   │   │       ├── theme_selector.dart         # 主题选择器（新建）
│   │   │       └── language_selector.dart      # 语言选择器（新建）
│   │   └── domain/
│   │       └── settings_manager.dart  # 设置管理器（新建）
│   │
│   ├── help/                         # ❓ 帮助模块
│   │   └── presentation/
│   │       └── pages/
│   │           ├── help_page.dart              # 帮助页面（从help_page.dart迁移）
│   │           └── tutorial_page.dart          # 教程页面（新建）
│   │
│   └── personalization/              # 🎨 个性化模块
│       └── presentation/
│           └── pages/
│               └── personalization_page.dart   # 个性化页面（从personalization_page.dart迁移）
│
├── shared/                           # 🔧 共享资源
│   ├── widgets/                      # 🧩 通用UI组件
│   │   ├── buttons/                  # 🔘 按钮组件
│   │   │   ├── primary_button.dart             # 主按钮
│   │   │   ├── secondary_button.dart           # 次按钮
│   │   │   └── icon_button.dart               # 图标按钮
│   │   ├── dialogs/                  # 💬 对话框组件
│   │   │   ├── confirm_dialog.dart            # 确认对话框
│   │   │   ├── input_dialog.dart              # 输入对话框
│   │   │   └── info_dialog.dart               # 信息对话框
│   │   ├── loading/                  # ⏳ 加载组件
│   │   │   ├── loading_widget.dart            # 加载组件（从loading_widget.dart迁移）
│   │   │   ├── skeleton_loader.dart           # 骨架屏（新建）
│   │   │   └── progress_indicator.dart        # 进度指示器（新建）
│   │   ├── error/                    # ❌ 错误组件
│   │   │   ├── error_widget.dart              # 错误组件（从error_widget.dart迁移）
│   │   │   └── empty_state_widget.dart        # 空状态组件（新建）
│   │   ├── animations/               # ✨ 通用动画
│   │   │   ├── fade_animation.dart            # 淡入淡出
│   │   │   ├── slide_animation.dart           # 滑动动画
│   │   │   └── scale_animation.dart           # 缩放动画
│   │   └── navigation/               # 🧭 导航组件
│   │       ├── app_bar_widget.dart            # 应用栏（从app_bar_widget.dart迁移）
│   │       ├── left_navigation_widget.dart     # 左侧导航（从left_navigation_widget.dart迁移）
│   │       └── bottom_navigation.dart          # 底部导航（新建）
│   │
│   ├── utils/                        # 🛠️ 工具类
│   │   ├── formatters/               # 📝 格式化工具
│   │   │   ├── currency_formatter.dart        # 货币格式化
│   │   │   ├── date_formatter.dart            # 日期格式化
│   │   │   └── number_formatter.dart          # 数字格式化
│   │   ├── validators/               # ✅ 验证工具
│   │   │   ├── amount_validator.dart          # 金额验证
│   │   │   ├── input_validator.dart           # 输入验证
│   │   │   └── category_validator.dart        # 分类验证
│   │   ├── extensions/               # 🔧 扩展方法
│   │   │   ├── string_extensions.dart         # 字符串扩展
│   │   │   ├── date_extensions.dart           # 日期扩展
│   │   │   └── number_extensions.dart         # 数字扩展
│   │   ├── responsive_layout.dart    # 响应式布局（从responsive_layout.dart迁移）
│   │   ├── env_check.dart            # 环境检查（从env_check.dart迁移）
│   │   └── platform_utils.dart       # 平台工具（新建）
│   │
│   └── constants/                    # 📌 常量定义
│       ├── app_constants.dart        # 应用常量（从app_constants.dart迁移）
│       ├── api_constants.dart        # API常量（新建）
│       ├── storage_keys.dart         # 存储键值（新建）
│       └── asset_paths.dart          # 资源路径（新建）
│
├── l10n/                             # 🌍 国际化（未来扩展）
│   ├── app_en.arb                   # 英文资源
│   └── app_zh.arb                   # 中文资源
│
└── main.dart                         # 🚀 应用入口（简化版）
```

## 📋 文件迁移映射表

### 🔄 需要迁移的文件

| 原文件路径 | 新文件路径 | 说明 |
|-----------|-----------|------|
| `lib/main.dart` | `lib/app/app.dart` + `lib/main.dart`(简化) | 主入口拆分 |
| `lib/screens/home_screen.dart` | 拆分为多个文件（见下方详细说明） | 核心页面拆分 |
| `lib/screens/home_screen_content.dart` | 合并到相应的jar视图文件 | 内容整合 |
| `lib/screens/home_screen_refactored.dart` | 参考后删除 | 提取有用部分 |
| `lib/screens/jar_detail_page.dart` | `lib/features/jars/presentation/pages/jar_detail_page.dart` | 直接迁移 |
| `lib/screens/settings_page.dart` | `lib/features/settings/presentation/pages/settings_page.dart` | 直接迁移 |
| `lib/screens/help_page.dart` | `lib/features/help/presentation/pages/help_page.dart` | 直接迁移 |
| `lib/screens/statistics_page.dart` | `lib/features/statistics/presentation/pages/statistics_page.dart` | 直接迁移 |
| `lib/screens/personalization_page.dart` | `lib/features/personalization/presentation/pages/personalization_page.dart` | 直接迁移 |

### 🔨 需要拆分的大文件

#### 1. home_screen.dart (1059行) 拆分方案：
- **主框架** → `lib/features/jars/presentation/pages/jars_home_page.dart`
- **收入罐头部分** → `lib/features/jars/presentation/pages/income_jar_view.dart`
- **支出罐头部分** → `lib/features/jars/presentation/pages/expense_jar_view.dart`
- **综合罐头部分** → `lib/features/jars/presentation/pages/summary_jar_view.dart`
- **背景渲染** → `lib/features/jars/presentation/widgets/jar_background.dart`
- **手势处理** → `lib/features/jars/domain/gesture_handler.dart`

#### 2. drag_record_input.dart (1600+行) 拆分方案：
- **主拖拽逻辑** → `lib/features/transaction_input/presentation/widgets/category_selector/drag_selector.dart`
- **环状图绘制** → `lib/features/transaction_input/presentation/widgets/category_selector/ring_chart.dart`
- **分类创建对话框** → `lib/features/transaction_input/presentation/widgets/category_selector/category_creator.dart`
- **拖拽动画** → `lib/features/transaction_input/presentation/widgets/animations/drag_feedback.dart`
- **角度计算** → `lib/features/transaction_input/domain/drag_calculator.dart`

#### 3. transaction_input_widget.dart, enhanced_transaction_input.dart 合并方案：
- **统一输入组件** → `lib/features/transaction_input/presentation/pages/transaction_input_page.dart`
- **金额输入** → `lib/features/transaction_input/presentation/widgets/amount_input/amount_field.dart`
- **输入验证** → `lib/features/transaction_input/domain/input_validator.dart`

### 📦 Widgets目录重组

| 原文件 | 新位置 | 说明 |
|--------|--------|------|
| `widgets/money_jar_widget.dart` | `features/jars/presentation/widgets/jar_3d_visual.dart` | 拆分为多个组件 |
| `widgets/jar_settings_dialog.dart` | `features/settings/presentation/pages/jar_settings_page.dart` | 升级为独立页面 |
| `widgets/enhanced_pie_chart.dart` | `features/transaction_input/presentation/widgets/category_selector/ring_chart.dart` | 重命名并优化 |
| `widgets/category_chart_widget.dart` | `features/statistics/presentation/widgets/charts/pie_chart.dart` | 统一图表组件 |
| `widgets/gesture_handler.dart` | `features/jars/domain/gesture_handler.dart` | 移到领域层 |
| `widgets/background/background_widget.dart` | `features/jars/presentation/widgets/jar_background.dart` | 保持独立 |
| `widgets/navigation/app_bar_widget.dart` | `shared/widgets/navigation/app_bar_widget.dart` | 作为共享组件 |
| `widgets/navigation/left_navigation_widget.dart` | `shared/widgets/navigation/left_navigation_widget.dart` | 作为共享组件 |
| `widgets/hints/swipe_hint_widget.dart` | `features/jars/presentation/widgets/swipe_hint.dart` | 归属罐头模块 |
| `widgets/common/loading_widget.dart` | `shared/widgets/loading/loading_widget.dart` | 通用组件 |
| `widgets/common/error_widget.dart` | `shared/widgets/error/error_widget.dart` | 通用组件 |

### 🗂️ Models和Services重组

| 原文件 | 新位置 | 说明 |
|--------|--------|------|
| `models/transaction_record_hive.dart` | `core/data/models/transaction_model.dart` | 数据模型层 |
| `providers/transaction_provider.dart` | `core/domain/repositories/transaction_repository.dart` + Provider保留 | 分离接口和实现 |
| `services/storage_service.dart` | `core/data/datasources/local/hive_datasource.dart` | 数据源层 |
| `services/storage_service_mobile.dart` | 合并到`hive_datasource.dart` | 平台特定实现 |
| `services/storage_service_web.dart` | 合并到`hive_datasource.dart` | 平台特定实现 |
| `constants/app_constants.dart` | 拆分到`shared/constants/`和`app/theme/` | 按用途分类 |

## 🚀 迁移步骤

### 第一阶段：创建目录结构（立即执行）
1. 创建所有新目录
2. 添加README.md说明文件到每个主要目录
3. 创建占位文件标记用途

### 第二阶段：核心层迁移（第1周）
1. 迁移数据模型
2. 创建领域实体
3. 定义仓库接口
4. 实现数据源

### 第三阶段：功能模块迁移（第2-3周）
1. 罐头功能模块
2. 交易输入模块
3. 统计分析模块
4. 设置模块

### 第四阶段：UI层整合（第4周）
1. 整合所有页面
2. 更新路由系统
3. 测试功能完整性

## 📝 注意事项

1. **保留所有功能**：迁移过程中不删除任何功能
2. **逐步迁移**：先创建新文件，测试后再删除旧文件
3. **版本控制**：每完成一个模块就提交一次
4. **测试验证**：每个模块迁移后都要测试
5. **文档更新**：同步更新相关文档

## 🎯 预期效果

- **代码组织**：清晰的模块划分，便于团队协作
- **可维护性**：单一职责，易于理解和修改
- **可扩展性**：新功能可以独立添加，不影响现有代码
- **商业化就绪**：支持未来的云同步、订阅等商业功能