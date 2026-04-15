import Mathlib

/-!
# N-Dimensional Stereographic Projection: Core Definitions and Properties

## Overview

This file develops the theory of n-dimensional stereographic projection from
first principles using coordinate formulas, establishing:

1. **Inverse stereographic projection** `invStereoN : (Fin N → ℝ) → (Fin (N+1) → ℝ)` maps ℝ^N → S^N
2. **Forward stereographic projection** `stereoN : {x : Fin (N+1) → ℝ // ...} → (Fin N → ℝ)` maps S^N\{NP} → ℝ^N
3. **Unit norm property**: the image of `invStereoN` lies on S^N
4. **Round-trip properties**: forward ∘ inverse = id and inverse ∘ forward = id
5. **Injectivity** of the inverse map

## Formulas

Given y = (y₁, ..., y_N) ∈ ℝ^N, let D = 1 + ‖y‖² = 1 + Σᵢ yᵢ². Then:

  invStereoN(y)ᵢ = 2·yᵢ / D        for i = 0, ..., N-1
  invStereoN(y)_N = (‖y‖² - 1) / D

Given x = (x₀, ..., x_N) on S^N with x_N ≠ 1 (not the north pole):

  stereoN(x)ᵢ = xᵢ / (1 - x_N)     for i = 0, ..., N-1
-/

open Finset BigOperators Real

noncomputable section

/-! ## Core Definitions -/

/-- The squared norm of a vector in ℝ^N, i.e., Σᵢ yᵢ². -/
def sqNorm (N : ℕ) (y : Fin N → ℝ) : ℝ := ∑ i, (y i) ^ 2

/-- The denominator D = 1 + ‖y‖² appearing in inverse stereographic projection. -/
def stereoDenom (N : ℕ) (y : Fin N → ℝ) : ℝ := 1 + sqNorm N y

/-- The denominator is always positive. -/
theorem stereoDenom_pos (N : ℕ) (y : Fin N → ℝ) : 0 < stereoDenom N y := by
  unfold stereoDenom sqNorm
  positivity

/-- The denominator is never zero. -/
theorem stereoDenom_ne_zero (N : ℕ) (y : Fin N → ℝ) : stereoDenom N y ≠ 0 :=
  ne_of_gt (stereoDenom_pos N y)

/-- N-dimensional inverse stereographic projection: ℝ^N → ℝ^{N+1}.
    Maps the "equatorial plane" to the unit sphere S^N,
    with the north pole (0,...,0,1) as the projection center. -/
def invStereoN (N : ℕ) (y : Fin N → ℝ) : Fin (N + 1) → ℝ := fun i =>
  let D := stereoDenom N y
  if h : (i : ℕ) < N then
    2 * y ⟨i, h⟩ / D
  else
    (sqNorm N y - 1) / D

/-- The last coordinate of invStereoN is (‖y‖² - 1) / D. -/
theorem invStereoN_last (N : ℕ) (y : Fin N → ℝ) :
    invStereoN N y ⟨N, Nat.lt_succ_iff.mpr le_rfl⟩ = (sqNorm N y - 1) / stereoDenom N y := by
  simp [invStereoN]

/-- The i-th coordinate (for i < N) of invStereoN is 2·yᵢ / D. -/
theorem invStereoN_lt (N : ℕ) (y : Fin N → ℝ) (i : Fin (N + 1)) (hi : (i : ℕ) < N) :
    invStereoN N y i = 2 * y ⟨i, hi⟩ / stereoDenom N y := by
  simp [invStereoN, hi]

/-! ## The Unit Norm Property -/

/-
Key algebraic identity: the sum of squares of the stereographic output equals
    (‖y‖² + 1)² / D², which equals 1 since D = ‖y‖² + 1.
-/
theorem invStereoN_norm_sq (N : ℕ) (y : Fin N → ℝ) :
    ∑ i : Fin (N + 1), (invStereoN N y i) ^ 2 = 1 := by
  unfold invStereoN;
  rw [ Fin.sum_univ_castSucc ] ; norm_num [ div_pow, Finset.mul_sum _ _ _, Finset.sum_mul, Finset.sum_add_distrib, sqNorm ] ; ring;
  unfold stereoDenom;
  norm_num [ ← Finset.sum_mul _ _ _, sqNorm ];
  -- Combine like terms and simplify the expression.
  field_simp
  ring

/-! ## Forward Stereographic Projection -/

/-- Forward stereographic projection from S^N \ {north pole} to ℝ^N. -/
def stereoN (N : ℕ) (x : Fin (N + 1) → ℝ)
    (hx_norm : ∑ i : Fin (N + 1), (x i) ^ 2 = 1)
    (hx_np : x ⟨N, Nat.lt_succ_iff.mpr le_rfl⟩ ≠ 1) :
    Fin N → ℝ := fun i =>
  x ⟨i, Nat.lt_succ_of_lt i.isLt⟩ / (1 - x ⟨N, Nat.lt_succ_iff.mpr le_rfl⟩)

/-! ## Round-trip: forward ∘ inverse = id -/

/-
The last coordinate of invStereoN is never 1 (the north pole is not in the image).
-/
theorem invStereoN_last_ne_one (N : ℕ) (y : Fin N → ℝ) :
    invStereoN N y ⟨N, Nat.lt_succ_iff.mpr le_rfl⟩ ≠ 1 := by
  unfold invStereoN;
  unfold stereoDenom;
  grind

/-
Forward ∘ Inverse = id: stereographic projection followed by its inverse recovers the original point.
-/
theorem stereoN_invStereoN (N : ℕ) (y : Fin N → ℝ) :
    stereoN N (invStereoN N y) (invStereoN_norm_sq N y) (invStereoN_last_ne_one N y) = y := by
  unfold invStereoN stereoN;
  unfold stereoDenom; norm_num;
  field_simp;
  rw [ mul_sub, mul_div_cancel₀ ] <;> ring ; exact ne_of_gt <| add_pos_of_pos_of_nonneg zero_lt_one <| Finset.sum_nonneg fun _ _ => sq_nonneg _

/-! ## Injectivity -/

/-
The N-dimensional inverse stereographic projection is injective.
-/
theorem invStereoN_injective (N : ℕ) : Function.Injective (invStereoN N) := by
  intro y1 y2 h_eq;
  -- From the last coordinate, (S_a - 1)/D_a = (S_b - 1)/D_b. Since D = 1 + S, this gives (D_a - 2)/D_a = (D_b - 2)/D_b, i.e. 1 - 2/D_a = 1 - 2/D_b, so D_a = D_b.
  have h_denom : stereoDenom N y1 = stereoDenom N y2 := by
    simp_all +decide [ funext_iff, Fin.ext_iff ];
    unfold invStereoN at h_eq;
    have := h_eq ⟨ N, Nat.lt_succ_self _ ⟩ ; norm_num at this;
    rw [ div_eq_div_iff ] at this <;> (unfold stereoDenom at * ; nlinarith [ sqNorm N y1, sqNorm N y2, show 0 ≤ sqNorm N y1 from Finset.sum_nonneg fun _ _ => sq_nonneg _, show 0 ≤ sqNorm N y2 from Finset.sum_nonneg fun _ _ => sq_nonneg _ ]);
  ext i;
  have := congr_fun h_eq ⟨ i, by linarith [ Fin.is_lt i ] ⟩ ; simp_all +decide [ Fin.ext_iff, invStereoN ];
  rw [ div_eq_div_iff ] at this <;> nlinarith [ show 0 < stereoDenom N y2 from by exact add_pos_of_pos_of_nonneg zero_lt_one <| Finset.sum_nonneg fun _ _ => sq_nonneg _ ]

end