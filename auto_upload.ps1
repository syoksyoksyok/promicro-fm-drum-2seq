# ========================================
# Pro Micro FM Drum Machine
# Auto Reset and Upload Script (PowerShell)
# ========================================

param(
    [Parameter(Mandatory=$false)]
    [string]$ComPort = ""
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Pro Micro FM Drum Machine" -ForegroundColor Cyan
Write-Host " Auto Reset and Upload Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# PlatformIOの検索（フルパス使用）
$pioCmd = $null

# 優先1: .platformio フォルダ内（推奨）
$pioPath1 = "$env:USERPROFILE\.platformio\penv\Scripts\pio.exe"
if (Test-Path $pioPath1) {
    $pioCmd = $pioPath1
    Write-Host "[INFO] Found PlatformIO at: $pioCmd" -ForegroundColor Green
}

# 優先2: Microsoft Store版Python
if (-not $pioCmd) {
    $pythonPackages = Get-ChildItem "$env:LOCALAPPDATA\Packages\PythonSoftwareFoundation.Python.*" -ErrorAction SilentlyContinue
    foreach ($pkg in $pythonPackages) {
        $pioPath = Get-ChildItem "$($pkg.FullName)\LocalCache\local-packages\Python*\Scripts\pio.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($pioPath) {
            $pioCmd = $pioPath.FullName
            Write-Host "[INFO] Found PlatformIO at: $pioCmd" -ForegroundColor Green
            break
        }
    }
}

# 優先3: 標準Python Scriptsフォルダ
if (-not $pioCmd) {
    $pythonDirs = Get-ChildItem "$env:LOCALAPPDATA\Programs\Python\Python*" -ErrorAction SilentlyContinue
    foreach ($dir in $pythonDirs) {
        $pioPath = "$($dir.FullName)\Scripts\pio.exe"
        if (Test-Path $pioPath) {
            $pioCmd = $pioPath
            Write-Host "[INFO] Found PlatformIO at: $pioCmd" -ForegroundColor Green
            break
        }
    }
}

if (-not $pioCmd) {
    Write-Host "[ERROR] PlatformIO not found!" -ForegroundColor Red
    Write-Host "Please install PlatformIO first:" -ForegroundColor Yellow
    Write-Host "  pip install platformio" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# COMポート自動検出
if ([string]::IsNullOrEmpty($ComPort)) {
    Write-Host "[INFO] Auto-detecting COM port..." -ForegroundColor Yellow

    # WMIでArduino Leonardoを検索
    $devices = Get-WmiObject -Query "SELECT * FROM Win32_PnPEntity WHERE Name LIKE '%Arduino Leonardo%'" -ErrorAction SilentlyContinue

    if ($devices) {
        foreach ($device in $devices) {
            if ($device.Name -match '(COM\d+)') {
                $ComPort = $matches[1]
                Write-Host "[INFO] Detected port: $ComPort" -ForegroundColor Green
                break
            }
        }
    }

    # 見つからない場合はPlatformIO device listで検索
    if ([string]::IsNullOrEmpty($ComPort)) {
        $deviceList = & $pioCmd device list 2>$null
        foreach ($line in $deviceList) {
            if ($line -match 'Arduino Leonardo' -and $line -match '^(COM\d+)') {
                $ComPort = $matches[1]
                Write-Host "[INFO] Detected port: $ComPort" -ForegroundColor Green
                break
            }
        }
    }

    # それでも見つからない場合はエラー
    if ([string]::IsNullOrEmpty($ComPort)) {
        Write-Host "[ERROR] Arduino Leonardo (Pro Micro) not found!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Available ports:" -ForegroundColor Yellow
        & $pioCmd device list
        Write-Host ""
        Write-Host "Usage:" -ForegroundColor Yellow
        Write-Host "  .\auto_upload.ps1           (auto-detect)" -ForegroundColor White
        Write-Host "  .\auto_upload.ps1 COM25     (manual specify)" -ForegroundColor White
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
} else {
    Write-Host "[INFO] Using specified port: $ComPort" -ForegroundColor Green
}

# ファームウェアの存在確認
$firmwarePath = ".pio\build\sparkfun_promicro16\firmware.hex"
if (-not (Test-Path $firmwarePath)) {
    Write-Host "[ERROR] Firmware not found!" -ForegroundColor Red
    Write-Host "Please build first:" -ForegroundColor Yellow
    Write-Host "  pio run" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "[INFO] Target port: $ComPort" -ForegroundColor Green
Write-Host ""

# ========================================
# Auto Reset Function
# ========================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Step 1: Auto Reset Pro Micro" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # シリアルポートを1200bpsで開いてすぐ閉じる（Pro Microのリセットトリガー）
    Write-Host "[INFO] Sending reset signal to $ComPort..." -ForegroundColor Yellow

    $port = New-Object System.IO.Ports.SerialPort
    $port.PortName = $ComPort
    $port.BaudRate = 1200
    $port.DataBits = 8
    $port.Parity = [System.IO.Ports.Parity]::None
    $port.StopBits = [System.IO.Ports.StopBits]::One

    $port.Open()
    Start-Sleep -Milliseconds 100
    $port.Close()

    Write-Host "[SUCCESS] Reset signal sent!" -ForegroundColor Green
    Write-Host "[INFO] Waiting for bootloader..." -ForegroundColor Yellow

    # ブートローダーが起動するまで待機（約2秒）
    Start-Sleep -Seconds 2

    Write-Host "[SUCCESS] Pro Micro should be in bootloader mode now!" -ForegroundColor Green
    Write-Host ""

} catch {
    Write-Host "[WARNING] Auto reset failed: $_" -ForegroundColor Yellow
    Write-Host "[INFO] Please reset Pro Micro manually (RST to GND twice)" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter when Pro Micro is in bootloader mode"
}

# ========================================
# Upload
# ========================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Step 2: Uploading Firmware" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[INFO] Starting upload to $ComPort..." -ForegroundColor Yellow
Write-Host ""

# アップロード実行
$uploadResult = & $pioCmd run --target upload --upload-port $ComPort

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host " UPLOAD SUCCESS!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Pro Micro is now running FM Drum Machine!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To monitor serial output:" -ForegroundColor Yellow
    Write-Host "  pio device monitor --port $ComPort --baud 115200" -ForegroundColor White
    Write-Host ""

    # シリアルモニタを起動するか確認
    $response = Read-Host "Open serial monitor now? (y/n)"
    if ($response -eq "y" -or $response -eq "Y") {
        Write-Host ""
        Write-Host "[INFO] Opening serial monitor (Press Ctrl+C to exit)..." -ForegroundColor Yellow
        Write-Host ""
        Start-Sleep -Seconds 1
        & $pioCmd device monitor --port $ComPort --baud 115200
    }

} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host " UPLOAD FAILED!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "  - Pro Micro is not in bootloader mode" -ForegroundColor White
    Write-Host "  - Wrong COM port specified" -ForegroundColor White
    Write-Host "  - USB cable is charge-only (not data)" -ForegroundColor White
    Write-Host ""
    Write-Host "Try again:" -ForegroundColor Yellow
    Write-Host "  .\auto_upload.ps1 -ComPort $ComPort" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Read-Host "Press Enter to exit"
