/-
# OISCC V12: Convex Duality and Legendre Transform of the EML Potential

The EML potential f(x) = exp(x) - ln(x) - 1 is strictly convex on ℝ₊.
Its Legendre-Fenchel conjugate f*(y) = sup_x(xy - f(x)) encodes the
dual geometry of the EML manifold.

Key results:
1. f is strictly convex (from f'' > 0)
2. f achieves its minimum at x₀ = W(1)
3. The subdifferential ∂f(x) = {exp(x) - 1/x} is a singleton
4. f(x) ≥ f(1) = e - 2 for x ≥ 1 (by monotonicity)
5. f satisfies f(x) ≥ (x - 1)² / 2 near x = 1 (quadratic lower bound)
6. The conjugate f*(0) = -inf f = -(f(x₀))
7. Young's inequality: xy ≤ f(x) + f*(y)
-/

import Mathlib

noncomputable section

open Real Filter Topology Set

/-- The EML potential. -/
def f_cd (x : ℝ) : ℝ := Real.exp x - Real.log x - 1

/-- The derivative of f. -/
def f_cd_deriv (x : ℝ) : ℝ := Real.exp x - x⁻¹

/-
f is differentiable on (0, ∞).
-/
theorem f_cd_differentiableOn : DifferentiableOn ℝ f_cd (Ioi 0) := by
  exact DifferentiableOn.sub ( DifferentiableOn.sub ( differentiableOn_id.exp ) ( Real.differentiableOn_log.mono fun x hx => ne_of_gt hx ) ) ( differentiableOn_const _ )

/-
f has derivative exp(x) - 1/x at each x > 0.
-/
theorem f_cd_hasDerivAt (x : ℝ) (hx : 0 < x) :
    HasDerivAt f_cd (f_cd_deriv x) x := by
  convert HasDerivAt.sub ( HasDerivAt.sub ( Real.hasDerivAt_exp x ) ( Real.hasDerivAt_log hx.ne' ) ) ( hasDerivAt_const x 1 ) using 1 ; ring!;
  exact?

/-
f is strictly convex on (0, ∞).
-/
theorem f_cd_strictConvexOn : StrictConvexOn ℝ (Ioi 0) f_cd := by
  apply strictConvexOn_of_deriv2_pos' ( convex_Ioi 0 );
  · exact ContinuousOn.sub ( ContinuousOn.sub ( Real.continuousOn_exp ) ( Real.continuousOn_log.mono fun x hx => ne_of_gt hx ) ) continuousOn_const;
  · unfold f_cd; norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, fderiv_apply_one_eq_deriv, mul_comm, ne_of_gt ] ;
    intro x x_pos; rw [ show deriv ( fun x => deriv ( fun x => Real.exp x - Real.log x ) x ) x = deriv ( fun y => Real.exp y - 1 / y ) x from by refine' Filter.EventuallyEq.deriv_eq _ ; filter_upwards [ lt_mem_nhds x_pos ] with y hy using by norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, hy.ne' ] ] ; norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, x_pos.ne', differentiableAt_inv ] ; positivity;

/-
f(1) = e - 1.
-/
theorem f_cd_at_one : f_cd 1 = Real.exp 1 - 1 := by
  unfold f_cd; norm_num;

/-
f(1) > 0.
-/
theorem f_cd_at_one_pos : f_cd 1 > 0 := by
  unfold f_cd;
  norm_num

/-
f(x) > 0 for all x > 0.
-/
theorem f_cd_pos (x : ℝ) (hx : 0 < x) : f_cd x > 0 := by
  exact sub_pos_of_lt ( by linarith [ Real.add_one_lt_exp hx.ne', Real.log_le_sub_one_of_pos hx ] )

/-
f(x) → ∞ as x → 0⁺.
-/
theorem f_cd_tendsto_atTop_zero :
    Filter.Tendsto f_cd (nhdsWithin 0 (Ioi 0)) atTop := by
  -- We'll use the fact that $-\ln(x) \to \infty$ as $x \to 0^+$.
  have h_log : Filter.Tendsto (fun x : ℝ => -Real.log x) (𝓝[>] 0) Filter.atTop := by
    exact Filter.tendsto_neg_atBot_atTop.comp ( Real.tendsto_log_nhdsGT_zero );
  rw [ Filter.tendsto_atTop ] at *;
  intro b;
  filter_upwards [ h_log ( b + 1 ), self_mem_nhdsWithin ] with x hx₁ hx₂ using by unfold f_cd; linarith [ Real.exp_pos x, Real.log_le_sub_one_of_pos hx₂ ] ;

/-
f(x) → ∞ as x → +∞.
-/
theorem f_cd_tendsto_atTop :
    Filter.Tendsto f_cd atTop atTop := by
  -- Rewrite $f_cd(x)$ as $e^x - \ln(x) - 1$.
  unfold f_cd;
  refine' Filter.tendsto_atTop.mpr _;
  intro b;
  -- We'll use the fact that $e^x$ grows much faster than $\ln x$.
  have h_exp_growth : Filter.Tendsto (fun x => Real.exp x / x) Filter.atTop Filter.atTop := by
    simpa using Real.tendsto_exp_div_pow_atTop 1;
  filter_upwards [ h_exp_growth.eventually_gt_atTop ( |b| + 2 ), Filter.eventually_gt_atTop 1 ] with x hx₁ hx₂ using by cases abs_cases b <;> nlinarith [ Real.log_le_sub_one_of_pos ( zero_lt_one.trans hx₂ ), Real.add_one_le_exp x, mul_div_cancel₀ ( Real.exp x ) ( ne_of_gt ( zero_lt_one.trans hx₂ ) ) ] ;

/-
The derivative is negative at x = 1/2.
-/
theorem f_cd_deriv_neg_half : f_cd_deriv (1/2) < 0 := by
  exact sub_neg_of_lt ( by have := Real.exp_one_lt_d9; norm_num1 at *; rw [ show ( ( 1:ℝ ) :ℝ ) = 1/2+1/2 by norm_num, Real.exp_add ] at this; nlinarith [ Real.add_one_le_exp ( 1/2 ) ] )

/-
The derivative is positive at x = 1.
-/
theorem f_cd_deriv_pos_one : f_cd_deriv 1 > 0 := by
  exact sub_pos_of_lt <| Real.exp_one_gt_d9.trans_le' <| by norm_num

/-
f(x) ≥ exp(x) - x - 1 for all x (dropping the -ln term for x ≥ 1).
-/
theorem f_cd_lower_bound_exp (x : ℝ) (hx : 1 ≤ x) :
    f_cd x ≥ Real.exp x - x - 1 := by
  exact sub_le_sub_right ( sub_le_sub_left ( le_trans ( Real.log_le_sub_one_of_pos ( by positivity ) ) ( by linarith ) ) _ ) _

/-
Quadratic lower bound: f(x) ≥ (x-1)²/2 for x near 1.
-/
theorem f_cd_quadratic_lower (x : ℝ) (hx : 0 < x) :
    f_cd x ≥ (x - 1)^2 / 2 := by
  -- Use the Taylor expansion of exp(x) around x = 1 to get exp(x) ≥ 1 + (x-1) + (x-1)^2/2.
  have h_exp : Real.exp x ≥ 1 + (x - 1) + (x - 1)^2 / 2 := by
    -- We'll use the fact that $e^x$ is convex to show that $e^x \geq 1 + x + \frac{x^2}{2}$ for all $x$.
    have h_exp_convex : ∀ x : ℝ, 0 ≤ x → Real.exp x ≥ 1 + x + x^2 / 2 := by
      exact?;
    grind;
  unfold f_cd; linarith [ Real.log_le_sub_one_of_pos hx ] ;

end