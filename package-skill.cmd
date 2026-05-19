@echo off
chcp 65001 >nul
echo ========================================
echo   氚云二开助手技能文件打包工具
echo ========================================
echo.

REM 检查必要文件是否存在
if not exist "SKILL.md" (
    echo [错误] 找不到 SKILL.md 文件!
    pause
    exit /b 1
)

if not exist "README.md" (
    echo [警告] 找不到 README.md 文件,将只打包 SKILL.md
    echo.
)

REM 创建临时目录
echo [1/4] 创建打包目录...
if exist "dist" rmdir /s /q "dist"
mkdir dist

REM 复制文件到打包目录
echo [2/4] 复制文件...
copy SKILL.md dist\SKILL.md >nul
if exist "README.md" copy README.md dist\README.md >nul

REM 如果有其他需要打包的文件,可以在这里添加
REM if exist "examples" xcopy /E /I /Y examples dist\examples >nul

REM 创建 ZIP 压缩包
echo [3/4] 创建 ZIP 压缩包...
powershell -Command "Compress-Archive -Path dist\* -DestinationPath h3yun-dev-assistant.zip -Force"

REM 清理临时目录
echo [4/4] 清理临时文件...
rmdir /s /q "dist"

echo.
echo ========================================
echo   打包完成!
echo   文件位置: %CD%\h3yun-dev-assistant.zip
echo ========================================
echo.
pause
