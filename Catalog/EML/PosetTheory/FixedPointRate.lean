import Mathlib
import EML.FixedPointConvergence
/-!
# EML Fixed-Point Theorem: Certified Geometric Convergence Rate

This file extends `EML.FixedPointConvergence`, which establishes that the EML
single operator `f(x) = exp(a) · log(b·x + c)` is a contraction on an invariant
interval and that its iteration converges to a unique fixed point.

The earlier file proves *that* the iteration converges (Cauchy ⇒ limit, and the
limit is a fixed point). It does **not** quantify *how fast*. The central claim
of the EML fixed-point conjecture is that convergence happens at rate `O(ρⁿ)`
where `ρ` is the contraction ratio. This file closes that gap by proving the
classical Banach **a priori error estimate** for the EML iteration:

  `|xₙ − x*| ≤ |x₁ − x₀| · ρⁿ / (1 − ρ)`.

This is the precise meaning of the `O(ρⁿ)` rate: the constant is fully explicit,
computable from the first step `|x₁ − x₀|` and the ratio `ρ`, and the bound
tends to `0` geometrically.

## Main results

* `EMLIterOp.iterSeq_dist_consecutive` — consecutive iterates contract:
  `dist xₙ xₙ₊₁ ≤ |x₁ − x₀| · ρⁿ`.
* `EMLIterOp.iterSeq_error_bound` — a priori error estimate against any limit.
* `EMLIterOp.iterSeq_certified_rate` — packaged certified convergence: there is
  a unique-style fixed point `x*` with the explicit geometric error bound at
  every step.
* `EMLIterOp.iterSeq_error_tendsto_zero` — the error bound vanishes, certifying
  genuine `O(ρⁿ)` convergence.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The EML iteration converges not merely in the
topological sense already recorded in `FixedPointConvergence`, but at a fully
explicit geometric rate governed by the contraction ratio `ρ`. Concretely, the
distance to the fixed point should be bounded by `|x₁ − x₀| · ρⁿ / (1 − ρ)`.

Experiment (Experimenter): The previous file already proved
`iterSeq_geometric_decay`: `|xₙ₊₁ − xₙ| ≤ ρⁿ · |x₁ − x₀|`. Mathlib's
`dist_le_of_le_geometric_of_tendsto` turns exactly this kind of per-step decay,
plus any convergent limit, into the a priori bound `C · rⁿ / (1 − r)`. The only
glue needed is to express the decay as a `dist`, reconcile the order of the
product `ρⁿ · C` vs `C · ρⁿ`, and reuse `iterSeq_converges` to supply the limit.

Analysis (Analyst): The key structural insight is that *one* per-step contraction
inequality already encodes the whole geometric tail. No new analytic input about
`exp`/`log` is required — the rate is a purely metric consequence of the
contraction. This separates the (hard) analytic fact `|f'| ≤ ρ < 1` from the
(soft) quantitative convergence theory.

Critique (Critic): Is the bound vacuous? No: `iterSeq_error_tendsto_zero` shows
the right-hand side genuinely tends to `0`, so the statement is non-trivial. Is
`EMLContractionData` itself inhabited (so the hypotheses are satisfiable)? Yes —
see `EML.FixedPointConcreteInstance`, which builds an explicit instance. The
bound is also sharp in spirit: at `n = 0` it reduces to the standard
`|x₀ − x*| ≤ |x₁ − x₀|/(1 − ρ)` Banach estimate.

Synthesis (PI): Together with the concrete instance file, this upgrades the EML
fixed-point story from "converges" to "converges with a certified, computable
geometric error bound", which is what makes EML usable as an iterative algorithm.
-- !-- Lab Notes -- !--
-/

noncomputable section

open Real Set Filter Topology

namespace EMLIterOp

/-- Consecutive iterates contract geometrically, phrased with `dist` so that it
feeds directly into Mathlib's geometric-series machinery. -/
theorem iterSeq_dist_consecutive
    (D : EMLContractionData) (x₀ : ℝ) (hx₀ : x₀ ∈ Icc D.lo D.hi) (n : ℕ) :
    dist (EMLIterOp.iterSeq D.a D.b D.c x₀ n)
         (EMLIterOp.iterSeq D.a D.b D.c x₀ (n + 1)) ≤
      |EMLIterOp.iterSeq D.a D.b D.c x₀ 1 -
        EMLIterOp.iterSeq D.a D.b D.c x₀ 0| * D.rho ^ n := by
  rw [Real.dist_eq, abs_sub_comm, mul_comm]
  exact iterSeq_geometric_decay D x₀ hx₀ n

/-- **A priori error estimate.** If the EML iteration converges to `xstar`, then
the distance from the `n`-th iterate to `xstar` is bounded by the explicit
geometric quantity `|x₁ − x₀| · ρⁿ / (1 − ρ)`. This is the precise `O(ρⁿ)` rate. -/
theorem iterSeq_error_bound
    (D : EMLContractionData) (x₀ : ℝ) (hx₀ : x₀ ∈ Icc D.lo D.hi)
    {xstar : ℝ}
    (hlim : Tendsto (EMLIterOp.iterSeq D.a D.b D.c x₀) atTop (𝓝 xstar)) (n : ℕ) :
    |EMLIterOp.iterSeq D.a D.b D.c x₀ n - xstar| ≤
      |EMLIterOp.iterSeq D.a D.b D.c x₀ 1 -
        EMLIterOp.iterSeq D.a D.b D.c x₀ 0| * D.rho ^ n / (1 - D.rho) := by
  have := dist_le_of_le_geometric_of_tendsto D.rho
    (|EMLIterOp.iterSeq D.a D.b D.c x₀ 1 - EMLIterOp.iterSeq D.a D.b D.c x₀ 0|)
    D.rho_lt_one (fun m => iterSeq_dist_consecutive D x₀ hx₀ m) hlim n
  rwa [Real.dist_eq] at this

/-- **Certified geometric convergence.** Packaging the existence of the fixed
point with the explicit a priori error bound at every step. -/
theorem iterSeq_certified_rate
    (D : EMLContractionData) (x₀ : ℝ) (hx₀ : x₀ ∈ Icc D.lo D.hi) :
    ∃ xstar, EMLIterOp D.a D.b D.c xstar = xstar ∧ xstar ∈ Icc D.lo D.hi ∧
      Tendsto (EMLIterOp.iterSeq D.a D.b D.c x₀) atTop (𝓝 xstar) ∧
      (∀ n, |EMLIterOp.iterSeq D.a D.b D.c x₀ n - xstar| ≤
        |EMLIterOp.iterSeq D.a D.b D.c x₀ 1 -
          EMLIterOp.iterSeq D.a D.b D.c x₀ 0| * D.rho ^ n / (1 - D.rho)) := by
  obtain ⟨xstar, hlim, hfix, hmem⟩ := iterSeq_converges D x₀ hx₀
  exact ⟨xstar, hfix, hmem, hlim, fun n => iterSeq_error_bound D x₀ hx₀ hlim n⟩

/-- The explicit error bound vanishes as `n → ∞`, certifying genuine `O(ρⁿ)`
geometric convergence (not merely qualitative convergence). -/
theorem iterSeq_error_tendsto_zero
    (D : EMLContractionData) (x₀ : ℝ) :
    Tendsto (fun n => |EMLIterOp.iterSeq D.a D.b D.c x₀ 1 -
        EMLIterOp.iterSeq D.a D.b D.c x₀ 0| * D.rho ^ n / (1 - D.rho))
      atTop (𝓝 0) := by
  have hρ : Tendsto (fun n => D.rho ^ n) atTop (𝓝 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one D.rho_nonneg D.rho_lt_one
  have : Tendsto (fun n => |EMLIterOp.iterSeq D.a D.b D.c x₀ 1 -
        EMLIterOp.iterSeq D.a D.b D.c x₀ 0| * D.rho ^ n / (1 - D.rho))
      atTop (𝓝 (|EMLIterOp.iterSeq D.a D.b D.c x₀ 1 -
        EMLIterOp.iterSeq D.a D.b D.c x₀ 0| * 0 / (1 - D.rho))) := by
    apply Tendsto.div_const
    exact Tendsto.const_mul _ hρ
  simpa using this

end EMLIterOp

end