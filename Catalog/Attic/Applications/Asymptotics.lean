import Novelty.AntiFibonacci.Basic

/-!
# The Anti-Fibonacci Sequence — Asymptotics and Golden-Ratio Avoidance

Building on `Catalog.Novelty.AntiFibonacci.Basic`, this file establishes the
*analytic* counterpoint to Fibonacci:

* Fibonacci: `F (n+1) / F n → φ` (the golden ratio) and `F n` grows exponentially.
* Anti-Fibonacci: `antiFib (n+1) / antiFib n → 1` and `antiFib n / n² → 1/2`.

## Main results

* `antiFib_growth` — quadratic growth with the *correct* constant:
  `antiFib n / n² → 1/2` (refuting the brief's `1/4` conjecture).
* `antiFib_ratio_tendsto_one` — consecutive ratios converge to `1`.
* `antiFib_ratio_not_tendsto_goldenRatio` — the consecutive ratio does **not** tend to
  the golden ratio: the sequence "avoids the golden ratio at all costs".  It also does
  not oscillate between `1` and `2`; it genuinely *converges* (to `1`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the brief asserts `A(n+1)/A(n)` "oscillates between 1 and 2"
and never converges, and that `A n / n² → 1/4`.

Experiment (Experimenter): with the closed form `A n = (n² - n + 2)/2`, the ratio is
`A(n+1)/A(n) = (n²+n+2)/(n²-n+2)`.  Numerically: n=10 → 1.24, n=100 → 1.02,
n=1000 → 1.002.  It is monotonically approaching `1`, NOT oscillating.

Analysis (Analyst): `A n / n² = (1 - 1/n + 2/n²)/2 → 1/2`, so the growth constant is
`1/2`, not `1/4`.  The ratio limit `1` is forced because the growth is polynomial of a
fixed degree; polynomial sequences of degree `d ≥ 1` always have consecutive ratio `→ 1`.

Critique (Critic): "avoids the golden ratio" must be a *theorem*, not a slogan.  We use
uniqueness of limits: if the ratio tended to `φ`, then `1 = φ`; but `φ² = φ + 1` would
give `1 = 2`, a contradiction.  Hence the golden ratio is provably avoided.

Synthesis: the sequence trades Fibonacci's exponential/golden-ratio behaviour for
quadratic growth with ratio limit `1`; both the `1/4` and the "oscillates 1–2" claims of
the brief are false and are replaced by the sharp, proved statements below.
-- !-- Lab Notes -- !--
-/

open Filter Topology

namespace AntiFibonacci

/-- Helper: `1 / n² → 0`. -/
private theorem one_div_sq_tendsto_zero :
    Tendsto (fun n : ℕ => (1 : ℝ) / (n : ℝ) ^ 2) atTop (𝓝 0) := by
  have h1 : Tendsto (fun n : ℕ => (1 : ℝ) / (n : ℝ)) atTop (𝓝 0) :=
    tendsto_one_div_atTop_nhds_zero_nat
  have := h1.mul h1
  simp only [mul_zero] at this
  convert this using 2 with n
  ring

/-- **Main result (quadratic growth, corrected constant).**
`antiFib n / n² → 1/2`.  This refutes the brief's conjectured `1/4`. -/
theorem antiFib_growth :
    Tendsto (fun n : ℕ => (antiFib n : ℝ) / (n : ℝ) ^ 2) atTop (𝓝 (1 / 2)) := by
  have h1 : Tendsto (fun n : ℕ => (1 : ℝ) / (n : ℝ)) atTop (𝓝 0) :=
    tendsto_one_div_atTop_nhds_zero_nat
  have h2 := one_div_sq_tendsto_zero
  have hev : ∀ᶠ n : ℕ in atTop, (antiFib n : ℝ) / (n : ℝ) ^ 2
      = 1 / 2 - (1 / (n : ℝ)) / 2 + 1 / (n : ℝ) ^ 2 := by
    filter_upwards [eventually_gt_atTop 0] with n hn
    have hn0 : (n : ℝ) ≠ 0 := by positivity
    rw [antiFib_real]; field_simp
  rw [tendsto_congr' hev]
  have := ((tendsto_const_nhds (x := (1 / 2 : ℝ))).sub (h1.div_const 2)).add h2
  simpa using this

/-- **Main result (ratio limit).** Consecutive anti-Fibonacci ratios converge to `1`.
Contrast with Fibonacci, whose ratios converge to the golden ratio. -/
theorem antiFib_ratio_tendsto_one :
    Tendsto (fun n : ℕ => (antiFib (n + 1) : ℝ) / (antiFib n : ℝ)) atTop (𝓝 1) := by
  have h1 : Tendsto (fun n : ℕ => (1 : ℝ) / (n : ℝ)) atTop (𝓝 0) :=
    tendsto_one_div_atTop_nhds_zero_nat
  have h2 := one_div_sq_tendsto_zero
  have hnum : Tendsto (fun n : ℕ => 1 + 1 / (n : ℝ) + 2 / (n : ℝ) ^ 2) atTop (𝓝 1) := by
    have := ((tendsto_const_nhds (x := (1 : ℝ))).add h1).add (h2.const_mul 2)
    simpa using this
  have hden : Tendsto (fun n : ℕ => 1 - 1 / (n : ℝ) + 2 / (n : ℝ) ^ 2) atTop (𝓝 1) := by
    have := ((tendsto_const_nhds (x := (1 : ℝ))).sub h1).add (h2.const_mul 2)
    simpa using this
  have hdiv := hnum.div hden (by norm_num)
  have hev : ∀ᶠ n : ℕ in atTop, (antiFib (n + 1) : ℝ) / (antiFib n : ℝ)
      = (1 + 1 / (n : ℝ) + 2 / (n : ℝ) ^ 2) / (1 - 1 / (n : ℝ) + 2 / (n : ℝ) ^ 2) := by
    filter_upwards [eventually_gt_atTop 0] with n hn
    have hn0 : (n : ℝ) ≠ 0 := by positivity
    have hden0 : ((n : ℝ) ^ 2 - n + 2) ≠ 0 := by nlinarith [sq_nonneg ((n : ℝ) - 1)]
    rw [antiFib_real, antiFib_real]
    push_cast
    field_simp
    ring
  rw [tendsto_congr' hev]
  simpa using hdiv

/-- **Main result (golden-ratio avoidance).** The consecutive ratio does *not* converge
to the golden ratio `φ`.  Since it converges to `1` and `φ² = φ + 1` forbids `φ = 1`,
uniqueness of limits rules out convergence to `φ`. -/
theorem antiFib_ratio_not_tendsto_goldenRatio :
    ¬ Tendsto (fun n : ℕ => (antiFib (n + 1) : ℝ) / (antiFib n : ℝ)) atTop
        (𝓝 Real.goldenRatio) := by
  intro hg
  have h1 : (1 : ℝ) = Real.goldenRatio :=
    tendsto_nhds_unique antiFib_ratio_tendsto_one hg
  have hsq := Real.goldenRatio_sq
  rw [← h1] at hsq
  norm_num at hsq

end AntiFibonacci