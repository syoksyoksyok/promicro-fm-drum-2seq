@echo off
setlocal enabledelayedexpansion
REM ========================================
REM Pro Micro FM Drum Machine - Serial Monitor
REM ========================================

echo ========================================
echo  Pro Micro FM Drum Machine
echo  Serial Monitor
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
    echo   monitor.bat           (auto-detect)
    echo   monitor.bat COM39     (manual specify)
    echo.
    pause
    exit /b 1
)

echo [INFO] Detected port: !COM_PORT!

:port_found

echo [INFO] Monitoring port: !COM_PORT!
echo [INFO] Baud rate: 115200
echo.
echo Press Ctrl+C to exit
echo.
echo ========================================
echo.

"%PIO_CMD%" device monitor --port !COM_PORT! --baud 115200

echo.
echo Serial monitor closed.
pause
