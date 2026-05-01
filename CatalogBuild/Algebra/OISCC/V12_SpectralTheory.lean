/-! # CatalogBuild.Algebra.OISCC.V12_SpectralTheory

Auto-generated from theorem catalog database.
Domain: Algebra/OISCC
Declarations: 14
-/

import Mathlib

noncomputable section

/-- The EML map. -/
def EML_sp (a b : ℝ) : ℝ := Real.exp a - Real.log b


/-- Trace of the Jacobian at (x,y): tr(J) = exp(x) + exp(y). -/
def jacobian_trace (x y : ℝ) : ℝ := Real.exp x + Real.exp y


/-- Determinant of the Jacobian: det(J) = exp(x)·exp(y) - 1/(xy). -/
def jacobian_det (x y : ℝ) : ℝ := Real.exp x * Real.exp y - (x * y)⁻¹


/-- The discriminant: Δ = tr² - 4·det. -/
def jacobian_disc (x y : ℝ) : ℝ :=
  jacobian_trace x y ^ 2 - 4 * jacobian_det x y


/-- [Section: # CatalogBuild.Speculative.OISCC.V12_SpectralTheory
Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 14] -/
theorem jacobian_trace_ge_two (x y : ℝ) (hx : 0 ≤ x) (hy : 0 ≤ y) :
    jacobian_trace x y ≥ 2 := by
  exact le_trans ( by norm_num ) ( add_le_add ( Real.one_le_exp hx ) ( Real.one_le_exp hy ) )


/-- [Section: # CatalogBuild.Speculative.OISCC.V12_SpectralTheory
Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 14] -/
theorem jacobian_trace_gt_two (x y : ℝ) (hx : 0 < x) (hy : 0 ≤ y) :
    jacobian_trace x y > 2 := by
  exact lt_of_le_of_lt ( by norm_num ) ( add_lt_add_of_lt_of_le ( Real.exp_lt_exp.mpr ( show x > 0 by linarith ) ) ( Real.one_le_exp ( show y ≥ 0 by linarith ) ) )


theorem jacobian_det_pos (x y : ℝ) (hx : 1 ≤ x) (hy : 1 ≤ y) :
    jacobian_det x y > 0 := by
  -- For x,y ≥ 1, we have exp(x+y) ≥ exp(2) > e² > 7 > 1 ≥ 1/(xy). Hence, det = exp(x+y) - 1/(xy) ≥ exp(2) - 1 > 0.
  have h_exp_xy : Real.exp (x + y) > 7 := by
    -- Since $x \geq 1$ and $y \geq 1$, we have $x + y \geq 2$. Therefore, $\exp(x + y) \geq \exp(2)$.
    have h_exp_xy_ge_exp2 : Real.exp (x + y) ≥ Real.exp 2 := by
      exact Real.exp_le_exp.mpr ( by linarith );
    exact lt_of_lt_of_le ( by have := Real.exp_one_gt_d9.le; norm_num1 at *; rw [ show ( 2:ℝ ) = 1+1 by norm_num, Real.exp_add ] ; nlinarith [ Real.add_one_le_exp 1 ] ) h_exp_xy_ge_exp2;
  unfold jacobian_det;
  rw [ ← Real.exp_add ] ; nlinarith [ inv_mul_cancel₀ ( by positivity : ( x * y ) ≠ 0 ), mul_le_mul_of_nonneg_left hy ( sub_nonneg.2 hx ) ]


theorem jacobian_det_formula (x y : ℝ) :
    jacobian_det x y = Real.exp (x + y) - (x * y)⁻¹ := by
  unfold jacobian_det; rw [ Real.exp_add ] ;


theorem jacobian_trace_after_step (x y : ℝ) :
    jacobian_trace (EML_sp x y) (EML_sp y x) =
    Real.exp (Real.exp x - Real.log y) + Real.exp (Real.exp y - Real.log x) := by
  rfl


theorem trace_growth (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    jacobian_trace (EML_sp x y) (EML_sp y x) =
    Real.exp (Real.exp x) / y + Real.exp (Real.exp y) / x := by
  unfold EML_sp jacobian_trace; ring;
  rw [ Real.exp_sub, Real.exp_sub, Real.exp_log hy, Real.exp_log hx ];
  ring


theorem jacobian_trace_diag (x : ℝ) : jacobian_trace x x = 2 * Real.exp x := by
  unfold jacobian_trace; ring;


theorem jacobian_det_diag (x : ℝ) :
    jacobian_det x x = Real.exp (2 * x) - x⁻¹ ^ 2 := by
  unfold jacobian_det; rw [ two_mul, Real.exp_add ] ; ring;


theorem spectral_lower_bound_diag (x : ℝ) (hx : 1 ≤ x) :
    jacobian_trace x x / 2 ≥ Real.exp x := by
  unfold jacobian_trace; linarith


theorem trace_after_step_diag (x : ℝ) (hx : 0 < x) :
    jacobian_trace (EML_sp x x) (EML_sp x x) =
    2 * Real.exp (Real.exp x) / x := by
  convert trace_growth _ _ ?_ hx using 1;
  · ring;
  · positivity


end
