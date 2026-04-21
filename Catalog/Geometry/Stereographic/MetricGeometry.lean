/-! # CatalogBuild.Geometry.Stereographic.MetricGeometry

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 10
-/

import Geometry.Stereographic.Basic
import Mathlib

noncomputable section

/-- Inner product of two vectors in Fin N → ℝ -/
def dotProdFin {N : ℕ} (y z : Fin N → ℝ) : ℝ := ∑ i, y i * z i



/-- Squared distance between two vectors -/
def sqDistFin {N : ℕ} (y z : Fin N → ℝ) : ℝ := ∑ i, (y i - z i) ^ 2



/-- [Section: # CatalogBuild.Geometry.Stereographic.MetricGeometry
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 10] -/
theorem sqNormFin_eq_dot {N : ℕ} (y : Fin N → ℝ) :
    sqNormFin y = dotProdFin y y := by
      exact Finset.sum_congr rfl fun _ _ => by ring;



theorem sqDistFin_expand {N : ℕ} (y z : Fin N → ℝ) :
    sqDistFin y z = sqNormFin y - 2 * dotProdFin y z + sqNormFin z := by
      unfold sqDistFin dotProdFin sqNormFin; simp +decide [ sub_sq ] ; ring;
      simpa [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul ] using by ring;



theorem invStereoN_dot_product {N : ℕ} (y z : Fin N → ℝ) :
    ∑ i : Fin (N + 1), invStereoN y i * invStereoN z i =
    (4 * dotProdFin y z + (sqNormFin y - 1) * (sqNormFin z - 1)) /
    (stereoDenom y * stereoDenom z) := by
      unfold invStereoN;
      unfold dotProdFin; norm_num [ Fin.sum_univ_castSucc, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, div_mul_div_comm, mul_assoc, mul_div_assoc ] ; ring;
      simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ]



theorem invStereoN_chordal_sq {N : ℕ} (y z : Fin N → ℝ) :
    ∑ i : Fin (N + 1), (invStereoN y i - invStereoN z i) ^ 2 =
    4 * sqDistFin y z / (stereoDenom y * stereoDenom z) := by
      -- Expand the squared distance using the definition of `invStereoN`.
      have h_expand : ∑ i : Fin (N + 1), (invStereoN y i - invStereoN z i) ^ 2 = (∑ i : Fin (N + 1), (invStereoN y i) ^ 2) + (∑ i : Fin (N + 1), (invStereoN z i) ^ 2) - 2 * (∑ i : Fin (N + 1), (invStereoN y i) * (invStereoN z i)) := by
        simpa only [ ← Finset.sum_add_distrib, ← Finset.sum_sub_distrib, Finset.mul_sum _ _ _ ] using Finset.sum_congr rfl fun i _ => by ring;
      -- Substitute the expressions for the norms and the dot product into the expanded squared distance.
      have h_subst : 2 - 2 * (4 * dotProdFin y z + (sqNormFin y - 1) * (sqNormFin z - 1)) / (stereoDenom y * stereoDenom z) = 4 * (sqNormFin y - 2 * dotProdFin y z + sqNormFin z) / (stereoDenom y * stereoDenom z) := by
        unfold stereoDenom;
        rw [ sub_div', div_eq_div_iff ] <;> ring <;> nlinarith only [ show 0 ≤ sqNormFin y from Finset.sum_nonneg fun _ _ => sq_nonneg _, show 0 ≤ sqNormFin z from Finset.sum_nonneg fun _ _ => sq_nonneg _ ];
      convert h_subst using 1;
      · rw [ h_expand, invStereoN_norm_sq, invStereoN_norm_sq, invStereoN_dot_product ] ; ring;
      · rw [ sqDistFin_expand ]



theorem conformal_metric_factor {N : ℕ} (y : Fin N → ℝ) :
    (2 / stereoDenom y) ^ 2 = 4 / (stereoDenom y) ^ 2 := by
      ring



theorem stereoDenom_ge_one {N : ℕ} (y : Fin N → ℝ) : 1 ≤ stereoDenom y := by
  exact le_add_of_nonneg_right ( sqNormFin_nonneg y )



theorem chordal_le_euclidean {N : ℕ} (y z : Fin N → ℝ) :
    4 * sqDistFin y z / (stereoDenom y * stereoDenom z) ≤ 4 * sqDistFin y z := by
      exact div_le_self ( mul_nonneg zero_le_four ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ) ) ( by exact one_le_mul_of_one_le_of_one_le ( by exact le_add_of_nonneg_right ( sqNormFin_nonneg _ ) ) ( by exact le_add_of_nonneg_right ( sqNormFin_nonneg _ ) ) )



theorem angular_distance_identity {N : ℕ} (y z : Fin N → ℝ) :
    2 - 2 * ∑ i : Fin (N + 1), invStereoN y i * invStereoN z i =
    ∑ i : Fin (N + 1), (invStereoN y i - invStereoN z i) ^ 2 := by
      -- By expanding the square on the right-hand side, we can separate the terms into the sum of squares and the cross terms.
      have h_expand : ∑ i, (invStereoN y i - invStereoN z i) ^ 2 = ∑ i, (invStereoN y i) ^ 2 - 2 * ∑ i, invStereoN y i * invStereoN z i + ∑ i, (invStereoN z i) ^ 2 := by
        simp +decide only [sub_sq, mul_assoc, sum_add_distrib, sum_sub_distrib, Finset.mul_sum _ _ _];
      linarith [ invStereoN_norm_sq y, invStereoN_norm_sq z ]



end
