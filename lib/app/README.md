# App层 - 应用程序配置

## 📋 目录说明

这是应用程序的配置层，负责应用级别的初始化和配置。

## 📁 目录结构

- **app.dart** - 应用程序主配置文件，包含应用初始化逻辑
- **routes/** - 路由管理
  - `app_routes.dart` - 路由定义和路径常量
  - `route_guards.dart` - 路由守卫，处理页面访问权限
  - `route_transitions.dart` - 自定义页面转场动画
- **theme/** - 主题管理
  - `app_theme.dart` - 应用主题配置
  - `app_colors.dart` - 颜色定义
  - `app_typography.dart` - 字体样式定义

## 💡 使用说明

1. **应用初始化**：在`app.dart`中配置应用启动时的初始化逻辑
2. **路由配置**：在`routes/app_routes.dart`中定义所有页面路由
3. **主题定制**：在`theme/`目录下配置应用的视觉样式

## 🔗 依赖关系

- 被`main.dart`调用
- 依赖`core/`层的业务逻辑
- 为`features/`层提供全局配置