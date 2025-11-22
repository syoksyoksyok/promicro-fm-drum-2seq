@echo off
REM ========================================
REM Pro Micro FM Drum Machine - Build Script
REM ========================================

echo ========================================
echo  Pro Micro FM Drum Machine
echo  Build Script for Windows
echo ========================================
echo.

REM PlatformIOがインストールされているか確認
where pio >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] PlatformIO not found!
    echo Please install PlatformIO first:
    echo   pip install platformio
    echo.
    pause
    exit /b 1
)

echo [INFO] Starting build...
echo.

REM ビルド実行
pio run

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo  BUILD SUCCESS!
    echo ========================================
    echo.
    echo Firmware location:
    echo   .pio\build\sparkfun_promicro16\firmware.hex
    echo.
    echo Next step: Upload to Pro Micro
    echo   upload.bat COM3
    echo.
) else (
    echo.
    echo ========================================
    echo  BUILD FAILED!
    echo ========================================
    echo.
    echo Please check the error messages above.
    echo.
)

pause
