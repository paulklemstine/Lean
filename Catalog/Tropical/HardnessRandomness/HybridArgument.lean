import Mathlib

/-!
# Hybrid Argument for Tropical Hardness vs Randomness

## Overview

The hybrid argument is the structural heart of the Nisan–Wigderson framework.
It decomposes the distinguishing advantage of any test against a multi-output
generator into a sum of single-coordinate prediction advantages.

This file proves two key lemmas:

1. **Telescope inequality**: The total distinguishing advantage is bounded by the
   sum of consecutive hybrid gaps.
2. **Averaging/pigeonhole lemma**: At least one coordinate contributes a gap
   of at least `total_advantage / m`.

These are domain-independent lemmas about sequences of reals that apply
to any generator construction (tropical or otherwise), but they form the
essential infrastructure for the tropical NW theorem.

## Keywords

hybrid argument, pseudorandom generators, telescoping sum, pigeonhole principle,
Nisan–Wigderson, tropical complexity theory
-/

noncomputable section

open Finset BigOperators

namespace TropicalHVR

/-! ## Telescope Inequality

The fundamental hybrid inequality: for any sequence of real numbers,
|a₀ - aₘ| ≤ Σᵢ |aᵢ - aᵢ₊₁|.

This follows from the triangle inequality applied to a telescoping sum.
-/

/-
**Telescope inequality.**
    For any sequence `a : ℕ → ℝ` and length `m`, the distance between
    `a 0` and `a m` is bounded by the sum of consecutive differences.
    This is the core structural lemma enabling the hybrid argument.
-/
theorem telescope_abs_le_sum (m : ℕ) (a : ℕ → ℝ) :
    |a 0 - a m| ≤ ∑ i ∈ Finset.range m, |a i - a (i + 1)| := by
  induction m <;> simp_all +decide [ Finset.sum_range_succ ];
  cases abs_cases ( a 0 - a ‹_› ) <;> cases abs_cases ( a 0 - a ( ‹_› + 1 ) ) <;> cases abs_cases ( a ‹_› - a ( ‹_› + 1 ) ) <;> linarith

/-! ## Averaging / Pigeonhole Lemma -/

/-
**Averaging lemma for non-negative reals.**
    If a sum over `Finset.range m` of non-negative reals is at least `S`,
    then at least one summand is at least `S / m`.
-/
theorem exists_le_of_sum_ge_div {m : ℕ} (hm : 0 < m)
    (f : ℕ → ℝ) (hf : ∀ i, i < m → 0 ≤ f i) (S : ℝ)
    (hS : S ≤ ∑ i ∈ Finset.range m, f i) :
    ∃ i, i < m ∧ S / (m : ℝ) ≤ f i := by
  contrapose! hS;
  exact lt_of_lt_of_le ( Finset.sum_lt_sum_of_nonempty ⟨ _, Finset.mem_range.mpr hm ⟩ fun i hi => hS i ( Finset.mem_range.mp hi ) ) ( by norm_num [ mul_div_cancel₀, hm.ne' ] )

/-
**Pigeonhole for hybrid gaps.**
    If the total advantage `|a 0 - a m|` is at least `ε`, then there exists an
    index where the consecutive gap is at least `ε / m`. This is the hybrid
    averaging lemma that enables the NW reduction.
-/
theorem hybrid_pigeonhole (m : ℕ) (hm : 0 < m)
    (a : ℕ → ℝ) (ε : ℝ) (hε : ε ≤ |a 0 - a m|) :
    ∃ i, i < m ∧ ε / (m : ℝ) ≤ |a i - a (i + 1)| := by
  -- Apply the averaging lemma with $f i = |a i - a (i + 1)|$ and $S = ε$.
  apply exists_le_of_sum_ge_div hm (fun i => |a i - a (i + 1)|) (fun i hi => abs_nonneg _) ε;
  exact hε.trans ( telescope_abs_le_sum m a )

/-! ## Next-Bit Prediction from Distinguishing

The NW insight: if a test T distinguishes the generator's output from uniform
with advantage ε, then for some coordinate j, the test can be converted into
a predictor for f on the j-th substring with advantage ε/m.
-/

/-- **Prediction advantage from hybrid gap.**
    For any sequence of hybrid acceptance probabilities, a large total gap
    implies a large individual prediction gap. -/
theorem prediction_from_hybrid_gap (m : ℕ) (hm : 0 < m)
    (acceptH : ℕ → ℝ) (ε : ℝ) (hε : ε ≤ |acceptH 0 - acceptH m|) :
    ∃ j, j < m ∧ ε / m ≤ |acceptH j - acceptH (j + 1)| :=
  hybrid_pigeonhole m hm acceptH ε hε

end TropicalHVR

end