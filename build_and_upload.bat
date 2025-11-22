@echo off
REM ========================================
REM Pro Micro FM Drum Machine
REM Build and Upload Script for Windows
REM ========================================

echo ========================================
echo  Pro Micro FM Drum Machine
echo  Build and Upload Script
echo ========================================
echo.

REM 引数チェック
if "%1"=="" (
    echo [ERROR] Please specify COM port!
    echo.
    echo Usage:
    echo   build_and_upload.bat COM3
    echo.
    echo Available ports:
    pio device list
    echo.
    pause
    exit /b 1
)

set COM_PORT=%1

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

REM ========================================
REM Step 1: Build
REM ========================================
echo ========================================
echo  Step 1/2: Building...
echo ========================================
echo.

pio run

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Build failed!
    pause
    exit /b 1
)

echo.
echo [SUCCESS] Build completed!
echo.

REM ========================================
REM Step 2: Upload
REM ========================================
echo ========================================
echo  Step 2/2: Uploading...
echo ========================================
echo.
echo [INFO] Target port: %COM_PORT%
echo.
echo ========================================
echo  IMPORTANT: Reset Pro Micro Now!
echo ========================================
echo.
echo Please reset Pro Micro by:
echo   1. Connect RST pin to GND twice quickly
echo      (within 0.5 seconds interval)
echo   2. LED should start blinking
echo.
echo Press any key when Pro Micro is in bootloader mode...
pause >nul

echo.
echo [INFO] Uploading to %COM_PORT%...
echo.

pio run --target upload --upload-port %COM_PORT%

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo  ALL DONE! SUCCESS!
    echo ========================================
    echo.
    echo Pro Micro is now running FM Drum Machine!
    echo.
    echo To monitor serial output:
    echo   pio device monitor --port %COM_PORT% --baud 115200
    echo.
    echo Or simply run:
    echo   monitor.bat %COM_PORT%
    echo.
) else (
    echo.
    echo ========================================
    echo  UPLOAD FAILED!
    echo ========================================
    echo.
    echo Please try again with manual upload:
    echo   upload.bat %COM_PORT%
    echo.
)

pause
