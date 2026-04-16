/-
# Novel Theorems on Stereographic Projection

This file contains novel results connecting stereographic projection to
conformal geometry, symmetry, and number theory.

## Main results

* `conformal_factor_eq_one_minus_last` — the conformal factor equals 1 minus the last coordinate
* `invStereoN_neg_first_coords` — negating input reflects first N coordinates
* `invStereoN_neg_last_coord` — negating input preserves last coordinate
* `invStereoN_scale_last` — scaling behavior of the last coordinate
* `energy_partition` — energy partition on the sphere
* `rotation_preserves_sqNorm` — orthogonal transformations preserve sqNorm
* `invStereoN_inversion_last` — inversion duality for the last coordinate
* `pythagorean_stereo_general` — Pythagorean identity for stereographic projection
-/
import Mathlib
import Geometry.Stereographic.Basic

namespace StereographicProjection

open Finset BigOperators

noncomputable section

/-
The conformal factor 2/D equals 1 minus the last coordinate of invStereoN
-/
theorem conformal_factor_eq_one_minus_last {N : ℕ} (y : Fin N → ℝ) :
    2 / stereoDenom y = 1 - invStereoN y (lastIdx N) := by
      rw [ invStereoN_last_coord ];
      unfold stereoDenom;
      rw [ one_sub_div ] <;> ring ; exact ne_of_gt <| add_pos_of_pos_of_nonneg zero_lt_one <| Finset.sum_nonneg fun _ _ => sq_nonneg _

/-
Squared conformal factor times sqNorm: (2/D)² · ‖y‖² = ∑ᵢ₌₀^{N-1} (invStereoN y i)²
-/
theorem conformal_factor_sq_times_sqNorm {N : ℕ} (y : Fin N → ℝ) :
    (2 / stereoDenom y) ^ 2 * sqNormFin y =
    ∑ i : Fin N, (invStereoN y ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩) ^ 2 := by
      unfold stereoDenom invStereoN;
      norm_num [ Finset.sum_ite, Finset.mul_sum _ _ _, mul_pow, div_pow ];
      rw [ ← Finset.sum_div _ _ _, ← Finset.mul_sum _ _ _ ] ; ring!;
      unfold stereoDenom; rw [ inv_pow ] ; ring;

/-
Negating the input reflects the first N coordinates of invStereoN
-/
theorem invStereoN_neg_first_coords {N : ℕ} (y : Fin N → ℝ) (i : Fin N) :
    invStereoN (fun j => -y j) ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩ =
    -(invStereoN y ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩) := by
      unfold invStereoN;
      simp +decide [ stereoDenom ];
      unfold sqNormFin; norm_num [ div_eq_mul_inv ] ;

/-
Negating the input preserves the last coordinate of invStereoN
-/
theorem invStereoN_neg_last_coord {N : ℕ} (y : Fin N → ℝ) :
    invStereoN (fun j => -y j) (lastIdx N) =
    invStereoN y (lastIdx N) := by
      -- By definition of `invStereoN`, the last coordinate is given by `(sqNormFin y - 1) / stereoDenom y`.
      simp [invStereoN, lastIdx];
      unfold sqNormFin stereoDenom; norm_num;
      unfold sqNormFin; norm_num;

/-
Scaling behavior: the last coordinate of invStereoN(r·y)
-/
theorem invStereoN_scale_last {N : ℕ} (y : Fin N → ℝ) (r : ℝ) :
    invStereoN (fun j => r * y j) (lastIdx N) =
    (r ^ 2 * sqNormFin y - 1) / (1 + r ^ 2 * sqNormFin y) := by
      unfold invStereoN; unfold lastIdx; ( unfold sqNormFin; );
      unfold stereoDenom; simp +decide [ div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] ;
      simp +decide only [sqNormFin, mul_pow, mul_comm]

/-
Energy partition: sum of squares of first N coords + last coord² = 1
-/
theorem energy_partition {N : ℕ} (y : Fin N → ℝ) :
    (∑ i : Fin N, (invStereoN y ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩) ^ 2) +
    (invStereoN y (lastIdx N)) ^ 2 = 1 := by
      conv_rhs => rw [ ← invStereoN_norm_sq y ];
      rw [ Fin.sum_univ_castSucc ];
      rfl

/-
Orthogonal transformations preserve sqNorm
-/
theorem rotation_preserves_sqNorm {N : ℕ} (R : Matrix (Fin N) (Fin N) ℝ)
    (hR : R * R.transpose = 1) (y : Fin N → ℝ) :
    sqNormFin (R.mulVec y) = sqNormFin y := by
      -- By definition of Euclidean norm, we have:
      unfold sqNormFin;
      -- Apply the norm squared to both sides of the equation R.mulVec y = (R * R.transpose) * y.
      have h_norm_sq : (Matrix.mulVec R y) ⬝ᵥ (Matrix.mulVec R y) = y ⬝ᵥ y := by
        simp +decide [ Matrix.dotProduct_mulVec, Matrix.vecMul_mulVec, hR ];
        rw [ mul_eq_one_comm.mp hR ];
        norm_num;
      simpa only [ sq, dotProduct ] using h_norm_sq

/-
Inversion duality: invStereoN(y/‖y‖²) has negated last coordinate,
    provided y ≠ 0
-/
theorem invStereoN_inversion_last {N : ℕ} (y : Fin N → ℝ) (hy : sqNormFin y ≠ 0) :
    invStereoN (fun j => y j / sqNormFin y) (lastIdx N) =
    -(invStereoN y (lastIdx N)) := by
      unfold invStereoN;
      unfold sqNormFin stereoDenom;
      norm_num [ lastIdx ];
      unfold sqNormFin; norm_num [ ← Finset.sum_div _ _ _, ← Finset.sum_mul, div_pow ] ; ring;
      field_simp;
      linarith [ one_div_mul_cancel ( show ( ∑ i, y i ^ 2 ) ≠ 0 from by simpa [ sqNormFin ] using hy ) ]

/-
Pythagorean identity for stereographic projection:
    4·S + (S - 1)² = (S + 1)² where S = ‖y‖²
-/
theorem pythagorean_stereo_general {N : ℕ} (y : Fin N → ℝ) :
    4 * sqNormFin y + (sqNormFin y - 1) ^ 2 = (sqNormFin y + 1) ^ 2 := by
      ring

end

end StereographicProjection