#ifndef AUDIO_ENGINE_H
#define AUDIO_ENGINE_H

#include <stdint.h>

// =============================================================================
// オーディオエンジン設定
// =============================================================================

// サンプルレート: 16kHz（推奨）
// 実際の値はタイマー設定で調整可能
#define SAMPLE_RATE 16000

// PWM分解能: 10bit (0-1023)
#define PWM_RESOLUTION 10
#define PWM_MAX_VALUE 1023

// チャンネル数
#define NUM_CHANNELS 2

// =============================================================================
// FMアルゴリズム定義
// =============================================================================

enum FmAlgorithm {
  ALG_SIMPLE_FM = 0,    // output = sin(phase_c + sin(phase_m) * index)
  ALG_STRONG_FM,        // output = sin(phase_c + sin(phase_m * ratio) * index_high)
  ALG_FEEDBACK,         // モジュレータにフィードバック
  ALG_NOISE_MIX,        // FM音 + ノイズのミックス
  ALG_COUNT
};

// =============================================================================
// FMドラムパラメータ構造体
// =============================================================================

struct FmDrumParams {
  // 周波数関連（固定小数点）
  uint32_t baseFreq;        // ベースとなるキャリア周波数（位相インクリメント値）
  uint32_t modFreq;         // モジュレータ周波数（位相インクリメント値）
  uint16_t modFreqRatio;    // モジュレータ周波数比（8.8固定小数点: 256 = 1.0倍）

  // FM変調関連
  uint16_t fmIndex;         // FMインデックス（変調量、0-16384程度）

  // エンベロープ関連
  uint16_t envDecay;        // ディケイ時間（大きいほど遅い減衰）
  uint16_t envLevel;        // 全体レベル（0-256程度）

  // その他
  uint8_t algo;             // 使用するアルゴリズム（FmAlgorithm）
  uint8_t accentLevel;      // アクセント時の倍率（128 = 1.0倍）
};

// =============================================================================
// FMドラム音声チャンネル構造体
// =============================================================================

struct FmDrumVoice {
  // パラメータ
  FmDrumParams params;

  // 位相アキュムレータ（32bit固定小数点）
  uint32_t phaseCarrier;
  uint32_t phaseModulator;

  // エンベロープ
  uint16_t envValue;        // 現在のエンベロープ値（0-65535）

  // フィードバック用
  int16_t feedbackSample;   // 前回の出力サンプル

  // ノイズジェネレータ用
  uint32_t noiseState;      // LFSR状態

  // アクティブフラグ
  bool active;
};

// =============================================================================
// グローバル関数
// =============================================================================

// オーディオエンジンの初期化（タイマー設定含む）
void audioEngineInit();

// FMドラムボイスのトリガー
void triggerDrum(uint8_t channel, bool accent);

// FMドラムパラメータの設定
void setDrumParams(uint8_t channel, const FmDrumParams* params);

// ディケイパラメータの更新（両チャンネル）
void updateDecay(uint16_t decayValue);

// FMドラムパラメータのランダム生成
void randomizeDrumParams(uint8_t channel);

// サンプル生成ISR（タイマー割り込みから呼ばれる）
// この関数は audio_engine.cpp 内で static として実装され、
// ISR(TIMER1_COMPA_vect) または ISR(TIMER3_COMPA_vect) から呼ばれます

#endif // AUDIO_ENGINE_H
