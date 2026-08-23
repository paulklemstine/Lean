/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Known versus unresolved cards — IV. Feedback, and what information is worth

`DeckGame.lean` shows that a *blind* pass through an unresolved block of `u`
cards yields expected score exactly `1` under unit scoring and exactly `0` under
fair odds, for every strategy.  This file isolates the resource that actually
changes the picture: **feedback**.

A feedback strategy sees each card after calling it, so the only state it needs
is the set `S` of cards still unseen; a strategy is therefore a map
`g : Finset α → α`, and it is *admissible* when it names a card that is still
live, `g S ∈ S`.  The score of such a strategy on a uniformly random arrangement
of `S` satisfies the exact recursion `expScore_step`.

Two theorems then pull in opposite directions:

* `expScore_hits_eq_harmonic` — under unit scoring the expected number of
  correct calls is the harmonic number `H_u`, *unbounded* in `u`
  (`feedback_edge_unbounded`, via the Oresme bound `harmonic_two_pow_ge`).
  Feedback is worth `H_u - 1 ≈ log u` extra cards.
* `expScore_fair_eq_zero` — under stagewise fair odds, the expected payoff is
  `0` for *every* admissible feedback strategy.

So the principle "uncertainty supplies no positive edge" is not fragile:
information does not create value against a correctly priced book, it only
changes the price.  What information does buy is visible only when the book is
mispriced — and then it buys exactly `H_u - 1`.

## Main results

* `expScore_step` — the exact one-stage recursion of the feedback game.
* `expScore_fair_eq_zero` — fair odds are information-proof.
* `expScore_hits_eq_harmonic` — feedback scores `H_u` hits.
* `harmonic_two_pow_ge` — Oresme's bound `1 + n/2 ≤ H_{2^n}`.
* `feedback_edge_unbounded` — the unit-scoring edge of feedback is unbounded.
* `feedback_strictly_beats_blind` — the quantitative dichotomy.
* `fair_odds_are_information_proof` — both games are worth `0` at fair odds.
-/

import MachineLearning.KnownUnresolvedCards.DeckGame
import Mathlib.NumberTheory.Harmonic.Defs
import Mathlib.NumberTheory.Harmonic.Bounds

namespace KnownUnresolvedCards

open Finset

/-! ## Harmonic preliminaries -/

lemma harmonic_eq_sum_Ioc (n : ℕ) : harmonic n = ∑ i ∈ Finset.Ioc 0 n, (i : ℚ)⁻¹ := by
  rw [harmonic_eq_sum_Icc]; congr 1

lemma half_le_sum_Ioc {m : ℕ} (hm : 1 ≤ m) :
    (1 : ℚ) / 2 ≤ ∑ i ∈ Finset.Ioc m (2 * m), (i : ℚ)⁻¹ := by
  have hm0 : (0 : ℚ) < (m : ℚ) := by exact_mod_cast hm
  have hcard : (Finset.Ioc m (2 * m)).card = m := by simp [Nat.card_Ioc]; omega
  have hb : ∀ i ∈ Finset.Ioc m (2 * m), (1 : ℚ) / (2 * m) ≤ (i : ℚ)⁻¹ := by
    intro i hi
    simp only [Finset.mem_Ioc] at hi
    have hi0 : (0 : ℚ) < (i : ℚ) := by exact_mod_cast (by omega : 0 < i)
    have hile : (i : ℚ) ≤ 2 * (m : ℚ) := by exact_mod_cast hi.2
    simpa [one_div] using one_div_le_one_div_of_le hi0 hile
  have hsum := Finset.card_nsmul_le_sum (Finset.Ioc m (2 * m)) (fun i => (i : ℚ)⁻¹)
    ((1 : ℚ) / (2 * m)) hb
  rw [hcard, nsmul_eq_mul] at hsum
  refine le_trans (le_of_eq ?_) hsum
  field_simp

lemma harmonic_two_mul_ge {m : ℕ} (hm : 1 ≤ m) : harmonic m + 1 / 2 ≤ harmonic (2 * m) := by
  have hsplit : ∑ i ∈ Finset.Ioc 0 m, (i : ℚ)⁻¹ + ∑ i ∈ Finset.Ioc m (2 * m), (i : ℚ)⁻¹
      = ∑ i ∈ Finset.Ioc 0 (2 * m), (i : ℚ)⁻¹ :=
    Finset.sum_Ioc_consecutive _ (Nat.zero_le _) (by omega)
  rw [harmonic_eq_sum_Ioc, harmonic_eq_sum_Ioc (2 * m), ← hsplit]
  have := half_le_sum_Ioc hm
  linarith

/-- **Oresme's bound**: the harmonic numbers grow at least logarithmically. -/
theorem harmonic_two_pow_ge (n : ℕ) : 1 + (n : ℚ) / 2 ≤ harmonic (2 ^ n) := by
  induction n with
  | zero => norm_num [harmonic_succ]
  | succ n ih =>
      have h1 : (1 : ℕ) ≤ 2 ^ n := Nat.one_le_two_pow
      have h2 := harmonic_two_mul_ge h1
      have he : (2 : ℕ) ^ (n + 1) = 2 * 2 ^ n := by ring
      rw [he]
      push_cast
      linarith

theorem harmonic_monotone : Monotone harmonic := by
  apply monotone_nat_of_le_succ
  intro n
  rw [harmonic_succ]
  have : (0 : ℚ) ≤ ((n : ℚ) + 1)⁻¹ := by positivity
  push_cast
  linarith

lemma harmonic_two : harmonic 2 = 3 / 2 := by
  norm_num [harmonic_succ]

/-! ## The feedback game -/

variable {α : Type*} [DecidableEq α]

/-- Expected score of the *feedback* game on the unseen set `S`: the next card is
uniform over `S`, the strategy `g` calls `g S`, is paid `hit |S|` if right and
`miss |S|` if wrong, and then the game continues on `S.erase a`. -/
noncomputable def expScore (hit miss : ℕ → ℚ) (g : Finset α → α) (S : Finset α) : ℚ :=
  if _h : S.Nonempty then
    (∑ a ∈ S.attach,
        ((if g S = (a : α) then hit S.card else miss S.card)
          + expScore hit miss g (S.erase (a : α)))) / S.card
  else 0
termination_by S.card
decreasing_by exact Finset.card_erase_lt_of_mem a.2

@[simp] lemma expScore_empty (hit miss : ℕ → ℚ) (g : Finset α → α) :
    expScore hit miss g (∅ : Finset α) = 0 := by
  rw [expScore.eq_def]; simp

/-- **One-stage recursion.**  For an admissible call `g S ∈ S`, exactly one of
the `|S|` equally likely cards is a hit. -/
lemma expScore_step (hit miss : ℕ → ℚ) (g : Finset α → α) {S : Finset α} (hS : S.Nonempty)
    (hg : g S ∈ S) :
    expScore hit miss g S =
      ((S.card : ℚ) * miss S.card + (hit S.card - miss S.card)
        + ∑ a ∈ S, expScore hit miss g (S.erase a)) / S.card := by
  rw [expScore.eq_def, dif_pos hS]
  congr 1
  rw [Finset.sum_attach S (fun a => (if g S = a then hit S.card else miss S.card)
      + expScore hit miss g (S.erase a))]
  rw [Finset.sum_add_distrib]
  congr 1
  have hsplit : ∀ a ∈ S, (if g S = a then hit S.card else miss S.card)
      = miss S.card + (if g S = a then hit S.card - miss S.card else 0) := by
    intro a _; by_cases h : g S = a <;> simp [h]
  rw [Finset.sum_congr rfl hsplit, Finset.sum_add_distrib, Finset.sum_const, nsmul_eq_mul,
    Finset.sum_ite_eq S (g S) (fun _ => hit S.card - miss S.card), if_pos hg]

/-- **Fair odds are information-proof.**  Paying `|S| - 1` on a hit and `-1` on a
miss — the fair price given the `|S|` live candidates — makes the whole feedback
game a zero-expectation bet, for every admissible strategy.  Sequential
information changes the odds, never the edge. -/
theorem expScore_fair_eq_zero (g : Finset α → α) (hg : ∀ T : Finset α, T.Nonempty → g T ∈ T)
    (S : Finset α) : expScore (fun m => (m : ℚ) - 1) (fun _ => -1) g S = 0 := by
  induction S using Finset.strongInduction with
  | _ S ih =>
    rcases S.eq_empty_or_nonempty with rfl | hS
    · exact expScore_empty _ _ _
    · rw [expScore_step _ _ _ hS (hg S hS)]
      have h0 : ∀ a ∈ S, expScore (fun m => (m : ℚ) - 1) (fun _ => -1) g (S.erase a) = 0 :=
        fun a ha => ih (S.erase a) (Finset.erase_ssubset ha)
      rw [Finset.sum_congr rfl h0, Finset.sum_const_zero]
      have hnum : ((S.card : ℚ) * (-1) + (((S.card : ℚ) - 1) - (-1)) + 0) = 0 := by ring
      rw [hnum, zero_div]

/-- **Feedback scores `H_u` hits.**  Under naive unit scoring, an admissible
feedback strategy on `u = |S|` unresolved cards makes exactly `H_u` correct calls
in expectation — compared with exactly `1` for a blind pass. -/
theorem expScore_hits_eq_harmonic (g : Finset α → α) (hg : ∀ T : Finset α, T.Nonempty → g T ∈ T)
    (S : Finset α) : expScore (fun _ => 1) (fun _ => 0) g S = harmonic S.card := by
  induction S using Finset.strongInduction with
  | _ S ih =>
    rcases S.eq_empty_or_nonempty with rfl | hS
    · simp
    · obtain ⟨k, hk⟩ : ∃ k, S.card = k + 1 :=
        ⟨S.card - 1, by have := Finset.card_pos.mpr hS; omega⟩
      rw [expScore_step _ _ _ hS (hg S hS)]
      have h0 : ∀ a ∈ S, expScore (fun _ => (1 : ℚ)) (fun _ => 0) g (S.erase a) = harmonic k := by
        intro a ha
        rw [ih (S.erase a) (Finset.erase_ssubset ha), Finset.card_erase_of_mem ha, hk]
        simp
      rw [Finset.sum_congr rfl h0, Finset.sum_const, nsmul_eq_mul, hk, harmonic_succ]
      push_cast
      field_simp
      ring

/-! ## What feedback is worth -/

/-- **The value of feedback is unbounded.**  Under unit scoring there are
unresolved blocks on which an admissible feedback strategy beats any prescribed
target `C`, whereas a blind strategy always scores exactly `1`. -/
theorem feedback_edge_unbounded (g : Finset ℕ → ℕ) (hg : ∀ T : Finset ℕ, T.Nonempty → g T ∈ T)
    (C : ℚ) : ∃ S : Finset ℕ, C < expScore (fun _ => 1) (fun _ => 0) g S := by
  obtain ⟨n, hn⟩ := exists_nat_gt (2 * C)
  refine ⟨Finset.range (2 ^ n), ?_⟩
  rw [expScore_hits_eq_harmonic g hg, Finset.card_range]
  have h := harmonic_two_pow_ge n
  have : C < 1 + (n : ℚ) / 2 := by linarith
  linarith

/-- **Blind versus informed, quantitatively.**  On an unresolved block of at
least two cards, every blind strategy scores `1` in expectation while every
admissible feedback strategy scores `H_u ≥ 3/2`. -/
theorem feedback_strictly_beats_blind [Fintype α] (hcard : 2 ≤ Fintype.card α)
    (g : α → α) (gf : Finset α → α) (hgf : ∀ T : Finset α, T.Nonempty → gf T ∈ T) :
    E (fun σ : Equiv.Perm α => (hits g σ : ℚ))
      < expScore (fun _ => 1) (fun _ => 0) gf (univ : Finset α) := by
  have hne : Nonempty α := Fintype.card_pos_iff.mp (by omega)
  rw [E_hits g, expScore_hits_eq_harmonic gf hgf, Finset.card_univ]
  have h2 : harmonic 2 ≤ harmonic (Fintype.card α) := harmonic_monotone hcard
  rw [harmonic_two] at h2
  linarith

/-- **Fair odds are information-proof, in both games.**  The blind fair-odds
book and the sequential fair-odds book are both worth exactly zero; the whole
difference between an ignorant and an informed player lives in the pricing, not
in the edge. -/
theorem fair_odds_are_information_proof [Fintype α] [Nonempty α]
    (g : α → α) (gf : Finset α → α) (hgf : ∀ T : Finset α, T.Nonempty → gf T ∈ T) :
    E (deckScore ((Fintype.card α : ℚ) - 1) (-1) g) = 0
      ∧ expScore (fun m => (m : ℚ) - 1) (fun _ => -1) gf (univ : Finset α) = 0 :=
  ⟨expected_fairOdds g, expScore_fair_eq_zero gf hgf univ⟩

/-- **The full deck with feedback.**  `d` cards known with certainty and `u`
unresolved cards played with feedback at stagewise fair odds still return
exactly `d`. -/
theorem feedback_game_payoff_eq_known (d : ℕ) (gf : Finset α → α)
    (hgf : ∀ T : Finset α, T.Nonempty → gf T ∈ T) (S : Finset α) :
    (d : ℚ) + expScore (fun m => (m : ℚ) - 1) (fun _ => -1) gf S = (d : ℚ) := by
  rw [expScore_fair_eq_zero gf hgf S, add_zero]

end KnownUnresolvedCards