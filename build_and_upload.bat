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

REM COMポート自動検出
echo [INFO] Auto-detecting COM port...

REM 方法1: SparkFun Pro Micro VID:PIDで検出（1B4F:9205=通常, 1B4F:9206=ブートローダ）
for /f "tokens=*" %%A in ('wmic path Win32_PnPEntity where "DeviceID like '%%VID_1B4F&PID_9205%%' or DeviceID like '%%VID_1B4F&PID_9206%%'" get Name 2^>nul ^| findstr /C:"COM"') do (
    for /f "tokens=*" %%B in ("%%A") do (
        for /f "tokens=1 delims=()" %%C in ("%%B") do (
            set "TEMP_LINE=%%B"
        )
    )
)

if defined TEMP_LINE (
    for /f "tokens=2 delims=()" %%D in ("!TEMP_LINE!") do (
        set "COM_PORT=%%D"
    )
)

REM 方法2: Arduino Leonardoで検出
if not defined COM_PORT (
    for /f "tokens=*" %%A in ('wmic path Win32_PnPEntity where "Name like '%%Arduino Leonardo%%'" get Name 2^>nul ^| findstr /C:"COM"') do (
        for /f "tokens=2 delims=()" %%B in ("%%A") do (
            set "COM_PORT=%%B"
        )
    )
)

REM 方法3: PlatformIO device listで検出
if not defined COM_PORT (
    set "TEMP_PIO_LIST=%TEMP%\pio_list.txt"
    "%PIO_CMD%" device list > "!TEMP_PIO_LIST!" 2>nul
    for /f "tokens=1" %%A in ('type "!TEMP_PIO_LIST!" ^| findstr /R "^COM[0-9]"') do (
        if not defined COM_PORT set "COM_PORT=%%A"
    )
    if exist "!TEMP_PIO_LIST!" del "!TEMP_PIO_LIST!"
)

if not defined COM_PORT (
    echo [ERROR] Arduino Leonardo (Pro Micro) not found!
    echo.
    echo Available ports:
    "%PIO_CMD%" device list
    echo.
    echo Usage:
    echo   build_and_upload.bat           (auto-detect)
    echo   build_and_upload.bat COM25     (manual specify)
    echo.
    pause
    exit /b 1
)

echo [INFO] Detected port: %COM_PORT%

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

"%PIO_CMD%" run --target upload --upload-port %COM_PORT%

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
