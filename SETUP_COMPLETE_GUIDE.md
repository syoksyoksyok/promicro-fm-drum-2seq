# 完全セットアップガイド

**あなたの環境専用の手順書**

プロジェクトパス: `C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq`

---

## 📋 目次

1. [前提条件の確認](#前提条件の確認)
2. [PlatformIOのインストール](#platformioのインストール)
3. [ビルド](#ビルド)
4. [Pro Microへの書き込み](#pro-microへの書き込み)
5. [動作確認](#動作確認)
6. [完全なコマンド集](#完全なコマンド集)

---

## 前提条件の確認

### 必要なもの

- ✅ Python 3.7以降
- ✅ Pro Micro (ATmega32U4)
- ✅ USBケーブル（データ転送対応）
- ✅ プロジェクトファイル（既に配置済み）

### Pythonのインストール確認

コマンドプロンプトを開いて:

```cmd
python --version
```

**出力例:**
```
Python 3.11.0
```

Python がインストールされていない場合:
1. https://www.python.org/downloads/ からダウンロード
2. インストール時に **"Add Python to PATH"** に必ずチェック
3. インストール後、コマンドプロンプトを再起動

---

## PlatformIOのインストール

### Step 1: コマンドプロンプトを開く

1. `Win + R` を押す
2. `cmd` と入力してEnter

### Step 2: PlatformIOをインストール

```cmd
pip install platformio
```

**出力例:**
```
Collecting platformio
  Downloading platformio-6.1.11.tar.gz
Installing collected packages: platformio
Successfully installed platformio-6.1.11
```

### Step 3: インストール確認

```cmd
pio --version
```

**出力例:**
```
PlatformIO Core, version 6.1.11
```

---

## ビルド

### Step 1: プロジェクトディレクトリへ移動

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
```

### Step 2: ビルド実行

**方法A: バッチファイルを使う（推奨）**

```cmd
build.bat
```

**方法B: PlatformIOコマンドを直接実行**

```cmd
pio run
```

### ビルド結果の確認

成功した場合の出力:

```
Processing sparkfun_promicro16 (platform: atmelavr; board: sparkfun_promicro16; framework: arduino)
...
Advanced Memory Usage is available via "PlatformIO Home > Project Inspect"
RAM:   [==        ]  15.2% (used 389 bytes from 2560 bytes)
Flash: [====      ]  42.1% (used 12134 bytes from 28672 bytes)
========================= [SUCCESS] Took 5.42 seconds =========================
```

**初回ビルドは5〜10分かかります**（AVRツールチェーンのダウンロード）

ファームウェアの場所:
```
C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq\.pio\build\sparkfun_promicro16\firmware.hex
```

---

## Pro Microへの書き込み

### Step 1: COMポートの確認

Pro MicroをUSBに接続してから:

```cmd
pio device list
```

**出力例:**
```
COM3
----
Hardware ID: USB VID:PID=1B4F:9206
Description: SparkFun Pro Micro (COM3)

COM4
----
Hardware ID: USB VID:PID=067B:2303
Description: USB Serial Port (COM4)
```

→ Pro Microは **COM3** です。あなたの環境でのポート番号をメモしてください。

### Step 2-A: 自動書き込み（推奨・簡単）

**PowerShellで実行:**

```powershell
powershell -ExecutionPolicy Bypass -File auto_upload.ps1 -ComPort COM3
```

※ COM3 を実際のポート番号に変更してください

このスクリプトは：
- Pro Microを自動的にリセット
- ブートローダーモードに移行
- ファームウェアを書き込み
- （オプション）シリアルモニタを起動

### Step 2-B: 手動書き込み

**コマンドプロンプトで実行:**

```cmd
upload.bat COM3
```

※ COM3 を実際のポート番号に変更してください

**重要な操作:**

1. スクリプト実行後、以下のメッセージが表示されます:
   ```
   IMPORTANT: Reset Pro Micro Now!
   Please reset Pro Micro by:
     1. Connect RST pin to GND twice quickly
        (within 0.5 seconds interval)
     2. LED should start blinking

   Press any key when Pro Micro is in bootloader mode...
   ```

2. Pro Microをリセット:
   - RSTピンをGNDに短絡（約0.2秒）
   - 離す
   - 再度短絡（約0.2秒）
   - LEDが点滅開始 → ブートローダーモード成功

3. キーボードの任意のキーを押す

4. 書き込み開始

### 書き込み成功の確認

```
avrdude: verifying ...
avrdude: 12134 bytes of flash verified

avrdude done.  Thank you.

========================================
 UPLOAD SUCCESS!
========================================
```

---

## 動作確認

### Step 1: シリアルモニタの起動

```cmd
monitor.bat COM3
```

または

```cmd
pio device monitor --port COM3 --baud 115200
```

### Step 2: 起動メッセージの確認

以下のように表示されればOK:

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

### Step 3: オーディオ出力の確認

**最小限の配線（動作確認用）:**

```
Pro Micro D5  ─── イヤホン/スピーカー +側
Pro Micro GND ─── イヤホン/スピーカー -側
```

D5ピンから音が聞こえるはずです。

**推奨の配線（RCフィルタ付き）:**

```
Pro Micro D5 ───[1kΩ]─┬─── CH1 Audio Out (左)
                       │
                    [100nF]
                       │
                      GND

Pro Micro D6 ───[1kΩ]─┬─── CH2 Audio Out (右)
                       │
                    [100nF]
                       │
                      GND
```

---

## 完全なコマンド集

### 初回セットアップ（すべて実行）

```cmd
REM Step 1: PlatformIOをインストール
pip install platformio

REM Step 2: プロジェクトディレクトリへ移動
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq

REM Step 3: ビルド
build.bat

REM Step 4: COMポート確認
pio device list

REM Step 5: 書き込み（COM3の場合）
upload.bat COM3

REM Step 6: 動作確認
monitor.bat COM3
```

### 2回目以降（コードを変更した後）

```cmd
REM プロジェクトディレクトリへ移動
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq

REM ビルド
build.bat

REM 書き込み
upload.bat COM3
```

### ワンライナー（ビルド→書き込みを一度に）

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq && build_and_upload.bat COM3
```

### クリーンビルド（問題が発生した場合）

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
clean.bat
build.bat
```

---

## バッチファイル一覧

プロジェクトルートに以下のバッチファイルが用意されています:

| ファイル名 | 用途 | 使い方 |
|-----------|------|--------|
| `build.bat` | ビルドのみ | `build.bat` |
| `upload.bat` | 書き込みのみ | `upload.bat COM3` |
| `build_and_upload.bat` | ビルド+書き込み | `build_and_upload.bat COM3` |
| `monitor.bat` | シリアルモニタ | `monitor.bat COM3` |
| `clean.bat` | ビルドファイル削除 | `clean.bat` |
| `auto_upload.ps1` | 自動リセット+書き込み | `powershell -ExecutionPolicy Bypass -File auto_upload.ps1 -ComPort COM3` |

---

## トラブルシューティング

### 問題1: `pio: command not found` または `'pio' は、内部コマンドまたは外部コマンド...`

**原因:** PlatformIOがインストールされていない、またはPATHが通っていない

**解決策:**

```cmd
REM 再インストール
pip install --upgrade platformio

REM パスの確認
where pio

REM 環境変数を確認（PowerShell）
$env:Path
```

### 問題2: `avrdude: butterfly_recv(): programmer is not responding`

**原因:** Pro Microがブートローダーモードになっていない

**解決策:**

1. RSTピンをGNDに2回短絡（約0.5秒間隔）
2. LEDが規則的に点滅することを確認
3. 8秒以内に書き込みコマンドを実行

**自動リセットスクリプトを使う（推奨）:**

```powershell
powershell -ExecutionPolicy Bypass -File auto_upload.ps1 -ComPort COM3
```

### 問題3: COMポートが見つからない

**解決策:**

1. デバイスマネージャーを開く（`Win + X` → `デバイスマネージャー`）
2. `ポート (COM と LPT)` を展開
3. Pro Microを抜き差しして、表示が変わるポートを確認
4. それでも表示されない場合:
   - USBケーブルを変更（データ転送対応のケーブルを使用）
   - 別のUSBポートを試す
   - Pro Microのドライバーをインストール

### 問題4: 書き込み後、シリアルモニタに何も表示されない

**確認事項:**

1. ボーレートが115200になっているか:
   ```cmd
   pio device monitor --port COM3 --baud 115200
   ```

2. 正しいCOMポートを指定しているか

3. 書き込み直後はPro Microがリセットされるため、数秒待つ

### 問題5: 音が出ない

**確認事項:**

1. D5/D6ピンから信号が出ているか（LED接続で確認可能）
2. RCフィルタが正しく接続されているか
3. スピーカー/イヤホンのボリュームが上がっているか
4. シリアルモニタで "Playback: Playing" と表示されているか
5. ボタン1（D2）を押して再生/停止を切り替えてみる

---

## Git関連コマンド

### 最新の変更を取得（更新があった場合）

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git pull origin claude/fm-drum-machine-01LVP5yJBvNCkW1WTujcN51H
```

### 取得後、再ビルドして書き込み

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git pull origin claude/fm-drum-machine-01LVP5yJBvNCkW1WTujcN51H
build.bat
upload.bat COM3
```

### 現在の状態確認

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git status
```

### ローカルの変更を破棄して最新版に戻す

ローカルで変更したファイルを破棄して、リモートの最新版に完全に戻したい場合:

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git reset --hard origin/claude/fm-drum-machine-01LVP5yJBvNCkW1WTujcN51H
git clean -fd
```

**注意:** このコマンドは、ローカルの変更を完全に削除します。

---

## 参考資料

- **クイックスタート**: [QUICKSTART_WINDOWS.md](QUICKSTART_WINDOWS.md)
- **詳細ビルド手順**: [WINDOWS_BUILD.md](WINDOWS_BUILD.md)
- **全体ドキュメント**: [README.md](README.md)

---

## サポート

問題が解決しない場合:

1. エラーメッセージ全文をコピー
2. 実行したコマンドをメモ
3. Pro Microの型番を確認（5V/16MHzか3.3V/8MHzか）
4. GitHubのIssuesで報告

---

**これで完了です！楽しいFMドラムマシンライフを！**
