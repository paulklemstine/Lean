/-! # CatalogBuild.Geometry.Stereographic.Basic

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 6
-/

import Mathlib

noncomputable section

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

end
