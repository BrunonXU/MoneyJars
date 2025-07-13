@echo off
echo ================================
echo MoneyJars Web部署脚本
echo ================================

echo 1. 检查Flutter环境...
flutter --version
if %errorlevel% neq 0 (
    echo 错误：Flutter未安装或未在PATH中
    pause
    exit /b 1
)

echo.
echo 2. 安装依赖...
flutter pub get
if %errorlevel% neq 0 (
    echo 错误：依赖安装失败
    pause
    exit /b 1
)

echo.
echo 3. 设置Web数据库...
dart run sqflite_common_ffi_web:setup
if %errorlevel% neq 0 (
    echo 错误：Web数据库设置失败
    pause
    exit /b 1
)

echo.
echo 4. 构建Web版本...
flutter build web --release --no-tree-shake-icons
if %errorlevel% neq 0 (
    echo 错误：Web构建失败
    pause
    exit /b 1
)

echo.
echo ================================
echo 构建完成！
echo ================================
echo.
echo 部署文件位置：%cd%\build\web
echo.
echo 部署选项：
echo 1. GitHub Pages：将build/web内容推送到gh-pages分支
echo 2. Netlify：拖拽build/web文件夹到netlify.com
echo 3. Vercel：在build/web目录运行 vercel 命令
echo 4. 本地测试：在build/web目录运行 python -m http.server 8080
echo.
echo 分享链接：部署完成后，朋友可以直接通过浏览器访问
echo.
pause 