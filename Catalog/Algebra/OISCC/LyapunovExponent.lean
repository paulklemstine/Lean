import Mathlib

/-! # CatalogBuild.Speculative.OISCC.LyapunovExponent

Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 13
-/

noncomputable section

/-- The diagonal map. -/
def d_lyap (x : ℝ) : ℝ := Real.exp x - Real.log x

/-- The single-step expansion rate (= larger eigenvalue on diagonal). -/
def rho (x : ℝ) : ℝ := Real.exp x + x⁻¹

/-- The log expansion rate. -/
def log_rho (x : ℝ) : ℝ := Real.log (rho x)

/-- ρ(x) > 0 for x > 0. -/
theorem rho_pos (x : ℝ) (hx : 0 < x) : rho x > 0 := by
  unfold rho; positivity

theorem rho_gt_one (x : ℝ) (hx : 0 < x) : rho x > 1 := by
  exact lt_add_of_le_of_pos ( Real.one_le_exp hx.le ) ( inv_pos.mpr hx )

/-- ρ(x) ≥ exp(x) for x > 0. -/
theorem rho_ge_exp (x : ℝ) (hx : 0 < x) : rho x ≥ Real.exp x := by
  unfold rho; linarith [inv_pos.mpr hx]

theorem rho_ge_e_plus_one (x : ℝ) (hx : 1 ≤ x) :
    rho x ≥ Real.exp 1 + 1 := by
  unfold rho;
  -- We'll use that $e^x$ grows faster than $x$ for $x \geq 1$.
  have h_exp_growth : Real.exp x ≥ Real.exp 1 + (x - 1) * Real.exp 1 := by
    rw [ show x = 1 + ( x - 1 ) by ring, Real.exp_add ];
    nlinarith [ Real.add_one_le_exp 1, Real.add_one_le_exp ( x - 1 ) ];
  nlinarith [ inv_pos.mpr ( by linarith : 0 < x ), mul_inv_cancel₀ ( by linarith : x ≠ 0 ), Real.add_one_le_exp 1, Real.add_one_le_exp x ]

/-- ln(ρ(x)) ≥ x for x ≥ 1. -/
theorem log_rho_ge_id (x : ℝ) (hx : 1 ≤ x) : log_rho x ≥ x := by
  unfold log_rho
  calc Real.log (rho x) ≥ Real.log (Real.exp x) := by
        exact Real.log_le_log (Real.exp_pos x) (rho_ge_exp x (by linarith))
    _ = x := Real.log_exp x

theorem d_lyap_gt_id (x : ℝ) (hx : 0 < x) : d_lyap x > x := by
  unfold d_lyap;
  rw [ show Real.exp x = Real.exp ( x - 1 ) * Real.exp 1 by rw [ ← Real.exp_add ] ; ring, mul_comm ];
  have := Real.exp_one_gt_d9.le ; norm_num1 at * ; nlinarith [ inv_pos.mpr hx, mul_inv_cancel₀ hx.ne', Real.add_one_le_exp ( x - 1 ), Real.log_le_sub_one_of_pos hx ]

theorem rho_orbit_growth (x : ℝ) (hx : 1 ≤ x) :
    rho (d_lyap x) > rho x := by
  -- To prove strict monotonicity on [1, ∞), we can show that the derivative of rho is positive on this interval.
  have h_deriv_pos : ∀ x ≥ 1, 0 < deriv rho x := by
    intro x hx; rw [ show rho = fun x ↦ Real.exp x + x⁻¹ by funext; rfl ] ; norm_num [ Real.differentiableAt_exp, differentiableAt_inv, show x ≠ 0 by linarith ];
    exact lt_of_le_of_lt ( inv_le_one_of_one_le₀ ( by nlinarith ) ) ( by norm_num; linarith );
  -- Since rho is strictly increasing on [1, ∞), we have rho(x) < rho(d(x)) if and only if x < d(x).
  have h_strict_mono : StrictMonoOn rho (Set.Ici 1) := by
    apply strictMonoOn_of_deriv_pos;
    · exact convex_Ici _;
    · exact continuousOn_of_forall_continuousAt fun x hx => by exact DifferentiableAt.continuousAt ( by exact differentiableAt_of_deriv_ne_zero ( ne_of_gt ( h_deriv_pos x hx ) ) );
    · exact fun x hx => h_deriv_pos x <| interior_subset hx;
  refine' h_strict_mono _ _ _ <;> norm_num [ hx ];
  · exact le_trans hx ( le_of_lt ( d_lyap_gt_id x ( by positivity ) ) );
  · exact d_lyap_gt_id x <| zero_lt_one.trans_le hx

theorem log_lyapunov_ge_orbit (x : ℝ) (hx : 1 ≤ x) :
    log_rho (d_lyap x) ≥ d_lyap x := by
  apply log_rho_ge_id;
  exact le_trans hx ( le_of_lt ( d_lyap_gt_id x ( by positivity ) ) )

theorem rho_strictMono_Ici : StrictMonoOn rho (Ici 1) := by
  norm_num [ StrictMonoOn ];
  intros a ha b hb hab; have h_deriv_pos : ∀ x, 1 ≤ x → 0 < deriv rho x := by
    intros x hx
    have h_deriv : deriv rho x = Real.exp x - 1 / x^2 := by
      convert HasDerivAt.deriv ( HasDerivAt.add ( Real.hasDerivAt_exp x ) ( hasDerivAt_inv ( by linarith ) ) ) using 1 ; ring!;
    exact h_deriv.symm ▸ sub_pos_of_lt ( by exact lt_of_lt_of_le ( by rw [ div_lt_iff₀ ] <;> nlinarith ) ( Real.add_one_le_exp x ) );
  -- Apply the mean value theorem to the interval $[a, b]$.
  obtain ⟨c, hc⟩ : ∃ c ∈ Set.Ioo a b, deriv rho c = (rho b - rho a) / (b - a) := by
    apply_rules [ exists_deriv_eq_slope ];
    · exact continuousOn_of_forall_continuousAt fun x hx => by exact DifferentiableAt.continuousAt ( by exact differentiableAt_of_deriv_ne_zero ( ne_of_gt ( h_deriv_pos x ( by linarith [ hx.1 ] ) ) ) );
    · exact fun x hx => DifferentiableAt.differentiableWithinAt ( by exact differentiableAt_of_deriv_ne_zero ( ne_of_gt ( h_deriv_pos x ( by linarith [ hx.1 ] ) ) ) );
  have := h_deriv_pos c ( by linarith [ hc.1.1 ] ) ; rw [ hc.2, lt_div_iff₀ ] at this <;> linarith;

theorem rho_tendsto_atTop : Filter.Tendsto rho atTop atTop := by
  -- Since $\rho(x) \geq e^x$ for $x > 0$ and $e^x \to \infty$ as $x \to \infty$, it follows that $\rho(x) \to \infty$ as $x \to \infty$.
  have h_rho_ge_exp : ∀ x > 0, rho x ≥ Real.exp x := by
    exact fun x a => rho_ge_exp x a;
  exact Filter.tendsto_atTop_mono' Filter.atTop ( Filter.eventually_atTop.mpr ⟨ 1, fun x hx => h_rho_ge_exp x <| zero_lt_one.trans_le hx ⟩ ) <| Real.tendsto_exp_atTop

end