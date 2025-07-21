# MoneyJars API 文档

## 项目概览

MoneyJars 是一个采用 Clean Architecture 架构的 Flutter 财务管理应用，支持 Web 和移动端部署。

## 架构层次

### 1. Domain Layer (领域层)
位置: `lib/core/domain/`

#### 实体 (Entities)
- **Transaction** (`entities/transaction.dart`)
  - 核心交易记录实体
  - 属性: id, amount, description, categoryId, type, date, etc.
  - 枚举: TransactionType (income, expense)

- **Category** (`entities/category.dart`) 
  - 分类实体，支持两级分类
  - 属性: id, name, type, icon, color, subCategories
  - 类型别名: CategoryType = TransactionType

- **JarSettings** (`entities/jar_settings.dart`)
  - 罐头设置实体
  - 属性: targetAmount, title, jarType, enableTargetReminder
  - 枚举: JarType (income, expense, comprehensive)

#### 仓库接口 (Repository Interfaces)
- **TransactionRepository** (`repositories/transaction_repository.dart`)
  ```dart
  abstract class TransactionRepository {
    Future<Either<Failure, List<Transaction>>> getAllTransactions();
    Future<Either<Failure, Transaction>> getTransactionById(String id);
    Future<Either<Failure, void>> addTransaction(Transaction transaction);
    Future<Either<Failure, void>> updateTransaction(Transaction transaction);
    Future<Either<Failure, void>> deleteTransaction(String id);
  }
  ```

- **CategoryRepository** (`repositories/category_repository.dart`)
  ```dart
  abstract class CategoryRepository {
    Future<Either<Failure, List<Category>>> getAllCategories();
    Future<Either<Failure, List<Category>>> getCustomCategories();
    Future<Either<Failure, void>> addCategory(Category category);
    Future<Either<Failure, void>> updateCategory(Category category);
  }
  ```

- **SettingsRepository** (`repositories/settings_repository.dart`)
  ```dart
  abstract class SettingsRepository {
    Future<Either<Failure, Map<JarType, JarSettings>>> getAllJarSettings();
    Future<Either<Failure, void>> updateJarSettings(JarSettings settings);
  }
  ```

### 2. Data Layer (数据层)
位置: `lib/core/data/`

#### 数据源 (Data Sources)
- **LocalDataSource** (`datasources/local/hive_datasource.dart`)
  - 抽象接口定义所有本地数据操作
  - 实现类: HiveLocalDataSource (使用 Hive 数据库)
  
#### 数据模型 (Data Models)
- **TransactionModel** (`models/transaction_model.dart`)
  - 带有 Hive 注解的数据模型
  - 包含 JSON 序列化方法

- **CategoryModel** (`models/category_model.dart`)
  - 分类数据模型，支持 Hive 存储

- **JarSettingsModel** (`models/jar_settings_model.dart`)
  - 罐头设置数据模型

#### 仓库实现 (Repository Implementations)
- **TransactionRepositoryImpl** (`repositories/transaction_repository_impl.dart`)
  - 实现 TransactionRepository 接口
  - 包含缓存机制和错误处理

### 3. Presentation Layer (表现层)
位置: `lib/screens/` 和 `lib/widgets/`

#### 主要页面
- **HomeScreen** (`screens/home_screen.dart`)
  - 主页面，展示三个罐头和交易记录
  - 集成拖拽录入功能

- **JarDetailPage** (`screens/jar_detail_page.dart`)
  - 罐头详情页面，显示具体交易记录

#### 核心 Widget
- **MoneyJarWidget** (`widgets/money_jar_widget.dart`)
  - 罐头显示组件
  - 支持背景图片和动画效果

- **DragRecordInput** (`widgets/drag_record_input.dart`)
  - 拖拽录入组件
  - 集成金额输入和分类选择

#### 状态管理
- **TransactionProvider** (`providers/transaction_provider.dart`)
  - 使用 Provider 模式管理交易状态
  - 包含缓存机制，提升性能

### 4. Services Layer (服务层)
位置: `lib/services/`

#### 存储服务
- **StorageService** (`storage_service.dart`)
  - 抽象存储服务接口
  
- **RepositoryStorageAdapter** (`storage_service_adapter.dart`)
  - 新旧架构桥接适配器
  - 实现向后兼容

#### 依赖注入
- **ServiceLocator** (`lib/core/di/service_locator.dart`)
  - 使用 get_it 管理依赖注入
  - 扩展方法提供便捷访问

## 主要功能模块

### 交易管理
```dart
// 添加交易
final transaction = Transaction(
  id: uuid.v4(),
  amount: 100.0,
  description: '午餐',
  parentCategoryId: 'food',
  type: TransactionType.expense,
);
await transactionRepository.addTransaction(transaction);
```

### 分类管理
```dart
// 添加自定义分类
final category = Category(
  id: uuid.v4(),
  name: '投资',
  type: TransactionType.income,
  icon: '📈',
  color: Colors.green.value,
);
await categoryRepository.addCategory(category);
```

### 拖拽交互
```dart
// 拖拽录入流程
1. 用户长按罐头启动拖拽
2. 拖拽到输入区域
3. 弹出金额输入界面
4. 选择分类
5. 确认保存交易记录
```

## UI 组件系统

### 现代化样式
- **ModernUIStyles** (`lib/utils/modern_ui_styles.dart`)
  - 统一的 UI 样式配置
  - 深色主题 (#1A3D2E 背景, #DC143C 强调色)

### 动画系统
- 页面切换动画
- 卡片悬浮效果
- 拖拽反馈动画
- 按钮点击动画

## 数据持久化

### Hive 数据库
- 高性能本地数据库
- 支持 Web 和移动端
- 类型安全的对象存储

### 数据模型映射
```dart
// 领域实体 -> 数据模型
TransactionModel _convertToModel(Transaction entity) {
  return TransactionModel(
    id: entity.id,
    amount: entity.amount,
    // ... 其他字段映射
  );
}
```

## 性能优化

### 缓存机制
- Provider 级别的内存缓存
- 60秒缓存有效期
- 智能缓存失效策略

### 列表优化
- ListView.builder 延迟加载
- cacheExtent 预加载优化
- ValueKey 提升 Widget 性能

## 测试架构

### 单元测试
- Repository 层测试
- Entity 测试  
- Mock 对象使用 mockito

### 测试文件
- `test/core/data/repositories/transaction_repository_test.dart`
- `test/core/domain/entities/transaction_test.dart`

## 部署配置

### Web 部署
- GitHub Actions 自动构建
- GitHub Pages 托管
- Flutter Web 优化配置

### 移动端构建
- Android APK 构建支持
- iOS 构建配置

## 开发工具

### 代码生成
```bash
# 生成 Hive 适配器和 JSON 序列化
dart run build_runner build --delete-conflicting-outputs
```

### 依赖管理
```bash
# 升级依赖包
flutter pub upgrade --major-versions
```

## 扩展性设计

### 插件化架构
- 新功能可作为独立模块添加
- 依赖注入支持动态配置
- Clean Architecture 支持扩展

### 多平台支持
- 响应式布局设计
- 平台特定的存储实现
- 统一的业务逻辑层

---

*文档生成时间: 2025-07-21*
*版本: v2.0*