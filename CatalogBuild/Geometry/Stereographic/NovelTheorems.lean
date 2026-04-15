/-! # CatalogBuild.Geometry.Stereographic.NovelTheorems

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 9
-/

import Geometry.Stereographic.NDimResearch.Basic
import Mathlib

noncomputable section

theorem conformal_factor_eq_one_minus_last (N : ℕ) (y : Fin N → ℝ) :
    2 / stereoDenom N y =
    1 - invStereoN N y ⟨N, Nat.lt_succ_iff.mpr le_rfl⟩ := by
  unfold invStereoN;
  split_ifs <;> norm_num [ stereoDenom ];
  · grind +extAll;
  · rw [ one_sub_div ] <;> ring ; linarith [ show 0 ≤ sqNorm N y from Finset.sum_nonneg fun _ _ => sq_nonneg _ ]


theorem conformal_factor_sq_times_sqNorm (N : ℕ) (y : Fin N → ℝ) :
    (2 / stereoDenom N y) ^ 2 * sqNorm N y =
    ∑ i : Fin N, (invStereoN N y ⟨i, Nat.lt_succ_of_lt i.isLt⟩) ^ 2 := by
  unfold invStereoN;
  unfold stereoDenom sqNorm; norm_num [ Finset.mul_sum _ _ _, mul_pow, mul_assoc, mul_comm, mul_left_comm, div_pow ] ;
  exact Finset.sum_congr rfl fun _ _ => by ring;


theorem invStereoN_neg_first_coords (N : ℕ) (y : Fin N → ℝ) (i : Fin (N + 1))
    (hi : (i : ℕ) < N) :
    invStereoN N (fun j => -(y j)) i = -(invStereoN N y i) := by
  unfold invStereoN;
  unfold stereoDenom; simp +decide [ hi, hi, div_neg, neg_div ];
  unfold sqNorm; norm_num;


theorem invStereoN_neg_last_coord (N : ℕ) (y : Fin N → ℝ) :
    invStereoN N (fun j => -(y j)) ⟨N, Nat.lt_succ_iff.mpr le_rfl⟩ =
    invStereoN N y ⟨N, Nat.lt_succ_iff.mpr le_rfl⟩ := by
  unfold invStereoN;
  unfold stereoDenom sqNorm; norm_num [ Finset.sum_neg_distrib ] ;


theorem invStereoN_scale_last (N : ℕ) (y : Fin N → ℝ) (r : ℝ) :
    invStereoN N (fun j => r * y j) ⟨N, Nat.lt_succ_iff.mpr le_rfl⟩ =
    (r ^ 2 * sqNorm N y - 1) / (1 + r ^ 2 * sqNorm N y) := by
  norm_num [ invStereoN ];
  unfold sqNorm stereoDenom;
  simp only [mul_pow, sqNorm, Finset.mul_sum _ _ _]


theorem energy_partition (N : ℕ) (y : Fin N → ℝ) :
    (∑ i : Fin N, (invStereoN N y ⟨i, Nat.lt_succ_of_lt i.isLt⟩) ^ 2) +
    (invStereoN N y ⟨N, Nat.lt_succ_iff.mpr le_rfl⟩) ^ 2 = 1 := by
  convert invStereoN_norm_sq N y using 1;
  refine' Eq.symm ( Fin.sum_univ_castSucc _ )


/-- The general N-dimensional Pythagorean identity using Fin-indexed sums:
(∑ (2·yᵢ)²) + (‖y‖² - 1)² = (‖y‖² + 1)². -/
theorem pythagorean_stereo_general (N : ℕ) (y : Fin N → ℝ) :
    4 * sqNorm N y + (sqNorm N y - 1) ^ 2 = (sqNorm N y + 1) ^ 2 := by
  unfold sqNorm; ring


theorem rotation_preserves_sqNorm (N : ℕ) (R : Fin N → Fin N → ℝ)
    (hR : ∀ i j : Fin N, ∑ k, R i k * R j k = if i = j then 1 else 0)
    (y : Fin N → ℝ) :
    sqNorm N (fun i => ∑ j, R i j * y j) = sqNorm N y := by
  -- Using the symmetry of R, we can rewrite the double sum as a dot product.
  have h_dot_product : ∑ i, (∑ j, R i j * y j) ^ 2 = ∑ j, ∑ k, y j * y k * (∑ i, R i j * R i k) := by
    simp +decide only [sq, Finset.mul_sum _ _ _, mul_comm, mul_left_comm];
    exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_comm );
  convert h_dot_product using 1;
  -- By the orthogonality condition, we know that $\sum_{i} R_{ij} R_{ik} = \delta_{jk}$, where $\delta_{jk}$ is the Kronecker delta.
  have h_orthogonality : ∀ j k, ∑ i, R i j * R i k = if j = k then 1 else 0 := by
    -- Apply the given hypothesis `hR` to rewrite the inner sum.
    have h_inner_sum : ∀ j k, ∑ i, R i j * R i k = ∑ i, R j i * R k i := by
      intro j k;
      convert mul_eq_one_comm.mp ( show Matrix.of ( fun i j => R i j ) * Matrix.of ( fun i j => R j i ) = 1 from Matrix.ext fun i j => by simpa [ Matrix.mul_apply, mul_comm ] using hR i j ) |> congr_arg ( fun m => m k j ) using 1;
      · simp +decide [ Matrix.mul_apply, mul_comm ];
      · simpa [ mul_comm, Matrix.one_apply, eq_comm ] using hR j k;
    aesop;
  simp +decide [ h_orthogonality, sqNorm ];
  exact Finset.sum_congr rfl fun _ _ => sq _


theorem invStereoN_inversion_last (N : ℕ) (y : Fin N → ℝ)
    (hy : sqNorm N y ≠ 0) :
    invStereoN N (fun j => y j / sqNorm N y) ⟨N, Nat.lt_succ_iff.mpr le_rfl⟩ =
    -(invStereoN N y ⟨N, Nat.lt_succ_iff.mpr le_rfl⟩) := by
  simp +decide [ invStereoN, sqNorm ] at hy ⊢;
  unfold stereoDenom; norm_num [ ← Finset.sum_div _ _ _, hy ] ;
  unfold sqNorm; norm_num [ Finset.sum_div _ _ _, div_pow, hy ] ; ring;
  norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hy ] ; ring;
  grind


end
