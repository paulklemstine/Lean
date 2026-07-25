import Mathlib
import EML.FixedPointConvergence

/-!
# EML Fixed-Point Theorem: First-Order Sensitivity of the Fixed Point in the Scaling Parameter

`EML.FixedPointConvergence` proves that the EML single operator
`f_a(x) = exp(a) · log(b·x + c)` (case `b = 1`) is a contraction with a unique
fixed point `x*(a)`, and the conjecture asks for `x*` "expressed as a power
series in `a`". `EML.FixedPointMonotoneParam` proves the *qualitative* fact that
`x*(a)` is increasing in `a`. What was missing is the **quantitative** content:
the actual slope `dx*/da`, i.e. the first-order coefficient of that power series.

This file supplies it by **implicit differentiation** of the fixed-point
identity `exp(a) · log(x(a) + c) = x(a)`. Differentiating both sides and using
the identity itself to simplify `exp(a)·log(x+c) = x`, one gets

  `x'(a) · (1 − ρ) = x(a)`,   where `ρ = exp(a)/(x(a)+c) = f'(x*(a))`,

so the exact first-order sensitivity is

  `dx*/da = x(a) / (1 − ρ) = x(a)·(x(a)+c) / (x(a)+c − exp a)`.

This is the explicit first Taylor coefficient of the conjectured power series.
On the attracting branch (`ρ < 1`, i.e. `x(a)+c > exp a`) with a positive fixed
point the slope is strictly positive, giving an *infinitesimal* refinement of the
catalog's monotone-dependence law (`fixedPoint_lt_of_a_lt`).

## Main results

* `EMLIterOp.fixedPointBranch_hasDerivAt` — the implicit-differentiation slope:
  any differentiable branch of fixed points has derivative `x(a)/(1 − ρ)`.
* `EMLIterOp.fixedPointBranch_deriv_eq` — the closed form
  `dx*/da = x(a)·(x(a)+c)/(x(a)+c − exp a)`.
* `EMLIterOp.fixedPointBranch_deriv_pos` — on the attracting branch with a
  positive fixed point the slope is strictly positive.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The conjecture's "power series in `a`" is concrete:
the fixed point's first-order coefficient should be `x/(1−ρ)`, the universal
Newton/implicit-function form, where `ρ = f'(x*)` is the very contraction ratio
governing convergence. Surprising twist worth testing: the *same* number `ρ` that
controls how fast the iteration converges also controls how fast the equilibrium
moves under a parameter change — convergence speed and parameter sensitivity are
two readings of one quantity.

Experiment (Experimenter): Differentiate `G(a) = exp a · log(x(a)+c)` with the
product and chain rules (`Real.hasDerivAt_exp`, `Real.hasDerivAt_log`,
`HasDerivAt.comp`, `HasDerivAt.mul`). The product-rule output is
`exp a·log(x+c) + exp a · x'/(x+c)`. The fixed-point identity collapses the first
term to `x(a)`, giving `G'(a) = x(a) + ρ·x'`. Since `G =ᶠ x` near `a`, their
derivatives agree, so `x' = x(a) + ρ·x'`, and `1 − ρ ≠ 0` solves it.

Analysis (Analyst): The decisive structural fact is that the fixed-point identity
must be used *twice*: once as a pointwise equation (to simplify the product-rule
term `exp a·log(x+c) ↦ x`) and once as an eventual equation (to transfer the
derivative of `G` to the derivative of `x` via `EventuallyEq`). The hypothesis
`ρ ≠ 1` is exactly the implicit-function-theorem non-degeneracy condition; it
fails precisely on the neutral threshold `c = exp(a)(1−a)` analysed in
`FixedPointThreshold`, where the slope blows up — consistent with the equilibrium
disappearing in a fold bifurcation there.

Critique (Critic): Is the differentiable-branch hypothesis vacuous? No — on the
attracting supercritical branch the implicit function theorem guarantees such a
`C¹` branch exists (`ρ ≠ 1`); we take its existence as input and compute the slope
rather than re-deriving IFT. Is the result trivial? No: it uses the full chain/
product rule and the eventual fixed-point identity, and produces a non-obvious
closed form that sharpens the catalog's qualitative monotonicity into an exact
rate.

Synthesis (PI): The first-order term of the conjectured power series is
`x*(a)·(x*(a)+c)/(x*(a)+c − exp a)`, finite and positive on the attracting
branch, infinite at the fold threshold — a complete first-order picture unifying
convergence rate and parameter sensitivity.
-- !-- Lab Notes -- !--
-/

noncomputable section

open Real Set Filter Topology

namespace EMLIterOp

/-
**Implicit-differentiation slope of the fixed-point branch.**
Let `X : ℝ → ℝ` be a differentiable branch of fixed points of the `b = 1` EML
operator near `a₀`: it has derivative `d` at `a₀`, equals a fixed point on a
neighborhood, stays in the domain `X a + c > 0`, and its contraction ratio
`ρ = exp a₀/(X a₀ + c)` is not `1`. Then `d = X a₀ / (1 − ρ)`.
-/
theorem fixedPointBranch_hasDerivAt (c a₀ d : ℝ) (X : ℝ → ℝ)
    (hX : HasDerivAt X d a₀)
    (hfix : ∀ᶠ a in 𝓝 a₀, EMLIterOp a 1 c (X a) = X a)
    (hdom : 0 < X a₀ + c)
    (hρ : exp a₀ / (X a₀ + c) ≠ 1) :
    d = X a₀ / (1 - exp a₀ / (X a₀ + c)) := by
  -- Apply the chain rule to find the derivative of $G(a) = \exp(a) \log(X(a) + c)$.
  have hG_deriv : HasDerivAt (fun a => Real.exp a * Real.log (X a + c)) (Real.exp a₀ * Real.log (X a₀ + c) + (Real.exp a₀) / (X a₀ + c) * d) a₀ := by
    convert HasDerivAt.mul ( Real.hasDerivAt_exp a₀ ) ( HasDerivAt.log ( hX.add_const c ) _ ) using 1 <;> norm_num [ hdom.ne' ] ; ring!;
  generalize_proofs at *; (
  -- Substitute the fixed-point identity into the derivative expression.
  have h_subst : Real.exp a₀ * Real.log (X a₀ + c) = X a₀ := by
    simpa [ EMLIterOp ] using hfix.self_of_nhds
  generalize_proofs at *; (
  -- Apply the fact that $G(a) = X(a)$ near $a₀$ to conclude the proof.
  have h_eq : HasDerivAt X (Real.exp a₀ * Real.log (X a₀ + c) + (Real.exp a₀) / (X a₀ + c) * d) a₀ := by
    refine' hG_deriv.congr_of_eventuallyEq _;
    filter_upwards [ hfix ] with a ha using by unfold EMLIterOp at ha; aesop;
  generalize_proofs at *; (
  exact eq_div_of_mul_eq ( sub_ne_zero_of_ne <| Ne.symm hρ ) <| by linarith [ hX.unique h_eq ] ;)))

/-
**Closed form of the fixed-point sensitivity.** Under the same hypotheses,
the slope equals `X a₀·(X a₀ + c)/(X a₀ + c − exp a₀)`.
-/
theorem fixedPointBranch_deriv_eq (c a₀ d : ℝ) (X : ℝ → ℝ)
    (hX : HasDerivAt X d a₀)
    (hfix : ∀ᶠ a in 𝓝 a₀, EMLIterOp a 1 c (X a) = X a)
    (hdom : 0 < X a₀ + c)
    (hne : X a₀ + c - exp a₀ ≠ 0) :
    d = X a₀ * (X a₀ + c) / (X a₀ + c - exp a₀) := by
  convert fixedPointBranch_hasDerivAt c a₀ d X hX hfix hdom _ using 1;
  · grind;
  · exact div_ne_one_of_ne <| by contrapose! hne; linarith;

/-
**Positivity of the sensitivity on the attracting branch.** If the fixed
point is positive (`0 < X a₀`) and attracting (`exp a₀ < X a₀ + c`, i.e. `ρ < 1`),
then the slope `dx*/da` is strictly positive: raising `a` strictly raises the
equilibrium, with an explicit positive rate.
-/
theorem fixedPointBranch_deriv_pos (c a₀ d : ℝ) (X : ℝ → ℝ)
    (hX : HasDerivAt X d a₀)
    (hfix : ∀ᶠ a in 𝓝 a₀, EMLIterOp a 1 c (X a) = X a)
    (hpos : 0 < X a₀)
    (hattr : exp a₀ < X a₀ + c) :
    0 < d := by
  have := fixedPointBranch_deriv_eq c a₀ d X hX hfix ( by linarith [ Real.exp_pos a₀ ] ) ( by linarith [ Real.exp_pos a₀ ] ) ; rw [ this ] ; exact div_pos ( mul_pos hpos ( by linarith [ Real.exp_pos a₀ ] ) ) ( by linarith [ Real.exp_pos a₀ ] ) ;

end EMLIterOp

end