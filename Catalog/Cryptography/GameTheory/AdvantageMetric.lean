/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Advantage as a Pseudo-Metric: the Quantitative Conservation Laws of Reductions

This file isolates the *two quantitative engines* that drive every
provable-security argument and proves them as standalone, axiom-clean theorems.

The unifying thread is **conservation**. Computational indistinguishability,
measured by *advantage*, behaves like a pseudo-metric coordinate:

* the **hybrid argument** is sub-additivity of advantage along a path of games
  (an *additive* conservation law), and
* **reduction composition** is multiplicativity of advantage-loss
  (a *multiplicative* conservation law).

All results are stated over an arbitrary real-valued advantage sequence
`d : ℕ → ℝ`, so they are reusable building blocks rather than ad-hoc bounds.

## Main results

* `advantage_triangle` — the triangle inequality for the advantage coordinate.
* `hybrid_argument` — telescoping: `|d 0 − d n| ≤ Σ_{i<n} |d i − d (i+1)|`.
* `hybrid_averaging` — pigeonhole: a total gap `≥ ε` forces a single step `≥ ε/n`.
* `reduction_composition` — advantage losses multiply: `advC ≤ (l₂·l₁)·advA`.
* `prg_stretch_amplification` — a uniform per-step gap `ε` over `n` hybrids
  yields a total gap `≤ n·ε`.

-- !-- Lab Notebook -- !--
Hypothesis: The "factor" bookkeeping of cryptographic hybrid/composition
  arguments is nothing but the additive (triangle) and multiplicative
  (Lipschitz-composition) conservation laws of a single real coordinate, the
  advantage. If true, each should reduce to a one-line Mathlib fact about ℝ
  plus a telescoping/pigeonhole step.
Result: Confirmed. `advantage_triangle` is `abs_sub_le`; `hybrid_argument` is a
  telescoping sum bounded by `Finset.abs_sum_le_sum_abs`; `hybrid_averaging` is
  the averaging pigeonhole; `reduction_composition` is monotone multiplication;
  `prg_stretch_amplification` chains the telescope with a constant bound.
Insight: Advantage is a genuine pseudo-metric coordinate. Sub-additivity along
  a *path* (hybrid) and multiplicativity of *loss* (composition) are dual and
  independent; the whole quantitative theory is their interplay.
Failure analysis: The averaging step is false without `0 < n`; with `n = 0`
  the empty sum is `0 ≥ ε` forces `ε ≤ 0` and there is no index to return.
  Hence the explicit positivity hypothesis.
-- !-- Lab Notebook -- !--
-/

namespace Cryptography.AdvantageMetric

open Finset

-- !-- The advantage coordinate satisfies the triangle inequality: chaining a
-- transition through an intermediate game `b` can only sub-add the gaps. -- !--
/-- **Triangle inequality for advantage.** The advantage between two games is at
most the sum of advantages through any intermediate game. -/
theorem advantage_triangle (a b c : ℝ) : |a - c| ≤ |a - b| + |b - c| := by
  exact abs_sub_le _ _ _

-- !-- Telescoping: `d 0 − d n = Σ (d i − d (i+1))`, then bound the absolute
-- value of a sum by the sum of absolute values. -- !--
/-- **The hybrid argument.** The end-to-end advantage along a sequence of `n`
games is bounded by the sum of the per-step advantages (sub-additivity along a
path). -/
theorem hybrid_argument (d : ℕ → ℝ) (n : ℕ) :
    |d 0 - d n| ≤ ∑ i ∈ Finset.range n, |d i - d (i + 1)| := by
  induction' n with n ih;
  · norm_num;
  · rw [ Finset.sum_range_succ ] ; exact le_trans ( abs_sub_le _ _ _ ) ( by linarith ) ;

-- !-- Pigeonhole/averaging: if every term were `< ε/n`, the sum would be
-- `< n·(ε/n) = ε`, contradicting the hypothesis. -- !--
/-- **Hybrid averaging.** If the total advantage across `n` steps is at least
`ε`, then some single step contributes at least `ε / n`. This is the extraction
principle at the heart of every hybrid reduction. -/
theorem hybrid_averaging (a : ℕ → ℝ) (n : ℕ) (ε : ℝ) (hn : 0 < n)
    (hsum : ε ≤ ∑ i ∈ Finset.range n, a i) :
    ∃ i, i < n ∧ ε / n ≤ a i := by
  contrapose! hsum;
  exact lt_of_lt_of_le ( Finset.sum_lt_sum_of_nonempty ⟨ _, Finset.mem_range.mpr hn ⟩ fun i hi => hsum i ( Finset.mem_range.mp hi ) ) ( by simp +decide [ mul_div_cancel₀, hn.ne' ] )

-- !-- Monotone multiplication: `advC ≤ l₂·advB ≤ l₂·(l₁·advA) = (l₂·l₁)·advA`,
-- using `0 ≤ l₂` to preserve the middle inequality. -- !--
/-- **Reduction composition.** Advantage losses multiply: if a reduction loses a
factor `l₁` and a second loses `l₂`, their composition loses `l₂·l₁`. -/
theorem reduction_composition (advA advB advC l₁ l₂ : ℝ) (hl₂ : 0 ≤ l₂)
    (hAB : advB ≤ l₁ * advA) (hBC : advC ≤ l₂ * advB) :
    advC ≤ (l₂ * l₁) * advA := by
  convert hBC.trans ( mul_le_mul_of_nonneg_left hAB hl₂ ) using 1 ; ring

-- !-- Apply `hybrid_argument`, then bound the sum of `n` terms each `≤ ε` by
-- `n·ε` with `Finset.sum_le_sum` and `Finset.sum_const`. -- !--
/-- **PRG-stretch amplification.** If each of `n` consecutive hybrids is
indistinguishable up to `ε`, the extremes are indistinguishable up to `n·ε`. -/
theorem prg_stretch_amplification (d : ℕ → ℝ) (n : ℕ) (ε : ℝ)
    (hstep : ∀ i, i < n → |d i - d (i + 1)| ≤ ε) :
    |d 0 - d n| ≤ n * ε := by
  induction' n with n ih;
  · norm_num;
  · exact abs_le.mpr ⟨ by push_cast; linarith [ abs_le.mp ( ih fun i hi => hstep i ( Nat.lt_succ_of_lt hi ) ), abs_le.mp ( hstep n ( Nat.lt_succ_self n ) ) ], by push_cast; linarith [ abs_le.mp ( ih fun i hi => hstep i ( Nat.lt_succ_of_lt hi ) ), abs_le.mp ( hstep n ( Nat.lt_succ_self n ) ) ] ⟩

end Cryptography.AdvantageMetric