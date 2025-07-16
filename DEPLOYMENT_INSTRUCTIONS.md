# MoneyJars Web部署说明

## 🎯 快速开始

### 方法1：使用部署脚本（推荐）
```bash
# Windows用户
deploy.bat

# 构建完成后，选择以下部署方式之一
```

### 方法2：手动部署
```bash
flutter pub get
dart run sqflite_common_ffi_web:setup
flutter build web --release --no-tree-shake-icons
```

## 📦 部署选项

### 🆓 免费方案

#### 1. GitHub Pages（推荐）
**优点**：完全免费，自动部署，稳定可靠

**步骤**：
1. 将项目推送到GitHub仓库
2. 在仓库设置中启用GitHub Pages
3. 使用GitHub Actions自动部署（已配置）
4. 访问：`https://yourusername.github.io/MoneyJars`

#### 2. Netlify
**优点**：部署简单，功能强大

**步骤**：
1. 访问 [netlify.com](https://netlify.com)
2. 注册账号
3. 拖拽 `build/web` 文件夹到页面
4. 获得随机域名，可自定义

#### 3. Vercel
**优点**：速度快，支持自定义域名

**步骤**：
1. 安装Vercel CLI：`npm i -g vercel`
2. 在 `build/web` 目录运行：`vercel`
3. 按提示完成部署

#### 4. Firebase Hosting
**优点**：Google提供，集成度高

**步骤**：
1. 安装Firebase CLI：`npm i -g firebase-tools`
2. 在项目目录运行：`firebase init hosting`
3. 设置public目录为 `build/web`
4. 运行：`firebase deploy`

## 🧪 本地测试

### 方法1：使用测试脚本
```bash
serve.bat
```

### 方法2：手动启动
```bash
cd build/web
python -m http.server 8080
```

然后访问：http://localhost:8080

## 📱 分享给朋友

### 直接分享
- 部署完成后，直接发送网址给朋友
- 朋友用任何浏览器打开即可使用
- 支持手机、平板、电脑

### PWA体验
- 朋友可以点击浏览器的"添加到主屏幕"
- 像原生应用一样使用
- 支持离线功能

## 🔧 技术细节

### 数据存储
- 使用浏览器的IndexedDB
- 数据存储在用户设备上
- 每个用户的数据完全独立
- 清除浏览器数据会丢失记录

### 兼容性
- ✅ Chrome 88+
- ✅ Firefox 78+
- ✅ Safari 14+
- ✅ Edge 88+

### 性能
- 首次加载：~3-5秒
- 后续使用：接近原生应用
- 离线支持：可离线使用

## 🚀 推荐部署流程

### 对于个人使用：
1. 使用GitHub Pages
2. 完全免费
3. 自动部署
4. 专业域名

### 对于商业使用：
1. 购买自定义域名
2. 使用Netlify Pro
3. 更好的性能和功能

## 📞 常见问题

**Q：数据会丢失吗？**
A：数据存储在浏览器本地，除非用户主动清除，否则会持久保存。

**Q：可以多设备同步吗？**
A：当前版本不支持，每个设备/浏览器数据独立。

**Q：朋友需要安装什么吗？**
A：不需要，只需要现代浏览器即可。

**Q：支持手机吗？**
A：完全支持，响应式设计适配所有设备。

**Q：可以离线使用吗？**
A：首次访问需要网络，之后可以离线使用。

## 🎉 部署完成后

1. 测试所有功能
2. 分享链接给朋友
3. 收集反馈
4. 持续改进

---

**祝您部署顺利！** 🎊 

## 部署到 GitHub Pages（Web 端）

### 1. 构建前 base href 必须设置为 /MoneyJars/

在 web/index.html 中，base href 必须为：
```html
<base href="/MoneyJars/">
```
或者使用动态 JS 适配（推荐，模板已内置）：
```js
<script>
(function() {
  var isLocal = location.hostname === "localhost" || location.hostname === "127.0.0.1";
  var base = document.createElement('base');
  base.href = isLocal ? "/" : "/MoneyJars/";
  var existingBase = document.querySelector('base');
  if (existingBase) existingBase.remove();
  document.head.insertBefore(base, document.head.firstChild);
})();
</script>
```

### 2. 构建命令

务必使用如下命令：
```bash
flutter build web --release --base-href "/MoneyJars/" --no-tree-shake-icons
```

### 3. 404常见原因与解决办法
- 404通常是 base href 配置错误导致，务必确认为 `/MoneyJars/`
- 检查 GitHub Pages 设置，分支选择 main，目录为 /（root）
- 推送后等待几分钟，GitHub Pages 需要时间同步
- 资源加载404，优先清理浏览器缓存再刷新

### 4. 资源路径和缓存问题
- 所有静态资源路径都依赖 base href，路径不对会全部404
- 若页面显示空白或资源404，优先检查 index.html 的 base href
- 若本地正常、线上404，99%是 base href 或缓存问题 