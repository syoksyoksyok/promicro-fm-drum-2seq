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

REM PlatformIOのフルパス指定
set "PIO_CMD=C:\Users\Administrator\.platformio\penv\Scripts\pio.exe"

if not exist "%PIO_CMD%" (
    echo [ERROR] PlatformIO not found at: %PIO_CMD%
    echo.
    echo Please check PlatformIO installation.
    pause
    exit /b 1
)

echo [INFO] Using PlatformIO: %PIO_CMD%

:pio_found

REM COMポート自動検出
set "COM_PORT="

REM 引数でCOMポートが指定されている場合はそれを使用
if not "%1"=="" (
    set "COM_PORT=%1"
    echo [INFO] Using specified port: %COM_PORT%
    goto :port_found
)

REM COMポート自動検出（PlatformIO device listを使用）
echo [INFO] Auto-detecting COM port...
set "TEMP_PIO_LIST=%TEMP%\pio_list.txt"
"%PIO_CMD%" device list > "%TEMP_PIO_LIST%" 2>nul

REM 最初のCOMポートを使用（COMで始まる行をすべて検索）
for /f "tokens=1" %%A in ('type "%TEMP_PIO_LIST%" ^| findstr /B "COM"') do (
    if not defined COM_PORT set "COM_PORT=%%A"
)

REM 一時ファイル削除
if exist "%TEMP_PIO_LIST%" del "%TEMP_PIO_LIST%"

if not defined COM_PORT (
    echo [ERROR] No COM port found!
    echo.
    echo Available ports:
    "%PIO_CMD%" device list
    echo.
    echo Usage:
    echo   upload.bat           (auto-detect)
    echo   upload.bat COM39     (manual specify)
    echo.
    pause
    exit /b 1
)

echo [INFO] Detected port: %COM_PORT%

:port_found

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
