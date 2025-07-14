# MoneyJars 开发路线图与待办清单

## 📋 文档信息
- **项目**: MoneyJars - 智能记账应用
- **当前版本**: v1.0.0+1
- **文档版本**: TODO v1.0
- **创建日期**: 2025年1月14日
- **状态**: 等待新开发者接手

---

## 🎯 项目现状总览

### ✅ 已完成 (Core MVP)
- 三罐头主界面设计和交互
- 拖拽式分类记录功能
- 两级分类系统
- 3D视觉效果和动画
- 本地数据存储 (SQLite/IndexedDB)
- Web端部署 (GitHub Pages)
- 基础罐头详情页面

### 🔄 进行中 (当前迭代)
- 完善文档和PRD
- 代码注释和结构优化
- 项目移交准备

### 📋 待开发 (开发路线图)
以下是按优先级排序的开发任务清单

---

## 🚀 P0 高优先级任务 (建议1-2个月完成)

### 1. 罐头详情页面功能增强 
**📁 位置**: `lib/screens/jar_detail_page.dart`  
**⏱️ 预估**: 2-3周  
**👨‍💻 难度**: 中等

#### 当前状态
```dart
// 已实现基础版本，包含：
- 金额卡片显示
- 基础分类统计
- 简单的列表展示
```

#### 待实现功能
- [ ] **完整交易记录列表**
  - 显示所有收入/支出明细
  - 按时间倒序排列
  - 支持分页加载 (每页20-50条)
  - 列表项包含：金额、描述、分类、时间

- [ ] **高级筛选功能**
  - 时间范围筛选 (今天/本周/本月/自定义)
  - 分类筛选 (单选/多选)
  - 金额范围筛选
  - 筛选条件组合

- [ ] **搜索功能**
  - 按描述关键词搜索
  - 按金额精确搜索
  - 搜索历史记录
  - 智能搜索建议

- [ ] **记录管理操作**
  - 编辑已有记录
  - 删除记录 (含确认弹窗)
  - 批量删除
  - 记录详情查看

- [ ] **数据导出功能**
  - CSV格式导出
  - Excel格式导出
  - PDF报告生成
  - 自定义导出范围

#### 技术实现建议
```dart
// 新增组件结构建议
lib/screens/jar_detail_page.dart
├── TransactionListWidget           // 交易列表组件
├── FilterChipsWidget              // 筛选标签
├── SearchBarWidget                // 搜索框
├── DateRangePickerWidget          // 日期选择器
├── TransactionEditDialog          // 编辑对话框
└── ExportOptionsBottomSheet       // 导出选项

// 新增状态管理
class JarDetailProvider extends ChangeNotifier {
  List<TransactionRecord> _filteredTransactions = [];
  DateRange? _dateRange;
  String _searchQuery = '';
  Set<String> _selectedCategories = {};
  
  // 核心方法
  void filterByDateRange(DateRange range);
  void filterByCategory(Set<String> categories);
  void searchTransactions(String query);
  void exportToCSV();
  void editTransaction(TransactionRecord record);
}
```

#### 依赖包需求
```yaml
# 需要添加的依赖
dependencies:
  file_picker: ^6.1.1              # 文件选择
  csv: ^5.0.2                      # CSV导出
  excel: ^2.1.0                    # Excel导出
  pdf: ^3.10.4                     # PDF生成
  flutter_chips_input: ^2.0.0      # 筛选标签
  infinite_scroll_pagination: ^4.0.0 # 分页加载
```

---

### 2. 高级数据统计图表
**📁 位置**: `lib/widgets/analytics/` (新建目录)  
**⏱️ 预估**: 2-3周  
**👨‍💻 难度**: 中高

#### 功能描述
提供丰富的数据可视化分析，帮助用户更好地理解财务状况。

#### 待实现功能
- [ ] **趋势分析图表**
  - 收入支出趋势线图 (日/周/月)
  - 净收入变化趋势
  - 同比/环比分析
  - 多时间段对比

- [ ] **分类分析**
  - 支出分类饼图 (增强版)
  - 分类排行榜
  - 分类趋势变化
  - 预算执行情况

- [ ] **智能报告**
  - 月度财务报告
  - 支出异常检测
  - 理财建议生成
  - 目标完成度分析

- [ ] **交互式图表**
  - 图表点击查看详情
  - 时间范围拖拽选择
  - 图例交互式筛选
  - 图表导出功能

#### 技术实现
```dart
// 新增组件架构
lib/widgets/analytics/
├── trend_chart_widget.dart         // 趋势图表
├── category_analysis_widget.dart   // 分类分析
├── monthly_report_widget.dart      // 月度报告
├── budget_progress_widget.dart     // 预算进度
└── chart_export_service.dart       // 图表导出

// 数据处理服务
lib/services/analytics_service.dart
class AnalyticsService {
  // 趋势数据计算
  List<TrendData> calculateTrend(DateRange range);
  
  // 分类统计
  Map<String, CategoryAnalysis> analyzeByCateogry();
  
  // 异常检测
  List<AnomalyDetection> detectAnomalies();
  
  // 报告生成
  MonthlyReport generateMonthlyReport(DateTime month);
}
```

#### 依赖包需求
```yaml
dependencies:
  fl_chart: ^0.65.0                # 图表库 (已有)
  syncfusion_flutter_charts: ^24.1.41 # 高级图表
  charts_flutter: ^0.12.0         # Google图表
  flutter_echarts: ^1.0.8         # ECharts图表
```

---

### 3. 高级分类管理系统
**📁 位置**: `lib/screens/category_management_page.dart` (新建)  
**⏱️ 预估**: 1-2周  
**👨‍💻 难度**: 中等

#### 当前限制
```dart
// 当前分类系统只支持：
- 预定义分类使用
- 简单的新分类创建
- 基本的颜色和图标选择
```

#### 待实现功能
- [ ] **分类CRUD操作**
  - 创建自定义分类和子分类
  - 编辑分类 (名称/颜色/图标)
  - 删除分类 (含数据迁移处理)
  - 分类启用/禁用

- [ ] **分类组织管理**
  - 拖拽排序分类顺序
  - 分类层级管理
  - 分类合并功能
  - 批量操作

- [ ] **智能分类功能**
  - 基于描述的智能分类建议
  - 常用分类快速选择
  - 分类使用频率统计
  - 相似交易的分类推荐

- [ ] **分类模板**
  - 预设分类模板
  - 导入/导出分类配置
  - 模板分享功能
  - 行业专用分类模板

#### 技术实现
```dart
// 新增页面和组件
lib/screens/category_management_page.dart
lib/widgets/category/
├── category_list_widget.dart       // 分类列表
├── category_edit_dialog.dart       // 编辑对话框
├── category_icon_picker.dart       // 图标选择器
├── category_color_picker.dart      // 颜色选择器
└── category_template_widget.dart   // 模板选择

// 扩展数据模型
class CategoryManager {
  // 分类CRUD
  Future<void> createCategory(Category category);
  Future<void> updateCategory(String id, Category category);
  Future<void> deleteCategory(String id, {String? migrateToId});
  
  // 智能功能
  List<Category> suggestCategories(String description);
  Map<String, int> getCategoryUsageStats();
  
  // 模板管理
  List<CategoryTemplate> getTemplates();
  void applyTemplate(CategoryTemplate template);
}
```

---

## 📈 P1 中优先级任务 (建议2-4个月完成)

### 4. 云端数据同步服务
**📁 位置**: `lib/services/sync_service.dart` (新建)  
**⏱️ 预估**: 4-6周  
**👨‍💻 难度**: 高

#### 功能描述
实现跨设备数据同步，提升用户体验和数据安全性。

#### 技术选型建议
```yaml
# Firebase方案 (推荐)
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.6.0

# 或 Supabase方案 (开源替代)
dependencies:
  supabase_flutter: ^2.0.0
```

#### 待实现功能
- [ ] **用户认证系统**
  - 邮箱/密码注册登录
  - Google/Apple社交登录
  - 匿名用户升级
  - 密码重置功能

- [ ] **数据同步机制**
  - 实时数据同步
  - 冲突解决策略
  - 离线数据缓存
  - 增量同步优化

- [ ] **多设备支持**
  - 设备管理
  - 数据版本控制
  - 同步状态指示
  - 数据一致性保证

- [ ] **数据备份恢复**
  - 自动云端备份
  - 手动备份触发
  - 数据恢复功能
  - 备份历史管理

#### 实现架构
```dart
// 同步服务架构
lib/services/sync/
├── sync_service.dart              // 同步服务主类
├── auth_service.dart              // 认证服务
├── firestore_service.dart         // Firestore操作
├── conflict_resolver.dart         // 冲突解决
└── offline_queue.dart             // 离线队列

class SyncService {
  // 认证相关
  Future<User?> signIn(String email, String password);
  Future<void> signOut();
  
  // 数据同步
  Future<void> syncAll();
  Future<void> uploadLocalChanges();
  Future<void> downloadRemoteChanges();
  
  // 冲突处理
  Future<void> resolveConflicts(List<ConflictRecord> conflicts);
}
```

#### 状态管理扩展
```dart
// 扩展Provider以支持同步
class TransactionProvider extends ChangeNotifier {
  final SyncService _syncService;
  bool _isSyncing = false;
  SyncStatus _syncStatus = SyncStatus.offline;
  
  // 同步相关方法
  Future<void> syncToCloud();
  void enableAutoSync();
  void handleConflict(ConflictRecord conflict);
}
```

---

### 5. 高级设置和个性化
**📁 位置**: `lib/screens/settings_page.dart` (新建)  
**⏱️ 预估**: 2-3周  
**👨‍💻 难度**: 中等

#### 待实现功能
- [ ] **主题系统**
  - 多种配色主题
  - 深色/浅色模式
  - 自定义主题配色
  - 主题预览功能

- [ ] **国际化支持**
  - 多语言切换 (中/英/日等)
  - 数字格式本地化
  - 日期格式适配
  - 右到左语言支持

- [ ] **货币设置**
  - 多货币支持
  - 汇率自动更新
  - 默认货币设置
  - 货币符号显示

- [ ] **通知提醒**
  - 记账提醒设置
  - 预算超支警告
  - 目标达成通知
  - 定期报告推送

#### 技术实现
```dart
// 新增设置相关组件
lib/screens/settings/
├── settings_page.dart             // 设置主页
├── theme_settings_page.dart       // 主题设置
├── currency_settings_page.dart    // 货币设置
├── notification_settings_page.dart // 通知设置
└── language_settings_page.dart    // 语言设置

// 设置服务
lib/services/settings_service.dart
class SettingsService {
  // 主题管理
  Future<void> setTheme(AppTheme theme);
  AppTheme getCurrentTheme();
  
  // 语言管理
  Future<void> setLocale(Locale locale);
  Locale getCurrentLocale();
  
  // 货币管理
  Future<void> setCurrency(Currency currency);
  Future<double> getExchangeRate(String from, String to);
}
```

#### 依赖包需求
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.1                    # 国际化
  shared_preferences: ^2.2.2       # 设置存储 (已有)
  flutter_local_notifications: ^16.3.0 # 本地通知
  timezone: ^0.9.2                 # 时区处理
  currency_picker: ^2.0.16         # 货币选择器
```

---

### 6. 数据导入导出系统
**📁 位置**: `lib/services/import_export_service.dart` (新建)  
**⏱️ 预估**: 2-3周  
**👨‍💻 难度**: 中高

#### 待实现功能
- [ ] **数据导入**
  - CSV文件导入
  - Excel文件导入
  - 其他记账应用数据迁移
  - 银行账单导入

- [ ] **数据导出**
  - 多格式导出 (CSV/Excel/PDF)
  - 自定义导出范围
  - 图表导出
  - 报告生成

- [ ] **数据验证**
  - 导入数据完整性检查
  - 重复数据检测
  - 格式错误提示
  - 数据清理建议

- [ ] **批量操作**
  - 批量编辑记录
  - 批量分类重新归档
  - 批量删除
  - 批量导入预览

#### 技术实现
```dart
// 导入导出服务
lib/services/import_export/
├── import_export_service.dart     // 主服务
├── csv_processor.dart             // CSV处理
├── excel_processor.dart           // Excel处理
├── data_validator.dart            // 数据验证
└── format_converter.dart          // 格式转换

class ImportExportService {
  // 导入功能
  Future<ImportResult> importFromCSV(File file);
  Future<ImportResult> importFromExcel(File file);
  Future<List<ValidationError>> validateImportData(List<Map> data);
  
  // 导出功能
  Future<File> exportToCSV(ExportConfig config);
  Future<File> exportToExcel(ExportConfig config);
  Future<File> generatePDFReport(ReportConfig config);
}
```

---

## 🔮 P2 低优先级任务 (建议4-6个月完成)

### 7. AI智能功能
**📁 位置**: `lib/services/ai_service.dart` (新建)  
**⏱️ 预估**: 6-8周  
**👨‍💻 难度**: 很高

#### 待实现功能
- [ ] **智能分类**
  - OCR发票识别
  - 自然语言描述分析
  - 机器学习分类模型
  - 用户行为学习

- [ ] **支出预测**
  - 基于历史数据的支出预测
  - 季节性支出分析
  - 异常支出检测
  - 预算建议生成

- [ ] **理财建议**
  - 个性化理财建议
  - 支出优化建议
  - 储蓄目标推荐
  - 投资建议 (基础)

#### 技术选型
```yaml
dependencies:
  google_ml_kit: ^0.16.3           # Google ML Kit
  tflite_flutter: ^0.10.4          # TensorFlow Lite
  camera: ^0.10.5                  # 相机功能
  image_picker: ^1.0.4             # 图片选择
  http: ^1.1.0                     # API调用
```

---

### 8. 社交分享功能
**📁 位置**: `lib/features/social/` (新建目录)  
**⏱️ 预估**: 3-4周  
**👨‍💻 难度**: 中等

#### 待实现功能
- [ ] **数据分享**
  - 生成可分享的统计图表
  - 成就分享 (目标达成等)
  - 月度报告分享
  - 自定义分享模板

- [ ] **家庭账本**
  - 多用户协作记账
  - 权限管理
  - 共享预算
  - 支出审批流程

- [ ] **社区功能**
  - 记账挑战活动
  - 经验分享
  - 模板分享
  - 排行榜功能

---

### 9. 扩展插件系统
**📁 位置**: `lib/plugins/` (新建目录)  
**⏱️ 预估**: 4-6周  
**👨‍💻 难度**: 很高

#### 待实现功能
- [ ] **插件架构**
  - 插件接口定义
  - 动态插件加载
  - 插件生命周期管理
  - 插件商店

- [ ] **第三方集成**
  - 银行API接入
  - 支付宝/微信数据同步
  - 信用卡账单导入
  - 投资账户集成

- [ ] **自动化规则**
  - 基于规则的自动记账
  - 定期交易自动创建
  - 智能分类规则
  - 提醒规则设置

---

## 🛠️ 技术债务处理

### 性能优化
- [ ] **大数据处理优化** (1-2周)
  - 虚拟列表实现
  - 数据分页加载
  - 内存优化
  - 查询性能优化

- [ ] **动画性能优化** (1周)
  - 减少不必要的重绘
  - 动画控制器优化
  - 帧率监控
  - 卡顿分析

### 代码重构
- [ ] **状态管理升级** (2-3周)
  - 考虑迁移到Riverpod
  - 状态持久化
  - 错误状态处理
  - 加载状态管理

- [ ] **架构优化** (2-3周)
  - Repository模式实现
  - 依赖注入框架
  - 服务定位器
  - 模块化架构

### 测试覆盖
- [ ] **单元测试** (2-3周)
  - 业务逻辑测试
  - 数据模型测试
  - 服务类测试
  - 工具函数测试

- [ ] **集成测试** (1-2周)
  - 用户流程测试
  - API集成测试
  - 数据库操作测试
  - 跨平台测试

---

## 📱 平台扩展计划

### iOS版本开发
**⏱️ 预估**: 4-6周  
**👨‍💻 难度**: 中高

#### 主要工作
- [ ] iOS平台适配和优化
- [ ] App Store上架准备
- [ ] iOS特有功能集成 (Face ID/Touch ID)
- [ ] Apple Pay集成 (可选)

### Android版本优化
**⏱️ 预估**: 2-3周  
**👨‍💻 难度**: 中等

#### 主要工作
- [ ] Android平台深度优化
- [ ] Google Play上架
- [ ] Android特有功能集成
- [ ] Material You适配

### 桌面版本开发
**⏱️ 预估**: 3-4周  
**👨‍💻 难度**: 中等

#### 主要工作
- [ ] Windows/macOS/Linux适配
- [ ] 桌面端UI优化
- [ ] 文件系统集成
- [ ] 系统通知集成

---

## 🎯 开发优先级建议

### 第一阶段 (前1-2个月)
**专注用户体验核心功能**
1. 罐头详情页面增强 ⭐⭐⭐⭐⭐
2. 高级数据统计图表 ⭐⭐⭐⭐
3. 分类管理系统 ⭐⭐⭐⭐

### 第二阶段 (2-4个月)
**构建商业化基础**
1. 云端数据同步 ⭐⭐⭐⭐⭐
2. 高级设置功能 ⭐⭐⭐
3. 数据导入导出 ⭐⭐⭐

### 第三阶段 (4-6个月)
**差异化竞争优势**
1. AI智能功能 ⭐⭐⭐⭐
2. 社交分享功能 ⭐⭐⭐
3. iOS版本开发 ⭐⭐⭐⭐⭐

### 第四阶段 (6个月+)
**生态系统建设**
1. 扩展插件系统 ⭐⭐⭐
2. 企业版本开发 ⭐⭐⭐⭐
3. 开放API平台 ⭐⭐⭐

---

## 🧰 开发资源和工具

### 推荐开发工具
- **IDE**: Android Studio / VS Code + Flutter插件
- **设计**: Figma (UI设计) / Adobe XD
- **版本控制**: Git + GitHub
- **项目管理**: GitHub Issues / Notion / Trello
- **API测试**: Postman / Insomnia
- **数据库**: DB Browser for SQLite

### 学习资源
- **Flutter官方文档**: https://flutter.dev/docs
- **Dart语言指南**: https://dart.dev/guides
- **Firebase文档**: https://firebase.google.com/docs
- **Material Design**: https://material.io/design
- **Flutter社区**: https://flutter.cn

### 第三方服务推荐
- **云服务**: Firebase / Supabase / AWS Amplify
- **分析**: Google Analytics / Mixpanel
- **崩溃监控**: Crashlytics / Sentry
- **性能监控**: Firebase Performance
- **A/B测试**: Firebase Remote Config

---

## 📊 工作量评估

### 总体评估
| 优先级 | 功能数量 | 预估工时 | 建议团队规模 |
|--------|----------|----------|--------------|
| P0 | 3个核心功能 | 6-8周 | 1-2名开发者 |
| P1 | 3个重要功能 | 8-12周 | 2-3名开发者 |
| P2 | 3个创新功能 | 12-18周 | 3-4名开发者 |
| 技术债务 | 代码优化 | 4-6周 | 1-2名开发者 |
| 平台扩展 | iOS/Android | 6-10周 | 2-3名开发者 |

### 团队配置建议
- **技术负责人** 1名: 架构设计、技术选型、代码审查
- **前端开发** 1-2名: UI实现、交互逻辑、用户体验
- **后端开发** 1名: 数据同步、API设计、服务端逻辑
- **UI/UX设计师** 1名: 界面设计、交互设计、用户体验
- **产品经理** 1名: 需求分析、优先级管理、用户反馈

---

## 🎯 成功指标 (KPI)

### 技术指标
- **代码质量**: 测试覆盖率 > 80%
- **性能指标**: 启动时间 < 3秒，操作响应 < 200ms
- **稳定性**: 崩溃率 < 0.1%
- **兼容性**: 支持 95% 目标设备

### 产品指标
- **用户体验**: 用户满意度 > 4.5/5
- **功能完整性**: 核心用户流程 100% 可用
- **数据准确性**: 统计计算错误率 < 0.01%
- **同步可靠性**: 数据同步成功率 > 99.9%

### 商业指标
- **用户增长**: 月活用户增长率 > 20%
- **用户留存**: 7日留存率 > 50%
- **付费转化**: 免费到付费转化率 > 15%
- **收入增长**: 月收入增长率 > 30%

---

## 🚀 快速开始指南

### 新开发者接手步骤

1. **环境搭建** (1-2天)
   ```bash
   # 克隆项目
   git clone https://github.com/BrunonXU/MoneyJars.git
   
   # 安装依赖
   flutter pub get
   
   # 设置Web数据库
   dart run sqflite_common_ffi_web:setup
   
   # 运行项目
   flutter run -d chrome
   ```

2. **代码熟悉** (3-5天)
   - 阅读 `MoneyJars_PRD_v1.0.md`
   - 查看核心组件实现
   - 理解数据流和状态管理
   - 运行并测试所有功能

3. **选择第一个任务** (1周)
   - 建议从"罐头详情页面增强"开始
   - 创建功能分支进行开发
   - 遵循现有代码规范和注释风格

4. **开发流程**
   - 功能设计 → 技术设计 → 编码实现 → 测试验证 → 代码审查 → 部署发布

### 紧急联系
如有技术问题或移交疑问，请联系原开发者：
- **GitHub**: https://github.com/BrunonXU
- **项目仓库**: https://github.com/BrunonXU/MoneyJars

---

*本开发路线图为MoneyJars项目的完整待办清单，按优先级和复杂度进行了详细规划。建议新开发团队按照此路线图进行有序开发，确保产品质量和用户体验。*

**文档版本**: TODO v1.0  
**最后更新**: 2025年1月14日  
**© 2025 BrunonXU. All rights reserved.** 