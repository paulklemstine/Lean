/-! # CatalogBuild.Computation.Other.InformationBounds

Auto-generated from theorem catalog database.
Domain: Computation/Other
Declarations: 4
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.Other.InformationBounds
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 4] -/
theorem binaryEntropy_max :
    ∀ p : ℝ, 0 ≤ p → p ≤ 1 → binaryEntropy p ≤ binaryEntropy (1/2) := by
  unfold binaryEntropy; norm_num;
  intro p hp hp'; split_ifs <;> norm_num at *;
  · exact mul_nonpos_of_nonneg_of_nonpos ( by norm_num ) ( Real.log_nonpos ( by norm_num ) ( by norm_num ) );
  · have := @Real.geom_mean_le_arith_mean;
    specialize this { 0, 1 } ( fun i => if i = 0 then 1 - p else p ) ( fun i => if i = 0 then 1 / ( 1 - p ) else 1 / p ) ; norm_num at *;
    have := this hp' hp hp' hp; rw [ Real.rpow_def_of_pos ( inv_pos.mpr ( by linarith ) ), Real.rpow_def_of_pos ( inv_pos.mpr ( by linarith ) ) ] at this; norm_num at *;
    rw [ ← Real.exp_add ] at this ; norm_num [ Real.log_div, show p ≠ 0 by linarith, show ( 1 - p ) ≠ 0 by linarith ] at *;
    have := Real.log_le_log ( by positivity ) this ; norm_num at this ; linarith [ Real.log_exp ( - ( Real.log ( 1 - p ) * ( 1 - p ) ) + - ( Real.log p * p ) ) ]


/-- Shannon entropy of a distribution. -/
def ProbDist.entropy {n : ℕ} (d : ProbDist n) : ℝ :=
  -∑ i : Fin n, if d.prob i = 0 then 0 else d.prob i * Real.log (d.prob i)


/-- The minimax detection probability for a uniform game is 1/n. -/
theorem minimax_detection_value {n : ℕ} (hn : 2 ≤ n) :
    (1 : ℝ) / n > 0 := by positivity


/-- [Section: # CatalogBuild.Speculative.Other.InformationBounds
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 4] -/
theorem infinite_horizon_optimal {n : ℕ} (hn : 2 ≤ n) (d : ProbDist n) :
    ∃ target : Fin n, 1 - d.prob target ≥ 1 - 1 / (n : ℝ) := by
  by_contra h;
  -- By assumption, $d.prob i > 1/n$ for all $i$.
  have h_all_gt : ∀ i : Fin n, d.prob i > 1 / (n : ℝ) := by
    grind;
  have := Finset.sum_lt_sum_of_nonempty ⟨ ⟨ 0, by linarith ⟩, Finset.mem_univ _ ⟩ fun i hi => h_all_gt i; simp_all +decide [ Finset.sum_const, nsmul_eq_mul ] ;
  rw [ mul_inv_cancel₀ ( by positivity ), d.prob_sum ] at this ; linarith


end
