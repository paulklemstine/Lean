import Catalog.Novelty.AntiFibonacciSumSpectrum

/-!
# The Anti-Fibonacci Sequence — Cubic Cesàro Growth of the Partial Sums

This file is the *analytic* companion to `Catalog.Novelty.AntiFibonacciSumSpectrum`.
From the exact cubic partial-sum identity there
(`6 · ∑_{k≤n} antiFib k = n³ + 5n + 6`) we read off the sharp *cubic* asymptotics of
the anti-Fibonacci partial sums:

* `antiFib_sum_real` — the real-valued closed form
  `∑_{k=0}^{n} antiFib k = (n³ + 5n + 6) / 6`.
* `antiFib_cesaro` — **cubic Cesàro growth**:
  `(∑_{k=0}^{n} antiFib k) / n³ → 1/6`.

This is the correct counterpoint to the *value*-level growth `antiFib n / n² → 1/2`
proved in `Catalog.Novelty.Asymptotics`: summing a `~ n²/2` sequence yields a `~ n³/6`
partial sum, exactly as `∫ x²/2 dx = x³/6`.  For genuine (exponential) Fibonacci the
analogous quantity `(∑_{k≤n} F k)/n³ = (F(n+2)-1)/n³` diverges to `+∞`; the
anti-Fibonacci partial sums instead have a *finite* cubic density `1/6`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): if `antiFib n ~ n²/2`, then Abel/Euler summation predicts
`∑_{k≤n} antiFib k ~ n³/6`, so `(∑_{k≤n} antiFib k)/n³ → 1/6`.  Falsifiable: the limit
is a *finite nonzero* constant (unlike Fibonacci, where the same ratio diverges).

Experiment (Experimenter): with `6·∑ = n³+5n+6` (proved ∈ the sibling file), at
`n = 100,200,…,600` the ratio `6·∑/n³` is `1.00050, 1.00013, …, 1.0000139…`,
monotonically approaching `1`; hence `∑/n³ → 1/6` (confirmed).

Analysis (Analyst): the exact identity kills all error terms: `∑/n³ = (1 + 5/n² +
6/n³)/6`.  Since `1/n² → 0` and `1/n³ → 0`, the limit is `1/6` by the algebra of
limits — no `O(·)` estimates, no integral comparison needed.

Critique (Critic): the statement must be a genuine limit, not a definitional rewrite.
We divide by `(n:ℝ)³` (which vanishes at `n = 0`), so we pass to the eventual filter
`atTop` and rewrite via `tendsto_congr'` on `n ≥ 1`, exactly as the sibling
`antiFib_growth` handles its `n²` denominator.  The `1/6` is irrational-free and
finite, and provably differs from Fibonacci's divergent behaviour.

Synthesis: the anti-Fibonacci partial sums grow like `n³/6`; the cubic Cesàro density
is the finite constant `1/6`, the discrete antiderivative of the value density `1/2`.
-- !-- Lab Notes -- !--
-/

open Filter Topology

namespace AntiFibonacci

/-- Real-valued closed form of the partial sum: `∑_{k=0}^{n} antiFib k = (n³+5n+6)/6`. -/
theorem antiFib_sum_real (n : ℕ) :
    (∑ k ∈ Finset.range (n + 1), (antiFib k : ℝ)) = ((n : ℝ) ^ 3 + 5 * n + 6) / 6 := by
  have h := antiFib_sum_closed n
  have hcast : (6 : ℝ) * (∑ k ∈ Finset.range (n + 1), (antiFib k : ℝ))
      = (n : ℝ) ^ 3 + 5 * n + 6 := by
    have : ((6 * (∑ k ∈ Finset.range (n + 1), antiFib k) : ℕ) : ℝ)
        = ((n ^ 3 + 5 * n + 6 : ℕ) : ℝ) := by exact_mod_cast congrArg (Nat.cast) h
    push_cast at this ⊢
    linarith [this]
  linarith [hcast]

/-
**Cubic Cesàro growth.** The anti-Fibonacci partial sums satisfy
`(∑_{k=0}^{n} antiFib k) / n³ → 1/6`: a finite cubic density, the discrete
antiderivative of the value-level density `antiFib n / n² → 1/2`.  (For exponential
Fibonacci the analogous ratio diverges.)
-/
theorem antiFib_cesaro :
    Tendsto (fun n : ℕ => (∑ k ∈ Finset.range (n + 1), (antiFib k : ℝ)) / (n : ℝ) ^ 3)
      atTop (𝓝 (1 / 6)) := by
  have h1 : Tendsto (fun n : ℕ => (1 : ℝ) / (n : ℝ)) atTop (𝓝 0) :=
    tendsto_one_div_atTop_nhds_zero_nat
  have h2 : Tendsto (fun n : ℕ => (1 : ℝ) / (n : ℝ) ^ 2) atTop (𝓝 0) := by
    have := h1.mul h1
    simp only [mul_zero] at this
    convert this using 2 with n; ring
  have h3 : Tendsto (fun n : ℕ => (1 : ℝ) / (n : ℝ) ^ 3) atTop (𝓝 0) := by
    have := h1.mul (h1.mul h1)
    simp only [mul_zero] at this
    convert this using 2 with n; ring
  have hev : ∀ᶠ n : ℕ in atTop,
      (∑ k ∈ Finset.range (n + 1), (antiFib k : ℝ)) / (n : ℝ) ^ 3
        = 1 / 6 + 5 / 6 * (1 / (n : ℝ) ^ 2) + 1 / (n : ℝ) ^ 3 := by
    filter_upwards [eventually_gt_atTop 0] with n hn
    have hn0 : (n : ℝ) ≠ 0 := by positivity
    rw [antiFib_sum_real]; field_simp
  rw [tendsto_congr' hev]
  have := ((tendsto_const_nhds (x := (1 / 6 : ℝ))).add (h2.const_mul (5 / 6))).add h3
  simpa using this

end AntiFibonacci