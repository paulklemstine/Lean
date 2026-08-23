/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Known versus unresolved cards — I. The uniform expectation calculus

A *prediction game* pays a rational amount on each of finitely many **cards**.
Some cards are **resolved**: the predictor knows their value and collects a
deterministic unit payoff.  The remaining cards are **unresolved**: the predictor
must guess, and the guess is priced at *fair odds*, i.e. the payoff on such a
card has zero mean.

This file develops the minimal probabilistic infrastructure needed to state and
prove the headline principle

> `E[total payoff] = (number of resolved cards)`,

namely a uniform-expectation functional `E` on a finite sample space, its
linearity, and the **splitting theorem** `expected_total_eq_certain_count`.

The point of stating the splitting theorem for an *arbitrary* finite index type
`ι` and an *arbitrary* subset `K : Finset ι` of resolved cards is that the deck
models of `PermCount.lean` and `DeckGame.lean` are then genuine instances rather
than re-proofs.

## Main results

* `E_sum` — linearity of uniform expectation over a `Finset` sum.
* `expected_total_eq_certain_count` — if every card of `K` pays a deterministic
  `1` and every card outside `K` is fair, the expected total payoff is `K.card`.
* `expected_total_eq_certain_sum` — the weighted version with arbitrary
  deterministic payoffs on `K`.
* `no_fair_portfolio_edge` — a portfolio consisting only of fair cards has zero
  expected payoff, *whatever* the (possibly wildly correlated) joint law.
-/

import Mathlib

namespace KnownUnresolvedCards

open Finset

/-! ## Uniform expectation on a finite sample space -/

variable {Ω : Type*} [Fintype Ω]

/-- The expectation of a rational observable `f` under the uniform law on the
finite sample space `Ω`. -/
def E (f : Ω → ℚ) : ℚ := (∑ ω, f ω) / (Fintype.card Ω : ℚ)

lemma E_def (f : Ω → ℚ) : E f = (∑ ω, f ω) / (Fintype.card Ω : ℚ) := rfl

lemma card_ne_zero [Nonempty Ω] : ((Fintype.card Ω : ℚ)) ≠ 0 := by
  have : 0 < Fintype.card Ω := Fintype.card_pos
  positivity

@[simp] lemma E_const [Nonempty Ω] (c : ℚ) : E (fun _ : Ω => c) = c := by
  have h := card_ne_zero (Ω := Ω)
  rw [E_def, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  field_simp

lemma E_add (f g : Ω → ℚ) : E (fun ω => f ω + g ω) = E f + E g := by
  simp only [E_def, Finset.sum_add_distrib]
  ring

lemma E_smul (c : ℚ) (f : Ω → ℚ) : E (fun ω => c * f ω) = c * E f := by
  simp only [E_def, ← Finset.mul_sum]
  ring

lemma E_neg (f : Ω → ℚ) : E (fun ω => -f ω) = -E f := by
  simp only [E_def, Finset.sum_neg_distrib]
  ring

/-- Linearity of the uniform expectation over a finite family of observables. -/
lemma E_sum {ι : Type*} (s : Finset ι) (f : ι → Ω → ℚ) :
    E (fun ω => ∑ i ∈ s, f i ω) = ∑ i ∈ s, E (f i) := by
  classical
  induction s using Finset.induction with
  | empty => simp [E_def]
  | insert a s ha ih =>
      simp only [Finset.sum_insert ha]
      rw [E_add, ih]

/-- The variance of a rational observable under the uniform law. -/
def Var (f : Ω → ℚ) : ℚ := E (fun ω => f ω ^ 2) - (E f) ^ 2

lemma Var_def (f : Ω → ℚ) : Var f = E (fun ω => f ω ^ 2) - (E f) ^ 2 := rfl

/-! ## Resolved and unresolved cards -/

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- A card is *resolved with value `c`* when its payoff is the constant `c`:
the predictor knows the card and collects `c` in every state of the world. -/
def Resolved (p : Ω → ℚ) (c : ℚ) : Prop := ∀ ω, p ω = c

/-- A card is *fair* when its payoff has zero mean: the odds offered exactly
compensate the residual uncertainty. -/
def Fair (p : Ω → ℚ) : Prop := E p = 0

lemma E_of_resolved [Nonempty Ω] {p : Ω → ℚ} {c : ℚ} (h : Resolved p c) : E p = c := by
  have hp : (fun ω : Ω => p ω) = (fun _ : Ω => c) := funext h
  simp [show p = (fun _ : Ω => c) from hp]

/-- **Splitting theorem, weighted form.**  If the cards indexed by `K` are
resolved with values `c i` and every card outside `K` is fair, then the expected
total payoff is `∑ i ∈ K, c i`: the unresolved cards contribute nothing. -/
theorem expected_total_eq_certain_sum [Nonempty Ω]
    (p : ι → Ω → ℚ) (K : Finset ι) (c : ι → ℚ)
    (hK : ∀ i ∈ K, Resolved (p i) (c i))
    (hU : ∀ i ∉ K, Fair (p i)) :
    E (fun ω => ∑ i, p i ω) = ∑ i ∈ K, c i := by
  classical
  rw [E_sum]
  rw [← Finset.sum_filter_add_sum_filter_not Finset.univ (fun i => i ∈ K)]
  have h1 : ∑ i ∈ Finset.univ.filter (fun i => i ∈ K), E (p i) = ∑ i ∈ K, c i := by
    have : Finset.univ.filter (fun i => i ∈ K) = K := by
      ext i; simp
    rw [this]
    exact Finset.sum_congr rfl fun i hi => E_of_resolved (hK i hi)
  have h2 : ∑ i ∈ Finset.univ.filter (fun i => i ∉ K), E (p i) = 0 := by
    apply Finset.sum_eq_zero
    intro i hi
    exact hU i (by simpa using (Finset.mem_filter.mp hi).2)
  rw [h1, h2, add_zero]

/-- **Splitting theorem (headline form).**  `d` cards predicted with certainty
each pay one unit, the remaining cards are fair guesses; the expected payoff is
exactly `d = K.card`.  Uncertainty supplies no positive edge. -/
theorem expected_total_eq_certain_count [Nonempty Ω]
    (p : ι → Ω → ℚ) (K : Finset ι)
    (hK : ∀ i ∈ K, Resolved (p i) 1)
    (hU : ∀ i ∉ K, Fair (p i)) :
    E (fun ω => ∑ i, p i ω) = (K.card : ℚ) := by
  have := expected_total_eq_certain_sum (Ω := Ω) p K (fun _ => 1) hK hU
  simpa using this

/-- **No edge from uncertainty alone.**  A portfolio built exclusively out of
fair cards has zero expected payoff — regardless of how the cards are
correlated, and regardless of how cleverly the guesses were chosen. -/
theorem no_fair_portfolio_edge [Nonempty Ω]
    (p : ι → Ω → ℚ) (hU : ∀ i, Fair (p i)) :
    E (fun ω => ∑ i, p i ω) = 0 := by
  have := expected_total_eq_certain_count (Ω := Ω) p ∅ (by simp) (by simpa using hU)
  simpa using this

end KnownUnresolvedCards