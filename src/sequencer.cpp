#include "sequencer.h"
#include "audio_engine.h"
#include <Arduino.h>

// =============================================================================
// グローバル変数
// =============================================================================

// 2トラックのパターン
static Pattern patterns[NUM_TRACKS];

// 現在のステップ位置
static uint8_t currentStep[NUM_TRACKS] = {0, 0};

// 再生中フラグ
volatile bool isPlaying = false;

// BPMとタイミング関連
static uint16_t currentBPM = 120;
static uint32_t tickCounter = 0;
static uint32_t ticksPerStep = 0;

// サンプルレートに基づくティック計算
// ticksPerStep = (SAMPLE_RATE * 60) / (BPM * 4)
// 16分音符ベースのシーケンサを想定

// =============================================================================
// シーケンサの初期化
// =============================================================================

void sequencerInit() {
  // パターンの初期化
  for (uint8_t t = 0; t < NUM_TRACKS; t++) {
    patterns[t].length = MAX_STEPS;
    for (uint8_t s = 0; s < MAX_STEPS; s++) {
      patterns[t].steps[s].flags = 0;
    }
    currentStep[t] = 0;
  }

  // BPMの設定
  setBPM(currentBPM);

  // デモパターンのロード
  loadDemoPattern();
}

// =============================================================================
// BPMの設定
// =============================================================================

void setBPM(uint16_t bpm) {
  currentBPM = bpm;
  // ticksPerStep = (SAMPLE_RATE * 60) / (BPM * 4)
  // 16分音符 = 1ステップ
  ticksPerStep = (SAMPLE_RATE * 60UL) / (bpm * 4UL);
}

// =============================================================================
// シーケンサの更新（オーディオISRから呼ばれる想定だが、ここでは簡易実装）
// =============================================================================

void sequencerUpdate() {
  if (!isPlaying) return;

  tickCounter++;

  if (tickCounter >= ticksPerStep) {
    tickCounter = 0;

    // 各トラックのステップを進める
    for (uint8_t t = 0; t < NUM_TRACKS; t++) {
      uint8_t step = currentStep[t];
      Step* stepData = &patterns[t].steps[step];

      // Gateがオンなら音を鳴らす
      if (stepData->flags & STEP_FLAG_GATE) {
        bool accent = (stepData->flags & STEP_FLAG_ACCENT) != 0;
        triggerDrum(t, accent);
      }

      // 次のステップへ
      currentStep[t]++;
      if (currentStep[t] >= patterns[t].length) {
        currentStep[t] = 0;
      }
    }
  }
}

// =============================================================================
// パターンのランダム生成
// =============================================================================

void randomizePattern(uint8_t track) {
  if (track >= NUM_TRACKS) return;

  Pattern* pattern = &patterns[track];

  // 全ステップをランダム化
  uint8_t gateCount = 0;
  for (uint8_t s = 0; s < pattern->length; s++) {
    // Gate ON/OFF (50%の確率)
    if (random(100) < 50) {
      pattern->steps[s].flags = STEP_FLAG_GATE;
      gateCount++;

      // Accentフラグ (25%の確率)
      if (random(100) < 25) {
        pattern->steps[s].flags |= STEP_FLAG_ACCENT;
      }
    } else {
      pattern->steps[s].flags = 0;
    }
  }

  // 最低1ステップはGate ONにする
  if (gateCount == 0) {
    uint8_t randomStep = random(pattern->length);
    pattern->steps[randomStep].flags = STEP_FLAG_GATE;
  }
}

// =============================================================================
// 全パターンとパラメータのランダム化
// =============================================================================

void randomizeAll() {
  // 全トラックのパターンをランダム化
  for (uint8_t t = 0; t < NUM_TRACKS; t++) {
    randomizePattern(t);
    randomizeDrumParams(t);
  }
}

// =============================================================================
// デモパターンのロード
// =============================================================================

void loadDemoPattern() {
  // Track A (CH1): キック風パターン
  // ステップ: X...X...X...X... (4つ打ち)
  patterns[0].length = 16;
  for (uint8_t s = 0; s < 16; s++) {
    if (s % 4 == 0) {
      patterns[0].steps[s].flags = STEP_FLAG_GATE;
      // 最初のステップにアクセント
      if (s == 0) {
        patterns[0].steps[s].flags |= STEP_FLAG_ACCENT;
      }
    } else {
      patterns[0].steps[s].flags = 0;
    }
  }

  // Track B (CH2): スネア/ハイハット風パターン
  // ステップ: ..X...X...X...X. (裏拍)
  patterns[1].length = 16;
  for (uint8_t s = 0; s < 16; s++) {
    if (s % 4 == 2) {
      patterns[1].steps[s].flags = STEP_FLAG_GATE;
    } else if (s % 2 == 1) {
      // 8分音符でハイハット的な音
      patterns[1].steps[s].flags = STEP_FLAG_GATE;
    } else {
      patterns[1].steps[s].flags = 0;
    }
  }

  // CH1のパラメータ（キック風）
  FmDrumParams kickParams;
  kickParams.baseFreq = 536870;       // 約60Hz (低音)
  kickParams.modFreqRatio = 128;      // 0.5倍
  kickParams.fmIndex = 6000;
  kickParams.envDecay = 3000;
  kickParams.envLevel = 220;
  kickParams.algo = ALG_SIMPLE_FM;
  kickParams.accentLevel = 160;
  setDrumParams(0, &kickParams);

  // CH2のパラメータ（スネア/ハイハット風）
  FmDrumParams snareParams;
  snareParams.baseFreq = 2684354;     // 約300Hz (中高音)
  snareParams.modFreqRatio = 512;     // 2.0倍
  snareParams.fmIndex = 8000;
  snareParams.envDecay = 1500;
  snareParams.envLevel = 180;
  snareParams.algo = ALG_NOISE_MIX;   // ノイズミックスでスネア感
  snareParams.accentLevel = 140;
  setDrumParams(1, &snareParams);
}

// =============================================================================
// 再生/停止のトグル
// =============================================================================

void togglePlayback() {
  isPlaying = !isPlaying;

  // 停止時はステップ位置をリセット
  if (!isPlaying) {
    currentStep[0] = 0;
    currentStep[1] = 0;
    tickCounter = 0;
  }
}

// =============================================================================
// 現在のステップ位置を取得
// =============================================================================

uint8_t getCurrentStep(uint8_t track) {
  if (track >= NUM_TRACKS) return 0;
  return currentStep[track];
}
