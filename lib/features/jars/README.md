# 罐头功能模块 (Jars Module)

## 🍯 模块概述

罐头模块是MoneyJars的核心功能，实现了三罐头系统的展示和交互。

## 📋 功能说明

### 三个罐头类型：
1. **💰 收入罐头** - 记录和展示所有收入
2. **💸 支出罐头** - 记录和展示所有支出  
3. **📊 综合罐头** - 显示净收入（收入-支出）

### 核心功能：
- 3D立体罐头视觉效果
- 动态金币堆叠动画
- 进度条显示（相对于目标金额）
- 垂直滑动切换罐头
- 手势识别触发记录

## 📁 目录结构

```
jars/
├── presentation/              # 表现层
│   ├── pages/                # 页面
│   │   ├── jars_home_page.dart        # 主页面容器
│   │   ├── income_jar_view.dart       # 收入罐头视图
│   │   ├── expense_jar_view.dart      # 支出罐头视图
│   │   ├── summary_jar_view.dart      # 综合罐头视图
│   │   └── jar_detail_page.dart       # 罐头详情页
│   ├── widgets/              # 组件
│   │   ├── jar_3d_visual.dart        # 3D罐头效果
│   │   ├── jar_progress_bar.dart     # 进度条
│   │   ├── coin_animation.dart       # 金币动画
│   │   ├── swipe_hint.dart           # 滑动提示
│   │   └── jar_background.dart       # 背景渲染
│   └── providers/            # 状态管理
│       ├── jars_provider.dart        # 罐头状态
│       └── jar_animation_provider.dart # 动画状态
└── domain/                   # 领域层
    ├── jar_calculator.dart   # 计算逻辑
    ├── jar_validator.dart    # 验证逻辑
    └── gesture_handler.dart  # 手势处理
```

## 🎯 关键交互

### 1. 页面切换
- **垂直滑动**：上下滑动切换三个罐头
- **页面指示器**：右侧显示当前页面

### 2. 记录触发
- **收入页面**：向上滑动触发收入记录
- **支出页面**：向下滑动触发支出记录
- **综合页面**：无滑动触发

### 3. 详情查看
- **点击罐头**：跳转到对应的详情页面
- **长按罐头**：显示快速统计

## 💡 开发说明

### 状态管理
```dart
// 使用Provider管理罐头状态
class JarsProvider extends ChangeNotifier {
  double incomeAmount;      // 收入总额
  double expenseAmount;     // 支出总额
  double targetAmount;      // 目标金额
  int currentPage;          // 当前页面索引
}
```

### 动画系统
- 金币动画：2秒循环，闪烁效果
- 呼吸提示：1秒循环，缩放效果
- 页面转场：300ms，平滑过渡

## 🔗 依赖关系

- 依赖`transaction_input/`模块进行交易输入
- 依赖`core/`层的数据仓库
- 被`app/routes/`调用作为主页面