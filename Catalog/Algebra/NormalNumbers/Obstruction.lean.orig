/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Obstructions to simple normality

Simple normality is a strong *equidistribution* constraint: each digit must
appear with frequency exactly `1/b`.  This file proves the basic **obstruction
theorems** that rule out normality whenever a digit has the wrong limiting
frequency, and derives the classical consequences:

* a digit whose frequency converges to anything other than `1/b` kills normality
  (`not_simplyNormal_of_freq_tendsto`);
* a digit that occurs only finitely often has frequency `0`, hence (for `b ≥ 2`)
  kills normality (`not_simplyNormal_of_finite`);
* an **eventually constant** digit sequence — the digit stream of a terminating
  base-`b` rational — is never simply normal (`not_simplyNormal_of_eventually_const`).

The last result is the formal core of the slogan *"a terminating / eventually
constant expansion cannot be normal"*: it is a genuine equidistribution
obstruction, not a triviality.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): normality should be *fragile* — any single digit with
density ≠ 1/b should break it.  Bold sub-conjecture: terminating rationals are
maximally non-normal (one digit eventually owns all the mass).
Experiment (Experimenter): prove the uniqueness-of-limits obstruction, then the
finite-support frequency-zero lemma by squeezing `0 ≤ freq ≤ N/n`, then assemble
the eventually-constant corollary by choosing a digit `≠ c` (available since
`b ≥ 2`).
Analysis (Analyst): the only analytic input is `tendsto_nhds_unique`; everything
else is the conservation law from `Basic` plus a squeeze.  The hypothesis `b ≥ 2`
is load-bearing precisely because `1/b = 0` would be possible at `b = 1` (a
degenerate single-digit alphabet where every sequence is "normal").
Critique (Critic): we must guard against the vacuous `b = 1` case — with one digit
`freq ≡ 1 = 1/1`, so the obstruction is genuinely false there.  Requiring `2 ≤ b`
draws the exact boundary, which we record rather than hide.
-- !-- end Lab Notes -- !--
-/
import Mathlib
import Catalog.Algebra.NormalNumbers.Basic

namespace NormalConstants

open Finset Filter Topology

/-- **Uniqueness obstruction.** If some digit's empirical frequency converges to a
value other than `1/b`, the sequence is not simply normal. -/
theorem not_simplyNormal_of_freq_tendsto {b : ℕ} (s : ℕ → Fin b) (d : Fin b)
    {L : ℝ} (hL : Tendsto (fun n => freq s d n) atTop (𝓝 L)) (hne : L ≠ 1 / (b : ℝ)) :
    ¬ SimplyNormal s := by
  intro hnorm
  exact hne (tendsto_nhds_unique hL (hnorm d))

/-
A digit that stops occurring past index `N` has empirical frequency tending to
`0`.
-/
theorem freq_tendsto_zero_of_finite {b : ℕ} (s : ℕ → Fin b) (d : Fin b) (N : ℕ)
    (h : ∀ k, N ≤ k → s k ≠ d) :
    Tendsto (fun n => freq s d n) atTop (𝓝 0) := by
  -- Since `countDigit s d n` is bounded above by `N` for all `n`, we have `freq s d n ≤ N / n`.
  have h_bound : ∀ n, freq s d n ≤ N / n := by
    intro n
    have h_count : countDigit s d n ≤ N := by
      exact le_trans ( Finset.card_le_card ( show Finset.filter ( fun k => s k = d ) ( Finset.range n ) ⊆ Finset.range N from fun x hx => Finset.mem_range.mpr <| Nat.lt_of_not_ge fun hx' => h x hx' <| Finset.mem_filter.mp hx |>.2 ) ) ( by simp );
    exact div_le_div_of_nonneg_right ( mod_cast h_count ) ( Nat.cast_nonneg _ );
  exact squeeze_zero ( fun n => div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ) ) h_bound ( tendsto_const_nhds.div_atTop tendsto_natCast_atTop_atTop )

/-- **Finite-support obstruction.** For `b ≥ 2`, a digit occurring only finitely
often prevents simple normality. -/
theorem not_simplyNormal_of_finite {b : ℕ} (hb : 2 ≤ b) (s : ℕ → Fin b) (d : Fin b)
    (N : ℕ) (h : ∀ k, N ≤ k → s k ≠ d) : ¬ SimplyNormal s := by
  apply not_simplyNormal_of_freq_tendsto s d (freq_tendsto_zero_of_finite s d N h)
  have hb0 : (0 : ℝ) < b := by positivity
  have : (0 : ℝ) < 1 / (b : ℝ) := by positivity
  linarith

/-- **Eventually-constant obstruction.** For `b ≥ 2`, a digit stream that is
eventually equal to a fixed digit `c` (the digits of a terminating base-`b`
rational) is never simply normal. -/
theorem not_simplyNormal_of_eventually_const {b : ℕ} (hb : 2 ≤ b) (s : ℕ → Fin b)
    (c : Fin b) (N : ℕ) (h : ∀ k, N ≤ k → s k = c) : ¬ SimplyNormal s := by
  -- pick a digit different from `c`; it occurs only before `N`.
  have hbpos : 0 < b := by omega
  obtain ⟨d, hd⟩ : ∃ d : Fin b, d ≠ c := by
    have : 1 < Fintype.card (Fin b) := by simpa using hb
    exact Fintype.exists_ne_of_one_lt_card this c
  refine not_simplyNormal_of_finite hb s d N ?_
  intro k hk
  rw [h k hk]
  exact hd.symm

end NormalConstants