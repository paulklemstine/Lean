/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The Discrete Gaussian and the Analytic Core of the LWE Reduction

The worst-case-to-average-case reduction for Learning with Errors is built on the
**Gaussian measure** on lattices.  The reduction samples lattice points from a
*discrete Gaussian* and argues that, once the width `s` exceeds the *smoothing
parameter*, the distribution behaves like the continuous Gaussian.  This module
formalises the pointwise Gaussian weight `ρ_s(x) = exp(-π x² / s²)`, its basic
shape (positivity, boundedness, evenness, monotone decay, scaling), and packages
the finitely supported discrete Gaussian as a genuine probability distribution.

## Main results

* `rho_pos`, `rho_le_one`, `rho_zero` — the Gaussian weight lands in `(0, 1]`
  with peak `1` at the origin.
* `rho_even`, `rho_scale` — evenness and the width-normalisation identity
  `ρ_s(x) = ρ₁(x / s)`.
* `rho_antitone_abs` — the weight decays monotonically in `|x|`, the shape fact
  behind Gaussian tail bounds.
* `discreteGaussian_sum_one` — the finitely supported discrete Gaussian is a
  probability distribution (masses sum to `1`).
* `discreteGaussian_nonneg`, `discreteGaussian_le_one` — its masses lie in
  `[0, 1]`.

## References

* Micciancio & Regev, "Worst-Case to Average-Case Reductions Based on Gaussian
  Measures", SIAM J. Comput. 2007.
* Banaszczyk, "New bounds in some transference theorems in the geometry of
  numbers", Math. Ann. 1993.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the analytic backbone of the Regev reduction reduces
to two facts about `ρ_s`: it is a peaked, monotonically decaying weight, and its
finite renormalisation is a probability law.  Everything quantitative
(smoothing, tail mass) is a consequence of monotone decay.

Experiment (Experimenter): define `ρ_s(x) = exp(-π x²/s²)`; prove the shape
lemmas; define `gaussianMass`/`discreteGaussian` over a `Finset ℝ` of lattice
points; show the masses are a probability distribution.

Analysis (Analyst): the scaling identity `ρ_s(x) = ρ₁(x/s)` holds *even at
`s = 0`* because Lean's `/0 = 0`; we keep it unconditional.  Monotone decay needs
`s > 0` and reduces (after `exp_le_exp`) to `gcongr` once the sign is flipped —
`gcongr` refuses negative coefficients, so the neg-rewrite is load-bearing.

Critique (Critic): `discreteGaussian_sum_one` is the non-trivial theorem — it
uses `Finset.sum_div` and positivity of the normaliser; not `rfl`.  The `[0,1]`
bounds are honest (require nonempty support / membership).

Synthesis (PI): these feed the "error width vs. smoothing parameter" comparison
consumed by `RegevParameters.lean`.
-- !-- Lab Notes -- !--
-/

open Finset BigOperators Real

noncomputable section

/-- The Gaussian weight of width `s` at `x`: `ρ_s(x) = exp(-π x² / s²)`. -/
def rho (s x : ℝ) : ℝ := Real.exp (-Real.pi * x ^ 2 / s ^ 2)

/-- The Gaussian weight is strictly positive. -/
theorem rho_pos (s x : ℝ) : 0 < rho s x := Real.exp_pos _

/-- The Gaussian weight peaks at `1` at the origin. -/
theorem rho_zero (s : ℝ) : rho s 0 = 1 := by simp [rho]

/-- The Gaussian weight is bounded above by `1`. -/
theorem rho_le_one (s x : ℝ) : rho s x ≤ 1 := by
  unfold rho
  rw [Real.exp_le_one_iff]
  apply div_nonpos_of_nonpos_of_nonneg
  · nlinarith [Real.pi_pos, sq_nonneg x]
  · positivity

/-- The Gaussian weight is even. -/
theorem rho_even (s x : ℝ) : rho s (-x) = rho s x := by simp [rho]

/-- **Width normalisation.**  Scaling the width is the same as scaling the input:
`ρ_s(x) = ρ₁(x / s)`. -/
theorem rho_scale (s x : ℝ) : rho s x = rho 1 (x / s) := by
  unfold rho
  rcases eq_or_ne s 0 with h | h
  · simp [h]
  · congr 1; field_simp

/-- **Monotone decay.**  For positive width, the Gaussian weight decreases as the
magnitude of the input grows. -/
theorem rho_antitone_abs (s x y : ℝ) (hs : 0 < s) (h : |x| ≤ |y|) :
    rho s y ≤ rho s x := by
  unfold rho
  rw [Real.exp_le_exp]
  have hxy : x ^ 2 ≤ y ^ 2 := by
    have := mul_self_le_mul_self (abs_nonneg x) h
    nlinarith [sq_abs x, sq_abs y]
  have hs2 : 0 < s ^ 2 := by positivity
  rw [neg_mul, neg_mul, neg_div, neg_div, neg_le_neg_iff]
  gcongr

/-! ## The discrete Gaussian as a probability distribution -/

/-- The total Gaussian mass of a finite set of lattice points. -/
def gaussianMass (s : ℝ) (pts : Finset ℝ) : ℝ := ∑ x ∈ pts, rho s x

/-- The total Gaussian mass of a nonempty support is strictly positive. -/
theorem gaussianMass_pos (s : ℝ) (pts : Finset ℝ) (h : pts.Nonempty) :
    0 < gaussianMass s pts :=
  Finset.sum_pos (fun x _ => rho_pos s x) h

/-- The discrete Gaussian probability mass at `x`, supported on `pts`. -/
def discreteGaussian (s : ℝ) (pts : Finset ℝ) (x : ℝ) : ℝ :=
  rho s x / gaussianMass s pts

/-- Discrete Gaussian masses are nonnegative. -/
theorem discreteGaussian_nonneg (s : ℝ) (pts : Finset ℝ) (x : ℝ) :
    0 ≤ discreteGaussian s pts x := by
  apply div_nonneg (rho_pos s x).le
  exact Finset.sum_nonneg (fun i _ => (rho_pos s i).le)

/-- **The discrete Gaussian is a probability distribution**: over a nonempty
support its masses sum to `1`. -/
theorem discreteGaussian_sum_one (s : ℝ) (pts : Finset ℝ) (h : pts.Nonempty) :
    ∑ x ∈ pts, discreteGaussian s pts x = 1 := by
  unfold discreteGaussian
  rw [← Finset.sum_div, div_eq_one_iff_eq (gaussianMass_pos s pts h).ne']
  rfl

/-- Each discrete Gaussian mass is at most `1`. -/
theorem discreteGaussian_le_one (s : ℝ) (pts : Finset ℝ) (x : ℝ) (hx : x ∈ pts) :
    discreteGaussian s pts x ≤ 1 := by
  unfold discreteGaussian
  rw [div_le_one (gaussianMass_pos s pts ⟨x, hx⟩)]
  exact Finset.single_le_sum (fun i _ => (rho_pos s i).le) hx

end