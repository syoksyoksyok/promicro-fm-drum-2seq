# クイックスタートガイド（Windows）

Pro Micro 2ch FM Drum Machine を最速で動かすための手順です。

## 最速の手順（5分で完了）

### 1. PlatformIOのインストール

PowerShellまたはコマンドプロンプトを開いて実行:

```cmd
pip install platformio
```

### 2. プロジェクトをダウンロード

```cmd
git clone https://github.com/syoksyoksyok/promicro-fm-drum-2seq.git
cd promicro-fm-drum-2seq
```

または、ZIPをダウンロードして解凍してから:

```cmd
cd C:\path\to\promicro-fm-drum-2seq
```

### 3. ビルド

```cmd
build.bat
```

**初回は5〜10分かかります**（ツールチェーンのダウンロード）

### 4. COMポート確認

Pro MicroをUSBに接続してから:

```cmd
pio device list
```

出力例:
```
COM3
----
Hardware ID: USB VID:PID=2341:8037
Description: SparkFun Pro Micro (COM3)
```

→ **COM3** をメモ

### 5. 書き込み

**方法A: 自動スクリプト（推奨）**

```powershell
powershell -ExecutionPolicy Bypass -File auto_upload.ps1 -ComPort COM3
```

**方法B: 手動スクリプト**

```cmd
upload.bat COM3
```

Pro Microをリセット（RSTピンをGNDに2回短絡）してから、
指示に従ってEnterキーを押す。

### 6. 動作確認

```cmd
monitor.bat COM3
```

以下のように表示されればOK:

```
Pro Micro FM Drum Machine
2ch FM Drum Sequencer
Sample Rate: 16kHz, PWM: 10bit
Initializing audio engine...
Initializing sequencer...
Ready!
Playback: Playing
```

### 7. 音を聞く

D5とD6ピンからPWM音声が出力されています。

**簡易接続（すぐに試したい場合）:**

```
Pro Micro D5 ─── [スピーカー/イヤホン+側]
Pro Micro GND ── [スピーカー/イヤホン-側]
```

**推奨接続（RCフィルタあり）:**

```
Pro Micro D5 ───[1kΩ]─┬─── CH1 Audio Out
                       │
                    [100nF]
                       │
                      GND
```

---

## ワンライナー（全部まとめて実行）

```cmd
pip install platformio && cd promicro-fm-drum-2seq && build.bat && upload.bat COM3
```

※ COM3は実際のポート番号に変更してください

---

## トラブルシューティング早見表

| 問題 | 解決策 |
|------|--------|
| `pip: command not found` | Pythonをインストール https://python.org |
| `pio: command not found` | `pip install platformio` を実行 |
| COMポートが見つからない | デバイスマネージャーで確認、USBケーブル変更 |
| アップロード失敗 | Pro Micro をリセット（RST→GND 2回）|
| 音が出ない | RCフィルタを確認、ボリューム確認 |

---

## よくある質問

**Q: Pythonがインストールされていない**

A: https://www.python.org/downloads/ からダウンロード。
   インストール時に **"Add Python to PATH"** にチェック！

**Q: Pro Microのリセット方法は？**

A: RSTピンとGNDを0.5秒間隔で2回短絡。LEDが点滅したらOK。

**Q: 書き込み後、何も聞こえない**

A:
1. D5/D6からPWMが出ているか確認（オシロスコープ/LED）
2. RCフィルタが正しく接続されているか確認
3. シリアルモニタで "Playback: Playing" と表示されるか確認

---

## 次のステップ

詳細な情報は以下を参照:

- **Windows環境の詳細**: [WINDOWS_BUILD.md](WINDOWS_BUILD.md)
- **全体ドキュメント**: [README.md](README.md)
- **配線図**: README.mdの「配線」セクション

---

**それでは、FM合成ドラムマシンを楽しんでください！**
