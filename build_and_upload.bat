@echo off
setlocal enabledelayedexpansion
REM ========================================
REM Pro Micro FM Drum Machine
REM Build and Upload Script for Windows
REM ========================================

echo ========================================
echo  Pro Micro FM Drum Machine
echo  Build and Upload Script
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
set "TEMP_COM_LIST=%TEMP%\pio_com.txt"
"%PIO_CMD%" device list > "%TEMP_PIO_LIST%" 2>nul

REM COMポート行を抽出
findstr /B "COM" "%TEMP_PIO_LIST%" > "%TEMP_COM_LIST%" 2>nul

REM 最初のCOMポートを使用
for /f "tokens=1" %%A in (%TEMP_COM_LIST%) do (
    if not defined COM_PORT set "COM_PORT=%%A"
)

REM 一時ファイル削除
if exist "%TEMP_PIO_LIST%" del "%TEMP_PIO_LIST%"
if exist "%TEMP_COM_LIST%" del "%TEMP_COM_LIST%"

REM 遅延展開を使用してCOM_PORTをチェック
if "!COM_PORT!"=="" (
    echo [ERROR] No COM port found!
    echo.
    echo Available ports:
    "%PIO_CMD%" device list
    echo.
    echo Usage:
    echo   build_and_upload.bat           (auto-detect)
    echo   build_and_upload.bat COM39     (manual specify)
    echo.
    pause
    exit /b 1
)

echo [INFO] Detected port: !COM_PORT!

:port_found

REM ========================================
REM Step 1: Build
REM ========================================
echo ========================================
echo  Step 1/2: Building...
echo ========================================
echo.

"%PIO_CMD%" run

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
echo [INFO] Target port: !COM_PORT!
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
echo [INFO] Uploading to !COM_PORT!...
echo.

"%PIO_CMD%" run --target upload --upload-port !COM_PORT!

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo  ALL DONE! SUCCESS!
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
    echo Please try again with manual upload:
    echo   upload.bat %COM_PORT%
    echo.
)

pause
