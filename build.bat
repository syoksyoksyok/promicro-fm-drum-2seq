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
