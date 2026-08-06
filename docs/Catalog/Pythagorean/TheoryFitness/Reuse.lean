/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license.

# k-fold reuse: the shared library strictly dominates a suite of specialists

Fix a finite corpus split into `k` blocks.  A *specialist* for block `i` writes
the general core plus its own private material; a *shared library* writes the
core once and all private material on top of it.  Both prove the whole corpus.

* `cost_library_add_card_core` : the exact accounting identity
  `cost(library) + k · core = Σ cost(specialist i) + core`;
* `library_cost_lt_specialists` : hence the library is strictly cheaper as soon
  as two specialists duplicate a nonempty core;
* `library_fitness_gt_specialists` : and therefore strictly fitter, by the
  ordinal principle of `Core.lean`.

This is the dependency-adjusted global champion conjecture proved outright for
the canonical comparison class (core + private material), with an exact formula
for the saving.
-/

import Catalog.Pythagorean.TheoryFitness.Core

namespace TheoryFitness

open Finset

variable {ι : Type*} (ℓ : ℕ → ℕ)

/-- **Exact reuse accounting.**  Pooling `k` specialists that all rebuild the
same core saves exactly `k - 1` copies of the core. -/
theorem cost_library_add_card_core (F : Finset ι) (core : Finset ℕ)
    (priv : ι → Finset ℕ) (hcore : ∀ i ∈ F, Disjoint core (priv i))
    (hpair : (F : Set ι).PairwiseDisjoint priv) :
    (∑ x ∈ core ∪ F.biUnion priv, ℓ x) + F.card * (∑ x ∈ core, ℓ x)
      = (∑ i ∈ F, ∑ x ∈ core ∪ priv i, ℓ x) + (∑ x ∈ core, ℓ x) := by
  have hdisj : Disjoint core (F.biUnion priv) :=
    (Finset.disjoint_biUnion_right _ _ _).2 hcore
  have hleft : (∑ x ∈ core ∪ F.biUnion priv, ℓ x)
      = (∑ x ∈ core, ℓ x) + ∑ i ∈ F, ∑ x ∈ priv i, ℓ x := by
    rw [Finset.sum_union hdisj, Finset.sum_biUnion hpair]
  have hright : (∑ i ∈ F, ∑ x ∈ core ∪ priv i, ℓ x)
      = F.card * (∑ x ∈ core, ℓ x) + ∑ i ∈ F, ∑ x ∈ priv i, ℓ x := by
    rw [Finset.sum_congr rfl (fun i hi => Finset.sum_union (hcore i hi)),
      Finset.sum_add_distrib, Finset.sum_const, smul_eq_mul]
  rw [hleft, hright]
  ring

/-- The shared library: the core plus every specialist's private material. -/
def libraryTheory (F : Finset ι) (core : Finset ℕ) (priv : ι → Finset ℕ)
    (corpus : Finset ℕ) : Theory where
  closure := core ∪ F.biUnion priv
  proves := corpus

/-- A specialist: the core rebuilt privately, plus its own material. -/
def specialistTheory (core : Finset ℕ) (priv : ι → Finset ℕ) (i : ι)
    (corpus : Finset ℕ) : Theory where
  closure := core ∪ priv i
  proves := corpus

/-- With two or more specialists duplicating a nonempty core, the shared library
is strictly cheaper than *any* single specialist is together with the others --
precisely, than the pooled cost of the suite. -/
theorem library_cost_lt_specialists (F : Finset ι) (core : Finset ℕ)
    (priv : ι → Finset ℕ) (corpus : Finset ℕ)
    (hcore : ∀ i ∈ F, Disjoint core (priv i))
    (hpair : (F : Set ι).PairwiseDisjoint priv)
    (hk : 2 ≤ F.card) (hpos : 0 < ∑ x ∈ core, ℓ x) :
    cost ℓ (libraryTheory F core priv corpus)
      < ∑ i ∈ F, cost ℓ (specialistTheory core priv i corpus) := by
  have h := cost_library_add_card_core ℓ F core priv hcore hpair
  have hcast : cost ℓ (libraryTheory F core priv corpus)
      = ∑ x ∈ core ∪ F.biUnion priv, ℓ x := rfl
  have hcast2 : (∑ i ∈ F, cost ℓ (specialistTheory core priv i corpus))
      = ∑ i ∈ F, ∑ x ∈ core ∪ priv i, ℓ x := rfl
  rw [hcast, hcast2]
  nlinarith [h, hpos, hk, Nat.zero_le (∑ x ∈ core ∪ F.biUnion priv, ℓ x)]

/-- **Dependency-adjusted champion, k-fold reuse form.**  The shared library has
strictly greater dependency-adjusted fitness than the pooled suite of
specialists proving the very same corpus. -/
theorem library_fitness_gt_specialists (F : Finset ι) (core : Finset ℕ)
    (priv : ι → Finset ℕ) (corpus : Finset ℕ)
    (hcore : ∀ i ∈ F, Disjoint core (priv i))
    (hpair : (F : Set ι).PairwiseDisjoint priv)
    (hk : 2 ≤ F.card) (hpos : 0 < ∑ x ∈ core, ℓ x)
    (hcorpus : 0 < corpus.card) :
    (corpus.card : ℚ) / ((∑ i ∈ F, cost ℓ (specialistTheory core priv i corpus) : ℕ) : ℚ)
      < fitness ℓ (libraryTheory F core priv corpus) := by
  have hlt := library_cost_lt_specialists ℓ F core priv corpus hcore hpair hk hpos
  have hlibpos : 0 < cost ℓ (libraryTheory F core priv corpus) := by
    have hsub : core ⊆ (libraryTheory F core priv corpus).closure := subset_union_left
    have : (∑ x ∈ core, ℓ x) ≤ cost ℓ (libraryTheory F core priv corpus) :=
      Finset.sum_le_sum_of_subset hsub
    omega
  have hsuitepos : (0 : ℚ)
      < ((∑ i ∈ F, cost ℓ (specialistTheory core priv i corpus) : ℕ) : ℚ) := by
    have : 0 < ∑ i ∈ F, cost ℓ (specialistTheory core priv i corpus) := by omega
    exact_mod_cast this
  have hlibposQ : (0 : ℚ) < ((cost ℓ (libraryTheory F core priv corpus) : ℕ) : ℚ) := by
    exact_mod_cast hlibpos
  have hnQ : (0 : ℚ) < (corpus.card : ℚ) := by exact_mod_cast hcorpus
  have hltQ : ((cost ℓ (libraryTheory F core priv corpus) : ℕ) : ℚ)
      < ((∑ i ∈ F, cost ℓ (specialistTheory core priv i corpus) : ℕ) : ℚ) := by
    exact_mod_cast hlt
  exact (div_lt_div_iff_of_pos_left hnQ hsuitepos hlibposQ).2 hltQ

end TheoryFitness