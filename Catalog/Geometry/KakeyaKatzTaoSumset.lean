/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The additive-combinatorics bridge: sumset growth (Katz–Tao framework)

The Katz–Tao approach to the Kakeya problem reduces dimension lower bounds to
*sum–difference* estimates in additive combinatorics: a Kakeya set forces a
configuration whose iterated sumsets must grow, and quantitative growth
translates back into a dimension bound.  The cleanest exactly-provable engine of
this kind is the **Cauchy–Davenport** inequality in the prime cyclic group
`ZMod p`.

This file proves the iterated-sumset growth law that powers such arguments:

  `|kA| ≥ min(p, k·(|A| − 1) + 1)`  for every nonempty `A ⊆ ZMod p`,

by induction on `k` using Cauchy–Davenport, and deduces the qualitative
corollary that any set with at least two elements *generates the whole group*
under enough additions (`kA = ZMod p` once `k ≥ p − 1`).  This is the discrete
analogue of "a Kakeya set, after enough additive combination, fills space".

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): Cauchy–Davenport should iterate to a linear-in-`k`
  growth `|kA| ≳ k|A|` until saturation at `p`.  Predicted exact bound
  `min(p, k(|A|−1)+1)`.
* Experiment (Experimenter): defined `sumIter A k` by recursion (`A + (A + …)`),
  proved nonemptiness by induction, and ran the induction on `k`, feeding
  `ZMod.cauchy_davenport` at each step.  The `min` and `ℕ`-subtraction bookkeeping
  was the only real obstacle (handled with `omega`).
* Analysis (Analyst): the bound is sharp for arithmetic progressions
  (`A = {0,1,…,m−1}` gives `kA = {0,…,k(m−1)}` of size exactly `k(m−1)+1` while
  that stays `< p`).  Saturation happens at `k = ⌈(p−1)/(|A|−1)⌉`.
* Critique (Critic): the corollary `sumset_generates` is non-vacuous — it needs
  `|A| ≥ 2`; for `|A| = 1` (singleton) `kA` is a singleton forever, which the
  bound `min(p, k·0+1) = 1` correctly predicts.  No hidden triviality: the proof
  uses genuine induction and Cauchy–Davenport, not `decide`.
* Synthesis (PI): `card_sumIter_ge` is the headline growth law;
  `sumset_generates` is the saturation corollary tying it to "filling space".
-/

open Finset Pointwise

namespace KakeyaKatzTao

/-- Iterated sumset: `sumIter A k = A + A + ⋯ + A` (`k+1` copies, so
`sumIter A 0 = A`). -/
def sumIter {p : ℕ} (A : Finset (ZMod p)) : ℕ → Finset (ZMod p)
  | 0 => A
  | (k + 1) => A + sumIter A k

@[simp] theorem sumIter_zero {p : ℕ} (A : Finset (ZMod p)) : sumIter A 0 = A := rfl

theorem sumIter_succ {p : ℕ} (A : Finset (ZMod p)) (k : ℕ) :
    sumIter A (k + 1) = A + sumIter A k := rfl

/-
The iterated sumset of a nonempty set is nonempty.
-/
theorem sumIter_nonempty {p : ℕ} {A : Finset (ZMod p)} (hA : A.Nonempty) (k : ℕ) :
    (sumIter A k).Nonempty := by
  induction' k with k ih <;> simp_all +decide [ sumIter_succ ]

/-
Any subset of `ZMod p` has at most `p` elements.
-/
theorem card_le_p {p : ℕ} [NeZero p] (A : Finset (ZMod p)) : A.card ≤ p := by
  simpa using Finset.card_le_univ A

/-
**Iterated Cauchy–Davenport growth.** For a prime `p` and nonempty
`A ⊆ ZMod p`, the `k`-fold sumset satisfies `|kA| ≥ min(p, k(|A|−1)+1)`.
-/
theorem card_sumIter_ge {p : ℕ} (hp : p.Prime) {A : Finset (ZMod p)}
    (hA : A.Nonempty) (k : ℕ) :
    min p (k * (A.card - 1) + 1) ≤ (sumIter A k).card := by
  induction' k with k ih;
  · grind +suggestions;
  · have := @ZMod.cauchy_davenport;
    convert this hp hA ( sumIter_nonempty hA k ) |> le_trans _ using 1;
    grind

/-
**Saturation / generation.** If `A ⊆ ZMod p` has at least two elements, then
once `k ≥ p − 1` the iterated sumset is all of `ZMod p` (it has `p` elements).
-/
theorem sumset_generates {p : ℕ} (hp : p.Prime) {A : Finset (ZMod p)}
    (hA : 2 ≤ A.card) {k : ℕ} (hk : p - 1 ≤ k) :
    (sumIter A k).card = p := by
  refine' le_antisymm _ _;
  · haveI := Fact.mk hp; exact le_trans ( Finset.card_le_univ _ ) ( by simp +decide ) ;
  · refine' le_trans _ ( card_sumIter_ge hp ( Finset.card_pos.mp ( by linarith ) ) k );
    exact le_min le_rfl ( by nlinarith [ Nat.sub_add_cancel hp.pos, Nat.sub_pos_of_lt hA ] )

end KakeyaKatzTao