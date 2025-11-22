@echo off
REM ========================================
REM Pro Micro FM Drum Machine - Serial Monitor
REM ========================================

echo ========================================
echo  Pro Micro FM Drum Machine
echo  Serial Monitor
echo ========================================
echo.

REM 引数チェック
if "%1"=="" (
    echo [INFO] No COM port specified, trying auto-detect...
    echo.

    REM 自動アップロード（ポート指定なし）
    pio device monitor --baud 115200

) else (
    set COM_PORT=%1
    echo [INFO] Monitoring port: %COM_PORT%
    echo [INFO] Baud rate: 115200
    echo.
    echo Press Ctrl+C to exit
    echo.
    echo ========================================
    echo.

    pio device monitor --port %COM_PORT% --baud 115200
)

echo.
echo Serial monitor closed.
pause
