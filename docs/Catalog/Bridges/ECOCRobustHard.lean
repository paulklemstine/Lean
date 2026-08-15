/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Hard ECOC Decoding Robustness

This file proves robustness for hard (Hamming) ECOC decoders by establishing that
sufficiently large bit margins preserve individual sign functions, and therefore
preserve every class's hard bit-agreement pattern exactly.

The key results are:

1. **Sign stability** (`sign_stable_of_gap_margin`): If the per-bit Lipschitz budget
   L*r is smaller than the absolute gap |g_j(x)|, the sign of g_j is invariant on the ball.

2. **Hard score preservation** (`hard_ecoc_robust_of_bit_sign_stability`): Under a
   uniform sign-stability condition, every class's hard score is constant on the ball.
-/
import Bridges.ECOCDefs
open scoped BigOperators
open Finset

variable {α : Type*} [PseudoMetricSpace α]

/-! ## Sign stability lemma -/

/-
If the Lipschitz perturbation budget is smaller than the absolute gap,
then the sign of the gap is preserved.
-/
theorem sign_stable_of_gap_margin
    {m : ℕ}
    (g : Fin m → α → ℝ)
    (L r : ℝ)
    (hL : BitGapLipschitzOn g L)
    (x x' : α)
    (hx' : dist x x' ≤ r)
    (j : Fin m)
    (hj : L * r < |g j x|) :
    Real.sign (g j x') = Real.sign (g j x) := by
  by_cases hL_nonneg : 0 ≤ L;
  · cases abs_cases ( g j x ) <;> cases abs_cases ( g j x' ) <;> simp +decide [ *, Real.sign ];
    · split_ifs <;> linarith [ abs_le.mp ( hL j x x' ), mul_le_mul_of_nonneg_left hx' hL_nonneg ];
    · nlinarith [ abs_le.mp ( hL j x x' ) ];
    · nlinarith [ hL j x x', abs_le.mp ( hL j x x' ) ];
  · have hL_zero : ∀ j x x', |g j x - g j x'| ≤ 0 * dist x x' := by
      exact fun j x x' => le_trans ( hL j x x' ) ( by nlinarith [ @dist_nonneg _ _ x x' ] );
    simp_all +decide [ sub_eq_iff_eq_add ];
    rw [ hL_zero j x x' ]

/-! ## Hard score preservation -/

/-
**Hard ECOC robustness.** If every bit has margin exceeding L*r, then every
class's hard score is preserved on the entire ball.
-/
theorem hard_ecoc_robust_of_bit_sign_stability
    {n m : ℕ}
    (C : CodeMatrix n m)
    (hC : ValidCodeMatrix C)
    (g : Fin m → α → ℝ)
    (L r : ℝ)
    (hL : BitGapLipschitzOn g L)
    (x : α)
    (hmargin : ∀ j, L * r < |g j x|) :
    ∀ x', dist x x' ≤ r →
      ∀ y, hardScore C g y x' = hardScore C g y x := by
  intros x' hx' y
  have h_sign_stable : ∀ j, Real.sign (g j x') = Real.sign (g j x) := by
    exact fun j => sign_stable_of_gap_margin g L r hL x x' hx' j (hmargin j)
  unfold hardScore;
  congr 1 with j ; simp +decide [ SignedBitScore, Real.sign ] at *;
  cases hC y j <;> simp +decide [ * ];
  · grind;
  · grind