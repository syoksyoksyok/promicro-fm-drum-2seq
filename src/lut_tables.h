#ifndef LUT_TABLES_H
#define LUT_TABLES_H

#include <stdint.h>
#include <avr/pgmspace.h>

// サイン波LUTのサイズ（256エントリ）
#define SINE_TABLE_SIZE 256
#define SINE_TABLE_MASK 0xFF

// サイン波LUT（-32767 〜 +32767 の範囲）
// PROGMEM に格納してFlashメモリを使用
extern const int16_t sine_table[SINE_TABLE_SIZE] PROGMEM;

// 位相管理用の定数
// 32bit位相アキュムレータ、上位8bitをテーブルインデックスとして使用
#define PHASE_BITS 32
#define PHASE_INDEX_SHIFT 24  // 上位8bitをインデックスに

#endif // LUT_TABLES_H
