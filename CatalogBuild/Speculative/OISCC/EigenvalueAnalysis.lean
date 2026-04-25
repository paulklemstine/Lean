/-! # CatalogBuild.Speculative.OISCC.EigenvalueAnalysis

Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 14
-/

import Mathlib

noncomputable section

/-- The larger eigenvalue on the diagonal. -/
def lambda_plus (x : ℝ) : ℝ := Real.exp x + x⁻¹


/-- The smaller eigenvalue on the diagonal. -/
def lambda_minus (x : ℝ) : ℝ := Real.exp x - x⁻¹


/-- The eigenvalue gap. -/
def eigenvalue_gap (x : ℝ) : ℝ := lambda_plus x - lambda_minus x


/-- λ+ > 0 for x > 0. -/
theorem lambda_plus_pos (x : ℝ) (hx : 0 < x) : lambda_plus x > 0 := by
  unfold lambda_plus; positivity


/-- λ+ > exp(x) for x > 0. -/
theorem lambda_plus_gt_exp (x : ℝ) (hx : 0 < x) :
    lambda_plus x > Real.exp x := by
  unfold lambda_plus; linarith [inv_pos.mpr hx]


/-- [Section: # CatalogBuild.Speculative.OISCC.EigenvalueAnalysis
Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 14] -/
theorem lambda_minus_pos (x : ℝ) (hx : 1 ≤ x) : lambda_minus x > 0 := by
  unfold lambda_minus;
  nlinarith [ inv_mul_cancel₀ ( by linarith : x ≠ 0 ), Real.add_one_le_exp x ]


/-- The eigenvalue gap is 2/x. -/
theorem eigenvalue_gap_eq (x : ℝ) : eigenvalue_gap x = 2 * x⁻¹ := by
  unfold eigenvalue_gap lambda_plus lambda_minus; ring


/-- The eigenvalue gap is positive for x > 0. -/
theorem eigenvalue_gap_pos (x : ℝ) (hx : 0 < x) : eigenvalue_gap x > 0 := by
  rw [eigenvalue_gap_eq]; positivity


/-- The eigenvalue sum equals 2·exp(x) (= trace). -/
theorem eigenvalue_sum_eq (x : ℝ) :
    eigenvalue_sum x = 2 * Real.exp x := by
  unfold eigenvalue_sum lambda_plus lambda_minus; ring


/-- The eigenvalue product = exp(x)² - 1/x² (= determinant). -/
theorem eigenvalue_product_eq (x : ℝ) :
    eigenvalue_product x = Real.exp x ^ 2 - x⁻¹ ^ 2 := by
  unfold eigenvalue_product lambda_plus lambda_minus; ring


theorem eigenvalue_product_pos (x : ℝ) (hx : 1 ≤ x) :
    eigenvalue_product x > 0 := by
  refine' ( eigenvalue_product_eq x ▸ sub_pos_of_lt _ );
  gcongr;
  exact lt_of_le_of_lt ( inv_le_one_of_one_le₀ hx ) ( by norm_num; linarith )


/-- The discriminant on the diagonal is 4/x². -/
theorem discriminant_diag (x : ℝ) :
    (eigenvalue_sum x) ^ 2 - 4 * eigenvalue_product x = 4 * x⁻¹ ^ 2 := by
  rw [eigenvalue_sum_eq, eigenvalue_product_eq]; ring


/-- λ+ ≥ λ- always for x > 0. -/
theorem lambda_plus_ge_minus (x : ℝ) (hx : 0 < x) :
    lambda_plus x ≥ lambda_minus x := by
  have := eigenvalue_gap_pos x hx
  unfold eigenvalue_gap at this
  linarith


theorem lambda_plus_orbit_growth (x : ℝ) (hx : 1 ≤ x) :
    lambda_plus (Real.exp x - Real.log x) > lambda_plus x := by
  unfold lambda_plus;
  -- Since $d(x) > x$, we have $\exp(d(x)) > \exp(x)$.
  have h_exp : Real.exp (Real.exp x - Real.log x) > Real.exp (x + 1) := by
    gcongr;
    rw [ show Real.exp x = Real.exp ( x - 1 ) * Real.exp 1 by rw [ ← Real.exp_add ] ; ring ];
    have := Real.log_le_sub_one_of_pos ( by linarith : 0 < x );
    nlinarith [ Real.add_one_le_exp ( x - 1 ), Real.add_one_lt_exp one_ne_zero ];
  norm_num [ Real.exp_add, Real.exp_log ( zero_lt_one.trans_le hx ) ] at h_exp;
  nlinarith [ inv_pos.mpr ( show 0 < Real.exp x - Real.log x by linarith [ Real.add_one_le_exp x, Real.log_le_sub_one_of_pos ( show 0 < x by linarith ) ] ), inv_pos.mpr ( show 0 < x by linarith ), mul_inv_cancel₀ ( ne_of_gt ( show 0 < Real.exp x - Real.log x by linarith [ Real.add_one_le_exp x, Real.log_le_sub_one_of_pos ( show 0 < x by linarith ) ] ) ), mul_inv_cancel₀ ( ne_of_gt ( show 0 < x by linarith ) ), Real.add_one_le_exp x, Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos ( show 0 < x by linarith ) ]


end
