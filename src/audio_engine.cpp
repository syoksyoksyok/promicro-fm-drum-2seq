#include "audio_engine.h"
#include "lut_tables.h"
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <Arduino.h>

// =============================================================================
// グローバル変数
// =============================================================================

// 2チャンネルのFMドラムボイス
static FmDrumVoice voices[NUM_CHANNELS];

// ディケイのグローバルスケール（ノブで制御）
static uint16_t globalDecayScale = 256; // 8.8固定小数点: 256 = 1.0倍

// =============================================================================
// ヘルパー関数：サイン波LUTから値を取得
// =============================================================================

// 32bit位相から16bitサイン波値を取得
static inline int16_t getSine(uint32_t phase) {
  uint8_t index = (phase >> PHASE_INDEX_SHIFT) & SINE_TABLE_MASK;
  return pgm_read_word(&sine_table[index]);
}

// =============================================================================
// ヘルパー関数：簡易ノイズジェネレータ（LFSR）
// =============================================================================

static inline int16_t generateNoise(uint32_t* state) {
  // 32bit LFSR（Xorshift）
  uint32_t x = *state;
  x ^= x << 13;
  x ^= x >> 17;
  x ^= x << 5;
  *state = x;
  // 16bitに変換
  return (int16_t)(x >> 16);
}

// =============================================================================
// ヘルパー関数：周波数からフェーズインクリメント値を計算
// =============================================================================

// freq_hz: 周波数（Hz）
// 戻り値: 32bit位相インクリメント値
static uint32_t frequencyToPhaseIncrement(uint16_t freq_hz) {
  // phase_increment = (freq_hz * 2^32) / SAMPLE_RATE
  // 16MHzのATmega32U4で64bit演算を避けるため、スケーリングして計算
  // 2^32 / SAMPLE_RATE = 4294967296 / 16000 = 268435.456 ≈ 268435
  // より正確には: (freq_hz * 268435456UL) / SAMPLE_RATE
  return ((uint32_t)freq_hz * 268435UL);
}

// =============================================================================
// FMドラムサンプル生成（各チャンネル）
// =============================================================================

static int16_t generateDrumSample(FmDrumVoice* voice) {
  if (!voice->active || voice->envValue == 0) {
    return 0;
  }

  int16_t output = 0;
  int16_t modSample = 0;
  int16_t carrierInput = 0;

  // アルゴリズムに応じた処理
  switch (voice->params.algo) {
    case ALG_SIMPLE_FM: {
      // output = sin(phase_c + sin(phase_m) * index)
      modSample = getSine(voice->phaseModulator);
      // fmIndexをスケーリング（右シフトで調整）
      carrierInput = (int32_t)modSample * voice->params.fmIndex >> 14;
      output = getSine(voice->phaseCarrier + carrierInput);
      break;
    }

    case ALG_STRONG_FM: {
      // output = sin(phase_c + sin(phase_m) * index_high)
      modSample = getSine(voice->phaseModulator);
      // より強い変調
      carrierInput = (int32_t)modSample * voice->params.fmIndex >> 12;
      output = getSine(voice->phaseCarrier + carrierInput);
      break;
    }

    case ALG_FEEDBACK: {
      // モジュレータにフィードバック
      int16_t fbAmount = voice->feedbackSample >> 3; // フィードバック量を1/8に
      modSample = getSine(voice->phaseModulator + fbAmount);
      carrierInput = (int32_t)modSample * voice->params.fmIndex >> 14;
      output = getSine(voice->phaseCarrier + carrierInput);
      voice->feedbackSample = modSample;
      break;
    }

    case ALG_NOISE_MIX: {
      // FM音 70% + ノイズ 30%
      modSample = getSine(voice->phaseModulator);
      carrierInput = (int32_t)modSample * voice->params.fmIndex >> 14;
      int16_t fmSample = getSine(voice->phaseCarrier + carrierInput);
      int16_t noiseSample = generateNoise(&voice->noiseState);

      // エンベロープをノイズにも適用
      noiseSample = (int32_t)noiseSample * voice->envValue >> 16;

      // ミックス: 70% FM + 30% ノイズ
      output = ((int32_t)fmSample * 179 + (int32_t)noiseSample * 77) >> 8; // 179/256≈0.7, 77/256≈0.3
      break;
    }

    default:
      output = 0;
      break;
  }

  // エンベロープ適用（ALG_NOISE_MIX以外）
  if (voice->params.algo != ALG_NOISE_MIX) {
    output = (int32_t)output * voice->envValue >> 16;
  }

  // レベル適用
  output = (int32_t)output * voice->params.envLevel >> 8;

  // 位相を進める
  voice->phaseCarrier += voice->params.baseFreq;
  voice->phaseModulator += voice->params.modFreq;

  // エンベロープを減衰（ディケイ）
  if (voice->envValue > 0) {
    // ディケイ速度 = 65535 / envDecay
    // envDecayが大きいほど遅く減衰
    uint16_t decay = voice->params.envDecay;
    if (decay > 0) {
      uint32_t decayAmount = 65536UL / decay;
      if (voice->envValue > decayAmount) {
        voice->envValue -= decayAmount;
      } else {
        voice->envValue = 0;
        voice->active = false;
      }
    }
  }

  return output;
}

// =============================================================================
// サンプル生成ISR（タイマー割り込みから呼ばれる）
// =============================================================================

static void audioSampleISR() {
  // 2チャンネル分のサンプルを生成
  int16_t sample1 = generateDrumSample(&voices[0]);
  int16_t sample2 = generateDrumSample(&voices[1]);

  // 16bit signed (-32768〜32767) を 10bit unsigned (0〜1023) に変換
  uint16_t pwm1 = ((int32_t)sample1 + 32768) >> 6; // 16bit -> 10bit
  uint16_t pwm2 = ((int32_t)sample2 + 32768) >> 6;

  // PWM値を制限
  if (pwm1 > PWM_MAX_VALUE) pwm1 = PWM_MAX_VALUE;
  if (pwm2 > PWM_MAX_VALUE) pwm2 = PWM_MAX_VALUE;

  // Timer4のOCRレジスタに直接書き込み
  // Pro MicroのTimer4: OC4A = D5 (PC6), OC4D = D6 (PD7)
  OCR4A = pwm1;  // CH1 -> D5
  OCR4D = pwm2;  // CH2 -> D6
}

// タイマー1の比較一致割り込み（サンプルレート用）
ISR(TIMER1_COMPA_vect) {
  audioSampleISR();
}

// =============================================================================
// Timer4のPWM設定（2ch独立PWM）
// =============================================================================

static void setupTimer4PWM() {
  // Timer4は10bit高速PWMモードで使用
  // Pro Micro (ATmega32U4)のTimer4は特殊なタイマー

  // ピン設定: OC4A (PC6/D5), OC4D (PD7/D6) を出力に
  pinMode(5, OUTPUT); // D5 (OC4A)
  pinMode(6, OUTPUT); // D6 (OC4D)

  // Timer4設定
  TCCR4A = 0;
  TCCR4B = 0;
  TCCR4C = 0;
  TCCR4D = 0;

  // PWM4A, PWM4D を有効化
  TCCR4A = (1 << COM4A1) | (1 << PWM4A);  // OC4A: 非反転PWM
  TCCR4C = (1 << COM4D1) | (1 << PWM4D);  // OC4D: 非反転PWM

  // 10bit分解能の高速PWM
  // TOP値を1023に設定（10bit）
  OCR4C = 1023;  // TOP値

  // プリスケーラ設定: 分周なし（CS43:0 = 0001）
  // PWM周波数 = 16MHz / (1 * 1024) ≈ 15.6kHz
  // より高い周波数を得るには、分解能を下げる必要がある
  // ここでは10bitを優先
  TCCR4B = (1 << CS40);  // プリスケーラ = 1

  // 初期デューティサイクル: 50%（中央値）
  OCR4A = 512;
  OCR4D = 512;

  // Timer4は割り込みを使用しない（PWM生成のみ）
}

// =============================================================================
// Timer1のCTC設定（サンプルレート用）
// =============================================================================

static void setupTimer1SampleRate() {
  // Timer1をCTCモードで使用してサンプルレート割り込みを生成
  // サンプルレート: 16kHz
  // 16MHz / (1 * 1000) = 16kHz

  TCCR1A = 0;
  TCCR1B = 0;
  TCNT1 = 0;

  // CTC mode (WGM12 = 1)
  TCCR1B |= (1 << WGM12);

  // プリスケーラ = 1 (CS10 = 1)
  TCCR1B |= (1 << CS10);

  // 比較一致値: 16MHz / 16kHz = 1000
  OCR1A = 999; // 0から数えるので-1

  // 比較一致割り込み有効化
  TIMSK1 |= (1 << OCIE1A);
}

// =============================================================================
// オーディオエンジン初期化
// =============================================================================

void audioEngineInit() {
  // ボイスの初期化
  for (uint8_t i = 0; i < NUM_CHANNELS; i++) {
    voices[i].phaseCarrier = 0;
    voices[i].phaseModulator = 0;
    voices[i].envValue = 0;
    voices[i].feedbackSample = 0;
    voices[i].noiseState = 0x12345678 + i; // 異なる初期値
    voices[i].active = false;

    // デフォルトパラメータ（後でランダマイズまたは設定される）
    voices[i].params.baseFreq = frequencyToPhaseIncrement(100 + i * 50);
    voices[i].params.modFreq = frequencyToPhaseIncrement(150 + i * 70);
    voices[i].params.modFreqRatio = 256; // 1.0倍
    voices[i].params.fmIndex = 4096;
    voices[i].params.envDecay = 2000;
    voices[i].params.envLevel = 200;
    voices[i].params.algo = ALG_SIMPLE_FM;
    voices[i].params.accentLevel = 160; // 1.25倍
  }

  // タイマー初期化
  setupTimer4PWM();
  setupTimer1SampleRate();

  // グローバル割り込み有効化
  sei();
}

// =============================================================================
// FMドラムのトリガー
// =============================================================================

void triggerDrum(uint8_t channel, bool accent) {
  if (channel >= NUM_CHANNELS) return;

  FmDrumVoice* voice = &voices[channel];

  // 位相をリセット
  voice->phaseCarrier = 0;
  voice->phaseModulator = 0;

  // エンベロープをリセット
  if (accent) {
    // アクセント時はレベルを上げる
    voice->envValue = 65535; // 最大値
  } else {
    voice->envValue = 52428; // 約80%
  }

  // フィードバックをリセット
  voice->feedbackSample = 0;

  // アクティブ化
  voice->active = true;
}

// =============================================================================
// FMドラムパラメータの設定
// =============================================================================

void setDrumParams(uint8_t channel, const FmDrumParams* params) {
  if (channel >= NUM_CHANNELS || params == nullptr) return;

  // パラメータをコピー
  voices[channel].params = *params;

  // modFreq を modFreqRatio から計算
  voices[channel].params.modFreq =
    ((uint32_t)params->baseFreq * params->modFreqRatio) >> 8;
}

// =============================================================================
// ディケイパラメータの更新（両チャンネル）
// =============================================================================

void updateDecay(uint16_t decayValue) {
  // decayValue: 0-1023 (analogReadの値)
  // これを適切な範囲にマッピング
  // 例: 500-8000 の範囲
  globalDecayScale = 500 + (decayValue * 7);

  // 各チャンネルのディケイに反映
  for (uint8_t i = 0; i < NUM_CHANNELS; i++) {
    // ベース値にスケールを適用
    // ここでは単純に上書き（ランダマイズ時のベース値を保持する場合は別途管理）
    voices[i].params.envDecay = globalDecayScale;
  }
}

// =============================================================================
// FMドラムパラメータのランダム生成
// =============================================================================

void randomizeDrumParams(uint8_t channel) {
  if (channel >= NUM_CHANNELS) return;

  FmDrumParams params;

  // ランダムな周波数（ドラム向けに低め〜中域）
  uint16_t baseFreqHz = 50 + (random(150)); // 50-200Hz
  params.baseFreq = frequencyToPhaseIncrement(baseFreqHz);

  // モジュレータ周波数比（0.5〜4.0倍）
  params.modFreqRatio = 128 + random(896); // 128-1024 (0.5-4.0倍)

  // FM変調インデックス（低め〜高め）
  params.fmIndex = 1000 + random(8000); // 1000-9000

  // ディケイ（現在のグローバル値をベースに）
  params.envDecay = globalDecayScale;

  // レベル（適度な音量）
  params.envLevel = 150 + random(100); // 150-250

  // アルゴリズムをランダム選択
  params.algo = random(ALG_COUNT);

  // アクセントレベル
  params.accentLevel = 140 + random(40); // 140-180 (約1.1-1.4倍)

  // パラメータを設定
  setDrumParams(channel, &params);
}
