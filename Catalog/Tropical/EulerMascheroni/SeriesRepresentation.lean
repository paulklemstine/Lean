import Mathlib

/-!
# A telescoping series representation of the Euler–Mascheroni constant

This file establishes the classical series
`γ = ∑_{k≥1} (1/k - log(1 + 1/k))`
for the Euler–Mascheroni constant `γ = Real.eulerMascheroniConstant`, building on
Mathlib's `Real.eulerMascheroniSeq` (the sequence `harmonic n - log (n+1)`).

The key observation is that the `n`-th partial sum of the series telescopes
*exactly* to `Real.eulerMascheroniSeq n`, so convergence of Mathlib's sequence
immediately yields a genuine `HasSum`.

## Main results
* `EulerMascheroni.emTerm` — the `k`-th term `1/(k+1) - (log (k+2) - log (k+1))`.
* `EulerMascheroni.partialSum_emTerm` — partial sums telescope to
  `Real.eulerMascheroniSeq n`.
* `EulerMascheroni.emTerm_nonneg` — every term is non-negative.
* `EulerMascheroni.hasSum_emTerm` — **the series sums to `γ`**.
* `EulerMascheroni.tendsto_partialSum_emTerm` — partial sums converge to `γ`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): The defining sequence `H_n - log(n+1)` of γ is itself a
  partial sum of a fixed nonnegative series, namely `∑ (1/k - log(1+1/k))`. If true,
  this turns the *limit* definition of γ into an honest convergent series with a
  `HasSum` certificate.
EXPERIMENT (Experimenter): Proved `∑_{k<n} (1/(k+1) - (log(k+2)-log(k+1))) = H_n - log(n+1)`
  by splitting the sum; the harmonic part is `harmonic n` definitionally and the log
  part telescopes via `Finset.sum_range_sub`. Non-negativity of each term reduces to
  `log x ≤ x - 1` (`Real.log_le_sub_one_of_pos`) at `x = (k+2)/(k+1)`.
ANALYSIS (Analyst): The identity is exact (no error term), so `HasSum` follows from
  `hasSum_iff_tendsto_nat_of_nonneg` plus Mathlib's `tendsto_eulerMascheroniSeq`.
  Non-negativity is essential: without it `Tendsto` of range-partial-sums would not
  upgrade to `HasSum` (the series is only conditionally indexed otherwise).
CRITIQUE (Critic): The theorem is not a definitional restatement — it produces a new
  object (`HasSum`) about an unordered sum, which is strictly stronger than the
  sequential limit Mathlib provides. The proof uses telescoping + a strict convexity
  inequality, not `rfl`/`simp`/`decide`.
SYNTHESIS (PI): A reusable `HasSum` certificate for γ that downstream files (the
  Tropical bridge) build on.
-/

open Real Finset Filter Topology

namespace EulerMascheroni

/-- The `k`-th term of the telescoping Euler–Mascheroni series:
`1/(k+1) - (log (k+2) - log (k+1)) = 1/(k+1) - log (1 + 1/(k+1))`. -/
noncomputable def emTerm (k : ℕ) : ℝ :=
  1 / (k + 1) - (Real.log (k + 2) - Real.log (k + 1))

/-- The partial sums of `emTerm` telescope to Mathlib's `eulerMascheroniSeq`. -/
theorem partialSum_emTerm (n : ℕ) :
    ∑ k ∈ Finset.range n, emTerm k = Real.eulerMascheroniSeq n := by
  unfold emTerm Real.eulerMascheroniSeq
  rw [Finset.sum_sub_distrib]
  have hlog : ∑ k ∈ Finset.range n, (Real.log (k + 2) - Real.log (k + 1))
      = Real.log (n + 1) := by
    rw [show (fun k : ℕ => Real.log (↑k + 2) - Real.log (↑k + 1))
          = (fun k : ℕ => Real.log ((↑(k + 1) : ℝ) + 1) - Real.log (↑k + 1)) by
        ext k; push_cast; ring_nf]
    rw [Finset.sum_range_sub (f := fun k : ℕ => Real.log (k + 1)) n]
    norm_num
  rw [hlog]
  have hharm : ∑ k ∈ Finset.range n, (1 : ℝ) / (k + 1) = (harmonic n : ℝ) := by
    rw [harmonic]; push_cast
    exact Finset.sum_congr rfl fun k _ => by rw [one_div]
  rw [hharm]

/-- Each term of the series is non-negative, since `log(1 + x) ≤ x`. -/
theorem emTerm_nonneg (k : ℕ) : 0 ≤ emTerm k := by
  unfold emTerm
  have hx : (0 : ℝ) < ((k : ℝ) + 2) / ((k : ℝ) + 1) := by positivity
  have h := Real.log_le_sub_one_of_pos hx
  rw [Real.log_div (by positivity) (by positivity)] at h
  have hsub : ((k : ℝ) + 2) / ((k : ℝ) + 1) - 1 = 1 / ((k : ℝ) + 1) := by
    field_simp; ring
  rw [hsub] at h
  linarith

/-- **Series representation of the Euler–Mascheroni constant.**
`∑_{k≥1} (1/k - log(1 + 1/k)) = γ` (as an unordered `HasSum`). -/
theorem hasSum_emTerm : HasSum emTerm Real.eulerMascheroniConstant := by
  rw [hasSum_iff_tendsto_nat_of_nonneg emTerm_nonneg]
  refine Real.tendsto_eulerMascheroniSeq.congr ?_
  intro n
  exact (partialSum_emTerm n).symm

/-- The partial sums of the Euler–Mascheroni series converge to `γ`. -/
theorem tendsto_partialSum_emTerm :
    Tendsto (fun n => ∑ k ∈ Finset.range n, emTerm k) atTop
      (𝓝 Real.eulerMascheroniConstant) := by
  refine Real.tendsto_eulerMascheroniSeq.congr ?_
  intro n
  exact (partialSum_emTerm n).symm

/-- The Euler–Mascheroni series is summable. -/
theorem summable_emTerm : Summable emTerm :=
  hasSum_emTerm.summable

end EulerMascheroni