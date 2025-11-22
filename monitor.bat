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
