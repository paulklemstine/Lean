/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Second moments in the catalog Erdős–Rényi model

This file builds directly on `Algebra.ErdosRenyi.Model`.  It derives the exact
second moment of an arbitrary finite family of subgraph indicators and a
Paley–Zygmund-style lower bound for appearance.  Together with the existing
first-moment theorem, these are the two standard counting tools used in random
graph threshold proofs.
-/
import Algebra.ErdosRenyi.Model
import Mathlib

open Finset BigOperators

namespace ErdosRenyi

variable {E ι : Type*} [Fintype E] [DecidableEq E] [Fintype ι]

/-- The second moment of a real random variable in the finite `G(n,p)` law. -/
noncomputable def secondMoment (p : ℝ) (X : (E → Bool) → ℝ) : ℝ :=
  ∑ g : E → Bool, weight p g * X g ^ 2

/-- The event that all edges in both prescribed sets are present is the event
that all edges in their union are present. -/
theorem allPresent_inter (A B : Finset E) :
    allPresent A ∩ allPresent B = allPresent (A ∪ B) := by
  ext g
  simp [allPresent]
  aesop

/-- Joint appearance probability of two fixed edge sets.  This is the overlap
calculation at the heart of second-moment estimates for subgraph counts. -/
theorem prob_allPresent_pair (p : ℝ) (A B : Finset E) :
    prob p (allPresent A ∩ allPresent B) = p ^ (A ∪ B).card := by
  rw [allPresent_inter, prob_allPresent]

/-- **Exact second-moment formula for subgraph counts.**  If copy `i` uses the
edge set `S i`, then
`E[X²] = ∑ i, ∑ j, p ^ |S i ∪ S j|`.
The off-diagonal terms explicitly retain all overlap information. -/
theorem secondMoment_subgraphCount (p : ℝ) (S : ι → Finset E) :
    secondMoment p (fun g => (subgraphCount S g : ℝ)) =
      ∑ i : ι, ∑ j : ι, p ^ (S i ∪ S j).card := by
  have hcount : ∀ g : E → Bool,
      (subgraphCount S g : ℝ) =
        ∑ i : ι, if (∀ e ∈ S i, g e = true) then 1 else 0 := by
    intro g
    simp [subgraphCount]
  simp only [secondMoment, hcount]
  simp_rw [pow_two, Finset.sum_mul, Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i hi
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro j hj
  rw [← prob_allPresent_pair p (S i) (S j)]
  unfold prob
  have hinter : allPresent (S i) ∩ allPresent (S j) =
      Finset.univ.filter (fun g =>
        (∀ e ∈ S i, g e = true) ∧ (∀ e ∈ S j, g e = true)) := by
    ext g
    simp [allPresent]
  rw [hinter, Finset.sum_filter]
  apply Finset.sum_congr rfl
  intro g hg
  by_cases hi' : ∀ e ∈ S i, g e = true
  · by_cases hj' : ∀ e ∈ S j, g e = true
    · have hp : (∀ e ∈ S i, g e = true) ∧ (∀ e ∈ S j, g e = true) := ⟨hi', hj'⟩
      simp only [if_pos hi', if_pos hj', if_pos hp]
      ring
    · have hp : ¬ ((∀ e ∈ S i, g e = true) ∧ (∀ e ∈ S j, g e = true)) :=
        fun h => hj' h.2
      simp only [if_pos hi', if_neg hj', if_neg hp]
      ring
  · have hp : ¬ ((∀ e ∈ S i, g e = true) ∧ (∀ e ∈ S j, g e = true)) :=
      fun h => hi' h.1
    simp only [if_neg hi', if_neg hp]
    ring

/-- Variance expressed through the first two moments. -/
noncomputable def countVariance (p : ℝ) (S : ι → Finset E) : ℝ :=
  secondMoment p (fun g => (subgraphCount S g : ℝ)) -
    expectation p (fun g => (subgraphCount S g : ℝ)) ^ 2

/-- Exact overlap expansion for the variance of a subgraph count. -/
theorem countVariance_eq_overlap_sum (p : ℝ) (S : ι → Finset E) :
    countVariance p S =
      (∑ i : ι, ∑ j : ι, p ^ (S i ∪ S j).card) -
        (∑ i : ι, p ^ (S i).card) ^ 2 := by
  rw [countVariance, secondMoment_subgraphCount, expectation_subgraphCount]

/-- A finite Cauchy–Schwarz inequality tailored to the support of a nonnegative
random variable. -/
theorem expectation_sq_le_prob_pos_mul_secondMoment
    {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (X : (E → Bool) → ℝ)
    (hX : ∀ g, 0 ≤ X g) :
    expectation p X ^ 2 ≤
      prob p (Finset.univ.filter (fun g => 0 < X g)) * secondMoment p X := by
  have hcs := Finset.sum_sq_le_sum_mul_sum_of_sq_eq_mul
    (Finset.univ : Finset (E → Bool))
    (r := fun g => weight p g * X g)
    (f := fun g => if 0 < X g then weight p g else 0)
    (g := fun g => weight p g * X g ^ 2)
    (fun g hg => by
      change 0 ≤ if 0 < X g then weight p g else 0
      split_ifs
      · exact weight_nonneg hp0 hp1 g
      · exact le_rfl)
    (fun g hg => mul_nonneg (weight_nonneg hp0 hp1 g) (sq_nonneg (X g)))
    (fun g hg => by
      change (weight p g * X g) ^ 2 =
        (if 0 < X g then weight p g else 0) * (weight p g * X g ^ 2)
      by_cases hx : 0 < X g
      · rw [if_pos hx]
        ring
      · have hx0 : X g = 0 := le_antisymm (not_lt.mp hx) (hX g)
        simp [hx0])
  simpa [expectation, prob, secondMoment, Finset.sum_filter] using hcs

/-- **Second-moment method / Paley–Zygmund at zero.**  For a nonnegative random
variable with positive second moment, its positivity probability is bounded below
by `(E X)² / E[X²]`. -/
theorem expectation_sq_div_secondMoment_le_prob_pos
    {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (X : (E → Bool) → ℝ)
    (hX : ∀ g, 0 ≤ X g) (h2 : 0 < secondMoment p X) :
    expectation p X ^ 2 / secondMoment p X ≤
      prob p (Finset.univ.filter (fun g => 0 < X g)) := by
  rw [div_le_iff₀ h2]
  simpa [mul_comm] using expectation_sq_le_prob_pos_mul_secondMoment hp0 hp1 X hX

/-- Specialized second-moment lower bound for the probability that at least one
member of a prescribed subgraph family appears. -/
theorem subgraphCount_secondMoment_lower_bound
    {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (S : ι → Finset E)
    (h2 : 0 < ∑ i : ι, ∑ j : ι, p ^ (S i ∪ S j).card) :
    (∑ i : ι, p ^ (S i).card) ^ 2 /
        (∑ i : ι, ∑ j : ι, p ^ (S i ∪ S j).card) ≤
      prob p (Finset.univ.filter (fun g => 0 < subgraphCount S g)) := by
  have h2' : 0 < secondMoment p (fun g => (subgraphCount S g : ℝ)) := by
    rw [secondMoment_subgraphCount]
    exact h2
  have hevent :
      Finset.univ.filter (fun g => 0 < subgraphCount S g) =
        Finset.univ.filter (fun g => (0 : ℝ) < (subgraphCount S g : ℝ)) := by
    ext g
    simp
  rw [← expectation_subgraphCount, ← secondMoment_subgraphCount, hevent]
  exact expectation_sq_div_secondMoment_le_prob_pos hp0 hp1
    (fun g => (subgraphCount S g : ℝ)) (fun _ => Nat.cast_nonneg _) h2'

end ErdosRenyi