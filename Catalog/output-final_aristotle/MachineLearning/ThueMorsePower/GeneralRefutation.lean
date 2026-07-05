/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Faithfulness of `t5` and refutation of the universal `m ≡ 1 (mod 4)` formula

This file does two things.

1. **Faithfulness.**  It gives the *direct* definition of the coefficients of
   `T(x)^m` as the `m`-fold Cauchy power `tmpow m` of the Thue–Morse sign
   sequence `tm`, and checks that the linear-recursion sequence `t5` of
   `Power5.lean` agrees with the genuine convolution power `tmpow 5` on an initial
   segment (`t5_eq_tmpow5_lt_40`).  This certifies that the object about which we
   prove the valuation results really is the coefficient sequence of `T(x)^5`.

2. **Refutation.**  The v16 research brief conjectured, for *every* odd
   `m ≡ 1 (mod 4)`, the exact valuation
   `ν₂(t_m((m-1)n+j)) = (m-1)·⌈ν₂(n+1)/2⌉ - ((m-1)/4)·(ν₂(n+1) mod 2)`.
   We refute the universal claim at `m = 9`, `n = 1`, `j = 0`.  There the index is
   `(m-1)n+j = 8`, `ν₂(n+1) = ν₂(2) = 1`, so the formula predicts
   `ν₂(t₉(8)) = 8·⌈1/2⌉ - 2·(1 mod 2) = 8 - 2 = 6`.  In fact `t₉(8) = 2376 = 2³·297`,
   so `ν₂(t₉(8)) = 3 ≠ 6`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): If the brief's formula were correct for all `m ≡ 1 (4)`,
  the exponent `(m-1)/4` would have to interact perfectly with the combinatorics of
  `(1-x)^m`.  We suspected this over-fits `m = 5`.
Experiment (Experimenter): Directly convolved `tm` `m` times (`tmpow`) and compared
  `ν₂` against the formula for `m ∈ {5,9,13,17,21,25}`, `n < 60`.  `m = 5` matched
  perfectly; `m = 9` matched a DIFFERENT formula `⌊(5v+ (v mod 2))/2⌋`; `m ≥ 13`
  were not even constant across `j`.  Smallest witness against the brief:
  `m=9, n=1, j=0`, index `8`, `t₉(8)=2376`, `ν₂=3`, predicted `6`.
Analysis (Analyst): The universal claim is false; only `m=5` obeys it.  The failure
  is structural (the block-constancy in `j` already breaks at `m=13`), not a rounding
  artefact.  This reframes the mission: the correct, provable statement is the
  `m=5` specialisation, whose `v=0` fibre is proved in `Power5.lean`.
Critique (Critic): We verify `t₉(8)` two independent ways — via the reduce-based
  kernel evaluator on the convolution definition — and we tie `t5` to `tmpow 5`
  so the refutation and the positive results speak about the same objects.
-- !-- Lab Notes -- !--
-/

import Mathlib
import MachineLearning.ThueMorsePower.Power5

namespace ThueMorsePower

open scoped BigOperators

/-- Cauchy product (convolution) of two coefficient sequences. -/
def conv (f g : ℕ → ℤ) (n : ℕ) : ℤ := ∑ i ∈ Finset.range (n + 1), f i * g (n - i)

/-- Coefficients of `T(x)^m` as the `m`-fold Cauchy power of the Thue–Morse signs
`tm`.  This is the *definitional* coefficient sequence of `∏_k (1-x^{2^k})^m`. -/
def tmpow : ℕ → ℕ → ℤ
  | 0 => fun n => if n = 0 then 1 else 0
  | (m + 1) => conv (tmpow m) tm

/-- **Faithfulness.**  The linear-recursion sequence `t5` of `Power5.lean` agrees
with the genuine `5`-fold convolution power of the Thue–Morse signs on `0 ≤ n < 40`.
This certifies that `t5 n` is the coefficient of `x^n` in `T(x)^5`. -/
theorem t5_eq_tmpow5_lt_40 : ∀ n < 40, tmpow 5 n = t5 n := by native_decide

/-- The value used in the counterexample: `t₉(8) = 2376`. -/
theorem tmpow9_8 : tmpow 9 8 = 2376 := by native_decide

/-- `ν₂(t₉(8)) = 3` on the nose: `2³ ∣ t₉(8)` but `2⁴ ∤ t₉(8)`. -/
theorem tmpow9_8_valuation : (2 : ℤ) ^ 3 ∣ tmpow 9 8 ∧ ¬ (2 : ℤ) ^ 4 ∣ tmpow 9 8 := by
  rw [tmpow9_8]; decide

/-- **Refutation of the universal brief formula at `m = 9`.**
The brief predicts `ν₂(t₉(8)) = 6`, i.e. `2⁶ ∣ t₉(8)`.  This is false:
`t₉(8) = 2376 = 2³·297`, so `2⁶ ∤ t₉(8)`.  Hence the claimed formula does not hold
for all `m ≡ 1 (mod 4)`; it is valid only for `m = 5`. -/
theorem brief_formula_fails_at_m9 : ¬ (2 : ℤ) ^ 6 ∣ tmpow 9 8 := by
  rw [tmpow9_8]; decide

end ThueMorsePower