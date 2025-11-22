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

REM 引数チェック
if "%1"=="" (
    echo [INFO] No COM port specified, trying auto-detect...
    echo.

    REM 自動検出
    "%PIO_CMD%" device monitor --baud 115200

) else (
    set COM_PORT=%1
    echo [INFO] Monitoring port: %COM_PORT%
    echo [INFO] Baud rate: 115200
    echo.
    echo Press Ctrl+C to exit
    echo.
    echo ========================================
    echo.

    "%PIO_CMD%" device monitor --port %COM_PORT% --baud 115200
)

echo.
echo Serial monitor closed.
pause
