# MoneyJars 代码清理和重组计划

## 🎯 目标
将混乱的文件结构重组为清晰、一致、易维护的架构

## 📁 新的目录结构设计

```
lib/
├── main.dart                    # 应用入口
│
├── config/                      # 配置和常量
│   ├── constants.dart          # 应用常量（原app_constants.dart）
│   └── theme.dart              # 主题配置（从constants中提取）
│
├── models/                      # 数据模型
│   ├── transaction.dart        # 交易模型（原transaction_record_hive.dart）
│   └── transaction.g.dart      # 生成文件
│
├── pages/                       # 所有页面（统一用pages）
│   ├── home/                   # 主页
│   │   ├── home_page.dart     # 主页面
│   │   └── widgets/            # 主页专用组件
│   │       └── jar_display.dart
│   ├── detail/                 # 详情页
│   │   └── jar_detail_page.dart
│   ├── statistics/             # 统计页
│   │   └── statistics_page.dart
│   ├── settings/               # 设置页
│   │   └── settings_page.dart
│   └── help/                   # 帮助页
│       └── help_page.dart
│
├── widgets/                     # 共享组件
│   ├── common/                 # 通用组件
│   │   ├── loading.dart        # 加载组件
│   │   └── error.dart          # 错误组件
│   ├── jar/                    # 罐头相关组件
│   │   ├── jar_widget.dart    # 罐头组件
│   │   └── jar_painter.dart   # 罐头绘制
│   ├── input/                  # 输入相关组件
│   │   ├── drag_input.dart    # 拖拽输入
│   │   └── transaction_input.dart
│   └── chart/                  # 图表组件
│       ├── pie_chart.dart      # 饼图
│       └── category_chart.dart # 分类图表
│
├── services/                    # 服务层
│   ├── storage/                # 存储服务
│   │   ├── storage_service.dart
│   │   ├── storage_mobile.dart
│   │   └── storage_web.dart
│   └── providers/              # 状态管理
│       └── transaction_provider.dart
│
├── utils/                       # 工具类
│   ├── responsive.dart         # 响应式工具
│   ├── styles.dart            # 样式工具
│   └── validators.dart        # 验证器
│
└── l10n/                       # 国际化（保持不变）
    ├── app_localizations.dart
    ├── app_localizations_en.dart
    └── app_localizations_zh.dart
```

## 🗑️ 需要删除的文件/目录

### 完全删除的目录
1. `features/` - 整个目录（空壳结构）
2. `shared/` - 整个目录（空壳结构）

### 需要删除的文件
1. `storage_service_adapter.dart.bak` - 备份文件
2. `env_check_stub.dart` - 临时文件
3. `home_screen_content.dart` - 可能是临时文件

## 🔄 文件重命名计划

### 统一命名规范
- 所有页面文件：`*_page.dart`
- 所有组件文件：`*_widget.dart` 或具体功能名
- 所有服务文件：`*_service.dart`
- 所有工具文件：具体功能名

### 具体重命名
```
transaction_record_hive.dart → transaction.dart
app_constants.dart → constants.dart
money_jar_widget.dart → jar_widget.dart
enhanced_pie_chart.dart → pie_chart.dart
enhanced_transaction_input.dart → transaction_input.dart
modern_ui_styles.dart → styles.dart
responsive_layout.dart → responsive.dart
error_widget.dart → error.dart
loading_widget.dart → loading.dart
drag_record_input.dart → drag_input.dart
```

## 📝 执行步骤

### Phase 1: 删除垃圾文件和空目录
1. 删除 features/ 目录
2. 删除 shared/ 目录
3. 删除所有 .bak 文件
4. 删除 stub 文件

### Phase 2: 创建新目录结构
1. 创建 config/ 目录
2. 创建 pages/ 及其子目录
3. 重组 widgets/ 目录
4. 重组 services/ 目录

### Phase 3: 移动和重命名文件
1. 移动页面文件到 pages/
2. 重命名所有文件符合规范
3. 整理组件到对应目录

### Phase 4: 更新import路径
1. 全局搜索替换旧路径
2. 修复所有import错误
3. 验证编译通过

## ⚠️ 注意事项

1. **保持功能完整** - 每步操作后测试
2. **Git提交** - 每个Phase完成后提交
3. **备份重要代码** - 移动前确认
4. **渐进式执行** - 不要一次改太多

## 🎯 预期结果

- 清晰的目录结构
- 一致的命名规范
- 易于维护和扩展
- 删除所有垃圾文件
- 提高代码可读性

---

准备好执行了吗？