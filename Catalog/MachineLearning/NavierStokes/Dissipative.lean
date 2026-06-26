import Mathlib

/-!
# Navier–Stokes Regularity: Dissipative Long-Time Dynamics (Absorbing Ball)

This file extends `NavierStokes.Core` from the *decay* regime to the *driven*
(forced) regime. The energy / enstrophy of the **forced** incompressible
Navier–Stokes equations on a domain with a Poincaré inequality satisfies a
scalar differential inequality of the form

`Y'(t) ≤ -a Y(t) + b`,

where `a = ν λ₁ > 0` is the (Poincaré-strengthened) dissipation rate and
`b ≥ 0` measures the power injected by the external force. This linear-with-source
inequality is the engine of the **theory of dissipative dynamical systems** for 2D
Navier–Stokes: it produces a bounded *absorbing set* and hence the existence of a
global attractor. Here we prove its three scalar consequences rigorously.

## Mathematical background

Multiplying the (forced) momentum/vorticity equation by the velocity/vorticity and
using the Poincaré inequality `‖∇u‖₂² ≥ λ₁‖u‖₂²` together with a bound on the
forcing term gives `Y' ≤ -a Y + b`. The integrating factor `g(t) = (Y(t) - b/a)
e^{a t}` is non-increasing, so:

* **A priori bound:** `Y(t) ≤ b/a + (Y₀ - b/a) e^{-a t}` (exact comparison solution).
* **Dissipativity:** `Y(t) ≤ max (Y₀) (b/a)` — a uniform-in-time bound; the ball of
  radius `b/a` (in the squared-norm observable) is *forward invariant up to the
  initial datum*.
* **Absorbing ball:** for every `ε > 0`, eventually `Y(t) ≤ b/a + ε`; i.e. every
  trajectory is eventually trapped in an arbitrarily small neighbourhood of the
  ball of radius `b/a`. This is the scalar shadow of the existence of a bounded
  absorbing set (the first step toward a global attractor).

The decay theorem `energy_exponential_decay` of `Core` is exactly the unforced
case `b = 0` of `dissipative_apriori`.

## Main results

* `dissipative_apriori` — `Y(t) ≤ b/a + (Y₀ - b/a) e^{-a t}`.
* `dissipative_bound` — uniform bound `Y(t) ≤ max (Y₀) (b/a)`.
* `dissipative_absorbing` — eventual entry into the ball `b/a + ε` (absorbing set).
* `dissipative_limsup_le` — `limsup Y ≤ b/a`, the sharp asymptotic enstrophy bound.

-- !-- Lab Notes -- !--
-- Hypothesis H5 (forced dissipativity): the unforced integrating-factor trick of
--   `Core.energy_exponential_decay` should survive verbatim with the shifted
--   observable `Y - b/a` in place of `Y`. Experiment: `g(t) = (Y t - b/a) e^{a t}`
--   has `g'(t) = (D t + a Y t - b) e^{a t} ≤ 0`, needing *no* sign assumption on
--   `Y`, `b`, or `Y₀`; only `a > 0` enters (to form `b/a`). Confirmed.
-- Insight: dissipativity `Y ≤ max(Y₀, b/a)` is a pure consequence of the comparison
--   solution since `e^{-a t} ∈ (0,1]`; the sign of `Y₀ - b/a` selects which bound is
--   active. No monotonicity of `Y` is needed.
-- Insight: the absorbing property is *asymptotic*, not invariance — for `Y₀ > b/a`
--   the trajectory leaves no finite ball smaller than `Y₀` immediately, but enters
--   `b/a + ε` after a transient of length `~ (1/a) log((Y₀-b/a)/ε)`.
-- Failure analysis: a naive attempt to prove `limsup Y ≤ b/a` directly via
--   `Filter.limsup_le_of_le` stalls on integrability/measurability of `limsup`; the
--   clean route is `limsup_le` of the explicit comparison bound whose `Tendsto` to
--   `b/a` is elementary (`Real.tendsto_exp_atBot` composed with `-a • id`).
-/

open scoped Topology
open Filter

namespace NavierStokes

/-! ## A priori comparison bound for the forced inequality -/

/-
**Forced dissipative a priori bound.** If `Y'(t) ≤ -a Y(t) + b` with dissipation
rate `a > 0`, then `Y(t)` is dominated by the comparison solution
`b/a + (Y₀ - b/a) e^{-a t}` for all `t ≥ 0`. No sign assumptions on `Y`, `b`, or
`Y₀` are needed. The unforced case `b = 0` recovers `energy_exponential_decay`.
-/
theorem dissipative_apriori
    (Y D : ℝ → ℝ) (a b : ℝ) (ha : 0 < a)
    (hY : ∀ t, HasDerivAt Y (D t) t)
    (hineq : ∀ t, D t ≤ -a * Y t + b) :
    ∀ t, 0 ≤ t → Y t ≤ b / a + (Y 0 - b / a) * Real.exp (-a * t) := by
  intro t ht
  have h_ineq : ∀ t, deriv (fun t => (Y t - b / a) * Real.exp (a * t)) t ≤ 0 := by
    intro t; norm_num [ mul_comm a, hY t |> HasDerivAt.differentiableAt ];
    rw [ hY t |> HasDerivAt.deriv ] ; nlinarith [ hineq t, Real.exp_pos ( t * a ), mul_div_cancel₀ b ha.ne', mul_le_mul_of_nonneg_right ( hineq t ) ( Real.exp_nonneg ( t * a ) ) ];
  -- Since $g(t)$ is non-increasing, we have $g(t) \leq g(0)$ for all $t \geq 0$.
  have h_g_le_g0 : ∀ t ≥ 0, (Y t - b / a) * Real.exp (a * t) ≤ (Y 0 - b / a) := by
    intro t ht; by_contra h_contra; push_neg at h_contra; (
    have := exists_deriv_eq_slope ( f := fun t => ( Y t - b / a ) * Real.exp ( a * t ) ) ( show t > 0 from ht.lt_of_ne ( by rintro rfl; norm_num at h_contra ) ) ; norm_num at this;
    exact absurd ( this ( continuousOn_of_forall_continuousAt fun x hx => DifferentiableAt.continuousAt ( by exact DifferentiableAt.mul ( DifferentiableAt.sub ( hY x |> HasDerivAt.differentiableAt ) ( differentiableAt_const _ ) ) ( DifferentiableAt.exp ( differentiableAt_id.const_mul _ ) ) ) ) ( fun x hx => DifferentiableAt.differentiableWithinAt ( by exact DifferentiableAt.mul ( DifferentiableAt.sub ( hY x |> HasDerivAt.differentiableAt ) ( differentiableAt_const _ ) ) ( DifferentiableAt.exp ( differentiableAt_id.const_mul _ ) ) ) ) ) ( by rintro ⟨ c, ⟨ hc₁, hc₂ ⟩, hc ⟩ ; rw [ eq_div_iff ] at hc <;> nlinarith [ h_ineq c ] ));
  convert add_le_add_left ( div_le_div_of_nonneg_right ( h_g_le_g0 t ht ) ( Real.exp_nonneg ( a * t ) ) ) ( b / a ) using 1 ; ring ; norm_num [ Real.exp_neg, Real.exp_ne_zero ];
  simpa [ Real.exp_neg ] using by ring;

/-! ## Uniform-in-time dissipativity -/

/-
**Dissipativity bound.** The forced enstrophy never exceeds the maximum of its
initial value and the forcing level `b/a`: `Y(t) ≤ max (Y₀) (b/a)` for all
`t ≥ 0`. This is the scalar absorbing-set bound.
-/
theorem dissipative_bound
    (Y D : ℝ → ℝ) (a b : ℝ) (ha : 0 < a)
    (hY : ∀ t, HasDerivAt Y (D t) t)
    (hineq : ∀ t, D t ≤ -a * Y t + b) :
    ∀ t, 0 ≤ t → Y t ≤ max (Y 0) (b / a) := by
  -- Apply the already-proved `dissipative_apriori` to conclude the proof.
  intros t ht
  have h_bound : Y t ≤ b / a + (Y 0 - b / a) * Real.exp (-a * t) :=
    dissipative_apriori Y D a b ha hY hineq t ht
  cases max_cases ( Y 0 ) ( b / a ) <;> nlinarith [ Real.exp_pos ( -a * t ), Real.exp_le_one_iff.mpr ( show -a * t ≤ 0 by nlinarith ) ]

/-! ## The absorbing ball -/

/-
**Absorbing ball.** For every `ε > 0`, the trajectory eventually enters the ball
of radius `b/a + ε`: `Y(t) ≤ b/a + ε` for all sufficiently large `t`. This is the
scalar shadow of the existence of a bounded absorbing set for the forced 2D
Navier–Stokes flow.
-/
theorem dissipative_absorbing
    (Y D : ℝ → ℝ) (a b : ℝ) (ha : 0 < a)
    (hY : ∀ t, HasDerivAt Y (D t) t)
    (hineq : ∀ t, D t ≤ -a * Y t + b) :
    ∀ ε > 0, ∀ᶠ t in atTop, Y t ≤ b / a + ε := by
  intro ε hε
  obtain ⟨T₀, hT₀⟩ : ∃ T₀ : ℝ, ∀ t ≥ T₀, b / a + (Y 0 - b / a) * Real.exp (-a * t) < b / a + ε := by
    have h_exp_zero : Filter.Tendsto (fun t => (Y 0 - b / a) * Real.exp (-a * t)) Filter.atTop (nhds 0) := by
      simpa using tendsto_const_nhds.mul ( Real.tendsto_exp_atBot.comp <| Filter.tendsto_neg_atTop_atBot.comp <| Filter.tendsto_id.const_mul_atTop ha );
    simpa using h_exp_zero.eventually ( gt_mem_nhds hε );
  filter_upwards [ Filter.eventually_ge_atTop T₀, Filter.eventually_ge_atTop 0 ] with t ht₁ ht₂ using le_trans ( dissipative_apriori Y D a b ha hY hineq t ht₂ ) ( le_of_lt ( hT₀ t ht₁ ) )

/-
**Sharp asymptotic enstrophy bound.** The limit superior of the forced enstrophy
is at most the forcing level `b/a`. The hypothesis `0 ≤ Y` is the physical
non-negativity of the squared-norm observable (enstrophy / energy); it pins the
asymptotic enstrophy to `[0, b/a]` and supplies the lower cobound that makes the
`limsup` well-behaved.
-/
theorem dissipative_limsup_le
    (Y D : ℝ → ℝ) (a b : ℝ) (ha : 0 < a)
    (hYnn : ∀ t, 0 ≤ Y t)
    (hY : ∀ t, HasDerivAt Y (D t) t)
    (hineq : ∀ t, D t ≤ -a * Y t + b) :
    limsup Y atTop ≤ b / a := by
  refine' le_of_forall_pos_le_add fun ε ε_pos => _;
  -- Use the fact that $Y(t)$ is bounded above by $b/a + \epsilon$ for sufficiently large $t$.
  have h_bound : ∀ᶠ t in atTop, Y t ≤ b / a + ε :=
    dissipative_absorbing Y D a b ha hY hineq ε ε_pos
  exact csInf_le ⟨ 0, fun x hx => by rcases Filter.eventually_atTop.mp hx with ⟨ t, ht ⟩ ; exact le_trans ( hYnn t ) ( ht t le_rfl ) ⟩ h_bound

end NavierStokes