@echo off
setlocal enabledelayedexpansion
REM ========================================
REM Pro Micro FM Drum Machine - Build Script
REM ========================================

echo ========================================
echo  Pro Micro FM Drum Machine
echo  Build Script for Windows
echo ========================================
echo.

REM PlatformIOの検索と設定
set "PIO_CMD=pio"

REM 方法1: PATHから検索
where pio >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [INFO] Found PlatformIO in PATH
    goto :pio_found
)

REM 方法2: よくある場所を検索
echo [INFO] Searching for PlatformIO...

REM .platformio フォルダ内
if exist "%USERPROFILE%\.platformio\penv\Scripts\pio.exe" (
    set "PIO_CMD=%USERPROFILE%\.platformio\penv\Scripts\pio.exe"
    echo [INFO] Found PlatformIO at: %PIO_CMD%
    goto :pio_found
)

REM Python Scripts フォルダ（複数バージョン対応）
for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python*") do (
    if exist "%%D\Scripts\pio.exe" (
        set "PIO_CMD=%%D\Scripts\pio.exe"
        echo [INFO] Found PlatformIO at: !PIO_CMD!
        goto :pio_found
    )
)

for /d %%D in ("%APPDATA%\Python\Python*") do (
    if exist "%%D\Scripts\pio.exe" (
        set "PIO_CMD=%%D\Scripts\pio.exe"
        echo [INFO] Found PlatformIO at: !PIO_CMD!
        goto :pio_found
    )
)

REM 見つからない場合
echo [ERROR] PlatformIO not found!
echo.
echo Please install PlatformIO first:
echo   pip install platformio
echo.
echo Or run find_pio.bat to locate existing installation
echo.
pause
exit /b 1

:pio_found

echo [INFO] Starting build...
echo.

REM ビルド実行
"%PIO_CMD%" run

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo  BUILD SUCCESS!
    echo ========================================
    echo.
    echo Firmware location:
    echo   .pio\build\sparkfun_promicro16\firmware.hex
    echo.
    echo Next step: Upload to Pro Micro
    echo   upload.bat COM3
    echo.
) else (
    echo.
    echo ========================================
    echo  BUILD FAILED!
    echo ========================================
    echo.
    echo Please check the error messages above.
    echo.
)

pause
