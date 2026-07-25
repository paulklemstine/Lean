import Mathlib

/-! # CatalogBuild.Speculative.OISCC.V12_CurvatureTheory

Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 15
-/

noncomputable section

/-- The EML Riemannian metric on ℝ₊. -/
def g_curv (x : ℝ) : ℝ := Real.exp x + x⁻¹ ^ 2

/-- The derivative of the metric: g'(x) = exp(x) - 2/x³. -/
def g_curv_deriv (x : ℝ) : ℝ := Real.exp x - 2 * x⁻¹ ^ 3

/-- The square root of the metric (for arc length). -/
def sqrt_g (x : ℝ) : ℝ := Real.sqrt (g_curv x)

/-- [Section: # CatalogBuild.Speculative.OISCC.V12_CurvatureTheory
Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 15] -/
theorem g_curv_pos (x : ℝ) (hx : 0 < x) : g_curv x > 0 := by
  exact add_pos ( Real.exp_pos x ) ( sq_pos_of_pos ( inv_pos.mpr hx ) )

theorem g_curv_ge_one (x : ℝ) (hx : 0 < x) : g_curv x ≥ 1 := by
  exact le_add_of_le_of_nonneg ( Real.one_le_exp hx.le ) ( sq_nonneg _ )

theorem g_curv_ge_exp (x : ℝ) : g_curv x ≥ Real.exp x := by
  exact le_add_of_nonneg_right ( sq_nonneg _ )

theorem g_curv_ge_inv_sq (x : ℝ) : g_curv x ≥ x⁻¹ ^ 2 := by
  exact le_add_of_nonneg_left <| Real.exp_nonneg x

theorem g_curv_hasDerivAt (x : ℝ) (hx : 0 < x) :
    HasDerivAt g_curv (g_curv_deriv x) x := by
  unfold g_curv g_curv_deriv;
  field_simp;
  convert HasDerivAt.add ( Real.hasDerivAt_exp x ) ( HasDerivAt.div ( hasDerivAt_const _ _ ) ( hasDerivAt_pow 2 x ) ( by positivity ) ) using 1 ; ring;
  grind

theorem g_curv_deriv_pos (x : ℝ) (hx : 1 ≤ x) : g_curv_deriv x > 0 := by
  exact sub_pos_of_lt ( by have := Real.exp_one_gt_d9.le; norm_num1 at *; nlinarith [ Real.exp_pos x, Real.exp_le_exp.mpr hx, inv_pos.mpr ( by positivity : 0 < x ), mul_inv_cancel₀ ( by positivity : x ≠ 0 ), pow_pos ( inv_pos.mpr ( by positivity : 0 < x ) ) 2, pow_pos ( inv_pos.mpr ( by positivity : 0 < x ) ) 3 ] )

theorem g_curv_strictMono_Ici : StrictMonoOn g_curv (Ici 1) := by
  intro a ha b hb hab;
  -- By the mean value theorem, there exists some $c \in (a, b)$ such that $g'(c) = \frac{g(b) - g(a)}{b - a}$.
  obtain ⟨c, hc⟩ : ∃ c ∈ Set.Ioo a b, deriv g_curv c = (g_curv b - g_curv a) / (b - a) := by
    apply_rules [ exists_deriv_eq_slope ];
    · exact ContinuousOn.add ( Real.continuousOn_exp ) ( ContinuousOn.pow ( continuousOn_id.inv₀ fun x hx => ne_of_gt <| lt_of_lt_of_le zero_lt_one <| ha.out.trans hx.1 ) 2 );
    · exact fun x hx => DifferentiableAt.differentiableWithinAt ( by exact HasDerivAt.differentiableAt ( g_curv_hasDerivAt x ( by linarith [ hx.1, hx.2, Set.mem_Ici.mp ha, Set.mem_Ici.mp hb ] ) ) );
  -- Since $g'(x) > 0$ for $x \geq 1$, we have $deriv g_curv c > 0$.
  have h_deriv_pos : deriv g_curv c > 0 := by
    rw [ show deriv g_curv c = g_curv_deriv c from HasDerivAt.deriv ( g_curv_hasDerivAt c <| by linarith [ hc.1.1, ha.out ] ) ] ; exact g_curv_deriv_pos c <| by linarith [ hc.1.1, ha.out ];
  rw [ hc.2, gt_iff_lt, lt_div_iff₀ ] at h_deriv_pos <;> linarith

theorem sqrt_g_ge_one (x : ℝ) (hx : 0 < x) : sqrt_g x ≥ 1 := by
  exact Real.le_sqrt_of_sq_le ( by linarith [ g_curv_ge_one x hx ] )

theorem sqrt_g_ge_inv (x : ℝ) (hx : 0 < x) : sqrt_g x ≥ x⁻¹ := by
  exact Real.le_sqrt_of_sq_le ( by exact le_trans ( by norm_num ) ( g_curv_ge_inv_sq x ) )

theorem g_curv_tendsto_atTop_zero :
    Filter.Tendsto g_curv (nhdsWithin 0 (Ioi 0)) atTop := by
  -- The term $x^{-1}^2$ goes to infinity as $x$ approaches $0^+$.
  have h_inv_sq : Filter.Tendsto (fun x : ℝ => x⁻¹ ^ 2) (𝓝[>] 0) Filter.atTop := by
    exact Filter.Tendsto.comp ( Filter.tendsto_pow_atTop ( by norm_num ) ) ( tendsto_inv_nhdsGT_zero );
  exact Filter.tendsto_atTop_mono ( fun x => by exact le_add_of_nonneg_left <| Real.exp_nonneg _ ) h_inv_sq

theorem g_curv_tendsto_atTop :
    Filter.Tendsto g_curv atTop atTop := by
  exact Filter.tendsto_atTop_mono ( fun x ↦ g_curv_ge_exp x ) ( Real.tendsto_exp_atTop )

theorem g_curv_convexOn : ConvexOn ℝ (Ioi 0) g_curv := by
  apply_rules [ convexOn_of_deriv2_nonneg, convex_Ioi ];
  · exact continuousOn_of_forall_continuousAt fun x hx => ContinuousAt.add ( Real.continuous_exp.continuousAt ) ( ContinuousAt.pow ( continuousAt_id.inv₀ hx.out.ne' ) 2 );
  · exact fun x hx => DifferentiableAt.differentiableWithinAt ( by exact DifferentiableAt.add ( Real.differentiableAt_exp ) ( DifferentiableAt.pow ( differentiableAt_id.inv ( ne_of_gt <| interior_subset hx ) ) 2 ) );
  · refine' DifferentiableOn.congr _ _;
    exacts [ fun x => Real.exp x - 2 * x⁻¹ ^ 3, DifferentiableOn.sub ( DifferentiableOn.exp differentiableOn_id ) ( DifferentiableOn.mul ( differentiableOn_const _ ) ( DifferentiableOn.pow ( differentiableOn_id.inv fun x hx => ne_of_gt <| interior_subset hx ) _ ) ), fun x hx => HasDerivAt.deriv <| g_curv_hasDerivAt x <| interior_subset hx ];
  · -- By definition of $g_{\text{curv}}$, we know that its second derivative is given by
    have h_second_deriv : ∀ x ∈ Set.Ioi 0, deriv^[2] g_curv x = deriv (fun x => Real.exp x - 2 / x^3) x := by
      intro x hx; refine' Filter.EventuallyEq.deriv_eq _ ; filter_upwards [ lt_mem_nhds hx.out ] with y hy ; unfold g_curv ; norm_num [ Real.differentiableAt_exp, hx.out.ne', hy.ne', div_eq_mul_inv, differentiableAt_inv ] ; ring;
      norm_num [ show y ^ 4 = y ^ 3 * y by ring, hy.ne' ];
    simp +zetaDelta at *;
    intro x hx; rw [ h_second_deriv x hx ] ; norm_num [ Real.differentiableAt_exp, hx.ne', div_eq_mul_inv, differentiableAt_inv ] ; ring_nf; positivity;

end
