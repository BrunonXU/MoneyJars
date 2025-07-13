@echo off
echo ================================
echo MoneyJars 本地测试服务器
echo ================================

cd build\web

echo 启动本地服务器...
echo 访问地址：http://localhost:8080
echo 按 Ctrl+C 停止服务器
echo.

python -m http.server 8080 