/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# BSD Research Cycle — The Frobenius Trace Recurrence and the Sato–Tate Angle

For an elliptic curve `E / ℚ` with good reduction at `p`, the number of points over
the extension field `𝔽_{p^n}` is governed by the Frobenius eigenvalues `α, β` (the
reciprocal roots of the local L-factor, with `α + β = a_p` and `α β = p`):

  `#E(𝔽_{p^n}) = p^n + 1 - (αⁿ + βⁿ)`.

The *power sums* `sₙ = αⁿ + βⁿ` are the traces of the `n`-th power of Frobenius.
This file isolates two structural pillars of the local BSD theory that complement
`LocalFactor.lean`:

* the **linear recurrence** `s_{n+2} = a_p · s_{n+1} - p · s_n` (with `s₀ = 2`,
  `s₁ = a_p`), Newton's identity for the degree-two characteristic polynomial, which
  lets the entire tower of point counts be computed from `a_p` and `p` alone; and
* the **Sato–Tate parametrization** `a_p = 2√p · cos θ`, the angular form of the
  Hasse bound that is the substrate of the Sato–Tate equidistribution conjecture.

It closes with the archimedean bound `‖αⁿ + βⁿ‖ ≤ 2 (√p)ⁿ` that the Riemann
Hypothesis over finite fields imposes on every power sum.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the whole sequence of point counts is *rigid* — it is the
  unique solution of a second-order linear recurrence with constant coefficients
  `a_p, p`, so `a_p` (equivalently `#E(𝔽_p)`) determines `#E(𝔽_{p^n})` for all `n`.
Experiment (Experimenter): define `traceSeq a p` by the recurrence and prove
  `traceSeq a p n = αⁿ + βⁿ` by two-step induction, using Newton's identity
  `power_sum_recurrence` (a pure `ring` fact once `α+β=a`, `αβ=p` are substituted).
Analysis (Analyst): the base cases `s₀ = 2` (not `1`!) and `s₁ = a` are forced by
  `α⁰ + β⁰ = 2`; getting `s₀` wrong is the classic off-by-one in Newton's identities.
  The Sato–Tate angle is well defined exactly because `|a| ≤ 2√p` puts `a/(2√p)` in
  `[-1, 1]`, the domain of `arccos`.
Critique (Critic): the norm bound `‖αⁿ + βⁿ‖ ≤ 2 (√p)ⁿ` must use only `‖α‖ = ‖β‖ =
  √p` (the RH input), not the algebraic relations, so it is the genuinely analytic
  half and stays valid for all `n` including the degenerate `n = 0` (`2 ≤ 2`).
Synthesis (PI): recurrence + angle + norm bound package the local point-count tower
  underlying the Euler product; the recurrence is the computational engine, the angle
  is the equidistribution coordinate, and the bound is the RH constraint.
-/
import Mathlib

namespace BSD.FrobeniusTrace

open Complex

/-
**Newton's recurrence for power sums.**  For `α, β` with sum `a` and product `p`,
the power sums `αⁿ + βⁿ` satisfy the degree-two linear recurrence
`s_{n+2} = a · s_{n+1} - p · s_n`.
-/
theorem power_sum_recurrence (α β a p : ℂ) (hs : α + β = a) (hp : α * β = p) (n : ℕ) :
    α ^ (n + 2) + β ^ (n + 2) = a * (α ^ (n + 1) + β ^ (n + 1)) - p * (α ^ n + β ^ n) := by
  subst_vars; ring;

/-- The **Frobenius trace sequence** `sₙ`: the unique solution of the recurrence
`s_{n+2} = a · s_{n+1} - p · s_n` with `s₀ = 2`, `s₁ = a`.  It equals the power sum
`αⁿ + βⁿ` of the Frobenius eigenvalues (`traceSeq_eq_power_sum`). -/
def traceSeq (a p : ℂ) : ℕ → ℂ
  | 0 => 2
  | 1 => a
  | (n + 2) => a * traceSeq a p (n + 1) - p * traceSeq a p n

@[simp] theorem traceSeq_zero (a p : ℂ) : traceSeq a p 0 = 2 := rfl

@[simp] theorem traceSeq_one (a p : ℂ) : traceSeq a p 1 = a := rfl

theorem traceSeq_succ_succ (a p : ℂ) (n : ℕ) :
    traceSeq a p (n + 2) = a * traceSeq a p (n + 1) - p * traceSeq a p n := rfl

/-
**The trace sequence computes the Frobenius power sums.**  If `α + β = a` and
`α β = p`, then `traceSeq a p n = αⁿ + βⁿ` for all `n`.
-/
theorem traceSeq_eq_power_sum (α β a p : ℂ) (hs : α + β = a) (hp : α * β = p) (n : ℕ) :
    traceSeq a p n = α ^ n + β ^ n := by
  induction' n using Nat.twoStepInduction with n ih1 ih2;
  · norm_num;
  · aesop;
  · grind +suggestions

/-- The point count `#E(𝔽_{p^n}) = p^n + 1 - sₙ` expressed through the trace
sequence, so the entire tower is determined by `a_p` and `p`. -/
def pointCount (a p : ℂ) (n : ℕ) : ℂ := p ^ n + 1 - traceSeq a p n

/-
At `n = 0` the trace-sequence point count vanishes (`p⁰ + 1 - 2 = 0`).
-/
@[simp] theorem pointCount_zero (a p : ℂ) : pointCount a p 0 = 0 := by
  unfold pointCount; norm_num

/-
At `n = 1` the point count is `p + 1 - a_p`, the defining relation for `a_p`.
-/
theorem pointCount_one (a p : ℂ) : pointCount a p 1 = p + 1 - a := by
  unfold pointCount; aesop;

/-
**Sato–Tate angle.**  Under the Hasse bound `a² ≤ 4p` (with `0 < p`), the trace of
Frobenius can be written `a = 2√p · cos θ` for an angle `θ ∈ [0, π]`.  This is the
angular coordinate in which the Sato–Tate conjecture predicts equidistribution.
-/
theorem exists_satoTate_angle (a p : ℝ) (hp : 0 < p) (h : a ^ 2 ≤ 4 * p) :
    ∃ θ : ℝ, θ ∈ Set.Icc 0 Real.pi ∧ a = 2 * Real.sqrt p * Real.cos θ := by
  refine' ⟨ Real.arccos ( a / ( 2 * Real.sqrt p ) ), ⟨ Real.arccos_nonneg _, Real.arccos_le_pi _ ⟩, _ ⟩;
  rw [ Real.cos_arccos, mul_div_cancel₀ _ ( by positivity ) ];
  · rw [ le_div_iff₀ ] <;> nlinarith [ Real.sqrt_nonneg p, Real.sq_sqrt hp.le ];
  · rw [ div_le_iff₀ ] <;> nlinarith [ Real.sqrt_nonneg p, Real.sq_sqrt hp.le ]

/-
**RH bound on the power sums.**  If both Frobenius eigenvalues lie on the circle
of radius `√p` (the Riemann Hypothesis over finite fields), then every power sum is
bounded: `‖αⁿ + βⁿ‖ ≤ 2 (√p)ⁿ`.
-/
theorem traceSeq_norm_le (α β : ℂ) (p : ℝ) (ha : ‖α‖ = Real.sqrt p)
    (hb : ‖β‖ = Real.sqrt p) (n : ℕ) :
    ‖α ^ n + β ^ n‖ ≤ 2 * Real.sqrt p ^ n := by
  exact le_trans ( norm_add_le _ _ ) ( by rw [ norm_pow, norm_pow, ha, hb ] ; linarith )

end BSD.FrobeniusTrace