# Shared层 - 共享资源

## 📋 目录说明

Shared层包含应用中多个模块共享的资源，包括通用组件、工具类和常量定义。

## 📁 目录结构

### 1. 🧩 widgets/ - 通用UI组件
- **buttons/** - 各种按钮组件
- **dialogs/** - 对话框组件
- **loading/** - 加载状态组件
- **error/** - 错误处理组件
- **animations/** - 通用动画效果
- **navigation/** - 导航相关组件

### 2. 🛠️ utils/ - 工具类
- **formatters/** - 格式化工具（货币、日期、数字）
- **validators/** - 验证工具（输入验证）
- **extensions/** - Dart扩展方法
- **responsive_layout.dart** - 响应式布局工具
- **platform_utils.dart** - 平台相关工具

### 3. 📌 constants/ - 常量定义
- **app_constants.dart** - 应用级常量
- **api_constants.dart** - API相关常量
- **storage_keys.dart** - 存储键值常量
- **asset_paths.dart** - 资源文件路径

## 💡 使用原则

1. **通用性**：只放置至少被2个以上模块使用的资源
2. **无状态**：组件应该是无状态的或只包含局部状态
3. **可配置**：通过参数支持不同的使用场景
4. **文档完善**：每个组件都应有清晰的使用说明

## 🎯 最佳实践

```dart
// 示例：使用通用按钮组件
PrimaryButton(
  text: '确认',
  onPressed: () => handleConfirm(),
  isLoading: isProcessing,
  icon: Icons.check,
)

// 示例：使用格式化工具
final formatted = CurrencyFormatter.format(1234.56); // ¥1,234.56

// 示例：使用验证工具
final isValid = AmountValidator.validate(inputAmount);
```

## 🔗 依赖关系

- 被所有features模块依赖
- 不依赖features层的具体实现
- 可以依赖core层的实体和接口