/-! # CatalogBuild.EML.V12.TaylorApproximation

Auto-generated from theorem catalog database.
Domain: EML/V12
Declarations: 16
-/

import Mathlib

noncomputable section

/-- σ(0) = 1. -/
theorem sigma_taylor_0 : emlSelfPair 0 = 1 := by
  unfold emlSelfPair; simp


/-- σ(x) − 1 = eˣ − 1 − x. -/
theorem sigma_taylor_error_1 (x : ℝ) :
    emlSelfPair x - 1 = Real.exp x - 1 - x := by
  unfold emlSelfPair; ring


/-- [Section: ## Section 1: Taylor Values] -/
theorem sigma_ge_taylor2_nonneg (x : ℝ) (hx : 0 ≤ x) :
    emlSelfPair x ≥ 1 + x ^ 2 / 2 := by
      unfold emlSelfPair;
      -- We'll use the exponential property: $e^x \geq 1 + x + \frac{x^2}{2}$ for $x \geq 0$.
      have h_exp : ∀ x : ℝ, 0 ≤ x → Real.exp x ≥ 1 + x + x^2 / 2 := by
        exact?;
      linarith [ h_exp x hx ]


theorem sigma_taylor2_fails_neg :
    ¬(∀ x : ℝ, emlSelfPair x ≥ 1 + x ^ 2 / 2) := by
      simp +zetaDelta at *;
      use -1; norm_num [ emlSelfPair ] ;
      have := Real.exp_neg_one_lt_d9 ; norm_num at * ; linarith


theorem sigma_ge_taylor3_nonneg (x : ℝ) (hx : 0 ≤ x) :
    emlSelfPair x ≥ 1 + x ^ 2 / 2 + x ^ 3 / 6 := by
      -- We start with the inequality for $x \ge 0$: $\exp(x) ≥ 1 + x + x^2 / 2 + x^3 / 6$.
      have exp_ge_sum : Real.exp x ≥ 1 + x + x ^ 2 / 2 + x ^ 3 / 6 := by
        have h_exp_ineq : ∀ x : ℝ, 0 ≤ x → Real.exp x ≥ ∑ k ∈ Finset.range 4, x^k / Nat.factorial k := by
          exact fun x hx => by rw [ Real.exp_eq_exp_ℝ ] ; rw [ NormedSpace.exp_eq_tsum_div ] ; exact Summable.sum_le_tsum ( Finset.range 4 ) ( fun _ _ => by positivity ) ( by simpa using Real.summable_pow_div_factorial x ) ;
        exact le_trans ( by norm_num [ Finset.sum_range_succ, Nat.factorial ] ) ( h_exp_ineq x hx );
      unfold emlSelfPair; linarith;


/-- For x ≤ 0: σ(x) ≤ 1 − x. -/
theorem sigma_le_one_minus_x (x : ℝ) (hx : x ≤ 0) :
    emlSelfPair x ≤ 1 - x := by
  unfold emlSelfPair; linarith [Real.exp_le_one_iff.mpr hx]


/-- For x ≤ 0: σ(x) ≤ 1 + |x|. -/
theorem sigma_upper_neg (x : ℝ) (hx : x ≤ 0) :
    emlSelfPair x ≤ 1 + |x| := by
  rw [abs_of_nonpos hx]; exact sigma_le_one_minus_x x hx


/-- σ and 1 + x²/2 agree at x = 0. -/
theorem sigma_vs_quad_at_zero :
    emlSelfPair 0 = 1 + (0:ℝ)^2/2 := by
  unfold emlSelfPair; simp


/-- σ(x) − (1 + x²/2) = exp(x) − 1 − x − x²/2. -/
theorem sigma_minus_quad (x : ℝ) :
    emlSelfPair x - (1 + x^2/2) = Real.exp x - 1 - x - x^2/2 := by
  unfold emlSelfPair; ring


/-- eml(0,1) = 1 (the base point). -/
theorem eml_base : eml 0 1 = 1 := by
  simp [eml, Real.log_one]


/-- At (0,1), the partial derivatives give: eml(h, 1) − eml(0,1) = exp(h) − 1. -/
theorem eml_linear_approx_x (h : ℝ) :
    eml h 1 - eml 0 1 = Real.exp h - 1 := by
  simp [eml, Real.log_one]


/-- exp(x) − 1 − x ≥ 0 for all x. -/
theorem exp_minus_linear_nonneg (x : ℝ) : Real.exp x - 1 - x ≥ 0 := by
  linarith [Real.add_one_le_exp x]


/-- [Section: ## Section 5: Exponential Remainder] -/
theorem exp_minus_linear_zero_iff (x : ℝ) :
    Real.exp x - 1 - x = 0 ↔ x = 0 := by
      exact ⟨ fun h => by contrapose! h; linarith [ Real.add_one_lt_exp ( show x ≠ 0 by aesop ) ], fun h => by norm_num [ h ] ⟩


/-- σ(x) − 1 = exp(x) − 1 − x (the remainder). -/
theorem sigma_remainder (x : ℝ) :
    emlSelfPair x - 1 = Real.exp x - 1 - x :=
  sigma_taylor_error_1 x


/-- d(0) = 1. -/
theorem emlDiag_at_zero : emlDiag 0 = 1 := by
  simp [emlDiag, Real.log_zero]


/-- d(z) ≥ 1 + z − log(z) for z > 0. -/
theorem emlDiag_lower (z : ℝ) (_hz : 0 < z) :
    emlDiag z ≥ 1 + z - Real.log z := by
  unfold emlDiag; linarith [Real.add_one_le_exp z]


end
