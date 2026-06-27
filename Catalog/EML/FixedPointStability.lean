import Mathlib
import EML.FixedPointConvergence
import EML.FixedPointThreshold
import EML.FixedPointExistenceDichotomy

/-!
# EML Fixed-Point Theorem: The Stability Dichotomy

`EML.FixedPointExistenceDichotomy` shows that, for the EML operator
`f(x) = exp(a) · log(x + c)` (case `b = 1`), a fixed point exists in the natural
domain `x + c > 0` iff `c ≥ exp(a)·(1 - a)`. The threshold file showed that on the
boundary `c = exp(a)·(1-a)` the unique fixed point is *neutral* (`f'(x*) = 1`).

This file analyses the **strictly supercritical** regime `c > exp(a)·(1 - a)` and
proves the full dynamical picture predicted by the contraction conjecture: there
are **two** distinct fixed points, straddling the critical argument `x + c = exp a`,
and they have *opposite* stability — one attracting (`|f'| < 1`, a genuine
contraction, the well-behaved iterative scheme of the conjecture) and one
repelling (`f' > 1`).

The mechanism is monotonicity of the derivative `f'(x) = exp(a)/(x + c)`, which is
strictly decreasing in `x` and equals exactly `1` at `x + c = exp a = x0 + c`.
The existence-dichotomy IVT root from the left witness lands *below* `x0`
(argument `< exp a`, derivative `> 1`), while a far-right witness produces a root
*above* `x0` (argument `> exp a`, derivative `< 1`).

## Main results

* `EMLIterOp.fixedPoint_deriv_ratio` — at any domain fixed point,
  `f'(x*) = exp(a)/(x* + c)`.
* `EMLIterOp.attracting_iff` — `f'(x*) < 1 ↔ exp a < x* + c`; dually
  `EMLIterOp.repelling_iff`.
* `EMLIterOp.exists_residual_neg_far` — an explicit far-right witness with
  `x + c > exp a` and negative residual.
* `EMLIterOp.exists_attracting_fixedPoint` — strictly supercritical ⇒ a fixed
  point with `f'(x*) < 1` (a genuine contraction).
* `EMLIterOp.exists_repelling_fixedPoint` — strictly supercritical ⇒ a fixed
  point with `f'(x*) > 1`.
* `EMLIterOp.two_distinct_fixedPoints` — strictly supercritical ⇒ two distinct
  domain fixed points.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Above the existence threshold the residual `g` is a
strictly concave-looking hump that pokes above the diagonal, so it must cross zero
*twice*; and because `f'(x) = exp(a)/(x+c)` decreases through the value `1` exactly
at the hump's peak `x0 = exp a - c`, the two crossings should have derivatives on
opposite sides of `1`: one contraction, one expansion.

Experiment (Experimenter): We reuse the peak value `g(x0) = exp(a)(a-1)+c > 0`
(strictly supercritical) together with two negative-residual witnesses: the left
witness `xL` from `residual_neg_left` (argument `exp(-M) < exp a`) and a far-right
witness with argument `> exp a` obtained from the sublinear bound
`log u ≤ 2(√u − 1)`. Two applications of the intermediate value theorem on
`[xL, x0]` and `[x0, x_R]` give roots on either side of `x0`; the strict
inequality `g(x0) > 0` forces both roots to be *distinct from* `x0`, hence to have
argument strictly below / above `exp a`. Plugging into `deriv_eq` (with `b = 1`,
so `f'(x*) = exp(a)/(x*+c)`) and `div_lt_one` / `one_lt_div` converts the argument
inequalities into the stability inequalities.

Analysis (Analyst): The unifying structural fact is that the *single* quantity
`x* + c` controls everything: it is `> exp a` exactly for the attractor and
`< exp a` exactly for the repeller, and the boundary `x* + c = exp a` is precisely
the neutral threshold point of the companion file. Stability is thus a clean
inequality on the log-argument, not a separate analytic computation.

Critique (Critic): Are the two fixed points really distinct? Yes — one has
argument `< exp a` and the other `> exp a`, so they cannot coincide. Is the
attractor claim vacuous (e.g. `f' < 1` but the point not actually a fixed point)?
No — each witness is a genuine zero of `g`, i.e. `f(x*) = x*`, and lies in the
domain `x* + c > 0`. Does the far-right witness need `c > 0`? No: the sublinear
`√`-bound argument only needs the argument `x + c` large, which we arrange
explicitly regardless of the sign of `c`.

Synthesis (PI): The strictly supercritical EML operator is a textbook
saddle-of-fixed-points system: exactly one attracting and one repelling fixed
point, separated by the neutral critical argument `exp a`. This pins down which
fixed point the conjecture's certified iteration actually converges to — the
larger one, with `x* + c > exp a`.
-- !-- Lab Notes -- !--
-/

noncomputable section

open Real Set

namespace EMLIterOp

/-
**Derivative at a fixed point equals the contraction ratio.** For `b = 1`,
the derivative of the EML operator at any point of the natural domain is
`exp(a)/(x + c)`; in particular at a fixed point `x*` it is `exp(a)/(x* + c)`.
-/
theorem fixedPoint_deriv_ratio (a c xstar : ℝ) (harg : 0 < xstar + c) :
    deriv (EMLIterOp a 1 c) xstar = exp a / (xstar + c) := by
  convert EMLIterOp.deriv_eq a 1 c xstar ( by linarith ) using 1 ; ring

/-
**Attracting criterion.** A domain fixed point of the `b = 1` EML operator is
attracting (`f'(x*) < 1`) precisely when its log-argument exceeds `exp a`.
-/
theorem attracting_iff (a c xstar : ℝ) (harg : 0 < xstar + c) :
    deriv (EMLIterOp a 1 c) xstar < 1 ↔ exp a < xstar + c := by
  rw [ fixedPoint_deriv_ratio a c xstar harg, div_lt_one harg ]

/-
**Repelling criterion.** Dually, the fixed point is repelling (`f'(x*) > 1`)
precisely when its log-argument is below `exp a`.
-/
theorem repelling_iff (a c xstar : ℝ) (harg : 0 < xstar + c) :
    1 < deriv (EMLIterOp a 1 c) xstar ↔ xstar + c < exp a := by
  rw [ EMLIterOp.fixedPoint_deriv_ratio a c xstar harg, one_lt_div ] ; linarith

/-
**Explicit far-right witness with negative residual.** There is a point whose
log-argument exceeds `exp a` and whose residual `f(x) - x` is strictly negative.
This is the upper anchor for the intermediate value theorem.
-/
theorem exists_residual_neg_far (a c : ℝ) :
    ∃ x : ℝ, exp a < x + c ∧ EMLIterOp a 1 c x - x < 0 := by
  unfold EMLIterOp;
  refine' ⟨ 16 * Real.exp a ^ 2 + 2 * c ^ 2 + 2 - c, _, _ ⟩ <;> norm_num;
  · nlinarith [ Real.exp_pos a ];
  · -- Use the sublinear log bound: log T ≤ 2 * Real.sqrt T.
    have h_log_bound : Real.log (16 * Real.exp a ^ 2 + 2 * c ^ 2 + 2) ≤ 2 * Real.sqrt (16 * Real.exp a ^ 2 + 2 * c ^ 2 + 2) := by
      have := Real.log_le_sub_one_of_pos ( show 0 < Real.sqrt ( 16 * Real.exp a ^ 2 + 2 * c ^ 2 + 2 ) by positivity );
      rw [ Real.log_sqrt ( by positivity ) ] at this ; linarith;
    nlinarith [ Real.sqrt_nonneg ( 16 * Real.exp a ^ 2 + 2 * c ^ 2 + 2 ), Real.mul_self_sqrt ( show 0 ≤ 16 * Real.exp a ^ 2 + 2 * c ^ 2 + 2 by positivity ), Real.exp_pos a, sq_nonneg ( Real.sqrt ( 16 * Real.exp a ^ 2 + 2 * c ^ 2 + 2 ) - 4 * Real.exp a ), sq_nonneg ( c - 1 ) ]

/-
**An attracting fixed point exists above the threshold.** In the strictly
supercritical regime there is a domain fixed point with `f'(x*) < 1`: a genuine
contraction, hence the well-behaved attractor of the EML iteration.
-/
theorem exists_attracting_fixedPoint (a c : ℝ)
    (hsup : 0 < exp a * (a - 1) + c) :
    ∃ xstar : ℝ, 0 < xstar + c ∧ EMLIterOp a 1 c xstar = xstar ∧
      deriv (EMLIterOp a 1 c) xstar < 1 := by
  obtain ⟨xR, hxR_arg, hxR_res⟩ : ∃ xR : ℝ, Real.exp a < xR + c ∧ EMLIterOp a 1 c xR - xR < 0 := exists_residual_neg_far a c;
  obtain ⟨xstar, hxstar_mem, hxstar_eq⟩ : ∃ xstar ∈ Set.Ioo (Real.exp a - c) xR, EMLIterOp a 1 c xstar - xstar = 0 := by
    apply_rules [ intermediate_value_Ioo' ];
    · linarith;
    · refine' ContinuousOn.sub _ continuousOn_id;
      refine' ContinuousOn.mul continuousOn_const ( ContinuousOn.log _ _ );
      · exact ContinuousOn.add ( continuousOn_const.mul continuousOn_id ) continuousOn_const;
      · exact fun x hx => by linarith [ hx.1, Real.exp_pos a ] ;
    · constructor <;> norm_num [ EMLIterOp ] at * ; nlinarith [ Real.exp_pos a, Real.log_exp a ];
      linarith;
  exact ⟨ xstar, by linarith [ hxstar_mem.1, Real.exp_pos a ], sub_eq_zero.mp hxstar_eq, by rw [ EMLIterOp.fixedPoint_deriv_ratio a c xstar ( by linarith [ hxstar_mem.1, Real.exp_pos a ] ) ] ; rw [ div_lt_one ( by linarith [ hxstar_mem.1, Real.exp_pos a ] ) ] ; linarith [ hxstar_mem.1, Real.exp_pos a ] ⟩

/-
**A repelling fixed point exists above the threshold.** In the strictly
supercritical regime there is a domain fixed point with `f'(x*) > 1`.
-/
theorem exists_repelling_fixedPoint (a c : ℝ)
    (hsup : 0 < exp a * (a - 1) + c) :
    ∃ xstar : ℝ, 0 < xstar + c ∧ EMLIterOp a 1 c xstar = xstar ∧
      1 < deriv (EMLIterOp a 1 c) xstar := by
  -- By the intermediate value theorem, since $g(x_L) < 0$ and $g(x_0) > 0$, there exists $x^* \in [x_L, x_0]$ such that $g(x^*) = 0$.
  obtain ⟨xstar, hxstar⟩ : ∃ xstar ∈ Set.Icc (Real.exp (-(c / Real.exp a + 1)) - c) (Real.exp a - c), EMLIterOp a 1 c xstar - xstar = 0 := by
    apply_rules [ intermediate_value_Icc ];
    · simp +zetaDelta at *;
      rw [ add_div', le_div_iff₀ ] <;> nlinarith [ Real.exp_pos a, Real.exp_neg a, mul_inv_cancel₀ ( ne_of_gt ( Real.exp_pos a ) ), Real.add_one_le_exp a, Real.add_one_le_exp ( -a ) ];
    · refine' ContinuousOn.sub _ continuousOn_id;
      refine' ContinuousOn.mul continuousOn_const ( ContinuousOn.log _ _ );
      · fun_prop;
      · intro x hx; linarith [ hx.1, hx.2, Real.exp_pos ( - ( c / Real.exp a + 1 ) ) ] ;
    · constructor <;> norm_num [ EMLIterOp ];
      · nlinarith [ Real.exp_pos a, Real.exp_pos ( -1 + - ( c / Real.exp a ) ), mul_div_cancel₀ c ( ne_of_gt ( Real.exp_pos a ) ), Real.add_one_le_exp a, Real.add_one_le_exp ( -1 + - ( c / Real.exp a ) ) ];
      · linarith;
  refine' ⟨ xstar, _, _, _ ⟩;
  · linarith [ hxstar.1.1, Real.exp_pos ( - ( c / Real.exp a + 1 ) ) ];
  · linarith;
  · -- Since $x^* \in [x_L, x_0]$, we have $x^* + c \leq x_0 + c = \exp a$.
    have h_xstar_plus_c_le_exp_a : xstar + c < Real.exp a := by
      by_contra h_contra;
      norm_num [ show xstar = Real.exp a - c by linarith [ hxstar.1.2 ] ] at *;
      unfold EMLIterOp at hxstar ; norm_num at hxstar;
      linarith;
    exact EMLIterOp.repelling_iff a c xstar ( by linarith [ hxstar.1.1, Real.exp_pos ( - ( c / Real.exp a + 1 ) ) ] ) |>.2 h_xstar_plus_c_le_exp_a

/-
**Two distinct fixed points above the threshold.** Combining the attractor
and the repeller, the strictly supercritical EML operator has two distinct fixed
points in its natural domain.
-/
theorem two_distinct_fixedPoints (a c : ℝ)
    (hsup : 0 < exp a * (a - 1) + c) :
    ∃ x₁ x₂ : ℝ, x₁ ≠ x₂ ∧ 0 < x₁ + c ∧ 0 < x₂ + c ∧
      EMLIterOp a 1 c x₁ = x₁ ∧ EMLIterOp a 1 c x₂ = x₂ := by
  obtain ⟨x₁, hx₁⟩ := exists_attracting_fixedPoint a c hsup
  obtain ⟨x₂, hx₂⟩ := exists_repelling_fixedPoint a c hsup;
  grind +extAll

end EMLIterOp

end