@echo off
REM ========================================
REM Pro Micro FM Drum Machine - Clean Script
REM ========================================

echo ========================================
echo  Pro Micro FM Drum Machine
echo  Clean Build Files
echo ========================================
echo.

REM PlatformIOがインストールされているか確認
where pio >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] PlatformIO not found!
    pause
    exit /b 1
)

echo [INFO] Cleaning build files...
echo.

pio run --target clean

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
