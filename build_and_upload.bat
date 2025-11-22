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

REM COMポート自動検出
set "COM_PORT="

REM 引数でCOMポートが指定されている場合はそれを使用
if not "%1"=="" (
    set "COM_PORT=%1"
    echo [INFO] Using specified port: %COM_PORT%
    goto :port_found
)

REM COMポート自動検出（PlatformIO device listを使用）
echo.
echo ========================================
echo [STEP 1] COMポート検出
echo ========================================
set "TEMP_PIO_LIST=%TEMP%\pio_list.txt"
set "TEMP_COM_LIST=%TEMP%\pio_com.txt"

echo [1-1] PlatformIOでデバイス一覧取得中...
"%PIO_CMD%" device list > "%TEMP_PIO_LIST%" 2>nul
if exist "%TEMP_PIO_LIST%" (
    echo [OK] デバイス一覧取得成功
) else (
    echo [NG] デバイス一覧取得失敗
)

echo.
echo [1-2] 検出されたデバイス:
echo ----------------------------------------
type "%TEMP_PIO_LIST%"
echo ----------------------------------------

echo.
echo [1-3] COMポート行を抽出中...
findstr /B "COM" "%TEMP_PIO_LIST%" > "%TEMP_COM_LIST%" 2>nul
if exist "%TEMP_COM_LIST%" (
    echo [OK] COMポート抽出成功
) else (
    echo [NG] COMポート抽出失敗
)

echo.
echo [1-4] 抽出されたCOMポート:
echo ----------------------------------------
type "%TEMP_COM_LIST%"
echo ----------------------------------------

echo.
echo [1-5] 最初のCOMポートを選択中...
for /f "tokens=1" %%A in (%TEMP_COM_LIST%) do (
    if "!COM_PORT!"=="" (
        set "COM_PORT=%%A"
        echo [OK] 選択: %%A
    )
)

echo.
echo [1-6] COMポート確定確認...
if "!COM_PORT!"=="" (
    echo [NG] COMポート検出失敗！
    echo.
    echo 利用可能なポート:
    "%PIO_CMD%" device list
    echo.
    echo 使用方法:
    echo   build_and_upload.bat           (自動検出)
    echo   build_and_upload.bat COM39     (手動指定)
    echo.
    REM 一時ファイル削除
    if exist "%TEMP_PIO_LIST%" del "%TEMP_PIO_LIST%"
    if exist "%TEMP_COM_LIST%" del "%TEMP_COM_LIST%"
    pause
    exit /b 1
) else (
    echo [OK] 確定: !COM_PORT!
)
echo ========================================

REM 一時ファイル削除
if exist "%TEMP_PIO_LIST%" del "%TEMP_PIO_LIST%"
if exist "%TEMP_COM_LIST%" del "%TEMP_COM_LIST%"

:port_found

echo.
echo ========================================
echo [STEP 2] ビルド実行
echo ========================================
echo 対象: Pro Micro FM Drum Machine
echo.
echo [2-1] ビルド開始...

"%PIO_CMD%" run

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ========================================
    echo [NG] ビルド失敗！
    echo ========================================
    echo.
    echo エラーを確認して修正してください。
    pause
    exit /b 1
)

echo.
echo ========================================
echo [OK] ビルド完了！
echo ========================================
echo.

echo.
echo ========================================
echo [STEP 3] アップロード実行
echo ========================================
echo 対象ポート: !COM_PORT!
echo.
echo ----------------------------------------
echo 重要: Pro Microをリセットしてください
echo ----------------------------------------
echo.
echo リセット方法:
echo   1. RSTピンをGNDに2回素早く接続
echo      (0.5秒以内の間隔で)
echo   2. LEDが点滅を開始
echo.
echo Pro Microがブートローダーモードになったら
echo 何かキーを押してください...
pause >nul

echo.
echo [3-1] アップロード開始...
echo ポート: !COM_PORT!
echo.

"%PIO_CMD%" run --target upload --upload-port !COM_PORT!

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo [成功] アップロード完了！
    echo ========================================
    echo.
    echo Pro Micro でFM Drum Machineが動作中です！
    echo.
    echo シリアル出力を確認するには:
    echo   monitor.bat !COM_PORT!
    echo.
    echo ========================================
    echo すべての処理が正常に完了しました！
    echo ========================================
    echo.
) else (
    echo.
    echo ========================================
    echo [失敗] アップロード失敗
    echo ========================================
    echo.
    echo 手動アップロードを試してください:
    echo   upload.bat !COM_PORT!
    echo.
    echo よくある問題:
    echo   - Pro Microがブートローダーモードでない
    echo   - 間違ったCOMポート
    echo   - USBケーブルがデータ転送非対応
    echo.
)

pause
