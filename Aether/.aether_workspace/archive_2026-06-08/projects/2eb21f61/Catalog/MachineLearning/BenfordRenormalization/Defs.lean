/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Benford Renormalization for Integer Dynamical Systems: Core Definitions

This module develops the foundational theory connecting Benford's law to
integer dynamical systems through the lens of additive cocycles and
spectral obstructions.

## Main Definitions

* `IntDynMap` — Structure for integer dynamical maps with expansion data
* `orbitSeq` — The orbit sequence T^k(n)
* `leadingDigitBase` — Leading digit extraction (base b)
* `benfordFreqUpTo` — Empirical leading-digit frequency
* `benfordTheoretical` — Benford's law predicted frequency log_b(1+1/d)
* `IsBenford` — A sequence satisfies Benford's law
* `DigitDiscrepancy` — Measures deviation from perfect Benford distribution
* `CocycleAdditiveDecomp` — Decomposes log cocycle into drift + oscillation

## Mathematical Overview

The central object is the **logarithmic cocycle** k ↦ log_b(T^k(n)) mod 1.
When this cocycle has no rational eigenvalue (no nontrivial q with
q·log_b(T^k(n)) eventually integral), the orbit mantissae are equidistributed
and Benford's law holds. The obstruction criterion provides a sharp
characterization of when this universality fails.
-/

namespace BenfordRenorm

open Real Finset Filter

/-! ## Leading Digit -/

/-- The leading (most significant) digit of `n` in base `b`.
For `b ≤ 1` or `n = 0`, returns `n` (degenerate case). -/
def leadingDigitBase (b n : ℕ) : ℕ :=
  if b ≤ 1 then n
  else if n < b then n
  else leadingDigitBase b (n / b)
termination_by n
decreasing_by exact Nat.div_lt_self (by omega) (by omega)

theorem leadingDigitBase_of_lt (b n : ℕ) (hb : 2 ≤ b) (hn : n < b) :
    leadingDigitBase b n = n := by
  unfold leadingDigitBase; simp [show ¬(b ≤ 1) by omega, hn]

theorem leadingDigitBase_div (b n : ℕ) (hb : 2 ≤ b) (hn : b ≤ n) :
    leadingDigitBase b n = leadingDigitBase b (n / b) := by
  rw [leadingDigitBase]
  simp [show ¬(b ≤ 1) by omega, show ¬(n < b) by omega]

theorem leadingDigitBase_pos (b n : ℕ) (hb : 2 ≤ b) (hn : 1 ≤ n) :
    1 ≤ leadingDigitBase b n := by
  induction n using Nat.strongRecOn with
  | _ n ih =>
    by_cases hn' : n < b
    · rw [leadingDigitBase_of_lt b n hb hn']; linarith
    · rw [leadingDigitBase_div b n hb (le_of_not_gt hn')]
      exact ih _ (Nat.div_lt_self hn (by linarith)) (Nat.div_pos (by linarith) (by linarith))

theorem leadingDigitBase_lt (b n : ℕ) (hb : 2 ≤ b) (hn : 1 ≤ n) :
    leadingDigitBase b n < b := by
  induction n using Nat.strongRecOn with
  | _ n ih =>
    by_cases hn' : n < b
    · rw [leadingDigitBase_of_lt b n hb hn']; exact hn'
    · rw [leadingDigitBase_div b n hb (le_of_not_gt hn')]
      exact ih _ (Nat.div_lt_self hn (by linarith)) (Nat.div_pos (by linarith) (by linarith))

/-! ## Empirical Frequencies and Benford's Law -/

/-- Empirical leading-digit frequency: proportion of k < N with leading digit d. -/
noncomputable def benfordFreqUpTo (b d : ℕ) (u : ℕ → ℕ) (N : ℕ) : ℝ :=
  if N = 0 then 0
  else ((range N).filter (fun k => leadingDigitBase b (u k) = d)).card / (N : ℝ)

/-- The Benford-law predicted frequency for digit `d` in base `b`: log_b(1 + 1/d). -/
noncomputable def benfordTheoretical (b d : ℕ) : ℝ :=
  Real.log (1 + 1 / (d : ℝ)) / Real.log (b : ℝ)

/-- A sequence `u` is **Benford in base `b`** if for every valid digit
`d ∈ {1, …, b-1}`, the empirical frequency converges to log_b(1 + 1/d). -/
def IsBenford (b : ℕ) (u : ℕ → ℕ) : Prop :=
  ∀ d, 1 ≤ d → d < b →
    Tendsto (benfordFreqUpTo b d u) atTop (nhds (benfordTheoretical b d))

/-! ## Spectral Obstruction -/

/-- A sequence has a **rational eigen-obstruction** in base `b` if
there exists a positive integer `q` such that `q · log_b(u(k))` is
eventually integral. -/
def HasRationalEigenObstruction (b : ℕ) (u : ℕ → ℕ) : Prop :=
  ∃ q : ℕ, 0 < q ∧ ∀ᶠ k in atTop,
    ∃ z : ℤ, (q : ℝ) * (Real.log (u k : ℝ) / Real.log (b : ℝ)) = (z : ℝ)

/-! ## Digit Discrepancy -/

/-- The **digit discrepancy** measures the maximum deviation of empirical
leading-digit frequencies from Benford predictions across all valid digits.
This is the supremum norm of the discrepancy vector. -/
noncomputable def digitDiscrepancy (b : ℕ) (u : ℕ → ℕ) (N : ℕ) : ℝ :=
  if h : 2 ≤ b then
    Finset.sup' (Finset.Icc 1 (b - 1))
      (by rw [Finset.nonempty_Icc]; omega)
      (fun d => |benfordFreqUpTo b d u N - benfordTheoretical b d|)
  else 0

/-! ## Cocycle Decomposition -/

/-- **Drift rate** of a dynamical orbit: average logarithmic growth per step. -/
noncomputable def driftRate (b : ℕ) (u : ℕ → ℕ) (k : ℕ) : ℝ :=
  if k = 0 then 0
  else Real.log (u k : ℝ) / (Real.log (b : ℝ) * k)

/-- **Oscillation component**: the fractional part of the log cocycle,
which determines digit statistics. -/
noncomputable def oscillation (b : ℕ) (u : ℕ → ℕ) (k : ℕ) : ℝ :=
  Int.fract (Real.log (u k : ℝ) / Real.log (b : ℝ))

/-! ## Integer Dynamical Map Structure -/

/-- An **integer dynamical map** bundled with its expansion data. -/
structure IntDynMap where
  /-- The map T : ℕ → ℕ -/
  map : ℕ → ℕ
  /-- T sends positive numbers to positive numbers -/
  map_pos : ∀ n, 1 ≤ n → 1 ≤ map n

/-- The orbit sequence of an integer dynamical map. -/
def IntDynMap.orbitSeq (T : IntDynMap) (n : ℕ) : ℕ → ℕ :=
  fun k => T.map^[k] n

/-- An orbit sequence starting from a positive seed stays positive. -/
theorem IntDynMap.orbitSeq_pos (T : IntDynMap) (n : ℕ) (hn : 1 ≤ n) (k : ℕ) :
    1 ≤ T.orbitSeq n k := by
  induction k with
  | zero => exact hn
  | succ k ih =>
    simp only [IntDynMap.orbitSeq, Function.iterate_succ', Function.comp_apply]
    exact T.map_pos _ ih

/-! ## Benford for Orbit Sequences -/

/-- An integer dynamical map is **Benford** for seed `n` in base `b`
if its orbit sequence satisfies Benford's law. -/
def IntDynMap.IsBenfordAt (T : IntDynMap) (b n : ℕ) : Prop :=
  IsBenford b (T.orbitSeq n)

/-- The set of seeds for which the orbit is Benford. -/
def IntDynMap.benfordSeeds (T : IntDynMap) (b : ℕ) : Set ℕ :=
  {n | T.IsBenfordAt b n}

/-! ## Frequency Properties -/

theorem benfordFreqUpTo_nonneg (b d : ℕ) (u : ℕ → ℕ) (N : ℕ) :
    0 ≤ benfordFreqUpTo b d u N := by
  unfold benfordFreqUpTo; split_ifs <;> positivity

theorem benfordFreqUpTo_le_one (b d : ℕ) (u : ℕ → ℕ) (N : ℕ) :
    benfordFreqUpTo b d u N ≤ 1 := by
  unfold benfordFreqUpTo; split_ifs with h
  · norm_num
  · exact div_le_one_of_le₀
      (mod_cast le_trans (Finset.card_filter_le _ _) (by simp))
      (Nat.cast_nonneg _)

end BenfordRenorm