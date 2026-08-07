import Mathlib

/-!
# Lyapunov exponents: a self-contained quantitative core

This file develops the elementary but quantitative theory of Lyapunov exponents that is
needed to speak rigorously about *deterministic chaos*: the exponent attached to a
trajectory of a (linearised) flow, its behaviour on purely exponential curves, the
maximal exponent of a family of trajectories, and the resulting **predictability
horizon** ("Lyapunov time").

The results here are used in `Physics.Chaos.ThreeBodyLagrange` to produce an explicit
positive Lyapunov exponent for the gravitational three-body problem, and in
`Physics.Chaos.EntropyLyapunov` to connect Lyapunov exponents to Kolmogorov–Sinai
entropy.

Main definitions:

* `lyapExp g` — the Lyapunov exponent `limsup_{t→∞} log ‖g t‖ / t` of a curve `g`.
* `maxLyapExp S` — the maximal Lyapunov exponent of a family `S` of curves.
* `lyapunovTime σ δ₀ Δ` — the time after which an initial separation `δ₀` growing at
  rate `σ` reaches the macroscopic scale `Δ`.

Main results:

* `lyapExp_of_exp_growth` — a purely exponential curve has exponent equal to its rate.
* `lyapExp_ge_of_exp_lower_bound` — exponential lower bounds give exponent lower bounds.
* `separation_reaches_scale` — quantitative sensitive dependence on initial conditions.
* `lyapunovTime_log_scaling` — the horizon grows only *logarithmically* in the accuracy,
  the quantitative signature of chaos.
-/

noncomputable section

open Filter Topology

namespace Chaos

variable {E : Type*} [NormedAddCommGroup E]

/-- The (maximal, forward) **Lyapunov exponent** of a curve `g : ℝ → E`:
`limsup_{t → ∞} (log ‖g t‖) / t`. -/
def lyapExp (g : ℝ → E) : ℝ := limsup (fun t => Real.log ‖g t‖ / t) atTop

/-- A curve whose norm is exactly `C e^{σ t}` has Lyapunov exponent `σ`. -/
theorem lyapExp_of_exp_growth (g : ℝ → E) (C σ : ℝ) (hC : 0 < C)
    (h : ∀ t, ‖g t‖ = C * Real.exp (σ * t)) : lyapExp g = σ := by
  have key : Tendsto (fun t : ℝ => Real.log ‖g t‖ / t) atTop (𝓝 σ) := by
    have hlog : ∀ t : ℝ, Real.log ‖g t‖ = Real.log C + σ * t := by
      intro t
      rw [h t, Real.log_mul (ne_of_gt hC) (Real.exp_ne_zero _), Real.log_exp]
    simp only [hlog]
    have hev : ∀ᶠ t : ℝ in atTop, (Real.log C + σ * t) / t = Real.log C / t + σ := by
      filter_upwards [eventually_gt_atTop (0:ℝ)] with t ht
      field_simp
    rw [tendsto_congr' hev]
    have h2 : Tendsto (fun t : ℝ => Real.log C / t) atTop (𝓝 0) :=
      Filter.Tendsto.div_atTop tendsto_const_nhds tendsto_id
    simpa using h2.add (tendsto_const_nhds (x := σ))
  exact key.limsup_eq

/-- If a curve grows at least like `C e^{σ t}` (and its exponent is finite, i.e. the
quotients are bounded above), then its Lyapunov exponent is at least `σ`. -/
theorem lyapExp_ge_of_exp_lower_bound (g : ℝ → E) (C σ : ℝ) (hC : 0 < C)
    (hbdd : IsBoundedUnder (· ≤ ·) atTop (fun t => Real.log ‖g t‖ / t))
    (h : ∀ t, C * Real.exp (σ * t) ≤ ‖g t‖) : σ ≤ lyapExp g := by
  refine le_of_forall_pos_le_add ?_
  intro ε hε
  have key : σ - ε ≤ lyapExp g := by
    refine le_limsup_of_frequently_le ?_ hbdd
    have hmain : ∀ᶠ t : ℝ in atTop, σ - ε ≤ Real.log ‖g t‖ / t := by
      filter_upwards [eventually_gt_atTop (0:ℝ), eventually_gt_atTop (|Real.log C| / ε)]
        with t ht ht2
      have hgt : 0 < ‖g t‖ := lt_of_lt_of_le (by positivity) (h t)
      have hlog : Real.log C + σ * t ≤ Real.log ‖g t‖ := by
        have := Real.log_le_log (by positivity) (h t)
        rwa [Real.log_mul (ne_of_gt hC) (Real.exp_ne_zero _), Real.log_exp] at this
      rw [le_div_iff₀ ht]
      have h1 : |Real.log C| < ε * t := by
        rw [div_lt_iff₀ hε] at ht2; linarith [ht2]
      have h2 : -(ε * t) < Real.log C := by
        have := abs_lt.mp h1; linarith [this.1]
      nlinarith
    exact hmain.frequently
  linarith

/-- The **maximal Lyapunov exponent** of a family `S` of trajectories. -/
def maxLyapExp (S : Set (ℝ → E)) : ℝ := sSup (lyapExp '' S)

theorem lyapExp_le_maxLyapExp {S : Set (ℝ → E)} {g : ℝ → E} (hg : g ∈ S)
    (hbdd : BddAbove (lyapExp '' S)) : lyapExp g ≤ maxLyapExp S :=
  le_csSup hbdd ⟨g, hg, rfl⟩

/-- **Chaos criterion.** If a single trajectory in the family has a positive Lyapunov
exponent, the maximal Lyapunov exponent of the family is strictly positive. -/
theorem maxLyapExp_pos {S : Set (ℝ → E)} {g : ℝ → E} (hg : g ∈ S)
    (hbdd : BddAbove (lyapExp '' S)) (hpos : 0 < lyapExp g) : 0 < maxLyapExp S :=
  lt_of_lt_of_le hpos (lyapExp_le_maxLyapExp hg hbdd)

/-! ### Predictability horizon -/

/-- The **Lyapunov time**: the time it takes an initial uncertainty `δ₀`, amplified at
exponential rate `σ`, to reach the macroscopic scale `Δ`. -/
def lyapunovTime (σ δ₀ Δ : ℝ) : ℝ := Real.log (Δ / δ₀) / σ

/-- **Quantitative sensitive dependence on initial conditions.** If the separation of
two trajectories obeys `δ t ≥ δ₀ e^{σ t}` with `σ > 0`, then after the Lyapunov time the
separation has reached the macroscopic scale `Δ`: arbitrarily small initial errors become
order-one errors in finite time. -/
theorem separation_reaches_scale (δ : ℝ → ℝ) (σ δ₀ Δ : ℝ) (hσ : 0 < σ) (hδ₀ : 0 < δ₀)
    (hΔ : 0 < Δ) (hgrow : ∀ t, δ₀ * Real.exp (σ * t) ≤ δ t)
    {t : ℝ} (ht : lyapunovTime σ δ₀ Δ ≤ t) : Δ ≤ δ t := by
  have hlog : Real.log (Δ / δ₀) ≤ σ * t := by
    rw [lyapunovTime, div_le_iff₀ hσ] at ht
    linarith [ht]
  have : Δ / δ₀ ≤ Real.exp (σ * t) := by
    calc Δ / δ₀ = Real.exp (Real.log (Δ / δ₀)) := (Real.exp_log (by positivity)).symm
    _ ≤ Real.exp (σ * t) := Real.exp_le_exp.mpr hlog
  have := (div_le_iff₀ hδ₀).mp this
  calc Δ = δ₀ * (Δ / δ₀) := by field_simp
  _ ≤ δ₀ * Real.exp (σ * t) := by
      exact mul_le_mul_of_nonneg_left (by rw [div_le_iff₀ hδ₀]; linarith) hδ₀.le
  _ ≤ δ t := hgrow t

/-- **Logarithmic cost of prediction.** Improving the initial accuracy by a factor `k > 1`
buys only an *additive* `log k / σ` of extra predictability. This is the practical
content of a positive Lyapunov exponent. -/
theorem lyapunovTime_log_scaling (σ δ₀ Δ k : ℝ) (hδ₀ : 0 < δ₀) (hΔ : 0 < Δ)
    (hk : 0 < k) :
    lyapunovTime σ (δ₀ / k) Δ = lyapunovTime σ δ₀ Δ + Real.log k / σ := by
  unfold lyapunovTime
  rw [div_div_eq_mul_div, ← add_div]
  congr 1
  rw [show Δ * k / δ₀ = (Δ / δ₀) * k by field_simp,
    Real.log_mul (by positivity) (by positivity)]

end Chaos