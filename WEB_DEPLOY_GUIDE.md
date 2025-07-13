# MoneyJars Web部署指南

## 项目转Web说明

### 1. 是否需要服务器？

**简短回答：不需要传统服务器！**

您的MoneyJars项目可以通过以下方式部署：

#### 静态网站托管（推荐）
- **GitHub Pages** - 免费，适合个人项目
- **Netlify** - 免费额度，自动部署
- **Vercel** - 免费，支持自定义域名
- **Firebase Hosting** - Google提供，免费额度

#### 特点：
- ✅ 无需服务器维护
- ✅ 完全免费或低成本
- ✅ 自动HTTPS
- ✅ 全球CDN加速
- ✅ 数据存储在用户浏览器本地

### 2. 数据存储方案

#### Web平台存储：
- **IndexedDB** - 浏览器本地数据库（持久化）
- **LocalStorage** - 简单键值存储
- **SessionStorage** - 会话级存储

#### 特点：
- 数据存储在用户设备上
- 不同用户数据完全隔离
- 清除浏览器数据会丢失记录
- 单个用户可存储几MB到几GB数据

## 部署步骤

### 步骤1：安装依赖
```bash
flutter pub get
```

### 步骤2：设置Web数据库
```bash
dart run sqflite_common_ffi_web:setup
```

### 步骤3：本地测试
```bash
flutter run -d chrome
```

### 步骤4：构建Web版本
```bash
flutter build web --release
```

### 步骤5：部署到托管平台

#### 方案A：GitHub Pages（推荐）
1. 将项目推送到GitHub仓库
2. 在仓库设置中启用GitHub Pages
3. 选择`/build/web`目录作为源
4. 获得类似`https://username.github.io/money-jars`的网址

#### 方案B：Netlify
1. 注册Netlify账号
2. 拖拽`build/web`文件夹到Netlify
3. 获得随机域名，可自定义

#### 方案C：Vercel
1. 安装Vercel CLI：`npm i -g vercel`
2. 在`build/web`目录运行：`vercel`
3. 按提示完成部署

## 分享给朋友

### 方式1：直接分享链接
- 部署完成后，直接分享网址
- 朋友打开浏览器即可使用
- 无需安装任何软件

### 方式2：生成PWA（渐进式Web应用）
- 朋友可以"添加到主屏幕"
- 像原生应用一样使用
- 支持离线功能

### 方式3：打包成桌面应用
- 使用Electron打包成exe/dmg
- 朋友可以像安装软件一样使用

## 优势对比

### Web版本优势：
- ✅ 无需安装，即开即用
- ✅ 自动更新，无需手动升级
- ✅ 跨平台兼容（Windows/Mac/Linux）
- ✅ 分享简单，只需发送链接
- ✅ 无需应用商店审核

### 注意事项：
- ⚠️ 数据存储在本地浏览器
- ⚠️ 清除浏览器数据会丢失记录
- ⚠️ 不同设备间数据不同步
- ⚠️ 需要网络连接首次访问

## 成本分析

### 完全免费方案：
- **托管**：GitHub Pages（免费）
- **域名**：使用github.io子域名（免费）
- **SSL证书**：自动提供（免费）
- **CDN**：全球加速（免费）

**总成本：0元/年**

### 进阶方案：
- **托管**：Netlify Pro（$19/月）
- **自定义域名**：$10-15/年
- **总成本**：约$240/年

## 技术实现

### 数据库适配：
```dart
// 自动检测平台并使用对应数据库
if (kIsWeb) {
  // Web平台使用IndexedDB
  databaseFactory = databaseFactoryFfiWeb;
} else {
  // 移动平台使用SQLite
  databaseFactory = databaseFactory;
}
```

### PWA配置：
- 已自动生成`web/manifest.json`
- 支持离线缓存
- 可添加到主屏幕

## 部署检查清单

- [ ] 安装Web依赖
- [ ] 设置Web数据库
- [ ] 本地测试通过
- [ ] 构建Web版本
- [ ] 选择托管平台
- [ ] 上传并部署
- [ ] 测试线上版本
- [ ] 分享给朋友

## 常见问题

**Q: 数据会丢失吗？**
A: 数据存储在浏览器本地，除非用户主动清除，否则会持久保存。

**Q: 可以多设备同步吗？**
A: 当前版本不支持，每个设备/浏览器数据独立。

**Q: 性能如何？**
A: Web版本性能接近原生应用，现代浏览器优化很好。

**Q: 支持哪些浏览器？**
A: Chrome、Firefox、Safari、Edge等现代浏览器。

**Q: 可以离线使用吗？**
A: 首次访问需要网络，之后可以离线使用。

---

**推荐部署方案：GitHub Pages + 自定义域名**
- 完全免费
- 自动部署
- 专业外观
- 易于维护 

## 🎯 选择建议

### 推荐选择：**什么都不选，直接保存**

因为您已经有了自定义的GitHub Actions工作流（我们之前配置的），所以：

1. **保持 "Source: GitHub Actions" 不变**
2. **不要点击任何 "Configure" 按钮**
3. **直接滚动到页面底部，如果有 "Save" 按钮就点击保存**

## 📋 选项说明

- **GitHub Pages Jekyll**：用于Jekyll静态网站生成器（不适合Flutter）
- **Static HTML**：用于纯HTML文件（我们的Flutter项目需要构建过程）

## 🚀 正确的操作步骤

1. **确认设置**：
   - Source 应该显示 "GitHub Actions"
   - 不要选择任何预设的工作流

2. **保存设置**：
   - 滚动到页面底部
   - 点击 "Save" 按钮（如果有的话）

3. **检查Actions**：
   - 访问 https://github.com/BrunonXU/MoneyJars/actions
   - 查看是否有新的工作流正在运行

## 💡 如果没有Save按钮

如果页面没有Save按钮，说明设置已经自动保存了。直接：

1. **访问Actions页面**：https://github.com/BrunonXU/MoneyJars/actions
2. **查看最新的工作流运行状态**
3. **等待部署完成**

## 🎉 预期结果

设置完成后，您的网站将在以下地址可用：
```
https://brunonxu.github.io/MoneyJars
```

**请按照上面的步骤操作，不要选择任何预设工作流，直接保存即可！** 🚀 