# Pro Micro 2ch FM Drum Machine

Arduino Pro Micro (ATmega32U4) 向けの2チャンネル独立FMドラムマシン＆ステップシーケンサー

## クイックスタート

**Windows環境の方（推奨順）:**
1. 📘 [完全セットアップガイド](SETUP_COMPLETE_GUIDE.md) - **あなたの環境専用の詳細手順**
2. 📝 [コマンドチートシート](COMMANDS_CHEATSHEET.md) - **コピペ用コマンド集**
3. 🔄 [Gitコマンドリファレンス](GIT_COMMANDS.md) - **最新版の取得方法**
4. ⚡ [クイックスタート](QUICKSTART_WINDOWS.md) - 5分で動かす最短手順
5. 📖 [詳細ビルド手順](WINDOWS_BUILD.md) - 3つの方法とトラブルシューティング

**Linux/Mac環境の方:**
- 下記の「ビルド＆書き込み手順」を参照

## 特徴

- **2チャンネル独立PWMオーディオ出力**（D5, D6）
- **2オペレータFM合成**による多彩なドラムサウンド
- **4種類のFMアルゴリズム**切り替え可能
  - ALG_SIMPLE_FM: シンプルなFM変調
  - ALG_STRONG_FM: 強めの変調
  - ALG_FEEDBACK: フィードバックFM
  - ALG_NOISE_MIX: FM音とノイズのミックス
- **16ステップ × 2トラック**のシーケンサー
- **シンプルなUI**: ボタン2個 + ノブ1個
- **固定小数点演算のみ**（float/double不使用）で高速動作
- **サンプルレート 16kHz、PWM 10bit分解能**

## 仕様

### ハードウェア
- **マイコン**: ATmega32U4 (Arduino Pro Micro, 16MHz)
- **RAM**: 約2.5KB
- **Flash**: 約32KB

### オーディオエンジン
- **サンプルレート**: 16kHz (Timer1でCTC割り込み)
- **PWM周波数**: 約15.6kHz (Timer4、10bit分解能)
- **出力ピン**:
  - CH1: D5 (OC4A)
  - CH2: D6 (OC4D)

### UI
- **ボタン1** (D2): 再生/停止
- **ボタン2** (D3): ランダマイズ（パターン＋パラメータ）
- **ノブ1** (A0): 2トラック共通のディケイ調整

## プロジェクト構成

```
promicro-fm-drum-2seq/
├── platformio.ini          # PlatformIO設定ファイル
├── README.md              # このファイル
└── src/
    ├── main.cpp           # メインプログラム（setup/loop）
    ├── audio_engine.h     # オーディオエンジン ヘッダー
    ├── audio_engine.cpp   # オーディオエンジン 実装
    ├── sequencer.h        # シーケンサー ヘッダー
    ├── sequencer.cpp      # シーケンサー 実装
    ├── lut_tables.h       # LUTテーブル ヘッダー
    └── lut_tables.cpp     # LUTテーブル 実装（サイン波）
```

## ビルド＆書き込み手順

### 必要なツール

- [PlatformIO](https://platformio.org/)（推奨）
- または Arduino IDE + Pro Microボードサポート

### PlatformIOでのビルド

```bash
# プロジェクトディレクトリに移動
cd promicro-fm-drum-2seq

# ビルド
pio run

# Pro Microを接続してアップロード
pio run --target upload

# シリアルモニタで動作確認
pio device monitor
```

### Arduino IDEでのビルド

1. `src/`内の全ファイルを1つのフォルダにコピー
2. `main.cpp`を`main.ino`にリネーム
3. Arduino IDEで開く
4. ボード設定: `Tools > Board > SparkFun AVR Boards > SparkFun Pro Micro`
5. プロセッサ: `ATmega32U4 (5V, 16MHz)`
6. コンパイル＆アップロード

### 手動書き込み（avrdude）

```bash
# Linuxの例
avrdude -p atmega32u4 -c avr109 -P /dev/ttyACM0 -b 57600 \
  -U flash:w:.pio/build/sparkfun_promicro16/firmware.hex:i

# Windowsの例
avrdude -p atmega32u4 -c avr109 -P COM3 -b 57600 ^
  -U flash:w:.pio\build\sparkfun_promicro16\firmware.hex:i
```

**注**: Pro Microは標準でUF2ブートローダーをサポートしていません。UF2形式で書き込む場合は、別途UF2対応ブートローダー（QMK/Catalinaなど）を書き込む必要があります。

## 配線

### オーディオ出力

PWM出力をRCローパスフィルタでアナログ化してから外部オーディオアンプに接続してください。

```
Pro Micro D5 (CH1) ───[1kΩ]─┬─── CH1 Audio Out
                            │
                          [100nF]
                            │
                           GND

Pro Micro D6 (CH2) ───[1kΩ]─┬─── CH2 Audio Out
                            │
                          [100nF]
                            │
                           GND
```

推奨フィルタ: 1kΩ + 100nF (カットオフ周波数 約1.6kHz)

### ボタン

```
D2 (Play/Stop) ───[タクトスイッチ]─── GND
D3 (Randomize) ───[タクトスイッチ]─── GND
```

内部プルアップ有効のため、外部抵抗不要。

### ノブ（可変抵抗器）

```
      VCC (5V)
         │
         ├─── 10kΩ可変抵抗
         │    (ポット)
         ├─────── A0
         │
        GND
```

## 使い方

1. Pro Microに電源を入れる
2. 起動直後、デモパターンが自動再生される
3. **ボタン1（再生/停止）**: シーケンサーの再生/停止を切り替え
4. **ボタン2（ランダマイズ）**: 2トラックのパターンとFMパラメータを完全ランダム化
5. **ノブ（ディケイ）**: 回すと両トラックのディケイ（音の長さ）が同時に変化

### デモパターン

- **Track A (CH1)**: キック風の4つ打ちパターン（60Hz前後の低音FM）
- **Track B (CH2)**: スネア/ハイハット風の裏拍パターン（300Hz前後 + ノイズミックス）

## 技術詳細

### タイマー構成

| タイマー | 用途 | モード | 周波数/レート |
|---------|------|--------|---------------|
| Timer1  | サンプルレート生成 | CTC | 16kHz (割り込み) |
| Timer4  | PWM生成（2ch） | 高速PWM 10bit | 約15.6kHz |

- **Timer1**: `ISR(TIMER1_COMPA_vect)`でオーディオサンプル生成
- **Timer4**: OC4A (D5) と OC4D (D6) でPWM出力、割り込みなし

### FM合成アルゴリズム

#### ALG_SIMPLE_FM
```
output = sin(phase_carrier + sin(phase_modulator) * fmIndex)
```

#### ALG_STRONG_FM
```
output = sin(phase_carrier + sin(phase_modulator) * fmIndex_high)
```

#### ALG_FEEDBACK
```
modulator += feedback_sample >> 3
output = sin(phase_carrier + sin(phase_modulator + feedback) * fmIndex)
```

#### ALG_NOISE_MIX
```
output = 0.7 * FM_sample + 0.3 * noise_sample
```

### メモリ使用量

- **サイン波LUT**: 256エントリ × 2バイト = 512バイト (PROGMEM)
- **パターンデータ**: 2トラック × 16ステップ × 1バイト = 32バイト
- **ボイス構造体**: 約60バイト × 2チャンネル = 120バイト
- 合計 RAM使用量: 約200〜300バイト（スタック除く）

### 性能最適化

- **浮動小数点演算禁止**: 全て整数/固定小数点演算
- **LUT使用**: サイン波はPROGMEMのテーブルから参照
- **ISRの軽量化**: 割り込み内では最小限の処理のみ
- **ビットシフト**: 乗算/除算を可能な限りビットシフトで代替

## トラブルシューティング

### 音が出ない

1. RCローパスフィルタが正しく接続されているか確認
2. シリアルモニタで"Ready!"と表示されるか確認
3. ボタン1で再生状態になっているか確認（"Playback: Playing"）

### ノイズが多い

1. RCフィルタのコンデンサ容量を増やす（100nF → 220nF）
2. グラウンドをしっかり接続
3. 電源ノイズを確認（USBノイズの場合は別電源を使用）

### ランダマイズで音が小さい/大きすぎる

- `audio_engine.cpp`の`randomizeDrumParams()`内で、`envLevel`の範囲を調整してください

## カスタマイズ

### BPMの変更

`sequencer.cpp`の`sequencerInit()`内で`setBPM(120)`の値を変更。

### ステップ数の変更

`sequencer.h`の`MAX_STEPS`を8, 16, 32などに変更。

### サンプルレートの変更

`audio_engine.cpp`の`setupTimer1SampleRate()`内で`OCR1A`の値を調整。

## ライセンス

MIT License

## 作者

Pro Micro FM Drum Machine Project

## 参考資料

- [ATmega32U4 Datasheet](https://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-7766-8-bit-AVR-ATmega16U4-32U4_Datasheet.pdf)
- [SparkFun Pro Micro Hookup Guide](https://learn.sparkfun.com/tutorials/pro-micro--fio-v3-hookup-guide)
- [FM Synthesis Wikipedia](https://en.wikipedia.org/wiki/Frequency_modulation_synthesis)

---

**Enjoy making beats with FM synthesis!**
