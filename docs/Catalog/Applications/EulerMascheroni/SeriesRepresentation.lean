/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Euler–Mascheroni Constant: An Accelerated, Manifestly Convergent Series

This file develops a *manifestly convergent* series representation of the
Euler–Mascheroni constant `γ = lim (H_n - log n)` built on Mathlib's
`eulerMascheroniConstant`, together with a sharp two-sided rational
approximation error bound.

The classical definition of `γ` as `lim (H_n - log(n+1))` is a difference of two
quantities that each diverge.  We package the *increments* of the defining
sequence into a single series whose `k`-th term

  `gammaTerm k = 1/(k+1) - (log(k+2) - log(k+1)) = 1/(k+1) - log(1 + 1/(k+1))`

is *nonnegative* (because `log(1+x) ≤ x`), so the resulting series converges
unconditionally and its partial sums equal the defining sequence exactly.

## Main results

- `EMR.sum_gammaTerm` : the `n`-th partial sum of `gammaTerm` telescopes
  exactly to `eulerMascheroniSeq n = H_n - log(n+1)`.
- `EMR.gammaTerm_nonneg` : every term is nonnegative.
- `EMR.hasSum_gammaTerm` : `HasSum gammaTerm eulerMascheroniConstant`, i.e.
  `γ = ∑_{k} (1/(k+1) - log(1 + 1/(k+1)))` as an unconditionally convergent sum.
- `EMR.tsum_gammaTerm` : `∑' k, gammaTerm k = γ`.
- `EMR.approx_error_bound` : for `n ≥ 1` the lower-sequence approximation is
  good to within `log(n+1) - log n = log(1 + 1/n)`:
    `0 < γ - (H_n - log(n+1)) < log(n+1) - log n`.

These give explicit, computable, *rational-plus-logarithm* approximations to `γ`
with a controlled (`O(1/n)`) error — the natural starting point for
irrationality investigations (see `IrrationalityCriterion.lean`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The defining sequence `H_n - log(n+1)` for `γ`, being
monotone increasing and bounded, must arise as the partial sums of a nonnegative
series; identifying that series gives an "accelerated" (manifestly convergent)
representation and a clean error bound.

Experiment (Experimenter): Defined `gammaTerm k = 1/(k+1) - (log(k+2)-log(k+1))`.
Proved the partial sums telescope to `eulerMascheroniSeq n` (`sum_gammaTerm`,
via induction for the log part and a cast identity for the harmonic part).
Nonnegativity follows from `Real.log_le_sub_one_of_pos` applied to `(k+2)/(k+1)`.
Summability from `summable_of_sum_range_le` with the ceiling `γ` provided by
Mathlib's `eulerMascheroniSeq_lt_eulerMascheroniConstant`.

Analysis (Analyst): The key structural insight is that `1/(k+1) - log(1+1/(k+1))`
is exactly the "overshoot" of the harmonic increment over the logarithmic
increment, and that this overshoot is provably nonnegative — turning a
difference of divergent series into a convergent series of positive terms.
The error bound is exactly the gap between Mathlib's lower sequence
`H_n - log(n+1)` and upper sequence `H_n - log n`.

Critique (Critic): The HasSum statement is NOT a definitional rewrite: it
upgrades the `Tendsto` of `range`-partial-sums to an unconditional `HasSum`,
which requires genuine summability.  The error bound is strict on both sides and
uses the strict monotonicity/antitonicity of the two Mathlib sequences.  No
`native_decide`, no vacuity.

Synthesis (PI): `γ` now has a manifestly convergent series and a sharp
`O(1/n)` rational-plus-log approximation, feeding the irrationality work.
-- !-- Lab Notes -- !--
-/
import Mathlib

open Real Filter Topology
open scoped BigOperators

namespace EMR

/-- The `k`-th term of the accelerated series for the Euler–Mascheroni constant:
`1/(k+1) - (log(k+2) - log(k+1)) = 1/(k+1) - log(1 + 1/(k+1))`. -/
noncomputable def gammaTerm (k : ℕ) : ℝ :=
  1 / (k + 1) - (Real.log (k + 2) - Real.log (k + 1))

/-- The real cast of the `n`-th harmonic number is the obvious finite sum. -/
lemma harmonic_cast_eq (n : ℕ) :
    (harmonic n : ℝ) = ∑ k ∈ Finset.range n, (1 : ℝ) / (k + 1) := by
  simp only [harmonic, Rat.cast_sum]
  apply Finset.sum_congr rfl
  intro k _
  push_cast; ring

/-- The logarithmic increments telescope: `∑_{k<n} (log(k+2) - log(k+1)) = log(n+1)`. -/
lemma log_telescope (n : ℕ) :
    ∑ k ∈ Finset.range n, (Real.log (k + 2) - Real.log (k + 1)) = Real.log (n + 1) := by
  induction n with
  | zero => simp
  | succ m ih =>
      rw [Finset.sum_range_succ, ih]
      push_cast
      ring_nf

/-- The `n`-th partial sum of `gammaTerm` telescopes to `eulerMascheroniSeq n`. -/
lemma sum_gammaTerm (n : ℕ) :
    ∑ k ∈ Finset.range n, gammaTerm k = eulerMascheroniSeq n := by
  unfold gammaTerm
  rw [Finset.sum_sub_distrib, log_telescope, ← harmonic_cast_eq]
  rfl

/-- Every term of the accelerated series is nonnegative, since
`log(1 + 1/(k+1)) ≤ 1/(k+1)`. -/
lemma gammaTerm_nonneg (k : ℕ) : 0 ≤ gammaTerm k := by
  unfold gammaTerm
  have hpos : (0:ℝ) < ((k:ℝ) + 2) / ((k:ℝ) + 1) := by positivity
  have hlog : Real.log (((k:ℝ)+2)/((k:ℝ)+1)) ≤ ((k:ℝ)+2)/((k:ℝ)+1) - 1 :=
    Real.log_le_sub_one_of_pos hpos
  rw [Real.log_div (by positivity) (by positivity)] at hlog
  have heq : ((k:ℝ)+2)/((k:ℝ)+1) - 1 = 1/((k:ℝ)+1) := by field_simp; ring
  rw [heq] at hlog
  linarith

/-- The accelerated series is summable, bounded above by `γ`. -/
lemma summable_gammaTerm : Summable gammaTerm := by
  apply summable_of_sum_range_le gammaTerm_nonneg (c := eulerMascheroniConstant)
  intro n
  rw [sum_gammaTerm]
  exact (eulerMascheroniSeq_lt_eulerMascheroniConstant n).le

/-- **Accelerated series representation of `γ`.**
`γ = ∑_{k} (1/(k+1) - log(1 + 1/(k+1)))` as an unconditionally convergent sum. -/
theorem hasSum_gammaTerm : HasSum gammaTerm eulerMascheroniConstant := by
  have hsum := summable_gammaTerm
  have h1 : Tendsto (fun n => ∑ k ∈ Finset.range n, gammaTerm k) atTop
      (𝓝 eulerMascheroniConstant) := by
    simp_rw [sum_gammaTerm]
    exact tendsto_eulerMascheroniSeq
  have h2 := hsum.hasSum.tendsto_sum_nat
  have heq : ∑' k, gammaTerm k = eulerMascheroniConstant := tendsto_nhds_unique h2 h1
  rw [← heq]
  exact hsum.hasSum

/-- The `tsum` form of the accelerated series representation. -/
theorem tsum_gammaTerm : ∑' k, gammaTerm k = eulerMascheroniConstant :=
  hasSum_gammaTerm.tsum_eq

/-- **Sharp two-sided approximation error bound.** For `n ≥ 1` the lower-sequence
approximation `H_n - log(n+1)` underestimates `γ` by a strictly positive amount
that is strictly less than `log(n+1) - log n = log(1 + 1/n)`. -/
theorem approx_error_bound (n : ℕ) (hn : 1 ≤ n) :
    0 < eulerMascheroniConstant - eulerMascheroniSeq n ∧
    eulerMascheroniConstant - eulerMascheroniSeq n < Real.log (n+1) - Real.log n := by
  refine ⟨by linarith [eulerMascheroniSeq_lt_eulerMascheroniConstant n], ?_⟩
  have h1 := eulerMascheroniConstant_lt_eulerMascheroniSeq' n
  have hne : n ≠ 0 := by omega
  rw [show eulerMascheroniSeq' n = (harmonic n:ℝ) - Real.log n by
    simp [eulerMascheroniSeq', hne]] at h1
  rw [show eulerMascheroniSeq n = (harmonic n:ℝ) - Real.log (n+1) from rfl]
  linarith

end EMR