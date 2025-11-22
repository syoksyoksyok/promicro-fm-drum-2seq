@echo off
setlocal enabledelayedexpansion
REM ========================================
REM Pro Micro FM Drum Machine - Clean Script
REM ========================================

echo ========================================
echo  Pro Micro FM Drum Machine
echo  Clean Build Files
echo ========================================
echo.

REM PlatformIOの検索と設定
set "PIO_CMD=pio"

where pio >nul 2>&1
if %ERRORLEVEL% EQU 0 goto :pio_found

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
pause
exit /b 1

:pio_found

echo [INFO] Cleaning build files...
echo.

"%PIO_CMD%" run --target clean

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo  CLEAN SUCCESS!
    echo ========================================
    echo.
    echo Build files have been removed.
    echo.
    echo To rebuild:
    echo   build.bat
    echo.
) else (
    echo.
    echo [ERROR] Clean failed!
    echo.
)

pause
