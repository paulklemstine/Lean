/-! # CatalogBuild.Geometry.Stereographic.Basic

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 13
-/

import Mathlib

noncomputable section

/-- Sum of squares of coordinates -/
def sqNormFin {N : ℕ} (y : Fin N → ℝ) : ℝ := ∑ i, y i ^ 2



/-- Denominator for stereographic projection, always positive -/
def stereoDenom {N : ℕ} (y : Fin N → ℝ) : ℝ := 1 + sqNormFin y



/-- [Section: # CatalogBuild.Geometry.Stereographic.Basic
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 13] -/
lemma sqNormFin_nonneg {N : ℕ} (y : Fin N → ℝ) : 0 ≤ sqNormFin y :=
  Finset.sum_nonneg fun i _ => sq_nonneg (y i)



lemma stereoDenom_pos {N : ℕ} (y : Fin N → ℝ) : 0 < stereoDenom y := by
  unfold stereoDenom
  linarith [sqNormFin_nonneg y]



lemma stereoDenom_ne_zero {N : ℕ} (y : Fin N → ℝ) : stereoDenom y ≠ 0 :=
  ne_of_gt (stereoDenom_pos y)



/-- Forward stereographic projection from S^N \ {NP} to ℝ^N.
Projects from the north pole (0,...,0,1). -/
def stereoN {N : ℕ} (x : Fin (N + 1) → ℝ) : Fin N → ℝ := fun i =>
  x ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩ / (1 - x ⟨N, Nat.lt_succ_iff.mpr le_rfl⟩)


def lastIdx (N : ℕ) : Fin (N + 1) := ⟨N, Nat.lt_succ_iff.mpr le_rfl⟩



lemma invStereoN_coord_lt {N : ℕ} (y : Fin N → ℝ) (i : Fin (N + 1)) (h : i.val < N) :
    invStereoN y i = 2 * y ⟨i.val, h⟩ / stereoDenom y := by
  simp [invStereoN, h]



lemma invStereoN_last_coord {N : ℕ} (y : Fin N → ℝ) :
    invStereoN y (lastIdx N) = (sqNormFin y - 1) / stereoDenom y := by
  simp [invStereoN, lastIdx]



theorem invStereoN_norm_sq {N : ℕ} (y : Fin N → ℝ) :
    ∑ i : Fin (N + 1), (invStereoN y i) ^ 2 = 1 := by
      unfold invStereoN;
      simp +decide [ Fin.sum_univ_castSucc, sq ];
      simp +decide [ stereoDenom, sqNormFin, mul_assoc, mul_comm, mul_left_comm, div_eq_mul_inv, Finset.mul_sum _ _ _, Finset.sum_mul ];
      simp +decide [ ← mul_assoc, ← Finset.sum_mul _ _ _ ];
      -- Combine like terms and simplify the expression.
      field_simp
      ring



theorem invStereoN_last_ne_one {N : ℕ} (y : Fin N → ℝ) :
    invStereoN y (lastIdx N) ≠ 1 := by
      rw [ invStereoN_last_coord ];
      exact div_ne_one_of_ne ( by linarith [ show sqNormFin y ≥ 0 by exact ( by exact Finset.sum_nonneg fun i _ ↦ pow_two_nonneg _ ), show stereoDenom y > sqNormFin y by exact lt_add_of_pos_left _ ( by norm_num ) ] )



theorem stereoN_invStereoN {N : ℕ} (y : Fin N → ℝ) :
    stereoN (invStereoN y) = y := by
      ext i;
      unfold stereoN invStereoN;
      split_ifs;
      · grind;
      · field_simp [stereoDenom_ne_zero];
        unfold stereoDenom sqNormFin; ring;
      · grobner;
      · grind



theorem invStereoN_image_eq {N : ℕ} :
    Set.range (@invStereoN N) = {x : Fin (N + 1) → ℝ |
      (∑ i, x i ^ 2 = 1) ∧ x (lastIdx N) ≠ 1} := by
        apply Set.eq_of_subset_of_subset;
        · exact Set.range_subset_iff.mpr fun y => ⟨ invStereoN_norm_sq y, invStereoN_last_ne_one y ⟩;
        · intro x hx;
          use fun i => x ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩ / (1 - x ⟨N, Nat.lt_succ_iff.mpr le_rfl⟩);
          unfold invStereoN;
          simp_all +decide [ Fin.sum_univ_castSucc, stereoDenom, sqNormFin ];
          simp_all +decide [ ← Finset.sum_div _ _ _, div_pow ];
          simp_all +decide [ Fin.castSucc, Fin.last, lastIdx ];
          simp_all +decide [ Fin.castAdd, Fin.castSucc ];
          simp_all +decide [ Fin.castLE, Fin.sum_univ_castSucc ];
          grind



end
