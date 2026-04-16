/-! # CatalogBuild.Speculative.OISCC.V11_HessianGeometry

Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 14
-/

import Mathlib

noncomputable section

def f_hess (x : ℝ) : ℝ := Real.exp x - Real.log x - 1

def f_hess_deriv (x : ℝ) : ℝ := Real.exp x - x⁻¹

def g_metric (x : ℝ) : ℝ := Real.exp x + x⁻¹ ^ 2


theorem f_hess_hasDerivAt (x : ℝ) (hx : 0 < x) :
    HasDerivAt f_hess (f_hess_deriv x) x := by
  unfold f_hess f_hess_deriv
  convert ((Real.hasDerivAt_exp x).sub (Real.hasDerivAt_log hx.ne')).sub
    (hasDerivAt_const x (1 : ℝ)) using 1; ring


theorem g_metric_pos (x : ℝ) (hx : 0 < x) : g_metric x > 0 := by
  unfold g_metric; positivity


theorem g_metric_ge_one (x : ℝ) (hx : 0 < x) : g_metric x ≥ 1 := by
  unfold g_metric
  have : Real.exp x ≥ 1 := Real.one_le_exp (le_of_lt hx)
  linarith [sq_nonneg x⁻¹]


theorem g_metric_ge_exp (x : ℝ) : g_metric x ≥ Real.exp x := by
  unfold g_metric; linarith [sq_nonneg x⁻¹]


theorem eta_strictMono : StrictMonoOn eta (Ioi 0) := by
  exact fun x _ y _ hxy => sub_lt_sub ( Real.exp_lt_exp.mpr hxy ) ( inv_strictAnti₀ ( by linarith [ Set.mem_Ioi.mp ‹x ∈ Set.Ioi 0› ] ) hxy )


/-- The Bregman divergence of f. -/
def B_hess (x y : ℝ) : ℝ := f_hess x - f_hess y - f_hess_deriv y * (x - y)


theorem B_hess_self (x : ℝ) : B_hess x x = 0 := by
  unfold B_hess; ring


theorem B_hess_nonneg (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    B_hess x y ≥ 0 := by
  unfold B_hess f_hess f_hess_deriv;
  -- We'll use the exponential property to simplify the expression. Note that $e^x \geq e^y + e^y(x - y)$ for all $x, y \in \mathbb{R}$.
  have h_exp : Real.exp x ≥ Real.exp y + Real.exp y * (x - y) := by
    have := Real.add_one_le_exp ( x - y ) ; ( rw [ Real.exp_sub ] at *; nlinarith [ Real.exp_pos y, mul_div_cancel₀ ( Real.exp x ) ( ne_of_gt ( Real.exp_pos y ) ) ] ; );
  -- We'll use the logarithmic property to simplify the expression. Note that $\log x \leq \log y + \frac{x - y}{y}$ for all $x, y \in \mathbb{R}$.
  have h_log : Real.log x ≤ Real.log y + (x - y) / y := by
    rw [ Real.log_le_iff_le_exp ( by positivity ) ];
    rw [ Real.exp_add, Real.exp_log hy ];
    nlinarith [ Real.add_one_le_exp ( ( x - y ) / y ), mul_div_cancel₀ ( x - y ) hy.ne' ];
  ring_nf at *; nlinarith [ inv_pos.mpr hy, mul_inv_cancel₀ hy.ne' ] ;


theorem B_hess_eq_zero_iff (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    B_hess x y = 0 ↔ x = y := by
  -- Apply the Taylor expansion for the natural logarithm function.
  have h_log_taylor : ∀ y : ℝ, 0 < y → ∀ x : ℝ, 0 < x → Real.log x ≤ Real.log y + (x - y) / y := by
    intro y hy x hx; rw [ Real.log_le_iff_le_exp ( by positivity ) ] ; rw [ Real.exp_add, Real.exp_log hy ] ; ring_nf;
    nlinarith [ Real.add_one_le_exp ( - ( y * y⁻¹ ) + x * y⁻¹ ), mul_inv_cancel₀ hy.ne' ];
  -- Apply the strict convexity of the exponential function.
  have h_exp_strict_convex : ∀ y : ℝ, 0 < y → ∀ x : ℝ, 0 < x → x ≠ y → Real.exp x > Real.exp y + Real.exp y * (x - y) := by
    intro y hy x hx hxy; rw [ show x = y + ( x - y ) by ring, Real.exp_add ] ;
    nlinarith [ Real.exp_pos y, Real.exp_pos ( x - y ), Real.add_one_lt_exp ( show x - y ≠ 0 by contrapose! hxy; linarith ) ];
  unfold B_hess;
  unfold f_hess f_hess_deriv; constructor;
  · grind;
  · grind +revert


/-- The Pythagorean theorem for the Bregman divergence. -/
theorem bregman_pythagorean (x y z : ℝ) :
    B_hess x z = B_hess x y + B_hess y z + (f_hess_deriv y - f_hess_deriv z) * (x - y) := by
  simp [B_hess]; ring


/-- The three-point identity. -/
theorem bregman_three_point (x y z : ℝ) :
    B_hess x z - B_hess x y - B_hess y z = (f_hess_deriv y - f_hess_deriv z) * (x - y) := by
  simp [B_hess]; ring


end
