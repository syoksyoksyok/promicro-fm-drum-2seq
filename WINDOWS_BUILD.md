# Windows環境でのビルド＆書き込み手順

Pro Micro 2ch FM Drum Machine を Windows 環境でビルドして書き込むための詳細手順です。

## 目次

1. [方法1: PlatformIO CLI（推奨）](#方法1-platformio-cli推奨)
2. [方法2: Arduino IDE](#方法2-arduino-ide)
3. [方法3: avrdude直接実行](#方法3-avrdude直接実行)
4. [トラブルシューティング](#トラブルシューティング)

---

## 方法1: PlatformIO CLI（推奨）

### 前提条件

- Python 3.7以降
- Git for Windows（オプション）

### Step 1: PlatformIO Core のインストール

**PowerShellを開いて以下を実行:**

```powershell
# Pythonがインストールされているか確認
python --version

# PlatformIO Coreをインストール
pip install platformio

# インストール確認
pio --version
```

**または、コマンドプロンプト:**

```cmd
python --version
pip install platformio
pio --version
```

### Step 2: プロジェクトディレクトリへ移動

```cmd
cd C:\path\to\promicro-fm-drum-2seq
```

※ `C:\path\to\` の部分は実際のプロジェクトパスに置き換えてください。

### Step 3: ビルド

```cmd
pio run
```

初回実行時は、必要なツールチェーン（AVRツール）が自動的にダウンロードされます。

**出力例:**
```
Processing sparkfun_promicro16 (platform: atmelavr; board: sparkfun_promicro16; framework: arduino)
...
Advanced Memory Usage is available via "PlatformIO Home > Project Inspect"
RAM:   [==        ]  15.2% (used 389 bytes from 2560 bytes)
Flash: [====      ]  42.1% (used 12134 bytes from 28672 bytes)
========================= [SUCCESS] Took 5.42 seconds =========================
```

### Step 4: COMポートの確認

**PowerShell:**

```powershell
# Pro MicroをUSBに接続してから実行
pio device list
```

**出力例:**
```
COM3
----
Hardware ID: USB VID:PID=2341:8037
Description: SparkFun Pro Micro (COM3)
```

→ この例では **COM3** がPro Microのポートです。

### Step 5: 書き込み（アップロード）

**重要: Pro Microは書き込み前にリセットが必要です**

1. Pro MicroのRSTピンを2回連続でGNDに短絡（またはリセットボタンを2回押す）
2. 約8秒以内に以下のコマンドを実行

```cmd
pio run --target upload
```

PlatformIOが自動的にCOMポートを検出して書き込みます。

**手動でポート指定する場合:**

```cmd
pio run --target upload --upload-port COM3
```

### Step 6: シリアルモニタで動作確認

```cmd
pio device monitor
```

**出力例:**
```
Pro Micro FM Drum Machine
2ch FM Drum Sequencer
Sample Rate: 16kHz, PWM: 10bit
Initializing audio engine...
Initializing sequencer...
Ready!
Button1: Play/Stop
Button2: Randomize
Knob: Decay
Playback: Playing
```

終了するには `Ctrl + C`

---

## 方法2: Arduino IDE

### Step 1: Arduino IDEのインストール

1. [Arduino公式サイト](https://www.arduino.cc/en/software)からArduino IDE 2.xをダウンロード
2. インストーラーを実行してインストール

### Step 2: SparkFun ボードサポートの追加

1. Arduino IDEを起動
2. `File > Preferences` を開く
3. "Additional Boards Manager URLs" に以下を追加:
   ```
   https://raw.githubusercontent.com/sparkfun/Arduino_Boards/main/IDE_Board_Manager/package_sparkfun_index.json
   ```
4. `Tools > Board > Boards Manager` を開く
5. 検索欄に "sparkfun" と入力
6. "SparkFun AVR Boards" をインストール

### Step 3: プロジェクトファイルの準備

**PowerShellまたはコマンドプロンプト:**

```cmd
cd C:\path\to\promicro-fm-drum-2seq

# Arduinoスケッチ用フォルダを作成
mkdir arduino_build
cd arduino_build

# 全ソースファイルをコピー
copy ..\src\*.cpp .
copy ..\src\*.h .

# main.cpp を main.ino にリネーム
ren main.cpp main.ino
```

### Step 4: Arduino IDEで開く

1. `arduino_build\main.ino` をArduino IDEで開く
2. ボード設定:
   - `Tools > Board > SparkFun AVR Boards > SparkFun Pro Micro`
   - `Tools > Processor > ATmega32U4 (5V, 16MHz)`
3. COMポート設定:
   - `Tools > Port > COM3` (実際のポート番号を選択)

### Step 5: コンパイル＆アップロード

1. Pro MicroのRSTを2回連続で短絡（ブートローダーモード）
2. すぐに `Sketch > Upload` をクリック（またはCtrl+U）

**成功メッセージ:**
```
Sketch uses 12134 bytes (42%) of program storage space.
Global variables use 389 bytes (15%) of dynamic memory.
```

### Step 6: シリアルモニタで確認

1. `Tools > Serial Monitor` を開く
2. ボーレートを `115200` に設定
3. 起動メッセージが表示されることを確認

---

## 方法3: avrdude直接実行

### 前提条件

- avrdudeがインストール済み（PlatformIOまたはArduino IDEに含まれる）

### PlatformIOのavrdudeを使う場合

```cmd
cd C:\path\to\promicro-fm-drum-2seq

# ビルド
pio run

# Pro Microをリセットしてから8秒以内に実行
C:\Users\<ユーザー名>\.platformio\packages\tool-avrdude\avrdude.exe ^
  -C C:\Users\<ユーザー名>\.platformio\packages\tool-avrdude\avrdude.conf ^
  -p atmega32u4 ^
  -c avr109 ^
  -P COM3 ^
  -b 57600 ^
  -U flash:w:.pio\build\sparkfun_promicro16\firmware.hex:i
```

※ `<ユーザー名>` と `COM3` を実際の値に置き換えてください。

### Arduino IDEのavrdudeを使う場合

```cmd
"C:\Program Files (x86)\Arduino\hardware\tools\avr\bin\avrdude.exe" ^
  -C "C:\Program Files (x86)\Arduino\hardware\tools\avr\etc\avrdude.conf" ^
  -p atmega32u4 ^
  -c avr109 ^
  -P COM3 ^
  -b 57600 ^
  -U flash:w:.pio\build\sparkfun_promicro16\firmware.hex:i
```

---

## バッチファイルの使用

便利なバッチファイル（`.bat`）を用意しました。

### `build.bat` の使い方

プロジェクトルートで実行:

```cmd
build.bat
```

### `upload.bat` の使い方

```cmd
upload.bat COM3
```

※ COM3 の部分を実際のポート番号に変更してください。

---

## トラブルシューティング

### 問題1: COMポートが見つからない

**解決策:**

1. デバイスマネージャーを開く（`Win + X` → `デバイスマネージャー`）
2. `ポート (COM と LPT)` を展開
3. Pro Microを接続すると新しいCOMポートが表示される
4. 表示されない場合:
   - USBケーブルを変える（データ転送対応のケーブルを使用）
   - 別のUSBポートを試す
   - Pro Microのドライバーをインストール

**Pro Micro ドライバーのインストール:**

Windows 10/11では通常自動認識されますが、認識しない場合:

```powershell
# SparkFunのドライバーページ
Start-Process "https://learn.sparkfun.com/tutorials/pro-micro--fio-v3-hookup-guide/installing-windows"
```

### 問題2: avrdude: butterfly_recv(): programmer is not responding

**原因:** Pro Microがブートローダーモードになっていない

**解決策:**

1. Pro MicroのRSTピンをGNDに2回連続で短絡（約0.5秒間隔）
2. LEDが点滅し始める（ブートローダーモード）
3. すぐに（8秒以内に）書き込みコマンドを実行

**自動リセットスクリプト（PowerShell）:**

```powershell
# reset_and_upload.ps1
$port = "COM3"
$mode = New-Object System.IO.Ports.SerialPort $port,1200,None,8,One
$mode.Open()
$mode.Close()
Start-Sleep -Seconds 2
pio run --target upload --upload-port $port
```

実行:
```cmd
powershell -ExecutionPolicy Bypass -File reset_and_upload.ps1
```

### 問題3: python が認識されない

**解決策:**

1. [Python公式サイト](https://www.python.org/downloads/)からPythonをダウンロード
2. インストール時に **"Add Python to PATH"** にチェックを入れる
3. コマンドプロンプトを再起動

### 問題4: pio: コマンドが見つかりません

**解決策:**

```cmd
# PlatformIOを再インストール
python -m pip install --upgrade platformio

# パスを確認
where pio

# パスが表示されない場合、環境変数に追加
# C:\Users\<ユーザー名>\AppData\Local\Programs\Python\Python3x\Scripts
```

### 問題5: メモリ不足エラー

```
region 'text' overflowed by XXX bytes
```

**解決策:**

`platformio.ini`のビルドフラグを確認（既に最適化済み）:

```ini
build_flags =
    -Os                    ; サイズ最適化（最優先）
    -fno-exceptions
    -fno-threadsafe-statics
    -flto
```

不要な機能を削減:
- `main.cpp`のシリアル出力を削除
- パターン数を減らす

### 問題6: 書き込み後、シリアルモニタに何も表示されない

**原因:** ボーレートの不一致

**解決策:**

シリアルモニタのボーレートを **115200** に設定してください。

```cmd
# PlatformIOの場合
pio device monitor --baud 115200
```

---

## 環境変数の設定（オプション）

開発を効率化するために環境変数を設定:

**PowerShell（管理者権限）:**

```powershell
# PlatformIOのパスを追加
[Environment]::SetEnvironmentVariable(
    "Path",
    $env:Path + ";C:\Users\$env:USERNAME\.platformio\penv\Scripts",
    "User"
)
```

**コマンドプロンプト（管理者権限）:**

```cmd
setx PATH "%PATH%;C:\Users\%USERNAME%\.platformio\penv\Scripts"
```

---

## よくある質問

### Q1: Pro Microがブートローダーモードにならない

**A:** RSTピンを2回短絡する間隔を調整してください（0.3〜0.7秒間隔）。LEDが規則的に点滅したら成功です。

### Q2: 複数のPro Microを使う場合は？

**A:** COMポート番号を指定してください:

```cmd
pio run --target upload --upload-port COM4
```

### Q3: ビルドに時間がかかる

**A:** 初回ビルドは依存関係のダウンロードに時間がかかります（5〜10分）。2回目以降は30秒程度です。

### Q4: UF2形式で書き込みたい

**A:** Pro Microは標準でUF2をサポートしていません。QMK/Catalinaブートローダーを別途書き込む必要があります（非推奨・上級者向け）。

---

## まとめ

**最も簡単な方法（推奨）:**

```cmd
# 1. PlatformIOをインストール
pip install platformio

# 2. プロジェクトディレクトリへ移動
cd C:\path\to\promicro-fm-drum-2seq

# 3. ビルド
pio run

# 4. Pro MicroをRST 2回でブートローダーモード

# 5. 書き込み
pio run --target upload

# 6. 動作確認
pio device monitor
```

**完了！** Pro Microから2chのFMドラムサウンドが聞こえるはずです。

---

## 参考リンク

- [PlatformIO公式ドキュメント](https://docs.platformio.org/)
- [Arduino IDE公式ドキュメント](https://www.arduino.cc/en/Guide)
- [SparkFun Pro Micro Guide](https://learn.sparkfun.com/tutorials/pro-micro--fio-v3-hookup-guide)
- [avrdude マニュアル](https://www.nongnu.org/avrdude/user-manual/avrdude.html)

---

**お困りの際は、エラーメッセージ全文とともにお問い合わせください。**
