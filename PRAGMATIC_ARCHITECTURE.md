# MoneyJars 务实架构方案

## 🎯 设计原则
- **刚好够用**: 不过度设计，但留有扩展空间
- **功能聚合**: 相关功能放在一起，不过度拆分
- **清晰边界**: 页面、组件、服务职责明确
- **易于理解**: 新人能快速上手

## 📁 推荐架构（务实版）

```
lib/
├── main.dart                    # 应用入口
│
├── core/                        # 核心配置（轻量级）
│   ├── constants/               # 常量定义
│   │   ├── app_constants.dart   # 应用常量
│   │   ├── colors.dart          # 颜色定义
│   │   └── strings.dart         # 字符串常量
│   ├── theme/                   # 主题配置
│   │   └── app_theme.dart       # 统一主题
│   └── router/                  # 路由管理（如果需要）
│       └── app_router.dart
│
├── models/                      # 数据模型（保持简单）
│   ├── transaction.dart         # 交易模型
│   ├── category.dart           # 分类模型
│   └── jar_settings.dart       # 罐头设置
│
├── pages/                       # 页面层（按功能组织）
│   ├── home/                    # 主页模块
│   │   ├── home_page.dart      # 主页面
│   │   └── widgets/             # 页面专属组件
│   │       ├── jar_display.dart
│   │       ├── jar_carousel.dart
│   │       └── quick_actions.dart
│   │
│   ├── transaction/             # 交易模块
│   │   ├── add_transaction_page.dart
│   │   ├── transaction_list_page.dart
│   │   └── widgets/
│   │       ├── drag_input.dart  # 拖拽输入（核心功能）
│   │       ├── amount_input.dart
│   │       └── category_selector.dart
│   │
│   ├── statistics/              # 统计模块
│   │   ├── statistics_page.dart
│   │   └── widgets/
│   │       ├── pie_chart.dart
│   │       ├── bar_chart.dart
│   │       └── stats_card.dart
│   │
│   ├── settings/                # 设置模块
│   │   ├── settings_page.dart
│   │   ├── jar_settings_page.dart
│   │   └── category_settings_page.dart
│   │
│   └── shared/                  # 跨页面共享组件
│       ├── jar_detail_page.dart
│       ├── help_page.dart
│       └── personalization_page.dart
│
├── widgets/                     # 全局共享组件
│   ├── common/                  # 基础组件
│   │   ├── loading_indicator.dart
│   │   ├── error_widget.dart
│   │   └── empty_state.dart
│   ├── jar/                     # 罐头组件（核心UI）
│   │   ├── money_jar_widget.dart
│   │   ├── jar_painter.dart
│   │   └── jar_settings_dialog.dart
│   └── charts/                  # 图表组件（可复用）
│       ├── enhanced_pie_chart.dart
│       └── category_chart.dart
│
├── services/                    # 服务层（业务逻辑）
│   ├── storage/                 # 存储服务
│   │   ├── storage_service.dart # 接口定义
│   │   ├── storage_mobile.dart  # 移动端实现
│   │   └── storage_web.dart     # Web端实现
│   ├── transaction_service.dart # 交易业务逻辑
│   └── statistics_service.dart  # 统计计算逻辑
│
├── providers/                   # 状态管理（集中管理）
│   ├── transaction_provider.dart
│   ├── category_provider.dart   # 分类管理
│   └── settings_provider.dart   # 设置管理
│
├── utils/                       # 工具类
│   ├── formatters.dart         # 格式化工具
│   ├── validators.dart         # 验证器
│   ├── responsive.dart         # 响应式工具
│   └── platform_utils.dart     # 平台判断
│
└── l10n/                       # 国际化
    └── (保持现状)
```

## 🚀 为什么这个架构适合MoneyJars？

### 1. **适度分层**
- pages/ → 页面和页面专属组件
- widgets/ → 可复用的全局组件
- services/ → 业务逻辑（不在UI中）
- providers/ → 状态管理

### 2. **功能内聚**
- 每个页面模块包含自己的widgets/
- 相关功能放在一起，减少跳转
- 核心功能（拖拽输入）易于定位

### 3. **扩展友好**
```
添加"预算管理"功能：
pages/
└── budget/                     # 新增模块
    ├── budget_page.dart
    ├── budget_settings_page.dart
    └── widgets/
        └── budget_progress.dart

services/
└── budget_service.dart         # 预算逻辑

providers/
└── budget_provider.dart        # 预算状态
```

### 4. **团队协作**
- 按功能模块分工
- 清晰的文件位置
- 不过度抽象

## 📋 迁移策略

### Phase 1: 基础整理（1天）
1. 删除 features/ 和 shared/ 空目录
2. 创建 core/ 目录，移动常量和主题
3. 整理 models/ 目录

### Phase 2: 页面重组（1天）
1. 创建 pages/ 目录结构
2. 移动页面文件到对应模块
3. 将页面专属组件移到 pages/*/widgets/

### Phase 3: 组件分类（半天）
1. 整理 widgets/ 为全局共享组件
2. 分类到 common/、jar/、charts/
3. 删除重复组件

### Phase 4: 服务层提取（半天）
1. 创建 services/ 目录
2. 将业务逻辑从UI中提取
3. 整理 providers/ 状态管理

### Phase 5: 工具类整合（2小时）
1. 合并 utils/ 中的相似功能
2. 删除未使用的工具类
3. 规范命名

## ⚖️ 权衡利弊

### ✅ 优点
- 结构清晰但不过度
- 适合中等规模项目
- 易于维护和扩展
- 团队容易理解

### ⚠️ 注意
- 不是最"纯净"的架构
- 模块间可能有轻度耦合
- 需要团队约定规范

## 🎯 这个架构能支撑

- ✅ 当前所有功能
- ✅ PRD中的未来功能
- ✅ 3-5人团队开发
- ✅ 10万行代码规模
- ✅ 2-3年的持续迭代

超过这个规模时，可以逐步向更复杂的架构演进。

---

**记住：最好的架构是适合项目当前阶段的架构！**