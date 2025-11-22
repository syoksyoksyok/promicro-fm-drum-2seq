@echo off
REM ========================================
REM Pro Micro FM Drum Machine - Upload Script
REM ========================================

echo ========================================
echo  Pro Micro FM Drum Machine
echo  Upload Script for Windows
echo ========================================
echo.

REM 引数チェック
if "%1"=="" (
    echo [ERROR] Please specify COM port!
    echo.
    echo Usage:
    echo   upload.bat COM3
    echo.
    echo Available ports:
    pio device list
    echo.
    pause
    exit /b 1
)

set COM_PORT=%1

echo [INFO] Target port: %COM_PORT%
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

REM ファームウェアの存在確認
if not exist ".pio\build\sparkfun_promicro16\firmware.hex" (
    echo [ERROR] Firmware not found!
    echo Please build first:
    echo   build.bat
    echo.
    pause
    exit /b 1
)

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

REM アップロード実行
pio run --target upload --upload-port %COM_PORT%

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo  UPLOAD SUCCESS!
    echo ========================================
    echo.
    echo Pro Micro is now running FM Drum Machine!
    echo.
    echo To monitor serial output:
    echo   pio device monitor --port %COM_PORT% --baud 115200
    echo.
) else (
    echo.
    echo ========================================
    echo  UPLOAD FAILED!
    echo ========================================
    echo.
    echo Common issues:
    echo   - Pro Micro is not in bootloader mode
    echo   - Wrong COM port specified
    echo   - USB cable is data-transfer only
    echo.
    echo Try again:
    echo   1. Reset Pro Micro (RST to GND twice)
    echo   2. Run: upload.bat %COM_PORT%
    echo.
)

pause
