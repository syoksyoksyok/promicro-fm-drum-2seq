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

REM PlatformIOの検索と設定（フルパス使用）
echo [INFO] Searching for PlatformIO...

REM 優先1: .platformio フォルダ内（推奨）
if exist "%USERPROFILE%\.platformio\penv\Scripts\pio.exe" (
    set "PIO_CMD=%USERPROFILE%\.platformio\penv\Scripts\pio.exe"
    echo [INFO] Found PlatformIO at: %PIO_CMD%
    goto :pio_found
)

REM 優先2: Microsoft Store版Python
for /d %%D in ("%LOCALAPPDATA%\Packages\PythonSoftwareFoundation.Python.*") do (
    if exist "%%D\LocalCache\local-packages\Python*\Scripts\pio.exe" (
        for %%F in ("%%D\LocalCache\local-packages\Python*\Scripts\pio.exe") do (
            set "PIO_CMD=%%F"
            echo [INFO] Found PlatformIO at: !PIO_CMD!
            goto :pio_found
        )
    )
)

REM 優先3: 標準Python Scriptsフォルダ
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
