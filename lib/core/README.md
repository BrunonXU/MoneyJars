# Core层 - 核心业务逻辑

## 📋 层级说明

Core层是应用的核心业务层，独立于UI框架，包含所有业务逻辑和数据处理。

## 🏗️ 架构设计

采用Clean Architecture的分层设计：

### 1. Domain层（领域层）
- **entities/** - 业务实体，核心数据结构
- **repositories/** - 仓库接口定义（抽象）
- **usecases/** - 用例，封装具体业务规则

### 2. Data层（数据层）
- **models/** - 数据模型，用于数据传输
- **repositories/** - 仓库接口的具体实现
- **datasources/** - 数据源（本地/远程）

### 3. Error层（错误处理）
- **exceptions.dart** - 自定义异常类型
- **failures.dart** - 失败类型定义
- **error_handler.dart** - 统一错误处理

## 🎯 设计原则

1. **依赖倒置**：外层依赖内层，内层不依赖外层
2. **单一职责**：每个类只负责一个功能
3. **接口隔离**：通过接口定义契约
4. **可测试性**：业务逻辑独立，便于单元测试

## 💡 使用指南

```dart
// 示例：使用用例添加交易
final addTransaction = AddTransactionUseCase(
  repository: transactionRepository,
  validator: transactionValidator,
);

final result = await addTransaction.execute(
  amount: 100.0,
  category: category,
  type: TransactionType.income,
);
```

## 🔗 依赖关系

- 不依赖任何UI框架
- 被`features/`层调用
- 通过依赖注入获取具体实现