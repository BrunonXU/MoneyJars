# MoneyJars 商业级架构设计

## 🎯 设计原则
- **模块化**: 按业务功能划分，便于团队并行开发
- **可扩展**: 新功能可以独立添加，不影响现有代码
- **可测试**: 依赖注入，业务逻辑与UI分离
- **可维护**: 清晰的分层和职责划分

## 📁 商业级目录结构

```
lib/
├── main.dart                    # 应用入口
├── app.dart                     # 应用配置
│
├── core/                        # 核心层（基础设施）
│   ├── config/                  # 配置
│   │   ├── app_config.dart      # 应用配置
│   │   ├── constants.dart       # 常量定义
│   │   ├── environment.dart     # 环境配置
│   │   └── theme/               # 主题系统
│   │       ├── app_theme.dart
│   │       ├── colors.dart
│   │       └── typography.dart
│   │
│   ├── di/                      # 依赖注入
│   │   └── injection.dart       # GetIt配置
│   │
│   ├── router/                  # 路由管理
│   │   ├── app_router.dart      # 路由定义
│   │   └── route_guards.dart    # 路由守卫
│   │
│   ├── network/                 # 网络层（为未来API准备）
│   │   ├── api_client.dart
│   │   ├── interceptors/
│   │   └── exceptions/
│   │
│   ├── database/                # 数据库层
│   │   ├── app_database.dart
│   │   └── daos/                # 数据访问对象
│   │
│   └── utils/                   # 核心工具
│       ├── logger.dart          # 日志系统
│       ├── validators.dart      # 验证器
│       └── extensions/          # Dart扩展
│
├── data/                        # 数据层
│   ├── models/                  # 数据模型
│   │   ├── transaction/
│   │   │   ├── transaction_model.dart
│   │   │   └── transaction_model.g.dart
│   │   ├── category/
│   │   │   └── category_model.dart
│   │   └── user/
│   │       └── user_model.dart
│   │
│   ├── repositories/            # 仓库实现
│   │   ├── transaction_repository_impl.dart
│   │   ├── category_repository_impl.dart
│   │   └── user_repository_impl.dart
│   │
│   └── datasources/             # 数据源
│       ├── local/
│       │   ├── transaction_local_datasource.dart
│       │   └── cache_datasource.dart
│       └── remote/              # 为未来API准备
│           └── transaction_remote_datasource.dart
│
├── domain/                      # 领域层（业务逻辑）
│   ├── entities/                # 业务实体
│   │   ├── transaction.dart
│   │   ├── category.dart
│   │   └── jar.dart
│   │
│   ├── repositories/            # 仓库接口
│   │   ├── transaction_repository.dart
│   │   └── category_repository.dart
│   │
│   └── usecases/                # 用例（业务逻辑）
│       ├── transaction/
│       │   ├── add_transaction.dart
│       │   ├── get_transactions.dart
│       │   └── delete_transaction.dart
│       └── statistics/
│           ├── calculate_total.dart
│           └── get_category_stats.dart
│
├── features/                    # 功能模块（按业务划分）
│   ├── home/                    # 主页模块
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── home_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── jar_carousel.dart
│   │   │   │   └── quick_stats_card.dart
│   │   │   └── providers/
│   │   │       └── home_provider.dart
│   │   └── data/                # 模块特定数据
│   │
│   ├── transaction/             # 交易模块
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── add_transaction_page.dart
│   │   │   │   └── transaction_list_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── drag_input/
│   │   │   │   │   ├── drag_input_widget.dart
│   │   │   │   │   └── drag_controller.dart
│   │   │   │   └── transaction_form.dart
│   │   │   └── providers/
│   │   │       └── transaction_provider.dart
│   │   └── domain/              # 模块特定业务逻辑
│   │
│   ├── statistics/              # 统计模块
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   ├── widgets/
│   │   │   │   ├── charts/
│   │   │   │   └── reports/
│   │   │   └── providers/
│   │   └── domain/
│   │
│   ├── jar_management/          # 罐头管理模块
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── jar_detail_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── jar_widget.dart
│   │   │   │   └── jar_settings_dialog.dart
│   │   │   └── providers/
│   │   └── domain/
│   │
│   ├── settings/                # 设置模块
│   │   └── presentation/
│   │
│   └── onboarding/              # 新手引导模块（未来）
│       └── presentation/
│
├── shared/                      # 共享资源
│   ├── widgets/                 # 通用UI组件
│   │   ├── buttons/
│   │   │   ├── primary_button.dart
│   │   │   └── icon_button.dart
│   │   ├── cards/
│   │   │   └── app_card.dart
│   │   ├── dialogs/
│   │   │   └── confirmation_dialog.dart
│   │   ├── loading/
│   │   │   ├── loading_overlay.dart
│   │   │   └── shimmer_loading.dart
│   │   └── forms/
│   │       ├── app_text_field.dart
│   │       └── amount_input.dart
│   │
│   ├── utils/                   # 共享工具
│   │   ├── responsive/
│   │   │   ├── responsive_builder.dart
│   │   │   └── size_config.dart
│   │   ├── formatters/
│   │   │   ├── currency_formatter.dart
│   │   │   └── date_formatter.dart
│   │   └── helpers/
│   │       └── platform_helper.dart
│   │
│   └── styles/                  # 共享样式
│       ├── spacing.dart         # 间距系统
│       ├── animations.dart      # 动画常量
│       └── decorations.dart     # 装饰样式
│
└── l10n/                        # 国际化
    ├── app_localizations.dart
    └── arb/
        ├── app_en.arb
        └── app_zh.arb
```

## 🚀 未来扩展示例

### 添加"预算管理"功能
```
features/
└── budget/                      # 新功能模块
    ├── domain/
    │   ├── entities/
    │   │   └── budget.dart
    │   └── usecases/
    │       └── track_budget.dart
    ├── data/
    │   └── repositories/
    └── presentation/
        ├── pages/
        ├── widgets/
        └── providers/
```

### 添加"云同步"功能
```
core/
└── sync/                        # 核心同步服务
    ├── sync_manager.dart
    └── conflict_resolver.dart

data/
└── datasources/
    └── remote/
        └── sync_datasource.dart
```

## 📋 迁移策略

### Phase 1: 核心基础设施
1. 建立 core/ 层
2. 配置依赖注入
3. 设置路由系统

### Phase 2: 分离业务逻辑
1. 创建 domain/ 层
2. 定义 repositories 接口
3. 实现 usecases

### Phase 3: 模块化功能
1. 按功能创建 features/
2. 每个功能独立的 presentation/domain/data
3. 明确模块边界

### Phase 4: 共享资源
1. 提取通用组件到 shared/
2. 建立设计系统
3. 统一样式规范

## 🎯 商业化优势

1. **团队协作**
   - 不同团队负责不同 feature
   - 清晰的模块边界减少冲突

2. **可扩展性**
   - 新功能作为独立 feature 添加
   - 不影响现有代码

3. **可测试性**
   - 依赖注入便于 mock
   - 业务逻辑与 UI 分离

4. **可维护性**
   - 清晰的分层架构
   - 统一的代码组织

5. **性能优化**
   - 模块懒加载
   - 独立的状态管理

6. **国际化就绪**
   - 完整的 l10n 支持
   - 易于添加新语言

## ⚠️ 重要考虑

1. **不要过度设计** - 根据实际需求逐步演进
2. **保持一致性** - 所有模块遵循相同模式
3. **文档先行** - 每个模块都要有清晰文档
4. **代码审查** - 确保架构规范执行

这个架构可以支撑 **100万行代码** 的大型商业应用！