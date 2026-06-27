/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Simple normality of digit sequences — combinatorial foundations

This file develops a self-contained, purely combinatorial theory of **simple
normality** for base-`b` digit sequences `s : ℕ → Fin b`.  A real number is
*simply normal* in base `b` exactly when every digit `d ∈ {0, …, b-1}` occurs in
its base-`b` expansion with limiting frequency `1/b`.  We capture this directly on
the digit stream:

* `countDigit s d n` — how many of the first `n` digits equal `d`;
* `freq s d n` — the empirical frequency `countDigit s d n / n`;
* `SimplyNormal s` — `freq s d n → 1/b` for every digit `d`.

The foundational results here are the **conservation law** (the digit counts
partition `n`, hence the empirical frequencies always sum to `1`) and the
monotone-divergence criterion for digits occurring infinitely often, which reuses
the order-theoretic dichotomy proved in
`Catalog.Novelty.SequenceLemmas` (`DegreeNormalizedTreeCut`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "normality" of a constant, after stripping the
real-analytic packaging of base-`b` expansions, is a *frequency* statement about
its digit stream; the right primitive object is therefore the empirical digit
distribution `freq s · n`, an honest probability vector for each `n`.
Experiment (Experimenter): formalize `countDigit`/`freq`/`SimplyNormal` over
`Fin b` and prove that the counts fiber the index set `range n`.
Analysis (Analyst): the conservation law `∑ d, countDigit s d n = n` is the
combinatorial heart — every downstream obstruction (a digit with the wrong
limiting frequency) is a violation of this partition in the limit.  The
"infinitely often ⇒ count diverges" lemma is exactly the unbounded-monotone half
of the catalog dichotomy, so we import it rather than re-prove it.
Critique (Critic): `freq s d 0 = 0/0 = 0` is a junk value; this is harmless
because `SimplyNormal` is an `atTop` statement, but we flag it and prove the
frequency-sum law only for `0 < n`.
-- !-- end Lab Notes -- !--
-/
import Mathlib
import Catalog.Novelty.SequenceLemmas

namespace NormalConstants

open Finset Filter Topology

/-- Number of occurrences of digit `d` among the first `n` terms of `s`. -/
def countDigit {b : ℕ} (s : ℕ → Fin b) (d : Fin b) (n : ℕ) : ℕ :=
  ((Finset.range n).filter (fun k => s k = d)).card

/-- Empirical frequency of digit `d` among the first `n` terms of `s`. -/
noncomputable def freq {b : ℕ} (s : ℕ → Fin b) (d : Fin b) (n : ℕ) : ℝ :=
  (countDigit s d n : ℝ) / n

/-- A digit sequence is **simply normal** when every digit's empirical frequency
converges to `1/b`. -/
def SimplyNormal {b : ℕ} (s : ℕ → Fin b) : Prop :=
  ∀ d : Fin b, Tendsto (fun n => freq s d n) atTop (𝓝 (1 / (b : ℝ)))

/-- A digit count never exceeds the number of terms inspected. -/
theorem countDigit_le {b : ℕ} (s : ℕ → Fin b) (d : Fin b) (n : ℕ) :
    countDigit s d n ≤ n := by
  unfold countDigit
  calc ((Finset.range n).filter (fun k => s k = d)).card
      ≤ (Finset.range n).card := Finset.card_filter_le _ _
    _ = n := Finset.card_range n

/-- **Conservation law.** The digit counts partition the index window: summing the
counts over all digits returns the window size `n`. -/
theorem sum_countDigit {b : ℕ} (s : ℕ → Fin b) (n : ℕ) :
    ∑ d : Fin b, countDigit s d n = n := by
  have h := Finset.card_eq_sum_card_fiberwise (f := s) (s := Finset.range n)
    (t := (Finset.univ : Finset (Fin b))) (fun k _ => Finset.mem_univ (s k))
  simp only [Finset.card_range] at h
  simpa [countDigit] using h.symm

/-- The empirical frequencies form a probability vector: they sum to `1`. -/
theorem sum_freq {b : ℕ} (s : ℕ → Fin b) {n : ℕ} (hn : 0 < n) :
    ∑ d : Fin b, freq s d n = 1 := by
  have hn' : (n : ℝ) ≠ 0 := by exact_mod_cast hn.ne'
  unfold freq
  rw [← Finset.sum_div]
  rw [show (∑ d : Fin b, (countDigit s d n : ℝ)) = ((∑ d : Fin b, countDigit s d n : ℕ) : ℝ) by
    push_cast; rfl]
  rw [sum_countDigit]
  field_simp

/-- `countDigit s d` is monotone in the window size. -/
theorem countDigit_monotone {b : ℕ} (s : ℕ → Fin b) (d : Fin b) :
    Monotone (countDigit s d) := by
  intro m n hmn
  unfold countDigit
  exact Finset.card_le_card (Finset.filter_subset_filter _ (Finset.range_subset_range.mpr hmn))

/-
If digit `d` occurs at or beyond every threshold (i.e. infinitely often), its
count is unbounded.  This is the unbounded-monotone branch of the catalog
dichotomy `DegreeNormalizedTreeCut`.
-/
theorem countDigit_not_bddAbove {b : ℕ} (s : ℕ → Fin b) (d : Fin b)
    (h : ∀ N, ∃ k ≥ N, s k = d) : ¬ BddAbove (Set.range (countDigit s d)) := by
  intro h_bdd
  obtain ⟨B, hB⟩ := h_bdd;
  -- By induction on $B$, we can find $n$ such that $countDigit s d n \geq B + 1$.
  have h_ind : ∀ m : ℕ, ∃ n : ℕ, countDigit s d n ≥ m := by
    intro m; induction' m with m ih <;> simp_all +decide [ countDigit ] ;
    obtain ⟨ n, hn ⟩ := ih; obtain ⟨ k, hk₁, hk₂ ⟩ := h n; use k + 1; simp_all +decide [ Finset.filter ] ;
    exact hn.trans ( Multiset.card_mono <| Multiset.filter_le_filter _ <| Multiset.range_le.mpr hk₁ );
  exact absurd ( h_ind ( B + 1 ) ) ( by rintro ⟨ n, hn ⟩ ; linarith [ hB ( Set.mem_range_self n ) ] )

/-- **Infinitely often ⇒ diverging count.** If digit `d` occurs infinitely often
then `countDigit s d n → ∞`.  Proof reuses the catalog lemma
`DegreeNormalizedTreeCut.monotone_nat_unbounded_eventually_ge`. -/
theorem countDigit_tendsto_atTop {b : ℕ} (s : ℕ → Fin b) (d : Fin b)
    (h : ∀ N, ∃ k ≥ N, s k = d) :
    Tendsto (countDigit s d) atTop atTop := by
  rw [tendsto_atTop_atTop]
  intro k
  obtain ⟨N, hN⟩ := DegreeNormalizedTreeCut.monotone_nat_unbounded_eventually_ge
    (countDigit s d) (countDigit_monotone s d) (countDigit_not_bddAbove s d h) k
  exact ⟨N, fun n hn => hN n hn⟩

end NormalConstants