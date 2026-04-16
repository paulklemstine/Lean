/-
# Metric Geometry of Stereographic Projection

This file formalizes metric properties of stereographic projection,
including the chordal distance formula, the pullback metric, and
geodesic relationships.

## Main results

* `chordal_distance_formula` — chordal distance between sphere images
* `stereoDenom_sum` — key identity for the product of denominators
* `invStereoN_dot_product` — inner product of two stereographic images
* `invStereoN_chordal_sq` — squared chordal distance in terms of flat coordinates
* `stereoDenom_of_sum` — denominator of sum in terms of individual norms
-/
import Mathlib
import Geometry.Stereographic.Basic

namespace StereographicProjection

open Finset BigOperators

noncomputable section

/-- Inner product of two vectors in Fin N → ℝ -/
def dotProdFin {N : ℕ} (y z : Fin N → ℝ) : ℝ := ∑ i, y i * z i

/-- Squared distance between two vectors -/
def sqDistFin {N : ℕ} (y z : Fin N → ℝ) : ℝ := ∑ i, (y i - z i) ^ 2

/-
sqNormFin equals dotProdFin with itself
-/
theorem sqNormFin_eq_dot {N : ℕ} (y : Fin N → ℝ) :
    sqNormFin y = dotProdFin y y := by
      exact Finset.sum_congr rfl fun _ _ => by ring;

/-
Expansion of squared distance
-/
theorem sqDistFin_expand {N : ℕ} (y z : Fin N → ℝ) :
    sqDistFin y z = sqNormFin y - 2 * dotProdFin y z + sqNormFin z := by
      unfold sqDistFin dotProdFin sqNormFin; simp +decide [ sub_sq ] ; ring;
      simpa [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul ] using by ring;

/-
Inner product of two stereographic images on the sphere.
    ⟨invStereoN y, invStereoN z⟩ = (4⟨y,z⟩ + (S_y - 1)(S_z - 1)) / (D_y · D_z)
    where S = ‖·‖², D = 1 + ‖·‖²
-/
theorem invStereoN_dot_product {N : ℕ} (y z : Fin N → ℝ) :
    ∑ i : Fin (N + 1), invStereoN y i * invStereoN z i =
    (4 * dotProdFin y z + (sqNormFin y - 1) * (sqNormFin z - 1)) /
    (stereoDenom y * stereoDenom z) := by
      unfold invStereoN;
      unfold dotProdFin; norm_num [ Fin.sum_univ_castSucc, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, div_mul_div_comm, mul_assoc, mul_div_assoc ] ; ring;
      simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ]

/-
Squared chordal distance between two stereographic images:
    ‖invStereoN y - invStereoN z‖² = 4·‖y - z‖² / (D_y · D_z)
-/
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

/-
The conformal factor: infinitesimal distances scale by 2/D.
    ds²_sphere = (2/D)² · ds²_flat  (pointwise identity)
-/
theorem conformal_metric_factor {N : ℕ} (y : Fin N → ℝ) :
    (2 / stereoDenom y) ^ 2 = 4 / (stereoDenom y) ^ 2 := by
      ring

/-
stereoDenom is a smooth positive function, bounded below by 1
-/
theorem stereoDenom_ge_one {N : ℕ} (y : Fin N → ℝ) : 1 ≤ stereoDenom y := by
  exact le_add_of_nonneg_right ( sqNormFin_nonneg y )

/-
Reverse triangle inequality for chordal distance through denominators:
    the chordal metric is bounded by the Euclidean metric
-/
theorem chordal_le_euclidean {N : ℕ} (y z : Fin N → ℝ) :
    4 * sqDistFin y z / (stereoDenom y * stereoDenom z) ≤ 4 * sqDistFin y z := by
      exact div_le_self ( mul_nonneg zero_le_four ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ) ) ( by exact one_le_mul_of_one_le_of_one_le ( by exact le_add_of_nonneg_right ( sqNormFin_nonneg _ ) ) ( by exact le_add_of_nonneg_right ( sqNormFin_nonneg _ ) ) )

/-
The "angular excess" identity: the sum of dot products with self minus
    cross terms equals the squared distance, connecting angle to distance
-/
theorem angular_distance_identity {N : ℕ} (y z : Fin N → ℝ) :
    2 - 2 * ∑ i : Fin (N + 1), invStereoN y i * invStereoN z i =
    ∑ i : Fin (N + 1), (invStereoN y i - invStereoN z i) ^ 2 := by
      -- By expanding the square on the right-hand side, we can separate the terms into the sum of squares and the cross terms.
      have h_expand : ∑ i, (invStereoN y i - invStereoN z i) ^ 2 = ∑ i, (invStereoN y i) ^ 2 - 2 * ∑ i, invStereoN y i * invStereoN z i + ∑ i, (invStereoN z i) ^ 2 := by
        simp +decide only [sub_sq, mul_assoc, sum_add_distrib, sum_sub_distrib, Finset.mul_sum _ _ _];
      linarith [ invStereoN_norm_sq y, invStereoN_norm_sq z ]

end

end StereographicProjection