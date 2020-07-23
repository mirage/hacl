/* MIT License
 *
 * Copyright (c) 2016-2020 INRIA, CMU and Microsoft Corporation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "evercrypt_targetconfig.h"
#include "libintvector.h"
#include "kremlin/internal/types.h"
#include "kremlin/lowstar_endianness.h"
#include <string.h>
#include "kremlin/internal/target.h"

#ifndef __Hacl_Hash_H
#define __Hacl_Hash_H

#include "Hacl_Kremlib.h"
#include "Hacl_Spec.h"

void Hacl_Hash_SHA2_update_multi_512(uint64_t *s, uint8_t *blocks, uint32_t n_blocks);

void
Hacl_Hash_SHA2_update_last_512(
  uint64_t *s,
  FStar_UInt128_uint128 prev_len,
  uint8_t *input,
  uint32_t input_len
);

void Hacl_Hash_SHA2_hash_512(uint8_t *input, uint32_t input_len, uint8_t *dst);

void Hacl_Hash_Core_SHA2_init_512(uint64_t *s);

void Hacl_Hash_Core_SHA2_update_512(uint64_t *hash, uint8_t *block);

void Hacl_Hash_Core_SHA2_pad_512(FStar_UInt128_uint128 len, uint8_t *dst);

void Hacl_Hash_Core_SHA2_finish_512(uint64_t *s, uint8_t *dst);

#define __Hacl_Hash_H_DEFINED
#endif
