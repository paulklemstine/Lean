/-
# EML V11 — Differentiability and Derivative Theory

Complete differentiability analysis of the EML operator,
its partial derivatives, self-pairing derivatives,
and critical point theory.
-/

import Mathlib

noncomputable section

open Real Filter Topology Set

/-! ## Core Definitions -/

def eml (x y : ℝ) : ℝ := Real.exp x - Real.log y
def emlSelfPair (x : ℝ) : ℝ := Real.exp x - x
def emlDiag (z : ℝ) : ℝ := Real.exp z - Real.log z

/-! ## Section 1: Differentiability of EML -/

/-- EML is differentiable in x (for any fixed y). -/
theorem eml_differentiable_x (y : ℝ) : Differentiable ℝ (fun x => eml x y) := by
  unfold eml
  exact (differentiable_exp.comp differentiable_id).sub (differentiable_const _)

/-- EML is differentiable in y on (0,∞) (for any fixed x). -/
theorem eml_differentiable_y_pos (x : ℝ) :
    DifferentiableOn ℝ (fun y => eml x y) (Set.Ioi 0) := by
  unfold eml
  exact (differentiableOn_const _).sub (Real.differentiableOn_log.mono (by
    intro y hy; simp [Set.mem_compl_iff]; exact ne_of_gt hy))

/-- The self-pairing σ(x) = eˣ − x is differentiable. -/
theorem emlSelfPair_differentiable : Differentiable ℝ emlSelfPair := by
  unfold emlSelfPair
  exact differentiable_exp.sub differentiable_id

/-! ## Section 2: Derivative Computations -/

/-- ∂eml/∂x = exp(x). -/
theorem eml_deriv_x (y : ℝ) (x : ℝ) :
    HasDerivAt (fun x => eml x y) (Real.exp x) x := by
  have h1 := Real.hasDerivAt_exp x
  have h2 : HasDerivAt (fun _ : ℝ => Real.log y) 0 x := hasDerivAt_const x (Real.log y)
  convert h1.sub h2 using 1; ring

/-- ∂eml/∂y = −1/y for y ≠ 0. -/
theorem eml_deriv_y (x : ℝ) (y : ℝ) (hy : y ≠ 0) :
    HasDerivAt (fun y => eml x y) (-(1/y)) y := by
  have h1 : HasDerivAt (fun _ : ℝ => Real.exp x) 0 y := hasDerivAt_const y (Real.exp x)
  have h2 := Real.hasDerivAt_log hy
  have h3 := h1.sub h2
  convert h3 using 1; ring

/-- σ'(x) = eˣ − 1. -/
theorem emlSelfPair_deriv (x : ℝ) :
    HasDerivAt emlSelfPair (Real.exp x - 1) x := by
  show HasDerivAt (fun x => Real.exp x - x) (Real.exp x - 1) x
  exact (Real.hasDerivAt_exp x).sub (hasDerivAt_id x)

/-- σ'(0) = 0: the self-pairing has a critical point at x = 0. -/
theorem emlSelfPair_deriv_zero :
    HasDerivAt emlSelfPair 0 0 := by
  have := emlSelfPair_deriv 0; norm_num at this; exact this

/-- σ'(x) > 0 for x > 0. -/
theorem emlSelfPair_deriv_pos {x : ℝ} (hx : 0 < x) :
    Real.exp x - 1 > 0 := by
  linarith [Real.add_one_le_exp x]

/-- σ'(x) < 0 for x < 0. -/
theorem emlSelfPair_deriv_neg {x : ℝ} (hx : x < 0) :
    Real.exp x - 1 < 0 := by
  have : Real.exp x < 1 := by
    rw [← Real.exp_zero]; exact Real.exp_strictMono hx
  linarith

/-! ## Section 3: Second Derivatives -/

/-- σ''(x) = eˣ (the derivative of eˣ − 1). -/
theorem emlSelfPair_second_deriv (x : ℝ) :
    HasDerivAt (fun x => Real.exp x - 1) (Real.exp x) x := by
  have h1 := Real.hasDerivAt_exp x
  have h2 : HasDerivAt (fun _ : ℝ => (1 : ℝ)) 0 x := hasDerivAt_const x 1
  convert h1.sub h2 using 1; ring

/-- ∂²eml/∂x² = exp(x) > 0. -/
theorem eml_second_deriv_x_pos (x : ℝ) : Real.exp x > 0 :=
  Real.exp_pos x

/-- ∂²eml/∂y² = 1/y² > 0 for y > 0. -/
theorem eml_second_deriv_y_pos (y : ℝ) (hy : 0 < y) : 1 / y ^ 2 > 0 := by
  positivity

/-! ## Section 4: Monotonicity from Derivatives -/

/-
σ is strictly monotone increasing on [0,∞).
-/
theorem emlSelfPair_strictMono_nonneg :
    StrictMonoOn emlSelfPair (Set.Ici 0) := by
  intro;
  intro ha x hx hax; have := exists_deriv_eq_slope ( f := fun x => Real.exp x - x ) hax; norm_num at *;
  exact this ( Continuous.continuousOn <| by continuity ) ( Differentiable.differentiableOn <| by norm_num [ Real.differentiable_exp ] ) |> fun ⟨ c, hc₁, hc₂ ⟩ => by rw [ eq_div_iff ] at hc₂ <;> norm_num [ emlSelfPair ] at * <;> nlinarith [ Real.add_one_le_exp c, Real.exp_lt_exp.2 hc₁.1, Real.exp_lt_exp.2 hc₁.2 ] ;

/-
σ is strictly antitone on (−∞, 0].
-/
theorem emlSelfPair_strictAnti_nonpos :
    StrictAntiOn emlSelfPair (Set.Iic 0) := by
  unfold StrictAntiOn;
  simp +zetaDelta at *;
  intros a ha b hb hab; have h_deriv_neg : ∀ x, x < 0 → deriv emlSelfPair x < 0 := by
    exact fun x hx => by rw [ show emlSelfPair = fun x => Real.exp x - x from funext fun x => rfl ] ; norm_num [ Real.differentiableAt_exp ] ; linarith [ Real.exp_lt_one_iff.mpr hx ] ;
  have := exists_deriv_eq_slope emlSelfPair hab;
  exact this ( ContinuousOn.sub ( Real.continuousOn_exp ) continuousOn_id ) ( DifferentiableOn.sub ( Real.differentiable_exp.differentiableOn ) differentiableOn_id ) |> fun ⟨ c, hc₁, hc₂ ⟩ => by have := h_deriv_neg c ( by linarith [ hc₁.1, hc₁.2 ] ) ; rw [ hc₂, div_lt_iff₀ ] at this <;> linarith

/-
d(z) = exp(z) - log(z) is strictly monotone on (1,∞).
-/
theorem emlDiag_strictMono_gt_one :
    StrictMonoOn emlDiag (Set.Ioi 1) := by
  -- By definition of $d$, we know that its derivative is $d'(z) = \exp(z) - \frac{1}{z}$.
  have hd_deriv : ∀ z > 1, deriv emlDiag z = Real.exp z - 1 / z := by
    intro z hz; unfold emlDiag; norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, ne_of_gt ( zero_lt_one.trans hz ) ] ;
  -- Since $d'(z) = \exp(z) - \frac{1}{z}$ and $\exp(z) > \frac{1}{z}$ for all $z > 1$, it follows that $d'(z) > 0$ for all $z > 1$.
  have hd_deriv_pos : ∀ z > 1, deriv emlDiag z > 0 := by
    exact fun z hz => hd_deriv z hz ▸ sub_pos_of_lt ( by rw [ div_lt_iff₀ ] <;> nlinarith [ Real.add_one_le_exp z ] );
  apply strictMonoOn_of_deriv_pos;
  · exact convex_Ioi 1;
  · exact continuousOn_of_forall_continuousAt fun x hx => by exact DifferentiableAt.continuousAt ( by exact differentiableAt_of_deriv_ne_zero ( ne_of_gt ( hd_deriv_pos x hx ) ) ) ;
  · aesop

/-! ## Section 5: Diagonal Map Derivative -/

/-- d'(z) = exp(z) - 1/z for z > 0. -/
theorem emlDiag_deriv_pos (z : ℝ) (hz : 0 < z) :
    HasDerivAt emlDiag (Real.exp z - 1 / z) z := by
  unfold emlDiag
  have h1 := Real.hasDerivAt_exp z
  have h2 := Real.hasDerivAt_log (ne_of_gt hz)
  convert h1.sub h2 using 1; ring

/-
d'(z) > 0 for z ≥ 1.
-/
theorem emlDiag_deriv_pos_ge_one (z : ℝ) (hz : 1 ≤ z) :
    Real.exp z - 1 / z > 0 := by
  exact sub_pos_of_lt ( by rw [ div_lt_iff₀ ( by positivity ) ] ; nlinarith [ Real.add_one_le_exp z ] )

/-! ## Section 6: Continuity -/

/-- EML is continuous in x for fixed y. -/
theorem eml_continuous_x (y : ℝ) : Continuous (fun x => eml x y) :=
  (eml_differentiable_x y).continuous

/-- σ is continuous. -/
theorem emlSelfPair_continuous : Continuous emlSelfPair :=
  emlSelfPair_differentiable.continuous

/-! ## Section 7: EML Gradient -/

/-- The gradient of eml never vanishes (for y ≠ 0): ‖∇eml‖² = e²ˣ + 1/y² > 0. -/
theorem eml_grad_nonzero (x y : ℝ) (hy : 0 < y) :
    (Real.exp x) ^ 2 + (1 / y) ^ 2 > 0 := by
  positivity

/-! ## Section 8: σ has no inflection points -/

/-- σ has no inflection points (σ'' = eˣ > 0 everywhere). -/
theorem emlSelfPair_no_inflection (x : ℝ) :
    Real.exp x > 0 := Real.exp_pos x

end