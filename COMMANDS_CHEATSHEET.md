# コマンドチートシート（コピペ用）

**あなたの環境:** `C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq`

すべてのコマンドは、コピー＆ペーストしてそのまま使えます。

---

## 🚀 初回セットアップ（最初の1回だけ）

### すべて一括実行

コマンドプロンプトを開いて、以下をコピペして実行:

```cmd
pip install platformio && cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq && pio device list
```

COMポート番号をメモしたら:

```cmd
build.bat
```

ビルド完了後:

```cmd
upload.bat COM3
```

※ COM3 を実際のポート番号に変更

---

## 📝 日常的に使うコマンド

### プロジェクトディレクトリへ移動

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
```

### ビルドのみ

```cmd
build.bat
```

### 書き込みのみ（COM3の場合）

```cmd
upload.bat COM3
```

### ビルド + 書き込み（一括実行）

```cmd
build_and_upload.bat COM3
```

### シリアルモニタ起動

```cmd
monitor.bat COM3
```

### ビルドファイルのクリーン

```cmd
clean.bat
```

---

## ⚡ 自動リセット付き書き込み（推奨）

PowerShellで実行:

```powershell
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
powershell -ExecutionPolicy Bypass -File auto_upload.ps1 -ComPort COM3
```

---

## 🔧 PlatformIO直接コマンド

バッチファイルを使わない場合:

### ビルド

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
pio run
```

### 書き込み

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
pio run --target upload --upload-port COM3
```

### クリーン

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
pio run --target clean
```

### シリアルモニタ

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
pio device monitor --port COM3 --baud 115200
```

### デバイス一覧

```cmd
pio device list
```

---

## 🛠️ トラブルシューティング用コマンド

### Pythonバージョン確認

```cmd
python --version
```

### PlatformIOバージョン確認

```cmd
pio --version
```

### PlatformIOの再インストール

```cmd
pip uninstall platformio
pip install platformio
```

### PlatformIOのアップグレード

```cmd
pip install --upgrade platformio
```

### パスの確認

```cmd
where python
where pip
where pio
```

### COMポート確認（PowerShell）

```powershell
Get-WmiObject Win32_SerialPort | Select-Object Name, DeviceID
```

### デバイスマネージャーを開く

```cmd
devmgmt.msc
```

---

## 📊 情報確認コマンド

### メモリ使用量確認

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
pio run --verbose
```

### プロジェクト情報

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
pio project config
```

### ボード情報

```cmd
pio boards atmega32u4
```

---

## 🎯 シチュエーション別コマンド

### 初めて書き込む

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
build.bat
pio device list
upload.bat COM3
monitor.bat COM3
```

### コードを変更した後

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
build.bat
upload.bat COM3
```

### エラーが出て困った時

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
clean.bat
build.bat
upload.bat COM3
```

### 別のPro Microに書き込む

```cmd
pio device list
upload.bat COM4
```

※ COMポート番号を変更

---

## 💻 PowerShell用コマンド

### 一括実行（ビルド→書き込み→モニタ）

```powershell
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
.\build.bat
powershell -ExecutionPolicy Bypass -File auto_upload.ps1 -ComPort COM3
.\monitor.bat COM3
```

### 変数を使ったスマートな実行

```powershell
$ProjectPath = "C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq"
$ComPort = "COM3"

cd $ProjectPath
.\build.bat
.\upload.bat $ComPort
.\monitor.bat $ComPort
```

---

## 📱 ショートカット作成用コマンド

デスクトップにショートカットを作成する場合:

### ビルド用ショートカット

1. デスクトップで右クリック → 新規作成 → ショートカット
2. 場所:
   ```
   C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq\build.bat
   ```
3. 名前: `FM Drum - Build`

### 書き込み用ショートカット

1. デスクトップで右クリック → 新規作成 → ショートカット
2. 場所:
   ```
   C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq\upload.bat COM3
   ```
3. 名前: `FM Drum - Upload`

---

## 🔄 頻繁に使うワンライナー

### クイックビルド＆アップロード

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq && build_and_upload.bat COM3
```

### クリーン＆リビルド＆アップロード

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq && clean.bat && build.bat && upload.bat COM3
```

### アップロード＆モニタ

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq && upload.bat COM3 && monitor.bat COM3
```

---

## 📋 よく使うコマンドのエイリアス設定（PowerShell）

PowerShellプロファイルに追加すると便利:

```powershell
# PowerShellプロファイルを開く
notepad $PROFILE

# 以下を追加
function fmdrum-cd { cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq }
function fmdrum-build { cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq; .\build.bat }
function fmdrum-upload { cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq; .\upload.bat COM3 }
function fmdrum-monitor { cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq; .\monitor.bat COM3 }
```

保存後、PowerShellを再起動して:

```powershell
fmdrum-cd       # プロジェクトディレクトリへ移動
fmdrum-build    # ビルド
fmdrum-upload   # 書き込み
fmdrum-monitor  # モニタ
```

---

## 🆘 緊急時のコマンド

### Pro Microが認識しなくなった

```cmd
REM デバイスマネージャーでドライバーを削除
devmgmt.msc

REM Pro Microを抜き差し

REM 再度確認
pio device list
```

### PlatformIOが壊れた

```cmd
pip uninstall platformio
pip cache purge
pip install platformio
```

### 完全クリーンインストール

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
rmdir /s /q .pio
clean.bat
build.bat
```

---

**このチートシートをブックマークして、いつでも参照してください！**
