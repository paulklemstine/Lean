/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Benford Renormalization: Core Definitions and Structural Lemmas

This module introduces the core mathematical objects for the theory of
Benford renormalization in integer dynamical systems.

## Main Definitions

* `leadingDigitBase` — the leading (most significant) digit of a natural number
* `benfordFreqUpTo` — empirical leading-digit frequency over finite windows
* `benfordTheoretical` — the Benford-law predicted frequency
* `fracLogBase` — fractional part of the base-b logarithm (the "cocycle")
* `HasRationalEigenObstruction` — the spectral obstruction to Benford universality
* `logCocycle` — the renormalized logarithmic cocycle along a dynamical orbit

## Mathematical Overview

The central invariant is the **logarithmic cocycle**
`k ↦ fract(log_b(T^k(n)))`, whose distribution modulo 1 completely
determines the leading-digit statistics of the orbit.
-/

namespace BenfordRenormalization

open Real Finset Filter

/-! ## Leading Digit -/

/-- The leading (most significant) digit of `n` in base `b`.
For `b ≤ 1` or `n = 0`, returns `n` (degenerate case).
For `n ≥ 1` and `b ≥ 2`, returns a value in `{1, …, b-1}`. -/
def leadingDigitBase (b n : ℕ) : ℕ :=
  if b ≤ 1 then n
  else if n < b then n
  else leadingDigitBase b (n / b)
termination_by n
decreasing_by exact Nat.div_lt_self (by omega) (by omega)

/-
Unfolding lemma: for `b ≥ 2` and `n < b`,
`leadingDigitBase b n = n`.
-/
theorem leadingDigitBase_of_lt (b n : ℕ) (hb : 2 ≤ b) (hn : n < b) :
    leadingDigitBase b n = n := by
  unfold leadingDigitBase; aesop;

/-
Unfolding lemma: for `b ≥ 2` and `n ≥ b`,
`leadingDigitBase b n = leadingDigitBase b (n / b)`.
-/
theorem leadingDigitBase_div (b n : ℕ) (hb : 2 ≤ b) (hn : b ≤ n) :
    leadingDigitBase b n = leadingDigitBase b (n / b) := by
  rw [ leadingDigitBase ];
  grind

/-
The leading digit of a positive number in base `b ≥ 2` is positive.
-/
theorem leadingDigitBase_pos (b n : ℕ) (hb : 2 ≤ b) (hn : 1 ≤ n) :
    1 ≤ leadingDigitBase b n := by
  induction' n using Nat.strong_induction_on with n ih;
  by_cases hn' : n < b;
  · rw [ leadingDigitBase_of_lt b n hb hn' ] ; linarith;
  · rw [ leadingDigitBase_div b n hb ( le_of_not_gt hn' ) ] ; exact ih _ ( Nat.div_lt_self hn ( by linarith ) ) ( Nat.div_pos ( by linarith ) ( by linarith ) ) ;

/-
The leading digit in base `b ≥ 2` is strictly less than `b`.
-/
theorem leadingDigitBase_lt (b n : ℕ) (hb : 2 ≤ b) (hn : 1 ≤ n) :
    leadingDigitBase b n < b := by
  by_contra h_contra;
  induction' n using Nat.strong_induction_on with n ih generalizing b;
  by_cases hn' : n < b;
  · exact h_contra ( by rw [ leadingDigitBase_of_lt b n hb hn' ] ; linarith );
  · exact ih ( n / b ) ( Nat.div_lt_self hn ( by linarith ) ) b hb ( Nat.div_pos ( by linarith ) ( by linarith ) ) ( by rw [ leadingDigitBase_div b n hb ( by linarith ) ] at h_contra; aesop )

/-
The leading digit of `b ^ k` in base `b ≥ 2` is always `1`.
-/
theorem leadingDigitBase_pow (b k : ℕ) (hb : 2 ≤ b) :
    leadingDigitBase b (b ^ k) = 1 := by
  induction' k with k ih;
  · unfold leadingDigitBase; aesop;
  · convert leadingDigitBase_div b ( b ^ ( k + 1 ) ) hb _ using 1;
    · rw [ pow_succ', Nat.mul_div_cancel_left _ ( by linarith ), ih ];
    · exact Nat.le_self_pow ( by norm_num ) _

/-! ## Empirical Frequencies and Benford's Law -/

/-- The proportion of indices `k ∈ {0, …, N-1}` where the leading digit
of `u(k)` in base `b` equals `d`. -/
noncomputable def benfordFreqUpTo (b d : ℕ) (u : ℕ → ℕ) (N : ℕ) : ℝ :=
  if N = 0 then 0
  else ((range N).filter (fun k => leadingDigitBase b (u k) = d)).card / (N : ℝ)

/-- The Benford-law predicted frequency for digit `d` in base `b`:
`log_b(1 + 1/d)`. -/
noncomputable def benfordTheoretical (b d : ℕ) : ℝ :=
  Real.log (1 + 1 / (d : ℝ)) / Real.log (b : ℝ)

/-- A sequence `u` is **Benford in base `b`** if for every valid digit
`d ∈ {1, …, b-1}`, the empirical leading-digit frequency converges to
the Benford prediction `log_b(1 + 1/d)`. -/
def IsBenford (b : ℕ) (u : ℕ → ℕ) : Prop :=
  ∀ d, 1 ≤ d → d < b →
    Tendsto (benfordFreqUpTo b d u) atTop (nhds (benfordTheoretical b d))

/-! ## The Logarithmic Cocycle -/

/-- The fractional part of the base-`b` logarithm of a positive real.
This is the fundamental "cocycle coordinate" that determines digit statistics. -/
noncomputable def fracLogBase (b : ℕ) (x : ℝ) : ℝ :=
  Int.fract (Real.log x / Real.log (b : ℝ))

/-- The full logarithmic cocycle along an orbit of `T`:
`logCocycle b T n k = log_b(T^k(n))`. -/
noncomputable def logCocycle (b : ℕ) (T : ℕ → ℕ) (n k : ℕ) : ℝ :=
  Real.log ((T^[k] n : ℕ) : ℝ) / Real.log (b : ℝ)

/-! ## Spectral Obstruction -/

/-- A sequence `u` has a **rational eigen-obstruction** in base `b` if
there exists a positive integer `q` such that `q · log_b(u(k))` is
eventually an integer. -/
def HasRationalEigenObstruction (b : ℕ) (u : ℕ → ℕ) : Prop :=
  ∃ q : ℕ, 0 < q ∧ ∀ᶠ k in atTop,
    ∃ z : ℤ, (q : ℝ) * (Real.log (u k : ℝ) / Real.log (b : ℝ)) = (z : ℝ)

/-- A sequence has **eventually constant fractional log** if
`fract(log_b(u(k)))` stabilizes to a single value. -/
def HasEventuallyConstantFracLog (b : ℕ) (u : ℕ → ℕ) : Prop :=
  ∃ c : ℝ, ∀ᶠ k in atTop,
    Int.fract (Real.log (u k : ℝ) / Real.log (b : ℝ)) = c

/-! ## Basic Frequency Properties -/

/-
`benfordFreqUpTo` is always nonneg.
-/
theorem benfordFreqUpTo_nonneg (b d : ℕ) (u : ℕ → ℕ) (N : ℕ) :
    0 ≤ benfordFreqUpTo b d u N := by
  unfold benfordFreqUpTo; positivity;

/-
`benfordFreqUpTo` is at most 1.
-/
theorem benfordFreqUpTo_le_one (b d : ℕ) (u : ℕ → ℕ) (N : ℕ) :
    benfordFreqUpTo b d u N ≤ 1 := by
  unfold benfordFreqUpTo; split_ifs <;> norm_num;
  exact div_le_one_of_le₀ ( mod_cast le_trans ( Finset.card_filter_le _ _ ) ( by simpa ) ) ( Nat.cast_nonneg _ )

/-
When every term has leading digit `d`, the frequency is 1.
-/
theorem benfordFreqUpTo_eq_one_of_all (b d : ℕ) (u : ℕ → ℕ) (N : ℕ)
    (hN : 0 < N)
    (hall : ∀ k, k < N → leadingDigitBase b (u k) = d) :
    benfordFreqUpTo b d u N = 1 := by
  convert div_self _;
  rotate_left;
  exact ↑N;
  · positivity;
  · unfold benfordFreqUpTo;
    rw [ if_neg hN.ne', Finset.filter_true_of_mem fun k hk => hall k ( Finset.mem_range.mp hk ), Finset.card_range ]

/-
When no term has leading digit `d`, the frequency is 0.
-/
theorem benfordFreqUpTo_eq_zero_of_none (b d : ℕ) (u : ℕ → ℕ) (N : ℕ)
    (hN : 0 < N)
    (hnone : ∀ k, k < N → leadingDigitBase b (u k) ≠ d) :
    benfordFreqUpTo b d u N = 0 := by
  unfold benfordFreqUpTo; aesop;

/-
The Benford theoretical frequency for valid digits is positive.
-/
theorem benfordTheoretical_pos (b d : ℕ) (hb : 2 ≤ b) (hd : 1 ≤ d) (hdb : d < b) :
    0 < benfordTheoretical b d := by
  exact div_pos ( Real.log_pos ( by norm_num; positivity ) ) ( Real.log_pos ( by norm_cast ) )

/-
The Benford theoretical frequency for valid digits is at most 1.
-/
theorem benfordTheoretical_le_one (b d : ℕ) (hb : 2 ≤ b) (hd : 1 ≤ d) (hdb : d < b) :
    benfordTheoretical b d ≤ 1 := by
  rw [ benfordTheoretical, div_le_one ];
  · exact Real.log_le_log ( by positivity ) ( by rw [ add_div', div_le_iff₀ ] <;> norm_cast <;> nlinarith );
  · exact Real.log_pos <| Nat.one_lt_cast.mpr hb

/-
The Benford theoretical frequency for digit 1 in base `b ≥ 3` is
strictly less than 1. (In base 2 it equals 1 since 1 is the only digit.)
-/
theorem benfordTheoretical_one_lt_one_of_base_ge_three (b : ℕ) (hb : 3 ≤ b) :
    benfordTheoretical b 1 < 1 := by
  convert div_lt_one ?_ |>.2 ( Real.log_lt_log ?_ ?_ ) using 1;
  · exact Real.log_pos <| by norm_cast; linarith;
  · norm_num;
  · norm_num; linarith [ ( by norm_cast : ( 3 : ℝ ) ≤ b ) ]

end BenfordRenormalization