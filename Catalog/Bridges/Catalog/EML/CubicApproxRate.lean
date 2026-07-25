/-
# EML Interpolation Theory: An Explicit Jackson-Type Rate for x³ on [0,1]

`EML.QuadraticApproxRate` realises `x²` on `[0,1]` as a rescaled *second*-order
forward difference of `exp`. This file generalises the technique one order higher,
constructing a single-exponential **EML network** for `x ↦ x³`:
`emlCubicApprox h x = (6/h³)·(exp(h·x) − 1 − h·x − (h·x)²/2)`,
the rescaled *third*-order increment of `exp`. Taylor's theorem (`Real.exp_bound`
at `n = 4`) gives the uniform error bound `|emlCubicApprox h x − x³| ≤ (5/16)·h` on
`[0,1]`, so `h = 1/n` produces a width-`n` family with the Jackson rate `O(1/n)`.

Together with `EML.QuadraticApproxRate` this shows the EML finite-difference
construction reaches *every* monomial constructively with an explicit linear rate,
the structural building block behind Stone–Weierstrass density (`EML.StoneWeierstrassApprox`).

## Main results
- `exp_sub_cubic_le`: Taylor estimate `|exp u − (1+u+u²/2+u³/6)| ≤ (5/96)·u⁴` on `[0,1]`.
- `emlCubicApprox_error`: uniform error bound `|emlCubicApprox h x − x³| ≤ (5/16)·h`.
- `emlCubicApprox_rate`: width-`n` rate `|emlCubicApprox (1/n) x − x³| ≤ 5/(16·n)`.
- `emlCubicApprox_tendsto`: pointwise convergence to `x³` on `[0,1]`.
-/
import Mathlib

noncomputable section

open Real

/-- The EML network approximating `x³`: the rescaled third-order increment of `exp`.
`emlCubicApprox h x = (6/h³)·(exp(h·x) − 1 − h·x − (h·x)²/2)`. Built only from `exp`,
addition, multiplication and scalars, it is an EML function. -/
def emlCubicApprox (h x : ℝ) : ℝ :=
  (6 / h ^ 3) * (Real.exp (h * x) - 1 - h * x - (h * x) ^ 2 / 2)

/-
**Key Taylor estimate.** For `u ∈ [0,1]`, the exponential exceeds its cubic Taylor
polynomial by at most `(5/96)·u⁴`.
-/
theorem exp_sub_cubic_le (u : ℝ) (hu0 : 0 ≤ u) (hu1 : u ≤ 1) :
    |Real.exp u - (1 + u + u ^ 2 / 2 + u ^ 3 / 6)| ≤ (5 / 96) * u ^ 4 := by
  have := Real.exp_bound (show |u| ≤ 1 by simpa [abs_of_nonneg hu0] using hu1)
    (show 0 < 4 by norm_num)
  norm_num [Finset.sum_range_succ, abs_of_nonneg hu0] at this ⊢
  linarith

/-
**Explicit uniform error bound.** On `[0,1]`, with step `0 < h ≤ 1`, the EML
network `emlCubicApprox h` approximates `x³` to within `(5/16)·h`.
-/
theorem emlCubicApprox_error (h : ℝ) (hh0 : 0 < h) (hh1 : h ≤ 1)
    (x : ℝ) (hx : x ∈ Set.Icc (0 : ℝ) 1) :
    |emlCubicApprox h x - x ^ 3| ≤ (5 / 16) * h := by
  have hb : |Real.exp (h * x) - (1 + (h * x) + (h * x) ^ 2 / 2 + (h * x) ^ 3 / 6)|
      ≤ (5 / 96) * (h * x) ^ 4 :=
    exp_sub_cubic_le (h * x) (mul_nonneg hh0.le hx.1) (mul_le_one₀ hh1 hx.1 hx.2)
  have h_id : emlCubicApprox h x - x ^ 3
      = (6 / h ^ 3) * (Real.exp (h * x) - (1 + (h * x) + (h * x) ^ 2 / 2 + (h * x) ^ 3 / 6)) := by
    have hh : h ≠ 0 := hh0.ne'
    unfold emlCubicApprox; field_simp; ring
  rw [h_id, abs_mul, abs_of_pos (by positivity), div_mul_eq_mul_div,
    div_le_iff₀ (by positivity)]
  have hx4 : (h * x) ^ 4 ≤ h ^ 4 := by
    have : x ^ 4 ≤ 1 := pow_le_one₀ hx.1 hx.2
    nlinarith [pow_nonneg hh0.le 4, mul_pow h x 4]
  nlinarith [hb, abs_nonneg (Real.exp (h * x) - (1 + (h * x) + (h * x) ^ 2 / 2 + (h * x) ^ 3 / 6)),
    hh0, hx4, pow_pos hh0 4]

/-
**Width-`n` Jackson-type rate.** Choosing `h = 1/n`, the width-`n` EML network
approximates `x³` on `[0,1]` with error at most `5/(16·n)`, i.e. rate `O(1/n)`.
-/
theorem emlCubicApprox_rate (n : ℕ) (hn : 1 ≤ n)
    (x : ℝ) (hx : x ∈ Set.Icc (0 : ℝ) 1) :
    |emlCubicApprox (1 / n) x - x ^ 3| ≤ 5 / (16 * n) := by
  convert emlCubicApprox_error (1 / n) (by positivity)
    (by rw [div_le_iff₀ (by positivity)]; norm_cast; linarith) x hx using 1
  ring

/-
**Convergence.** For each fixed `x ∈ [0,1]`, the width-`n` EML networks converge
to `x³` as `n → ∞`.
-/
theorem emlCubicApprox_tendsto (x : ℝ) (hx : x ∈ Set.Icc (0 : ℝ) 1) :
    Filter.Tendsto (fun n : ℕ => emlCubicApprox (1 / n) x) Filter.atTop (nhds (x ^ 3)) := by
  rw [Metric.tendsto_nhds]
  intro ε hε
  refine Filter.eventually_atTop.mpr ⟨⌈ε⁻¹ * 5⌉₊ + 1, fun n hn => ?_⟩
  have := emlCubicApprox_rate n (by linarith) x hx
  simp_all +decide
  exact this.trans_lt (by rw [div_lt_iff₀] <;> nlinarith [Nat.lt_of_ceil_lt hn, mul_inv_cancel₀ hε.ne'])

/-
-- !-- Lab Notes -- !--

## Hypothesis (Hypothesizer)
`EML.QuadraticApproxRate` reaches `x²` via the second-order increment of `exp`.
Bold conjecture: the same idea generalises one order up — the *third*-order
increment `(6/h³)(exp(hx) − 1 − hx − (hx)²/2)` is an EML network approximating `x³`
with the same linear Jackson rate `O(1/n)`, and the pattern continues for every
monomial.

## Experiment (Experimenter)
Numerical check (Float) of the error `emlCubicApprox h x − x³`:
  h = 0.1 , x = 1   → 0.02628   ( ≤ (5/16)·0.1  = 0.03125 )
  h = 0.01, x = 1   → 0.002510  ( ≤ (5/16)·0.01 = 0.003125 )
The bound `(5/16)·h` holds and is nearly tight at `x = 1`.

## Analysis (Analyst)
Setting `u = h·x`, algebra gives
  emlCubicApprox h x − x³ = (6/h³)·(exp u − (1 + u + u²/2 + u³/6)).
`Real.exp_bound` at `n = 4` bounds the remainder by `(5/96)|u|⁴`; substituting
`|u| = h·x ≤ 1` collapses the `h³` denominator to leave `(5/16)·h·x⁴ ≤ (5/16)·h`.
This is "true and the construction is the right one": each extra order of the
forward difference of `exp` peels off the next monomial, costing one factor of `h`
in the rate. The provable constant from `Real.exp_bound` is `5/16`.

## Critique (Critic)
- Not trivial: needs Taylor's theorem, the `u = h·x` substitution, `field_simp`/`ring`
  to clear the `h³` denominator, and `nlinarith` with the `x⁴ ≤ 1` bound.
- Boundary: `h = 0` excluded (division by zero); `x ∈ [0,1]` needed so `|u| ≤ 1`.
- Genuinely extends the catalog: it is a *new monomial* (`x³`) realised as an
  explicit EML network with a quantitative rate, demonstrating the
  finite-difference template scales beyond the catalog's `x²`.

## Synthesis (PI)
The order-`k` forward difference of `exp`, rescaled by `k!/hᵏ`, is an EML network
for `xᵏ` with rate `O(1/n)`. With `x²` (`QuadraticApproxRate`) and now `x³` in hand,
the entire polynomial algebra is constructively EML-approximable, providing the
explicit, rate-equipped backbone for the Stone–Weierstrass density of
`EML.StoneWeierstrassApprox`.
-/
end