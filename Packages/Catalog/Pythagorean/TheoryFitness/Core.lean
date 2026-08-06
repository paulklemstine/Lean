/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license.

# Dependency-adjusted fitness of formal theories (Core)

This file makes the "fitness landscape of mathematical theories" programme
precise enough to be *falsifiable*.  A **theory** is modelled by

* the transitive **dependency closure** of the declarations it uses, as a
  `Finset` of declaration identifiers -- so a dependency shared by two parts of
  the development is charged exactly once, and
* the finite set of corpus statements it **proves**.

Given a source-length function `ℓ`, the *dependency-adjusted cost* is the sum of
`ℓ` over the closure and the *fitness* is `#proved / cost`.

The main results are:

* `TheoryFitness.depClosure` : the transitive dependency closure exists inside a
  finite universe, is dependency-closed, contains the base, and is the **least**
  such set (`depClosure_minimal`);  hence the cost model is canonical.
* `depClosed_union`, `depClosed_inter` : dependency-closed libraries form a
  lattice, so the *shared* dependency mass of two developments is itself a
  legitimate library -- this is what licenses "charge shared dependencies once".
* `cost_union_add_cost_inter` : the exact inclusion-exclusion accounting of a
  merge.
* `fitness_le_iff_cost_le` : on a fixed corpus, fitness is a purely ordinal
  inverse of dependency-adjusted cost.
* `finite_maximum_principle` : a finite comparison class always has a champion.
* `shared_library_is_champion` : a library whose closure embeds in every
  competitor's closure *is* the champion; this is the exact content of the
  "dependency-adjusted global champion conjecture" once the comparison class and
  the cost model are fixed.
-/

import Mathlib

namespace TheoryFitness

open Finset

/-! ## Transitive dependency closures -/

section Closure

variable (deps : ℕ → Finset ℕ)

/-- A set of declarations is *dependency-closed* when it contains the direct
dependencies of each of its members. -/
def DepClosed (s : Finset ℕ) : Prop := ∀ i ∈ s, deps i ⊆ s

theorem depClosed_union {s t : Finset ℕ} (hs : DepClosed deps s)
    (ht : DepClosed deps t) : DepClosed deps (s ∪ t) := by
  intro i hi
  rcases mem_union.1 hi with h | h
  · exact (hs i h).trans subset_union_left
  · exact (ht i h).trans subset_union_right

theorem depClosed_inter {s t : Finset ℕ} (hs : DepClosed deps s)
    (ht : DepClosed deps t) : DepClosed deps (s ∩ t) := by
  intro i hi
  rw [mem_inter] at hi
  exact subset_inter (hs i hi.1) (ht i hi.2)

/-- One round of dependency expansion. -/
def depStep (s : Finset ℕ) : Finset ℕ := s ∪ s.biUnion deps

theorem subset_depStep (s : Finset ℕ) : s ⊆ depStep deps s := subset_union_left

theorem depStep_eq_self_iff (s : Finset ℕ) :
    depStep deps s = s ↔ DepClosed deps s := by
  constructor
  · intro h i hi j hj
    rw [← h]
    exact mem_union_right _ (mem_biUnion.2 ⟨i, hi, hj⟩)
  · intro h
    apply Subset.antisymm _ (subset_depStep deps s)
    intro j hj
    rcases mem_union.1 hj with hj | hj
    · exact hj
    · obtain ⟨i, hi, hij⟩ := mem_biUnion.1 hj
      exact h i hi hij

theorem depStep_subset_of_closed {s t : Finset ℕ} (ht : DepClosed deps t)
    (hst : s ⊆ t) : depStep deps s ⊆ t := by
  intro j hj
  rcases mem_union.1 hj with hj | hj
  · exact hst hj
  · obtain ⟨i, hi, hij⟩ := mem_biUnion.1 hj
    exact ht i (hst hi) hij

/-- The transitive dependency closure of `base`, computed inside a finite
universe `U`.  Iterating `depStep` more times than `U` has elements must reach a
fixed point. -/
def depClosure (U base : Finset ℕ) : Finset ℕ :=
  (depStep deps)^[U.card + 1] base

variable {deps}

theorem iterate_depStep_subset {U base : Finset ℕ} (hbase : base ⊆ U)
    (hU : DepClosed deps U) (k : ℕ) : (depStep deps)^[k] base ⊆ U := by
  induction k with
  | zero => simpa using hbase
  | succ k ih =>
      rw [Function.iterate_succ_apply']
      exact depStep_subset_of_closed deps hU ih

theorem monotone_iterate_depStep (base : Finset ℕ) (k : ℕ) :
    (depStep deps)^[k] base ⊆ (depStep deps)^[k + 1] base := by
  rw [Function.iterate_succ_apply']
  exact subset_depStep deps _

theorem base_subset_depClosure (U base : Finset ℕ) :
    base ⊆ depClosure deps U base := by
  have h : ∀ k, base ⊆ (depStep deps)^[k] base := by
    intro k
    induction k with
    | zero => simp
    | succ k ih => exact ih.trans (monotone_iterate_depStep base k)
  exact h _

theorem depClosure_subset {U base : Finset ℕ} (hbase : base ⊆ U)
    (hU : DepClosed deps U) : depClosure deps U base ⊆ U :=
  iterate_depStep_subset hbase hU _

/-- Minimality: the closure sits inside every dependency-closed set containing
the base. -/
theorem depClosure_minimal {U base t : Finset ℕ} (ht : DepClosed deps t)
    (hbt : base ⊆ t) : depClosure deps U base ⊆ t := by
  have h : ∀ k, (depStep deps)^[k] base ⊆ t := by
    intro k
    induction k with
    | zero => simpa using hbt
    | succ k ih =>
        rw [Function.iterate_succ_apply']
        exact depStep_subset_of_closed deps ht ih
  exact h _

/-- The computed closure really is dependency-closed. -/
theorem depClosed_depClosure {U base : Finset ℕ} (hbase : base ⊆ U)
    (hU : DepClosed deps U) : DepClosed deps (depClosure deps U base) := by
  rw [← depStep_eq_self_iff]
  set S : ℕ → Finset ℕ := fun k => (depStep deps)^[k] base with hS
  by_contra hfix
  -- if the chain never stabilises before step `U.card + 1`, its cardinality
  -- exceeds `U.card`, contradicting `S k ⊆ U`.
  have key : ∀ k, k ≤ U.card + 1 → k ≤ (S k).card := by
    intro k
    induction k with
    | zero => intro _; exact Nat.zero_le _
    | succ k ih =>
        intro hk
        have hsub : S k ⊆ S (k + 1) := monotone_iterate_depStep base k
        have hne : S k ≠ S (k + 1) := by
          intro heq
          -- `S k` would be a fixed point, hence so is `depClosure`
          have hfixk : depStep deps (S k) = S k := by
            have : S (k + 1) = depStep deps (S k) := Function.iterate_succ_apply' _ _ _
            rw [← this, ← heq]
          have hlast : S (U.card + 1) = S k := by
            have hkk : U.card + 1 = (U.card + 1 - k) + k := by omega
            show (depStep deps)^[U.card + 1] base = S k
            rw [hkk, Function.iterate_add_apply]
            exact Function.iterate_fixed hfixk _
          apply hfix
          show depStep deps ((depStep deps)^[U.card + 1] base)
              = (depStep deps)^[U.card + 1] base
          have : S (U.card + 1) = (depStep deps)^[U.card + 1] base := rfl
          rw [← this, hlast]
          exact hfixk
        have hcard : (S k).card < (S (k + 1)).card :=
          card_lt_card (Finset.ssubset_iff_subset_ne.2 ⟨hsub, hne⟩)
        have := ih (by omega)
        omega
  have h1 : U.card + 1 ≤ (S (U.card + 1)).card := key _ le_rfl
  have h2 : (S (U.card + 1)).card ≤ U.card :=
    card_le_card (iterate_depStep_subset hbase hU _)
  omega

end Closure

/-! ## Theories, dependency-adjusted cost and fitness -/

/-- A theory (a formal development) is recorded by the transitive dependency
closure of the declarations it uses, together with the corpus statements it
proves. -/
structure Theory where
  /-- transitive dependency closure of everything the development uses -/
  closure : Finset ℕ
  /-- the corpus statements the development proves -/
  proves : Finset ℕ

/-- Dependency-adjusted cost: every declaration in the transitive closure is
charged its source length exactly once. -/
def cost (ℓ : ℕ → ℕ) (T : Theory) : ℕ := ∑ i ∈ T.closure, ℓ i

/-- Fitness: proved corpus statements per unit of dependency-adjusted cost. -/
def fitness (ℓ : ℕ → ℕ) (T : Theory) : ℚ := (T.proves.card : ℚ) / (cost ℓ T : ℚ)

theorem cost_mono (ℓ : ℕ → ℕ) {T U : Theory} (h : T.closure ⊆ U.closure) :
    cost ℓ T ≤ cost ℓ U :=
  Finset.sum_le_sum_of_subset h

/-- The merge of two developments: dependencies are pooled (hence shared ones
are charged once) and the proved corpora are pooled. -/
def merge (T U : Theory) : Theory where
  closure := T.closure ∪ U.closure
  proves := T.proves ∪ U.proves

/-- Exact inclusion-exclusion accounting for a merge: the cost of the merge plus
the shared dependency mass equals the sum of the separate costs. -/
theorem cost_merge_add_cost_inter (ℓ : ℕ → ℕ) (T U : Theory) :
    cost ℓ (merge T U) + ∑ i ∈ T.closure ∩ U.closure, ℓ i
      = cost ℓ T + cost ℓ U :=
  Finset.sum_union_inter

/-- Merging never costs more than duplicating. -/
theorem cost_merge_le (ℓ : ℕ → ℕ) (T U : Theory) :
    cost ℓ (merge T U) ≤ cost ℓ T + cost ℓ U := by
  have := cost_merge_add_cost_inter ℓ T U
  omega

/-! ## Ordinal structure of fitness on a fixed corpus -/

/-- On a fixed nonempty corpus, fitness is exactly the reverse order of
dependency-adjusted cost.  This is the *finite maximum principle* in ordinal
form: nothing about the corpus matters except its cardinality. -/
theorem fitness_le_iff_cost_le (ℓ : ℕ → ℕ) {T U : Theory}
    (hcorpus : T.proves.card = U.proves.card) (hne : 0 < T.proves.card)
    (hT : 0 < cost ℓ T) (hU : 0 < cost ℓ U) :
    fitness ℓ T ≤ fitness ℓ U ↔ cost ℓ U ≤ cost ℓ T := by
  have hTQ : (0 : ℚ) < (cost ℓ T : ℚ) := by exact_mod_cast hT
  have hUQ : (0 : ℚ) < (cost ℓ U : ℚ) := by exact_mod_cast hU
  have hnQ : (0 : ℚ) < (T.proves.card : ℚ) := by exact_mod_cast hne
  unfold fitness
  rw [hcorpus] at hnQ ⊢
  rw [div_le_div_iff_of_pos_left hnQ hTQ hUQ]
  exact_mod_cast Iff.rfl

/-- Strict form of `fitness_le_iff_cost_le`. -/
theorem fitness_lt_iff_cost_lt (ℓ : ℕ → ℕ) {T U : Theory}
    (hcorpus : T.proves.card = U.proves.card) (hne : 0 < T.proves.card)
    (hT : 0 < cost ℓ T) (hU : 0 < cost ℓ U) :
    fitness ℓ T < fitness ℓ U ↔ cost ℓ U < cost ℓ T := by
  have h2 := fitness_le_iff_cost_le ℓ hcorpus.symm (hcorpus ▸ hne) hU hT
  rw [lt_iff_not_ge, lt_iff_not_ge, not_iff_not]
  exact h2

/-- **Finite maximum principle.**  Any nonempty finite comparison class of
theories contains a fitness champion. -/
theorem finite_maximum_principle {ι : Type*} (ℓ : ℕ → ℕ) (F : Finset ι)
    (hF : F.Nonempty) (Th : ι → Theory) :
    ∃ b ∈ F, ∀ a ∈ F, fitness ℓ (Th a) ≤ fitness ℓ (Th b) :=
  F.exists_max_image (fun a => fitness ℓ (Th a)) hF

/-- **Dependency-adjusted global champion.**  Among developments proving the
same corpus, a library whose transitive dependency closure embeds into every
competitor's closure has maximal dependency-adjusted fitness.  This is exactly
the reuse principle: general abstractions are paid for once and then dominate. -/
theorem shared_library_is_champion {ι : Type*} (ℓ : ℕ → ℕ) (F : Finset ι)
    (Th : ι → Theory) (L : Theory)
    (hcorpus : ∀ a ∈ F, (Th a).proves.card = L.proves.card)
    (hne : 0 < L.proves.card)
    (hsub : ∀ a ∈ F, L.closure ⊆ (Th a).closure)
    (hpos : 0 < cost ℓ L) :
    ∀ a ∈ F, fitness ℓ (Th a) ≤ fitness ℓ L := by
  intro a ha
  have hcost : cost ℓ L ≤ cost ℓ (Th a) := cost_mono ℓ (hsub a ha)
  have hposa : 0 < cost ℓ (Th a) := lt_of_lt_of_le hpos hcost
  exact (fitness_le_iff_cost_le ℓ (hcorpus a ha) (by rw [hcorpus a ha]; exact hne)
    hposa hpos).2 hcost

/-- Conversely, the champion among full-corpus provers is *characterised* by
minimal dependency-adjusted cost: the conjecture is empirically decidable by a
single measurement per competitor. -/
theorem champion_iff_min_cost {ι : Type*} (ℓ : ℕ → ℕ) (F : Finset ι)
    (Th : ι → Theory) (b : ι)
    (hcorpus : ∀ a ∈ F, (Th a).proves.card = (Th b).proves.card)
    (hne : 0 < (Th b).proves.card)
    (hposb : 0 < cost ℓ (Th b)) (hpos : ∀ a ∈ F, 0 < cost ℓ (Th a)) :
    (∀ a ∈ F, fitness ℓ (Th a) ≤ fitness ℓ (Th b)) ↔
      ∀ a ∈ F, cost ℓ (Th b) ≤ cost ℓ (Th a) := by
  constructor
  · intro h a ha
    exact (fitness_le_iff_cost_le ℓ (hcorpus a ha)
      (by rw [hcorpus a ha]; exact hne) (hpos a ha) hposb).1 (h a ha)
  · intro h a ha
    exact (fitness_le_iff_cost_le ℓ (hcorpus a ha)
      (by rw [hcorpus a ha]; exact hne) (hpos a ha) hposb).2 (h a ha)

end TheoryFitness