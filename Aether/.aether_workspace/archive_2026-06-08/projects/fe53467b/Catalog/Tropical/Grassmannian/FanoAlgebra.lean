/-
Copyright (c) 2025. All rights reserved.

# Algebraic Non-representability of the Fano Matroid

The Fano incidence structure forces `2 = 0` in the base field.
-/

import Mathlib
import Tropical.Grassmannian.Defs

open Matrix

/-- **The Fano incidence system is algebraically inconsistent over ℝ.**

    After normalizing columns 0,1,2 to the standard basis, the remaining
    Fano line conditions force `2·(nonzero product) = 0`, a contradiction. -/
theorem fano_normalized_contradiction :
    ¬ ∃ (a b d f g h p q r : ℝ),
      a ≠ 0 ∧ b ≠ 0 ∧ d ≠ 0 ∧ f ≠ 0 ∧ g ≠ 0 ∧ h ≠ 0 ∧ p ≠ 0 ∧
      g * r = h * q ∧
      f * p = d * r ∧
      a * q = b * p ∧
      a * f * g + d * b * h = 0 := by
  grobner

/-- Direct 3×3 determinant of columns i, j, k of a 3×n matrix. -/
def detCols {n : ℕ} (A : Matrix (Fin 3) (Fin n) ℝ) (i j k : Fin n) : ℝ :=
  det !![A 0 i, A 0 j, A 0 k;
         A 1 i, A 1 j, A 1 k;
         A 2 i, A 2 j, A 2 k]

/-- `detCols` is the same as `detCols3` from Defs. -/
lemma detCols_eq_detCols3 {n : ℕ} (A : Matrix (Fin 3) (Fin n) ℝ) (i j k : Fin n) :
    detCols A i j k = detCols3 A i j k := rfl

/-
**The full Fano non-representability theorem.**
    No 3×7 real matrix can have its dependent triples equal to exactly the Fano lines.
-/
set_option maxHeartbeats 800000 in
theorem fano_algebraic_contradiction :
    ¬ ∃ (A : Matrix (Fin 3) (Fin 7) ℝ),
      detCols A 0 1 2 ≠ 0 ∧
      detCols A 0 1 3 = 0 ∧ detCols A 0 2 4 = 0 ∧ detCols A 1 2 5 = 0 ∧
      detCols A 0 5 6 = 0 ∧ detCols A 1 4 6 = 0 ∧ detCols A 2 3 6 = 0 ∧
      detCols A 3 4 5 = 0 ∧
      detCols A 0 2 3 ≠ 0 ∧ detCols A 1 2 3 ≠ 0 ∧
      detCols A 0 1 4 ≠ 0 ∧ detCols A 0 2 5 ≠ 0 ∧
      detCols A 0 1 5 ≠ 0 ∧
      detCols A 1 2 6 ≠ 0 := by
  intros h_exists
  obtain ⟨A, hA_conditions⟩ := h_exists
  set M : Matrix (Fin 3) (Fin 3) ℝ := !![A 0 0, A 0 1, A 0 2; A 1 0, A 1 1, A 1 2; A 2 0, A 2 1, A 2 2];
  -- Let B = M⁻¹ * A. Then detCols B i j k = (det M)⁻¹ * detCols A i j k.
  obtain ⟨B, hB⟩ : ∃ B : Matrix (Fin 3) (Fin 7) ℝ, ∀ i j k : Fin 7, detCols B i j k = (M.det)⁻¹ * detCols A i j k ∧ B 0 0 = 1 ∧ B 1 0 = 0 ∧ B 2 0 = 0 ∧ B 0 1 = 0 ∧ B 1 1 = 1 ∧ B 2 1 = 0 ∧ B 0 2 = 0 ∧ B 1 2 = 0 ∧ B 2 2 = 1 := by
    have hB : ∃ B : Matrix (Fin 3) (Fin 7) ℝ, ∀ i j k : Fin 7, detCols B i j k = (M.det)⁻¹ * detCols A i j k ∧ B = M⁻¹ * A := by
      refine' ⟨ M⁻¹ * A, fun i j k => ⟨ _, rfl ⟩ ⟩;
      unfold detCols;
      have hB : Matrix.det (Matrix.of ![![M⁻¹ 0 0, M⁻¹ 0 1, M⁻¹ 0 2], ![M⁻¹ 1 0, M⁻¹ 1 1, M⁻¹ 1 2], ![M⁻¹ 2 0, M⁻¹ 2 1, M⁻¹ 2 2]]) = (M.det)⁻¹ := by
        convert Matrix.det_nonsing_inv M using 1;
        rw [ Ring.inverse ];
        split_ifs <;> simp_all +decide [ isUnit_iff_ne_zero ];
      convert congr_arg ( fun x => x * Matrix.det ( Matrix.of ![![A 0 i, A 0 j, A 0 k], ![A 1 i, A 1 j, A 1 k], ![A 2 i, A 2 j, A 2 k]] ) ) hB using 1;
      convert Matrix.det_mul _ _ using 2;
      ext i j; fin_cases i <;> fin_cases j <;> simp +decide [ Matrix.mul_apply, Fin.sum_univ_three ] ;
    obtain ⟨B, hB⟩ := hB
    have hB_inv : M⁻¹ * M = 1 := by
      have hM_inv : M.det ≠ 0 := by
        convert hA_conditions.1 using 1;
      exact Matrix.nonsing_inv_mul _ ( show IsUnit M.det from isUnit_iff_ne_zero.mpr hM_inv );
    use B; intro i j k; specialize hB i j k; simp_all +decide [ ← Matrix.ext_iff ] ;
    simp +zetaDelta at *;
    simp_all +decide [ Fin.forall_fin_succ, Matrix.mul_apply ];
    simp_all +decide [ Fin.sum_univ_three ];
  -- Apply the conditions from hB to each of the equalities and inequalities.
  have h_conditions :
    (B 0 0 = 1) ∧ (B 1 0 = 0) ∧ (B 2 0 = 0) ∧
    (B 0 1 = 0) ∧ (B 1 1 = 1) ∧ (B 2 1 = 0) ∧
    (B 0 2 = 0) ∧ (B 1 2 = 0) ∧ (B 2 2 = 1) ∧
    (detCols B 0 1 3 = 0) ∧ (detCols B 0 2 4 = 0) ∧ (detCols B 1 2 5 = 0) ∧
    (detCols B 3 4 5 = 0) ∧ (detCols B 0 5 6 = 0) ∧ (detCols B 1 4 6 = 0) ∧
    (detCols B 2 3 6 = 0) ∧ (detCols B 0 2 3 ≠ 0) ∧ (detCols B 1 2 3 ≠ 0) ∧
    (detCols B 0 1 4 ≠ 0) ∧ (detCols B 0 2 5 ≠ 0) ∧ (detCols B 0 1 5 ≠ 0) ∧ (detCols B 1 2 6 ≠ 0) := by
      simp_all +decide [ Fin.forall_fin_succ ];
      unfold detCols at * ; aesop ( simp_config := { decide := true } ) ;
  unfold detCols at h_conditions;
  simp +decide [ Matrix.det_fin_three ] at h_conditions;
  grind +revert