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

REM PlatformIOの検索と設定（フルパス使用）
REM 優先1: .platformio フォルダ内（推奨）
if exist "%USERPROFILE%\.platformio\penv\Scripts\pio.exe" (
    set "PIO_CMD=%USERPROFILE%\.platformio\penv\Scripts\pio.exe"
    goto :pio_found
)

REM 優先2: Microsoft Store版Python
for /d %%D in ("%LOCALAPPDATA%\Packages\PythonSoftwareFoundation.Python.*") do (
    if exist "%%D\LocalCache\local-packages\Python*\Scripts\pio.exe" (
        for %%F in ("%%D\LocalCache\local-packages\Python*\Scripts\pio.exe") do (
            set "PIO_CMD=%%F"
            goto :pio_found
        )
    )
)

REM 優先3: 標準Python Scriptsフォルダ
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
pause
exit /b 1

:pio_found

REM COMポート自動検出
set "COM_PORT="

REM 引数でCOMポートが指定されている場合はそれを使用
if not "%1"=="" (
    set "COM_PORT=%1"
    echo [INFO] Using specified port: %COM_PORT%
    goto :port_found
)

REM COMポート自動検出（Arduino Leonardoを検索）
echo [INFO] Auto-detecting COM port...
for /f "tokens=2 delims==" %%I in ('wmic path Win32_PnPEntity where "Name like '%%Arduino Leonardo%%'" get DeviceID /value 2^>nul') do (
    for /f "tokens=1 delims=\" %%J in ("%%I") do (
        set "DEVICE_ID=%%I"
    )
)

if defined DEVICE_ID (
    for /f "tokens=2 delims=()" %%K in ('wmic path Win32_PnPEntity where "DeviceID='!DEVICE_ID:\=\\!'" get Name /value ^| findstr /C:"COM"') do (
        set "COM_PORT=%%K"
    )
)

REM より汎用的な検出（上記で見つからない場合）
if not defined COM_PORT (
    for /f "tokens=*" %%A in ('"%PIO_CMD%" device list ^| findstr /C:"Arduino Leonardo"') do (
        for /f "tokens=1" %%B in ("%%A") do (
            set "COM_PORT=%%B"
        )
    )
)

if not defined COM_PORT (
    echo [ERROR] Arduino Leonardo (Pro Micro) not found!
    echo.
    echo Available ports:
    "%PIO_CMD%" device list
    echo.
    echo Usage:
    echo   monitor.bat           (auto-detect)
    echo   monitor.bat COM25     (manual specify)
    echo.
    pause
    exit /b 1
)

echo [INFO] Detected port: %COM_PORT%

:port_found

echo [INFO] Monitoring port: %COM_PORT%
echo [INFO] Baud rate: 115200
echo.
echo Press Ctrl+C to exit
echo.
echo ========================================
echo.

"%PIO_CMD%" device monitor --port %COM_PORT% --baud 115200

echo.
echo Serial monitor closed.
pause
