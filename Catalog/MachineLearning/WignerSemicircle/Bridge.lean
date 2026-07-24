/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Bridging the Combinatorial and Analytic Sides of the Semicircle Law

The Wigner semicircle law is proved by the *moment method*: one shows that the
moments of the empirical spectral measures converge to the moments of the
semicircle distribution, and that these moments determine the distribution
uniquely.  This file ties together the two developments:

* `Moments.lean` gives the moments of the standard (radius-`2`) semicircle
  distribution as the Catalan numbers `C_k = scMoment (2k)`;
* `Density.lean` gives the explicit radius-`1` semicircle *density* and computes
  its low-order integrals directly.

The two are related by the scaling `x ↦ x/2`, under which the `n`-th moment
scales by `2⁻ⁿ`.  Hence the even moments of the radius-`1` semicircle law are
`scaledMoment k = C_k / 4^k`.  We verify that these combinatorially-defined
numbers agree with the analytically-computed integrals of the density — this is
exactly the moment-matching at the heart of the moment method.

## Main results

- `scaledMoment_zero`         — `scaledMoment 0 = 1`.
- `scaledMoment_one`          — `scaledMoment 1 = 1/4`.
- `bridge_zeroth_moment`      — the 0-th combinatorial moment equals `∫ f`.
- `bridge_first_moment`       — the 1-st (odd) moment: both sides vanish.
- `bridge_second_moment`      — the 2-nd combinatorial moment equals `∫ x²·f`.
-/
import MachineLearning.WignerSemicircle.Moments
import MachineLearning.WignerSemicircle.Density

namespace MachineLearning.WignerSemicircle

open scoped Real

/-- The even moments of the **radius-`1`** semicircle law, obtained from the
Catalan (radius-`2`) moments by the scaling `x ↦ x/2`: `m_{2k} = C_k / 4^k`. -/
noncomputable def scaledMoment (k : ℕ) : ℝ := scMoment (2 * k) / 4 ^ k

/-- The total mass of the radius-`1` semicircle law is `1`. -/
theorem scaledMoment_zero : scaledMoment 0 = 1 := by
  simp [scaledMoment, scMoment_zero]

/-- The second moment (variance) of the radius-`1` semicircle law is `1/4`. -/
theorem scaledMoment_one : scaledMoment 1 = 1 / 4 := by
  simp [scaledMoment, scMoment_two]

/-- **Moment matching, 0-th moment.**  The combinatorial total mass equals the
analytic total mass `∫_{-1}^{1} f = 1`. -/
theorem bridge_zeroth_moment :
    scaledMoment 0 = ∫ x in (-1 : ℝ)..1, scDensity x := by
  rw [scaledMoment_zero, scDensity_normalization]

/-- **Moment matching, 1-st moment.**  Both the combinatorial odd moment and the
analytic mean of the (symmetric) law vanish. -/
theorem bridge_first_moment :
    scMoment 1 = ∫ x in (-1 : ℝ)..1, x * scDensity x := by
  rw [scMoment_odd (by decide), scDensity_mean_zero]

/-- **Moment matching, 2-nd moment.**  The combinatorial second moment `C_1/4`
equals the analytically-computed variance `∫_{-1}^{1} x²·f = 1/4`. -/
theorem bridge_second_moment :
    scaledMoment 1 = ∫ x in (-1 : ℝ)..1, x ^ 2 * scDensity x := by
  rw [scaledMoment_one, scDensity_second_moment]

end MachineLearning.WignerSemicircle