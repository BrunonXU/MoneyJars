# 贡献指南

感谢您对 MoneyJars 项目的关注！

⚠️ **重要提醒：本项目为商业软件，受专有许可证保护。**

本项目计划上架iOS App Store，所有代码和设计均为BrunonXU的知识产权。

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
⚠️ **注意：由于本项目为商业软件，代码贡献需要签署贡献者协议。**

1. 联系 BrunonXU 讨论您的想法
2. 签署贡献者许可协议 (CLA)
3. Fork 本仓库
4. 创建功能分支：`git checkout -b feature/amazing-feature`
5. 提交更改：`git commit -m 'Add amazing feature'`
6. 推送到分支：`git push origin feature/amazing-feature`
7. 创建 Pull Request

## 📋 开发指南

### 环境要求
- Flutter 3.13.0+
- Dart 3.1.0+
- Chrome 浏览器（用于Web测试）

### 本地开发
```bash
# 克隆仓库
git clone https://github.com/BrunonXU/MoneyJars.git

# 安装依赖
flutter pub get

# 生成Hive适配器（v1.0.1+）
dart run build_runner build --delete-conflicting-outputs

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

本项目采用专有许可证 - 详见 [LICENSE](LICENSE) 文件。

⚠️ **重要：本软件为商业产品，计划上架iOS App Store。所有权利归BrunonXU所有。**

## 🙏 致谢

感谢所有贡献者的努力！ 