import Mathlib

/-!
# A convergent series representation of the Euler–Mascheroni constant

Mathlib defines `Real.eulerMascheroniConstant` as the limit of the sequence
`eulerMascheroniSeq n = H_n - log (n + 1)` and proves the basic monotone /
bracketing facts (`Real.tendsto_eulerMascheroniSeq`,
`Real.eulerMascheroniSeq_lt_eulerMascheroniConstant`, …).  It does **not**, however,
record `γ` as the *sum of an explicit convergent series*.

Here we prove the classical identity
$$ \gamma \;=\; \sum_{k=0}^{\infty}\Bigl(\tfrac{1}{k+1} - \log\tfrac{k+2}{k+1}\Bigr)
        \;=\; \sum_{m=1}^{\infty}\Bigl(\tfrac1m - \log(1+\tfrac1m)\Bigr). $$
Every term is nonnegative (because `log(1+x) ≤ x`), and the partial sums telescope
*exactly* onto Mathlib's `eulerMascheroniSeq`, so the series converges to `γ` as a
`HasSum`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the defining sequence `H_n - log(n+1)` is itself the
sequence of partial sums of the term-by-term series `1/m - log(1+1/m)`; if so, `γ`
is literally a sum of a nonnegative convergent series.
Experiment (Experimenter): formalize `partial_sum n = eulerMascheroniSeq n` by
splitting the finite sum and telescoping `∑ log((k+2)/(k+1)) = log(n+1)`; combine
with `hasSum_iff_tendsto_nat_of_nonneg` and `Real.tendsto_eulerMascheroniSeq`.
Analysis (Analyst): the telescoping is the crux — `∑_{k<n} log((k+2)/(k+1))`
collapses via `log_mul` to `log(n+1)`; the harmonic part is a routine cast.
The nonnegativity of every term is exactly the convexity bound `log x ≤ x - 1`.
Critique (Critic): `HasSum` is genuinely stronger than the bare `Tendsto` of
`range`-partial sums for a general series, but is *equivalent* here precisely
because the terms are nonnegative — `term_nonneg` is therefore load-bearing, not
decorative.  Removing it would make `hasSum_iff_tendsto_nat_of_nonneg`
inapplicable and the `HasSum` claim false in general.
Synthesis (PI): the series representation is the cleanest bridge from Mathlib's
limit definition to the "series acceleration / integral representation" theme, and
is reused downstream (`EulerMascheroniApprox`) to identify the tail with the
approximation error.
-- !-- end Lab Notes -- !--
-/

open Real Filter Finset Topology

namespace EulerMascheroniSeries

/-- The `k`-th series term `1/(k+1) - log((k+2)/(k+1)) = 1/(k+1) - log(1 + 1/(k+1))`. -/
noncomputable def term (k : ℕ) : ℝ := 1 / (k + 1 : ℝ) - Real.log ((k + 2) / (k + 1))

/-- Each term is nonnegative, by the convexity bound `log x ≤ x - 1`. -/
lemma term_nonneg (k : ℕ) : 0 ≤ term k := by
  have hx : (0 : ℝ) < (k + 2) / (k + 1) := by positivity
  have h := Real.log_le_sub_one_of_pos hx
  have hsub : ((k : ℝ) + 2) / (k + 1) - 1 = 1 / (k + 1) := by field_simp; ring
  rw [hsub] at h
  simpa [term] using sub_nonneg.mpr h

/-- The real harmonic number as a finite sum of reciprocals. -/
lemma harmonic_cast (n : ℕ) : (harmonic n : ℝ) = ∑ k ∈ range n, 1 / (k + 1 : ℝ) := by
  rw [harmonic]; push_cast; simp [one_div]

/-- The logarithmic part telescopes: `∑_{k<n} log((k+2)/(k+1)) = log(n+1)`. -/
lemma sum_log_telescope (n : ℕ) :
    ∑ k ∈ range n, Real.log ((k + 2) / (k + 1) : ℝ) = Real.log (n + 1) := by
  induction n with
  | zero => simp
  | succ m ih =>
    rw [Finset.sum_range_succ, ih, ← Real.log_mul (by positivity) (by positivity)]
    congr 1; push_cast; field_simp; ring

/-- The `n`-th partial sum of the series equals Mathlib's `eulerMascheroniSeq n`. -/
lemma partial_sum (n : ℕ) :
    ∑ k ∈ range n, term k = Real.eulerMascheroniSeq n := by
  unfold term Real.eulerMascheroniSeq
  rw [Finset.sum_sub_distrib, sum_log_telescope, ← harmonic_cast]

/-- **Series representation of the Euler–Mascheroni constant.**
`γ = ∑_{k≥0} (1/(k+1) - log((k+2)/(k+1)))`. -/
theorem hasSum_eulerMascheroni :
    HasSum term Real.eulerMascheroniConstant := by
  refine (hasSum_iff_tendsto_nat_of_nonneg term_nonneg _).mpr ?_
  simp_rw [partial_sum]
  exact Real.tendsto_eulerMascheroniSeq

/-- The series is summable. -/
lemma summable_term : Summable term := hasSum_eulerMascheroni.summable

/-- `tsum` form of the series representation. -/
theorem tsum_eulerMascheroni :
    ∑' k, term k = Real.eulerMascheroniConstant :=
  hasSum_eulerMascheroni.tsum_eq

end EulerMascheroniSeries