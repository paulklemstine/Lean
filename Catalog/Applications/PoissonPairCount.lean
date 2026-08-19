/-
# Counting Poisson pairs: an exact bijection with the subgroup lattice

The converse of Poisson summation (`Catalog.Applications.PoissonSummationConverse`) says that
a nonempty Poisson pair is a subgroup together with its annihilator.  Here we upgrade that
statement from a *description* to an *enumeration*:

  the nonempty Poisson pairs of `G` are in **bijection** with the subgroups of `G`.

Consequently the analytic question "for how many pairs of finsets does Poisson summation
hold?" has a purely algebraic answer, `Nat.card (AddSubgroup G)`, and for a group of prime
order it collapses to exactly two pairs.

## Main results

* `FourierFA.poissonPairEquivSubgroup` — the bijection
  `{(S, T) // IsPoissonPair S T ∧ S.Nonempty} ≃ AddSubgroup G`.
* `FourierFA.card_poissonPairs` — the resulting count.
* `FourierFA.isPoissonPair_prime_card` — for `|G|` prime the only nonempty Poisson pairs are
  `({0}, Ĝ)` and `(G, {0})`.
-/

import Mathlib
import Catalog.Shared.FourierFiniteAbelian
import Catalog.Shared.FourierSubgroupDuality
import Catalog.Applications.PoissonSummationConverse

open Finset Fintype ComplexConjugate

namespace FourierFA

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-- The type of nonempty Poisson pairs of `G`. -/
abbrev PoissonPairs (G : Type*) [AddCommGroup G] [Fintype G] : Type _ :=
  {p : Finset G × Finset (AddChar G ℂ) // IsPoissonPair p.1 p.2 ∧ p.1.Nonempty}

/-- **The nonempty Poisson pairs of `G` are in bijection with the subgroups of `G`.**  The
map sends a pair to the annihilator of its dual side; its inverse sends a subgroup `H` to
`(H, H^⊥)`. -/
noncomputable def poissonPairEquivSubgroup : PoissonPairs G ≃ AddSubgroup G where
  toFun p := preAnnih p.1.2
  invFun H := by
    classical
    exact ⟨(subFinset H, annih H), isPoissonPair_subgroup H, subFinset_nonempty⟩
  left_inv := by
    rintro ⟨⟨S, T⟩, h, hS⟩
    classical
    refine Subtype.ext (Prod.ext ?_ ?_)
    · exact subFinset_preAnnih_eq h hS
    · exact annih_preAnnih_eq h hS
  right_inv := by
    intro H
    classical
    exact preAnnih_annih H

/-- **Exact count of Poisson pairs**: there are as many nonempty Poisson pairs as subgroups. -/
theorem card_poissonPairs :
    Nat.card (PoissonPairs G) = Nat.card (AddSubgroup G) :=
  Nat.card_congr poissonPairEquivSubgroup

/-! ## Groups of prime order -/

variable {S : Finset G} {T : Finset (AddChar G ℂ)}

/-- For a group of prime order, the only nonempty Poisson pairs are the two trivial ones. -/
theorem isPoissonPair_prime_card (hp : (Fintype.card G).Prime)
    (h : IsPoissonPair S T) (hS : S.Nonempty) :
    (S = {0} ∧ T = Finset.univ) ∨ (S = Finset.univ ∧ T = {0}) := by
  have hzero : (0 : G) ∈ S := zero_mem_of_isPoissonPair_primal h hS
  have hdvd : S.card ∣ Fintype.card G := card_dvd_of_isPoissonPair h hS
  rcases (Nat.Prime.eq_one_or_self_of_dvd hp _ hdvd) with h1 | h2
  · left
    have hSeq : S = {0} := by
      symm
      refine Finset.eq_of_subset_of_card_le ?_ (le_of_eq (by rw [h1, Finset.card_singleton]))
      intro x hx
      rw [Finset.mem_singleton.1 hx]
      exact hzero
    refine ⟨hSeq, ?_⟩
    refine isPoissonPair_unique_dual ?_ isPoissonPair_zero_univ ⟨0, ?_⟩
    · rw [← hSeq]; exact h
    · exact Finset.mem_singleton_self 0
  · right
    have hSeq : S = Finset.univ := by
      refine Finset.eq_univ_of_card S ?_
      rw [h2]
    refine ⟨hSeq, ?_⟩
    refine isPoissonPair_unique_dual ?_ isPoissonPair_univ_zero ⟨0, ?_⟩
    · rw [← hSeq]; exact h
    · exact Finset.mem_univ 0

end FourierFA