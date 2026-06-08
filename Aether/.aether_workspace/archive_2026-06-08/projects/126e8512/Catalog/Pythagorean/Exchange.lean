/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import ValuatedMatroidDepth.Defs

/-!
# Exchange Properties and Ratio Monotonicity from Depth

This file proves that directional depth ≥ 1 implies monotonicity of ratio
transforms, and combines exchange-closed support with log-concavity to derive
tropical exchange-type inequalities.

## Main Results

* `ratio_nonincreasing_of_depth_one` — ratio transforms decrease along their direction
* `exchangeMove_degree` — exchange moves preserve total degree on a degree slice
* `weak_exchange_of_depth_one` — exchange-closed support + depth 1 ⟹ tropical bound
-/

noncomputable section

open Finset BigOperators Function

namespace ValuatedMatroidDepth

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ## Ratio Monotonicity -/

set_option linter.unusedSectionVars false in
/-
**Ratio Monotonicity Theorem**: Directional depth ≥ 1 implies
    the ratio transform `Rᵢf` is non-increasing along direction `i`:
    `Rᵢf(m + eᵢ) ≤ Rᵢf(m)` for positive `f`.
-/
theorem ratio_nonincreasing_of_depth_one
    (f : (α → ℕ) → ℝ)
    (hf_pos : ∀ m, 0 < f m)
    (hf : DirectionalDepthAtLeast 1 f)
    (i : α) (m : α → ℕ) :
    ratioTransform i f (m + Pi.single i 1) ≤ ratioTransform i f m := by
  have := hf.1 i m; ( rw [ ratioTransform, ratioTransform ] ; rw [ div_le_div_iff₀ ] <;> nlinarith [ hf_pos m, hf_pos ( m + Pi.single i 1 ) ] ; )

/-! ## Exchange Move Properties -/

set_option linter.unusedSectionVars false in
/-- An exchange move at `i ≠ j` gives `m k` at coordinates `k ≠ i, j`. -/
theorem exchangeMove_apply_other (m : α → ℕ) (i j : α)
    (k : α) (hki : k ≠ i) (hkj : k ≠ j) :
    exchangeMove m i j k = m k := by
  simp [exchangeMove, Function.update, hki, hkj]

set_option linter.unusedSectionVars false in
/-- An exchange move increases coordinate `i` by 1. -/
theorem exchangeMove_apply_i (m : α → ℕ) (i j : α) (hij : i ≠ j) :
    exchangeMove m i j i = m i + 1 := by
  simp [exchangeMove, Function.update, hij]

set_option linter.unusedSectionVars false in
/-- An exchange move decreases coordinate `j` by 1 (truncating). -/
theorem exchangeMove_apply_j (m : α → ℕ) (i j : α) (hij : i ≠ j) :
    exchangeMove m i j j = m j - 1 := by
  simp [exchangeMove, Function.update, hij.symm]

/-! ## Exchange Degree Preservation -/

/-
Exchange moves preserve total degree when `i ≠ j` and `0 < m j`.
-/
theorem exchangeMove_degree (d : ℕ) (m : α → ℕ) (i j : α)
    (hij : i ≠ j) (hm : degreeSlice d m) (hmj : 0 < m j) :
    degreeSlice d (exchangeMove m i j) := by
  unfold degreeSlice exchangeMove at *;
  simp +decide [ hij, update_apply ];
  simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne', * ];
  rw [ ← hm, ← Finset.sum_erase_add _ _ ( Finset.mem_univ i ), ← Finset.sum_erase_add _ _ ( Finset.mem_erase_of_ne_of_mem ( Ne.symm hij ) ( Finset.mem_univ j ) ) ] ; split_ifs <;> simp_all +decide ; linarith [ Nat.sub_add_cancel hmj ]

/-! ## Weak Exchange Theorem -/

/-
**Weak Exchange from Depth 1**: If `f` has exchange-closed support on a degree
    slice, is everywhere positive, and has depth ≥ 1, then for any two multisets
    `m, n` with `m i < n i`, there exists an exchange coordinate `j` with `n j < m j`
    such that the exchange move produces a positive-weight point AND the directional
    log-concavity at `m` provides a tropical (log) bound.
-/
theorem weak_exchange_of_depth_one
    (d : ℕ) (f : (α → ℕ) → ℝ)
    (hf_pos : ∀ m, 0 < f m)
    (hsupp : exchangeClosedSupport f d)
    (hf : DirectionalDepthAtLeast 1 f) :
    ∀ ⦃m n : α → ℕ⦄,
      degreeSlice d m → degreeSlice d n →
      ∀ ⦃i : α⦄, m i < n i →
      ∃ j, n j < m j ∧
        0 < f (exchangeMove m i j) ∧
        Real.log (f m) + Real.log (f (m + Pi.single i 1 + Pi.single i 1)) ≤
          2 * Real.log (f (m + Pi.single i 1)) := by
  intros m n hm hn i hi
  obtain ⟨j, hj⟩ := hsupp hm hn (hf_pos m) (hf_pos n) hi
  use j
  simp_all +decide [ exchangeMove ];
  rw [ ← Real.log_mul ( ne_of_gt ( hf_pos _ ) ) ( ne_of_gt ( hf_pos _ ) ) ];
  rw [ ← Real.log_rpow, Real.log_le_log_iff ] <;> norm_num <;> try nlinarith [ hf_pos m, hf_pos ( m + Pi.single i 1 ), hf_pos ( m + Pi.single i 1 + Pi.single i 1 ) ];
  convert hf.1 i m using 1 ; ring

end ValuatedMatroidDepth

end