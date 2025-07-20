# 交易输入模块 (Transaction Input Module)

## 📝 模块概述

交易输入模块负责处理用户的收入/支出记录，特色是创新的拖拽式分类选择。

## 🎯 核心功能

### 1. 输入流程
1. **金额输入** - 输入交易金额
2. **描述输入** - 添加交易描述（可选）
3. **分类选择** - 拖拽白点到环状图选择分类
4. **确认提交** - 保存交易记录

### 2. 拖拽式分类选择
- 环状图展示所有分类
- 拖拽白点到对应分类区域
- 悬停时高亮显示
- 拖到圆环外创建新分类

## 📁 目录结构

```
transaction_input/
├── presentation/              # 表现层
│   ├── pages/
│   │   ├── transaction_input_page.dart    # 输入主页面
│   │   └── input_mode_selector.dart       # 输入模式选择
│   ├── widgets/
│   │   ├── amount_input/                  # 金额输入组件
│   │   │   ├── amount_field.dart         # 输入框
│   │   │   ├── calculator_pad.dart       # 计算器键盘
│   │   │   └── amount_formatter.dart     # 格式化
│   │   ├── category_selector/             # 分类选择组件
│   │   │   ├── drag_selector.dart        # 拖拽选择器
│   │   │   ├── ring_chart.dart           # 环状图
│   │   │   ├── category_creator.dart     # 新建分类
│   │   │   └── category_list.dart        # 分类列表
│   │   └── animations/                    # 动画效果
│   │       ├── drag_feedback.dart        # 拖拽反馈
│   │       ├── success_animation.dart    # 成功动画
│   │       └── hover_effects.dart        # 悬停效果
│   └── providers/
│       ├── input_provider.dart            # 输入状态
│       └── drag_state_provider.dart       # 拖拽状态
└── domain/                    # 领域层
    ├── input_validator.dart   # 输入验证
    ├── category_manager.dart  # 分类管理
    └── drag_calculator.dart   # 拖拽计算
```

## 🎨 拖拽系统详解

### 角度计算
```dart
// 将拖拽位置转换为分类索引
int calculateCategoryIndex(Offset position) {
  final angle = calculateAngle(position);
  final categoryAngle = 360 / categories.length;
  return (angle / categoryAngle).floor();
}
```

### 分类映射
- 0-30°：分类1
- 30-60°：分类2
- ...以此类推

### 创建新分类
- 拖拽到圆环外触发
- 弹出创建对话框
- 支持自定义名称和颜色

## 💡 关键特性

### 1. 智能提示
- 拖拽时显示分类名称
- 金额实时格式化
- 错误即时反馈

### 2. 流畅动画
- 拖拽轨迹动画
- 分类悬停放大
- 成功提交动画

### 3. 用户体验
- 支持手势取消
- 自动保存草稿
- 快速重复输入

## 🔧 配置参数

```dart
// 可配置的参数
const dragSensitivity = 0.5;        // 拖拽灵敏度
const hoverDuration = 200;          // 悬停检测时间
const animationDuration = 300;      // 动画时长
const ringChartRadius = 120.0;      // 环状图半径
```

## 🔗 依赖关系

- 被`jars/`模块调用显示输入界面
- 依赖`core/`层保存交易数据
- 使用`shared/`层的通用组件