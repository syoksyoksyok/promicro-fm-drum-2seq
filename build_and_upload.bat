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

REM PlatformIO full path
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

REM COM port auto-detection
set "COM_PORT="

REM Use specified port if provided as argument
if not "%1"=="" (
    set "COM_PORT=%1"
    echo [INFO] Using specified port: %COM_PORT%
    goto :port_found
)

REM Auto-detect COM port using PlatformIO device list
echo.
echo ========================================
echo [STEP 1] COM Port Detection
echo ========================================
set "TEMP_PIO_LIST=%TEMP%\pio_list.txt"

echo [1-1] Getting device list from PlatformIO...
"%PIO_CMD%" device list > "%TEMP_PIO_LIST%" 2>nul
if exist "%TEMP_PIO_LIST%" (
    echo [OK] Device list retrieved
) else (
    echo [NG] Failed to get device list
)

echo.
echo [1-2] Detected devices:
echo ----------------------------------------
type "%TEMP_PIO_LIST%"
echo ----------------------------------------

echo.
echo [1-3] Extracting COM port...
echo [DEBUG] Before loop: COM_PORT = [!COM_PORT!]

for /f "tokens=1" %%A in ('findstr /B "COM" "%TEMP_PIO_LIST%"') do (
    if "!COM_PORT!"=="" (
        set "COM_PORT=%%A"
        echo [OK] Selected: %%A
        echo [DEBUG] Inside loop: COM_PORT = [%%A]
    )
)

echo [DEBUG] After loop: COM_PORT = [!COM_PORT!]

REM Delete temp file
if exist "%TEMP_PIO_LIST%" del "%TEMP_PIO_LIST%"

echo.
echo [1-4] COM port verification...
echo [DEBUG] Before check: COM_PORT = [!COM_PORT!]

if "!COM_PORT!"=="" (
    echo [NG] No COM port detected!
    echo.
    echo Available ports:
    "%PIO_CMD%" device list
    echo.
    echo Usage:
    echo   build_and_upload.bat           (auto-detect)
    echo   build_and_upload.bat COM39     (manual specify)
    echo.
    pause
    exit /b 1
) else (
    echo [OK] Confirmed: !COM_PORT!
)
echo ========================================

:port_found

echo.
echo ========================================
echo [STEP 2] Building Firmware
echo ========================================
echo Target: Pro Micro FM Drum Machine
echo.
echo [2-1] Starting build...

"%PIO_CMD%" run

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ========================================
    echo [NG] Build FAILED!
    echo ========================================
    echo.
    echo Please check errors and fix them.
    pause
    exit /b 1
)

echo.
echo ========================================
echo [OK] Build Completed!
echo ========================================
echo.

echo.
echo ========================================
echo [STEP 3] Uploading Firmware
echo ========================================
echo Target port: !COM_PORT!
echo.
echo ----------------------------------------
echo IMPORTANT: Reset Pro Micro Now!
echo ----------------------------------------
echo.
echo Reset procedure:
echo   1. Connect RST pin to GND twice quickly
echo      (within 0.5 seconds interval)
echo   2. LED should start blinking
echo.
echo Press any key when Pro Micro is in bootloader mode...
pause >nul

echo.
echo [3-1] Starting upload...
echo Port: !COM_PORT!
echo.

"%PIO_CMD%" run --target upload --upload-port !COM_PORT!

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo [SUCCESS] Upload Completed!
    echo ========================================
    echo.
    echo Pro Micro is now running FM Drum Machine!
    echo.
    echo To monitor serial output:
    echo   monitor.bat !COM_PORT!
    echo.
    echo ========================================
    echo All processes completed successfully!
    echo ========================================
    echo.
) else (
    echo.
    echo ========================================
    echo [FAILED] Upload Failed
    echo ========================================
    echo.
    echo Try manual upload:
    echo   upload.bat !COM_PORT!
    echo.
    echo Common issues:
    echo   - Pro Micro is not in bootloader mode
    echo   - Wrong COM port
    echo   - USB cable does not support data transfer
    echo.
)

pause
