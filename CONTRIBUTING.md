# 贡献指南

感谢您对 MoneyJars 项目的关注！我们欢迎各种形式的贡献。

## 🤝 如何贡献

### 报告问题
- 使用 GitHub Issues 报告 bug
- 提供详细的重现步骤
- 包含系统信息和错误截图

### 提交功能请求
- 在 Issues 中描述新功能
- 说明功能的用途和价值
- 提供设计建议或草图

### 代码贡献
1. Fork 本仓库
2. 创建功能分支：`git checkout -b feature/amazing-feature`
3. 提交更改：`git commit -m 'Add amazing feature'`
4. 推送到分支：`git push origin feature/amazing-feature`
5. 创建 Pull Request

## 📋 开发指南

### 环境要求
- Flutter 3.13.0+
- Dart 3.1.0+
- Chrome 浏览器（用于Web测试）

### 本地开发
```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/MoneyJars.git

# 安装依赖
flutter pub get

# 设置Web数据库
dart run sqflite_common_ffi_web:setup

# 运行开发服务器
flutter run -d chrome
```

### 代码规范
- 遵循 Dart 官方代码风格
- 使用有意义的变量和函数名
- 添加必要的注释
- 保持代码简洁清晰

### 测试
- 在提交前测试所有功能
- 确保Web版本正常运行
- 验证响应式设计

## 📝 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

感谢所有贡献者的努力！ 