/-! # CatalogBuild.Speculative.OISCC.V11_CriticalPoint

Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 15
-/

import Mathlib

noncomputable section

/-- The EML potential function. -/
def f_pot (x : ℝ) : ℝ := Real.exp x - Real.log x - 1


/-- The derivative of f: f'(x) = exp(x) - 1/x. -/
def f_pot_deriv (x : ℝ) : ℝ := Real.exp x - x⁻¹


/-- f has the stated derivative at every x > 0. -/
theorem f_pot_hasDerivAt (x : ℝ) (hx : 0 < x) :
    HasDerivAt f_pot (f_pot_deriv x) x := by
  unfold f_pot f_pot_deriv
  have := (Real.hasDerivAt_exp x).sub (Real.hasDerivAt_log hx.ne')
  convert this.sub (hasDerivAt_const x (1 : ℝ)) using 1; ring


/-- The second derivative of f: f''(x) = exp(x) + 1/x². -/
def f_pot_deriv2 (x : ℝ) : ℝ := Real.exp x + x⁻¹ ^ 2


/-- The second derivative is strictly positive on (0, ∞). -/
theorem f_pot_deriv2_pos (x : ℝ) (hx : 0 < x) : f_pot_deriv2 x > 0 := by
  unfold f_pot_deriv2; positivity


/-- f'(x) is strictly increasing on (0, ∞) — f is strictly convex. -/
theorem f_pot_deriv_strictMono : StrictMonoOn f_pot_deriv (Ioi 0) := by
  intro a ha b hb hab
  unfold f_pot_deriv
  have h1 : Real.exp a < Real.exp b := Real.exp_lt_exp.mpr hab
  have h2 : b⁻¹ < a⁻¹ := by
    exact inv_strictAnti₀ (mem_Ioi.mp ha) hab
  linarith


theorem f_pot_deriv_neg_near_zero : f_pot_deriv (1/2) < 0 := by
  unfold f_pot_deriv;
  rw [ sub_neg, ← Real.log_lt_log_iff ( by positivity ) ] <;> norm_num;
  exact Real.log_two_gt_d9.trans_le' <| by norm_num


/-- f'(1) > 0. -/
theorem f_pot_deriv_pos_at_one : f_pot_deriv 1 > 0 := by
  unfold f_pot_deriv
  simp only [inv_one]
  linarith [Real.exp_one_gt_d9]


theorem exists_critical_point :
    ∃ x₀ : ℝ, x₀ ∈ Ioo (1/2 : ℝ) 1 ∧ f_pot_deriv x₀ = 0 := by
  apply_rules [ intermediate_value_Ioo ] <;> norm_num;
  · exact ContinuousOn.sub ( Real.continuousOn_exp ) ( continuousOn_inv₀.mono fun x hx => ne_of_gt <| lt_of_lt_of_le ( by norm_num ) hx.1 );
  · exact ⟨ f_pot_deriv_neg_near_zero, f_pot_deriv_pos_at_one ⟩


theorem lambert_w1_exists :
    ∃ x₀ : ℝ, x₀ ∈ Ioo 0 1 ∧ x₀ * Real.exp x₀ = 1 := by
  apply_rules [ intermediate_value_Ioo ] <;> norm_num;
  fun_prop


/-- f(x) > 0 for all x > 0. -/
theorem f_pot_pos (x : ℝ) (hx : 0 < x) : f_pot x > 0 := by
  unfold f_pot
  nlinarith [Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx]


/-- f(x) ≥ 1 for all x > 0. -/
theorem f_pot_ge_one (x : ℝ) (hx : 0 < x) : f_pot x ≥ 1 := by
  unfold f_pot
  linarith [Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx]


/-- f is differentiable on (0, ∞). -/
theorem f_pot_differentiableOn : DifferentiableOn ℝ f_pot (Ioi 0) :=
  fun x hx => (f_pot_hasDerivAt x hx).differentiableAt.differentiableWithinAt


/-- f is convex on (0, ∞). -/
theorem f_pot_convexOn : ConvexOn ℝ (Ioi 0) f_pot := by
  apply ConvexOn.sub
  · exact (convexOn_exp.subset (subset_univ _) (convex_Ioi 0)).sub
      (strictConcaveOn_log_Ioi.concaveOn)
  · exact concaveOn_const 1 (convex_Ioi 0)


theorem f_pot_strictMono_ge_one : StrictMonoOn f_pot (Ici 1) := by
  -- To prove strict monotonicity, we show that $f'(x) > 0$ for all $x > 1$, which implies $f$ is strictly increasing on $(1, \infty)$.
  have h_deriv_pos : ∀ x > 1, deriv f_pot x > 0 := by
    intros x hx; rw [ show deriv f_pot x = f_pot_deriv x from HasDerivAt.deriv ( by exact f_pot_hasDerivAt x <| by linarith ) ] ; exact sub_pos_of_lt <| by nlinarith [ Real.add_one_le_exp x, inv_mul_cancel₀ <| show x ≠ 0 by linarith ] ;
  -- By the Mean Value Theorem, since $f$ is differentiable and $f'(x) > 0$ for $x > 1$, $f$ is strictly increasing on $(1, \infty)$.
  have h_mvt : ∀ {a b : ℝ}, 1 ≤ a → a < b → ∃ c ∈ Set.Ioo a b, deriv f_pot c = (f_pot b - f_pot a) / (b - a) := by
    intros; apply_rules [ exists_deriv_eq_slope ];
    · exact continuousOn_of_forall_continuousAt fun x hx => by exact ContinuousAt.sub ( ContinuousAt.sub ( Real.continuous_exp.continuousAt ) ( Real.continuousAt_log ( by linarith [ hx.1 ] ) ) ) continuousAt_const;
    · exact fun x hx => DifferentiableAt.differentiableWithinAt ( by exact differentiableAt_of_deriv_ne_zero ( ne_of_gt ( h_deriv_pos x ( by linarith [ hx.1 ] ) ) ) );
  intro a ha b hb hab; have := h_mvt ha hab; obtain ⟨ c, hc₁, hc₂ ⟩ := this; have := h_deriv_pos c ( by linarith [ hc₁.1, hc₁.2, ha.out, hb.out ] ) ; rw [ hc₂, gt_iff_lt ] at this; rw [ lt_div_iff₀ ] at this <;> linarith;


end
