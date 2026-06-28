/-
# EML Interpolation Theory: Sharpness of the Jackson Rate for x² on [0,1]

`EML.QuadraticApproxRate` builds the explicit single-exponential EML network
`emlQuadApprox h x = (2/h²)·(exp(h·x) − 1 − h·x)` and proves the **upper** bound
`|emlQuadApprox h x − x²| ≤ (4/9)·h` (rate `O(1/n)` for `h = 1/n`).

This file proves the **matching lower bound**, establishing that the linear rate
is *sharp* for this construction: at the endpoint `x = 1` the error is bounded
below by `h/3`, so it is `Θ(h)` and cannot be improved to `o(h)` (in particular
not to the quadratic rate `O(h²)`).

The key estimate is the *cubic Taylor lower bound* for `exp` on the non-negative
reals, `1 + h + h²/2 + h³/6 ≤ exp h` (a partial sum of the exponential series),
which forces `(2/h²)(exp h − 1 − h) ≥ 1 + h/3`.

## Main results
- `exp_ge_cubic`: `1 + h + h²/2 + h³/6 ≤ exp h` for `0 ≤ h`.
- `emlQuadApprox_lower`: `h/3 ≤ emlQuadApprox h 1 − 1²` for `0 < h`.
- `emlQuadApprox_error_Theta`: two-sided bound `h/3 ≤ error ≤ (4/9)·h` at `x = 1`.
- `emlQuadApprox_rate_lower`: width-`n` lower bound `1/(3n) ≤ emlQuadApprox (1/n) 1 − 1`.
- `emlQuadApprox_not_o`: the error at `x = 1` never beats the linear rate.
-/
import Mathlib
import EML.QuadraticApproxRate

noncomputable section

open Real

/-
**Cubic Taylor lower bound for `exp`.** For `0 ≤ h` the third Taylor polynomial
underestimates the exponential. This is the partial sum
`∑_{m<4} hᵐ/m! ≤ exp h` of the exponential series specialised to `n = 4`.
-/
theorem exp_ge_cubic (h : ℝ) (hh : 0 ≤ h) :
    1 + h + h ^ 2 / 2 + h ^ 3 / 6 ≤ Real.exp h := by
  have := Real.sum_le_exp_of_nonneg hh 4
  simp [Finset.sum_range_succ] at this
  norm_num at this ⊢
  linarith

/-
**Lower bound at the endpoint.** At `x = 1` the EML quadratic network overshoots
`x² = 1` by at least `h/3`. Hence the approximation error is bounded below by a
positive multiple of `h`.
-/
theorem emlQuadApprox_lower (h : ℝ) (hh : 0 < h) :
    h / 3 ≤ emlQuadApprox h 1 - (1 : ℝ) ^ 2 := by
  have hle := exp_ge_cubic h hh.le
  unfold emlQuadApprox
  rw [mul_one]
  have key : (2 / h ^ 2) * (Real.exp h - 1 - h) = 2 * (Real.exp h - 1 - h) / h ^ 2 := by ring
  rw [key, le_sub_iff_add_le, le_div_iff₀ (by positivity)]
  nlinarith [hle, hh]

/-
**Two-sided `Θ(h)` bound.** Combining the lower bound of this file with the upper
bound `emlQuadApprox_error` from `EML.QuadraticApproxRate`, the error at `x = 1`
is sandwiched between `h/3` and `(4/9)·h`: the rate is linear and sharp.
-/
theorem emlQuadApprox_error_Theta (h : ℝ) (hh0 : 0 < h) (hh1 : h ≤ 1) :
    h / 3 ≤ emlQuadApprox h 1 - (1 : ℝ) ^ 2 ∧
    |emlQuadApprox h 1 - (1 : ℝ) ^ 2| ≤ (4 / 9) * h := by
  refine ⟨emlQuadApprox_lower h hh0, ?_⟩
  exact emlQuadApprox_error h hh0 hh1 1 (by norm_num)

/-
**Width-`n` lower bound.** Choosing `h = 1/n`, the width-`n` EML network differs
from `x² = 1` at `x = 1` by at least `1/(3n)`: a quantitative lower bound matching
the `O(1/n)` upper bound of `emlQuadApprox_rate`.
-/
theorem emlQuadApprox_rate_lower (n : ℕ) (hn : 1 ≤ n) :
    1 / (3 * n) ≤ emlQuadApprox (1 / n) 1 - (1 : ℝ) ^ 2 := by
  have hpos : (0 : ℝ) < 1 / n := by positivity
  have := emlQuadApprox_lower (1 / n) hpos
  have heq : (1 / (n : ℝ)) / 3 = 1 / (3 * n) := by ring
  rwa [heq] at this

/-
**The error never beats the linear rate.** For every `0 < h` the (signed) error
at `x = 1` is strictly positive; consequently `error / h ≥ 1/3 > 0`, so the
quotient does not tend to `0`. This rules out any super-linear rate `o(h)` for the
specific EML network `emlQuadApprox`, in sharp contrast to the existential
guarantees of generic universal-approximation theorems.
-/
theorem emlQuadApprox_not_o (h : ℝ) (hh : 0 < h) :
    1 / 3 ≤ (emlQuadApprox h 1 - (1 : ℝ) ^ 2) / h := by
  rw [le_div_iff₀ hh]
  have := emlQuadApprox_lower h hh
  linarith

/-
-- !-- Lab Notes -- !--

## Hypothesis (Hypothesizer)
The catalog (`EML.QuadraticApproxRate`) proves the *upper* Jackson bound
`|emlQuadApprox h x − x²| ≤ (4/9)·h`. Bold conjecture: this linear rate is sharp —
the construction genuinely cannot do better than `Θ(1/n)`. Concretely, at `x = 1`
the error should be bounded *below* by a positive multiple of `h`.

## Experiment (Experimenter)
Numerical probe of `emlQuadApprox h 1 − 1`:
  h = 0.1  → 0.03419   ( h/3 = 0.0333,  (4/9)h = 0.0444 )
  h = 0.01 → 0.003342  ( h/3 = 0.00333, (4/9)h = 0.00444 )
The signed error hugs `h/3` from above — a clean linear lower bound is plausible.

## Analysis (Analyst)
Writing the network at `x = 1` as `(2/h²)(exp h − 1 − h)` and using the partial
exponential series `1 + h + h²/2 + h³/6 ≤ exp h` (`Real.sum_le_exp_of_nonneg` at
`n = 4`) gives `(2/h²)(exp h − 1 − h) ≥ 1 + h/3`, i.e. error `≥ h/3`. This is
"true and structural": the `h³/6` term of the series is exactly what survives the
`(2/h²)` rescaling to produce the `h/3` floor. No counterexample; the bound is the
genuine leading-order behaviour.

## Critique (Critic)
- Not trivial: needs the exponential-series lower bound and a `field_simp`/`nlinarith`
  clearing of the `h²` denominator; `native_decide` cannot see real analysis.
- Boundary: `h = 0` excluded (pole); the endpoint `x = 1` is where the error is
  largest, so it is the right witness for sharpness.
- Genuinely extends the catalog: it *complements* `emlQuadApprox_error` with a
  matching lower bound, upgrading the one-sided `O(1/n)` to a two-sided `Θ(1/n)`
  and proving the rate is not improvable for this network.

## Synthesis (PI)
The explicit EML quadratic network has error exactly `Θ(1/n)` on `[0,1]`. The
linear Jackson rate is sharp for this construction; achieving `O(1/n²)` would
require a genuinely different (e.g. higher-order difference) EML network — which is
exactly the direction pursued in `EML.CubicApproxRate`.
-/
end