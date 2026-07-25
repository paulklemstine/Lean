import Mathlib

/-! # CatalogBuild.Speculative.OISCC.V12_VariationalPrinciples

Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 15
-/

noncomputable section

/-- The EML potential. -/
def f_var (x : ℝ) : ℝ := Real.exp x - Real.log x - 1

/-- The Riemannian metric. -/
def g_var (x : ℝ) : ℝ := Real.exp x + x⁻¹ ^ 2

/-- The "kinetic energy" in the EML metric. -/
def kinetic (x v : ℝ) : ℝ := g_var x * v ^ 2 / 2

/-- The EML Lagrangian. -/
def lagrangian (x v : ℝ) : ℝ := kinetic x v - f_var x

/-- [Section: # CatalogBuild.Speculative.OISCC.V12_VariationalPrinciples
Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 15] -/
theorem f_var_ge_one (x : ℝ) (hx : 0 < x) : f_var x ≥ 1 := by
  unfold f_var;
  nlinarith [ Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx ]

theorem f_var_pos (x : ℝ) (hx : 0 < x) : f_var x > 0 := by
  have := f_var_ge_one x hx
  linarith

theorem g_var_pos (x : ℝ) (hx : 0 < x) : g_var x > 0 := by
  exact add_pos_of_pos_of_nonneg ( Real.exp_pos _ ) ( sq_nonneg _ )

theorem kinetic_nonneg (x v : ℝ) (hx : 0 < x) : kinetic x v ≥ 0 := by
  exact div_nonneg ( mul_nonneg ( le_of_lt ( g_var_pos x hx ) ) ( sq_nonneg v ) ) zero_le_two

theorem kinetic_eq_zero_iff (x v : ℝ) (hx : 0 < x) :
    kinetic x v = 0 ↔ v = 0 := by
  unfold kinetic;
  norm_num [ g_var ];
  exact fun h => absurd h <| by positivity;

theorem lagrangian_at_rest (x : ℝ) (hx : 0 < x) :
    lagrangian x 0 = -f_var x := by
  unfold lagrangian kinetic f_var g_var; ring;

theorem lagrangian_at_rest_neg (x : ℝ) (hx : 0 < x) :
    lagrangian x 0 < 0 := by
  linarith [ lagrangian_at_rest x hx, f_var_pos x hx ]

/-- The "total energy" E = K + f is always ≥ 1 (positive energy theorem). -/
def total_energy (x v : ℝ) : ℝ := kinetic x v + f_var x

theorem total_energy_ge_one (x v : ℝ) (hx : 0 < x) :
    total_energy x v ≥ 1 := by
  exact le_add_of_nonneg_of_le ( kinetic_nonneg x v hx ) ( f_var_ge_one x hx )

theorem f_var_convexOn : ConvexOn ℝ (Ioi 0) f_var := by
  apply_rules [ convexOn_of_deriv2_nonneg, convex_Ioi ];
  · exact continuousOn_of_forall_continuousAt fun x hx => by exact ContinuousAt.sub ( ContinuousAt.sub ( Real.continuous_exp.continuousAt ) ( Real.continuousAt_log hx.out.ne' ) ) continuousAt_const;
  · exact DifferentiableOn.sub ( DifferentiableOn.exp differentiableOn_id ) ( DifferentiableOn.log differentiableOn_id fun x hx => ne_of_gt <| interior_subset hx ) |> DifferentiableOn.sub <| differentiableOn_const _;
  · -- The first derivative of $f(x)$ is $f'(x) = e^x - \frac{1}{x}$.
    have h_deriv : ∀ x ∈ Set.Ioi 0, deriv f_var x = Real.exp x - 1 / x := by
      intro x hx; unfold f_var; norm_num [ Real.differentiableAt_exp, hx.out.ne' ] ;
    exact DifferentiableOn.congr ( by exact DifferentiableOn.sub ( DifferentiableOn.exp differentiableOn_id ) ( DifferentiableOn.div ( differentiableOn_const _ ) differentiableOn_id fun x hx => ne_of_gt <| interior_subset hx ) ) fun x hx => h_deriv x <| interior_subset hx;
  · have h_deriv2 : ∀ x > 0, deriv^[2] (fun x => Real.exp x - Real.log x - 1) x = Real.exp x + 1 / x^2 := by
      have h_deriv2 : ∀ x > 0, deriv^[2] (fun x => Real.exp x - Real.log x - 1) x = deriv (fun x => Real.exp x - 1 / x) x := by
        exact fun x x_pos => Filter.EventuallyEq.deriv_eq ( by filter_upwards [ lt_mem_nhds x_pos ] with y hy using by norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, hy.ne' ] );
      intro x hx; rw [ h_deriv2 x hx ] ; norm_num [ Real.differentiableAt_exp, differentiableAt_inv, hx.ne' ];
    exact fun x hx => h_deriv2 x ( interior_subset hx ) ▸ add_nonneg ( Real.exp_nonneg x ) ( one_div_nonneg.mpr ( sq_nonneg x ) )

theorem f_var_orbit_growth (x : ℝ) (hx : 0 < x) :
    f_var (Real.exp x - Real.log x) > f_var x := by
  unfold f_var;
  -- Let $y = \exp(x) - \log(x)$.
  set y : ℝ := Real.exp x - Real.log x;
  -- Since $y > x$, we have $y > 1$.
  have hy_gt_one : 1 < y := by
    linarith [ Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx ];
  have := Real.add_one_le_exp ( y - 1 );
  norm_num [ Real.exp_sub ] at *;
  rw [ le_div_iff₀ ( Real.exp_pos _ ) ] at this;
  nlinarith [ Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos ( by linarith : 0 < y ) ]

end
