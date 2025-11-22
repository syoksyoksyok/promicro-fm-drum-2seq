@echo off
setlocal enabledelayedexpansion
REM ========================================
REM Pro Micro FM Drum Machine - Upload Script
REM ========================================

echo ========================================
echo  Pro Micro FM Drum Machine
echo  Upload Script for Windows
echo ========================================
echo.

REM PlatformIOの検索と設定
set "PIO_CMD=pio"

REM 方法1: PATHから検索
where pio >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    goto :pio_found
)

REM 方法2: よくある場所を検索
if exist "%USERPROFILE%\.platformio\penv\Scripts\pio.exe" (
    set "PIO_CMD=%USERPROFILE%\.platformio\penv\Scripts\pio.exe"
    goto :pio_found
)

for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python*") do (
    if exist "%%D\Scripts\pio.exe" (
        set "PIO_CMD=%%D\Scripts\pio.exe"
        goto :pio_found
    )
)

for /d %%D in ("%APPDATA%\Python\Python*") do (
    if exist "%%D\Scripts\pio.exe" (
        set "PIO_CMD=%%D\Scripts\pio.exe"
        goto :pio_found
    )
)

echo [ERROR] PlatformIO not found!
echo Please install PlatformIO or run find_pio.bat
pause
exit /b 1

:pio_found

REM 引数チェック
if "%1"=="" (
    echo [ERROR] Please specify COM port!
    echo.
    echo Usage:
    echo   upload.bat COM3
    echo.
    echo Available ports:
    "%PIO_CMD%" device list
    echo.
    pause
    exit /b 1
)

set COM_PORT=%1

echo [INFO] Target port: %COM_PORT%
echo.

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
"%PIO_CMD%" run --target upload --upload-port %COM_PORT%

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo  UPLOAD SUCCESS!
    echo ========================================
    echo.
    echo Pro Micro is now running FM Drum Machine!
    echo.
    echo To monitor serial output:
    echo   monitor.bat %COM_PORT%
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
