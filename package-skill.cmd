@echo off
chcp 65001 >nul
echo ========================================
echo   h3yun-dev-assistant Package Tool
echo ========================================
echo.

REM Check if required files exist
if not exist "SKILL.md" (
    echo [ERROR] SKILL.md not found!
    pause
    exit /b 1
)

if not exist "README.md" (
    echo [WARNING] README.md not found, will only package SKILL.md
    echo.
)

if not exist "CODING_STANDARDS.md" (
    echo [WARNING] CODING_STANDARDS.md not found, will package without coding standards
    echo.
)

REM Create temp directory
echo Step 1/4: Creating package directory...
if exist "dist" rmdir /s /q "dist"
mkdir dist

REM Copy files to package directory
echo Step 2/4: Copying files...
copy SKILL.md dist\SKILL.md >nul
if exist "README.md" copy README.md dist\README.md >nul
if exist "CODING_STANDARDS.md" copy CODING_STANDARDS.md dist\CODING_STANDARDS.md >nul

REM Create ZIP archive
echo Step 3/4: Creating ZIP archive...
powershell -Command "Compress-Archive -Path dist\* -DestinationPath h3yun-dev-assistant.zip -Force"

REM Clean up temp directory
echo Step 4/4: Cleaning up...
rmdir /s /q "dist"

echo.
echo ========================================
echo   Package Complete!
echo   File: %CD%\h3yun-dev-assistant.zip
echo ========================================
echo.
pause
