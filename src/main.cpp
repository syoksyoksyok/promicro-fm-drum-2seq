#include <Arduino.h>
#include "audio_engine.h"
#include "sequencer.h"

// =============================================================================
// ピン定義
// =============================================================================

// オーディオ出力ピン（PWM）
// D5 (OC4A) -> CH1
// D6 (OC4D) -> CH2
// これらはaudio_engine.cppで設定される

// ボタンピン
#define PIN_BUTTON_PLAY 2      // 再生/停止ボタン (D2)
#define PIN_BUTTON_RANDOM 3    // ランダマイズボタン (D3)

// ノブ（アナログ入力）
#define PIN_KNOB_DECAY A0      // ディケイ調整ノブ

// LED（BPM表示用）
#ifndef LED_BUILTIN
#define LED_BUILTIN 13         // Pro Micro内蔵LED
#endif

// =============================================================================
// ボタンデバウンス用変数
// =============================================================================

static bool lastButtonPlayState = HIGH;
static bool lastButtonRandomState = HIGH;
static unsigned long lastDebounceTime = 0;
static const unsigned long debounceDelay = 50; // 50ms

// =============================================================================
// ノブ読み取り用変数
// =============================================================================

static uint16_t knobValue = 512;
static uint16_t knobSmoothed = 512;
static const uint8_t knobSmoothFactor = 8; // 移動平均のファクター

// =============================================================================
// LED点滅用変数
// =============================================================================

static uint8_t lastStep = 0;
static unsigned long ledOnTime = 0;
static const unsigned long ledBlinkDuration = 50; // LED点灯時間（ms）

// =============================================================================
// 初期化
// =============================================================================

void setup() {
  // シリアル通信の初期化（デバッグ用、オプション）
  Serial.begin(115200);
  Serial.println(F("Pro Micro FM Drum Machine"));
  Serial.println(F("2ch FM Drum Sequencer"));
  Serial.println(F("Sample Rate: 16kHz, PWM: 10bit"));

  // ボタンピンの設定（内部プルアップ）
  pinMode(PIN_BUTTON_PLAY, INPUT_PULLUP);
  pinMode(PIN_BUTTON_RANDOM, INPUT_PULLUP);

  // アナログピンの設定
  pinMode(PIN_KNOB_DECAY, INPUT);

  // LED（BPM表示）の設定
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);

  // ランダムシードの初期化（アナログノイズから）
  randomSeed(analogRead(A1));

  // オーディオエンジンの初期化
  Serial.println(F("Initializing audio engine..."));
  audioEngineInit();

  // シーケンサの初期化
  Serial.println(F("Initializing sequencer..."));
  sequencerInit();

  // 初期ノブ値の読み取り
  knobValue = analogRead(PIN_KNOB_DECAY);
  knobSmoothed = knobValue;
  updateDecay(knobSmoothed);

  // 起動時は自動再生
  isPlaying = true;

  Serial.println(F("Ready!"));
  Serial.println(F("Button1: Play/Stop"));
  Serial.println(F("Button2: Randomize"));
  Serial.println(F("Knob: Decay"));
}

// =============================================================================
// ボタン入力処理
// =============================================================================

void handleButtons() {
  unsigned long currentTime = millis();

  // 再生/停止ボタン
  bool buttonPlayState = digitalRead(PIN_BUTTON_PLAY);
  if (buttonPlayState != lastButtonPlayState) {
    lastDebounceTime = currentTime;
  }
  if ((currentTime - lastDebounceTime) > debounceDelay) {
    if (buttonPlayState == LOW && lastButtonPlayState == HIGH) {
      // ボタンが押された（立ち下がり）
      togglePlayback();
      Serial.print(F("Playback: "));
      Serial.println(isPlaying ? F("Playing") : F("Stopped"));
    }
  }
  lastButtonPlayState = buttonPlayState;

  // ランダマイズボタン
  bool buttonRandomState = digitalRead(PIN_BUTTON_RANDOM);
  if (buttonRandomState != lastButtonRandomState) {
    lastDebounceTime = currentTime;
  }
  if ((currentTime - lastDebounceTime) > debounceDelay) {
    if (buttonRandomState == LOW && lastButtonRandomState == HIGH) {
      // ボタンが押された（立ち下がり）
      Serial.println(F("Randomizing patterns and parameters..."));
      randomizeAll();
    }
  }
  lastButtonRandomState = buttonRandomState;
}

// =============================================================================
// ノブ入力処理
// =============================================================================

void handleKnob() {
  // アナログ値を読み取り
  knobValue = analogRead(PIN_KNOB_DECAY);

  // 簡易移動平均フィルタ
  // smoothed = (smoothed * (factor-1) + value) / factor
  knobSmoothed = ((uint32_t)knobSmoothed * (knobSmoothFactor - 1) + knobValue) / knobSmoothFactor;

  // ディケイパラメータを更新
  updateDecay(knobSmoothed);
}

// =============================================================================
// LED点滅処理（BPM表示）
// =============================================================================

void handleLED() {
  if (!isPlaying) {
    // 停止中はLED消灯
    digitalWrite(LED_BUILTIN, LOW);
    return;
  }

  unsigned long currentTime = millis();

  // 現在のステップを取得（Track 0を基準）
  uint8_t currentStep = getCurrentStep(0);

  // ステップが変わったらLED点灯
  if (currentStep != lastStep) {
    lastStep = currentStep;
    ledOnTime = currentTime;
    digitalWrite(LED_BUILTIN, HIGH);
  }

  // 一定時間経過したらLED消灯
  if (currentTime - ledOnTime >= ledBlinkDuration) {
    digitalWrite(LED_BUILTIN, LOW);
  }
}

// =============================================================================
// メインループ
// =============================================================================

void loop() {
  // シーケンサの更新（オーディオISRから呼ばれる想定だが、
  // ここではメインループから呼ぶ簡易実装）
  sequencerUpdate();

  // ボタン入力処理
  handleButtons();

  // ノブ入力処理（一定間隔で）
  static unsigned long lastKnobRead = 0;
  unsigned long currentTime = millis();
  if (currentTime - lastKnobRead >= 50) { // 50msごと
    lastKnobRead = currentTime;
    handleKnob();
  }

  // LED点滅処理（BPM表示）
  handleLED();

  // CPU負荷軽減のため、短いディレイ
  delay(1);
}

// =============================================================================
// Arduinoエントリポイント（PlatformIOでは不要だがあっても問題ない）
// =============================================================================

// setup()とloop()はArduinoフレームワークが自動的に呼び出す
