import Geometry.Stereographic.Basic
import Mathlib

/-! # CatalogBuild.Geometry.Stereographic.SouthPole

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 11
-/


noncomputable section

/-- Inverse stereographic projection from the SOUTH pole.
For i < N: the i-th coordinate is `2 * y_i / (1 + ‖y‖²)`.
For i = N (last): the coordinate is `(1 - ‖y‖²) / (1 + ‖y‖²)`.
Note: this differs from `invStereoN` only in the sign of the last coordinate. -/
def invStereoS {N : ℕ} (y : Fin N → ℝ) : Fin (N + 1) → ℝ := fun i =>
  if h : i.val < N then
    2 * y ⟨i.val, h⟩ / stereoDenom y
  else
    (1 - sqNormFin y) / stereoDenom y



/-- Forward stereographic projection from the SOUTH pole (0,...,0,-1). -/
def stereoS {N : ℕ} (x : Fin (N + 1) → ℝ) : Fin N → ℝ := fun i =>
  x ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩ / (1 + x ⟨N, Nat.lt_succ_iff.mpr le_rfl⟩)



/-- [Section: # CatalogBuild.Geometry.Stereographic.SouthPole
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 11] -/
lemma invStereoS_coord_lt {N : ℕ} (y : Fin N → ℝ) (i : Fin (N + 1)) (h : i.val < N) :
    invStereoS y i = 2 * y ⟨i.val, h⟩ / stereoDenom y := by
  simp [invStereoS, h]



lemma invStereoS_last_coord {N : ℕ} (y : Fin N → ℝ) :
    invStereoS y (lastIdx N) = (1 - sqNormFin y) / stereoDenom y := by
  simp [invStereoS, lastIdx]



theorem invStereoS_norm_sq {N : ℕ} (y : Fin N → ℝ) :
    ∑ i : Fin (N + 1), (invStereoS y i) ^ 2 = 1 := by
      convert StereographicProjection.invStereoN_norm_sq y using 2;
      unfold invStereoS invStereoN;
      split_ifs <;> ring



theorem invStereoS_last_ne_neg_one {N : ℕ} (y : Fin N → ℝ) :
    invStereoS y (lastIdx N) ≠ -1 := by
      unfold invStereoS;
      simp +zetaDelta at *;
      split_ifs;
      · exact absurd ‹_› ( Nat.not_lt_of_ge ( Nat.le_refl _ ) );
      · rw [ div_eq_iff ] <;> first | linarith | unfold stereoDenom; linarith [ sqNormFin_nonneg y ]



theorem invStereoN_invStereoS_first_coords {N : ℕ} (y : Fin N → ℝ) (i : Fin N) :
    invStereoN y ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩ =
    invStereoS y ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩ := by
      unfold invStereoN invStereoS; aesop;



theorem invStereoS_last_neg_invStereoN {N : ℕ} (y : Fin N → ℝ) :
    invStereoS y (lastIdx N) = -(invStereoN y (lastIdx N)) := by
      rw [ invStereoS_last_coord, invStereoN_last_coord, ← neg_div ] ; ring



theorem stereoS_invStereoS {N : ℕ} (y : Fin N → ℝ) :
    stereoS (invStereoS y) = y := by
      unfold stereoS;
      ext i;
      unfold invStereoS;
      unfold stereoDenom; rw [ div_eq_iff ] <;> norm_num;
      · rw [ one_add_div ( by linarith [ show 0 ≤ sqNormFin y from Finset.sum_nonneg fun _ _ => sq_nonneg _ ] ) ] ; ring;
      · rw [ add_div', div_eq_iff ] <;> nlinarith [ show 0 ≤ sqNormFin y from Finset.sum_nonneg fun _ _ => sq_nonneg _ ]



theorem transition_map_is_inversion {N : ℕ} (y : Fin N → ℝ) (hy : sqNormFin y ≠ 0) (i : Fin N) :
    stereoS (invStereoN y) i = y i / sqNormFin y := by
      -- Substitute the expressions for invStereoN y i and invStereoN y (lastIdx N) into the equation.
      have h_subst : stereoS (invStereoN y) i = (2 * y i / stereoDenom y) / (1 + (sqNormFin y - 1) / stereoDenom y) := by
        simp +decide [ stereoS, invStereoN ];
      rw [ h_subst, div_div, mul_comm ];
      rw [ mul_add, mul_div_cancel₀ _ ( stereoDenom_pos _ |> ne_of_gt ) ] ; ring;
      unfold stereoDenom; ring;



theorem transition_map_involution {N : ℕ} (y : Fin N → ℝ)
    (hy : sqNormFin y ≠ 0) (i : Fin N) :
    stereoS (invStereoN (fun j => stereoS (invStereoN y) j)) i = y i := by
      unfold stereoS invStereoN;
      simp +decide [ sqNormFin, stereoDenom ] at *;
      field_simp;
      norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_div ] at *;
      grind



end
