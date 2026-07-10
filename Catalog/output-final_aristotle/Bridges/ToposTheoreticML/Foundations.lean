import Mathlib

/-! # Foundations for Topos-Theoretic Machine Learning

This file sets up the basic vocabulary shared by the learning-theoretic and
topos-theoretic developments:

* `ConceptFamily` and its `shatters` / `vcDimBound` predicates (combinatorics of
  Vapnik–Chervonenkis theory);
* `CompactRank`, the categorical counterpart of the VC dimension;
* `CryptoHardnessWitness`, a shattered witness set used in hardness reductions;
* `sauerShelahBound` and `sampleComplexityBound`, the two quantitative growth
  functions of statistical learning;
* `SieveOn`, the poset of sieves on an object, together with its bounded-lattice
  structure and the two extreme sieves `empty` and `maximal`.

Everything here is elementary; the substantive theorems live in the companion
file that imports this one.
-/

noncomputable section

open Finset

/-! ## Concept families and shattering -/

/-- A concept family on `α` is a nonempty collection of concepts (subsets of `α`). -/
structure ConceptFamily (α : Type*) where
  /-- The underlying set of concepts. -/
  concepts : Set (Set α)
  /-- A concept family is required to be nonempty. -/
  nonempty : concepts.Nonempty

namespace ConceptFamily

variable {α : Type*}

/-- A finite set `S` is *shattered* by `C` if every subset `T ⊆ S` is realised by
some concept, i.e. there is a concept agreeing with `T` on all of `S`. -/
def shatters (C : ConceptFamily α) (S : Finset α) : Prop :=
  ∀ T : Finset α, T ⊆ S → ∃ c ∈ C.concepts, ∀ x ∈ S, (x ∈ c ↔ x ∈ T)

/-- `C.vcDimBound d` says that no shattered set is larger than `d`; the least such
`d` (when it exists) is the Vapnik–Chervonenkis dimension. -/
def vcDimBound (C : ConceptFamily α) (d : ℕ) : Prop :=
  ∀ S : Finset α, C.shatters S → S.card ≤ d

end ConceptFamily

/-- The *compact rank* of a concept family: an upper bound `n` on the size of every
shattered set which is moreover attained (unless it is `0`).  This is the
topos-theoretic reformulation of the VC dimension as the rank of the largest
compact subobject that can be separated. -/
def CompactRank {α : Type*} (C : ConceptFamily α) (n : ℕ) : Prop :=
  (∀ S : Finset α, C.shatters S → S.card ≤ n) ∧
    (n = 0 ∨ ∃ S : Finset α, C.shatters S ∧ S.card = n)

/-- A hardness witness for a concept family: an explicit shattered set of a
prescribed cardinality `k`. -/
structure CryptoHardnessWitness {α : Type*} (C : ConceptFamily α) (k : ℕ) where
  /-- The witnessing finite set. -/
  witness : Finset α
  /-- The witness is shattered by `C`. -/
  witness_shattered : C.shatters witness
  /-- The witness has cardinality `k`. -/
  witness_card : witness.card = k

/-- A transfer morphism between two concept families, recording (for the purposes
of sample-complexity transfer) its Lipschitz constant. -/
structure TransferMorphism {α β : Type*}
    (C₁ : ConceptFamily α) (C₂ : ConceptFamily β) where
  /-- The Lipschitz constant governing sample-complexity inflation. -/
  lipschitzConst : ℝ

/-! ## Growth functions -/

/-- The Sauer–Shelah growth function `∑_{i ≤ d} C(m, i)`. -/
def sauerShelahBound (m d : ℕ) : ℕ := ∑ i ∈ Finset.range (d + 1), m.choose i

/-- At the diagonal the Sauer–Shelah bound is the full power of two: a set of
size `k` has `2^k` subsets. -/
theorem sauerShelah_full (k : ℕ) : sauerShelahBound k k = 2 ^ k := by
  unfold sauerShelahBound
  rw [Nat.sum_range_choose]

/-- A representative PAC sample-complexity bound, scaling like `d / ε²`. -/
def sampleComplexityBound (d : ℕ) (ε : ℝ) (_δ : ℝ) : ℝ := (d : ℝ) / ε ^ 2

/-- The sample-complexity bound is positive for admissible parameters. -/
theorem sampleComplexityBound_pos {d : ℕ} {ε δ : ℝ}
    (hd : 0 < d) (hε : 0 < ε) (_hδ : 0 < δ) (_hδ1 : δ < 1) :
    0 < sampleComplexityBound d ε δ := by
  unfold sampleComplexityBound
  have hd' : (0 : ℝ) < d := by exact_mod_cast hd
  positivity

/-- The sample-complexity bound is monotone in the VC dimension. -/
theorem sampleComplexity_linear_in_d {d₁ d₂ : ℕ} {ε δ : ℝ}
    (hε : 0 < ε) (_hδ : 0 < δ) (_hδ1 : δ < 1) (hd : d₁ ≤ d₂) :
    sampleComplexityBound d₁ ε δ ≤ sampleComplexityBound d₂ ε δ := by
  unfold sampleComplexityBound
  have hcast : (d₁ : ℝ) ≤ d₂ := by exact_mod_cast hd
  have hden : (0 : ℝ) < ε ^ 2 := by positivity
  gcongr

/-! ## Sieves and their lattice structure -/

/-- A sieve on `d` in a preorder: a downward-closed set of elements below `d`. -/
structure SieveOn (α : Type*) [Preorder α] (d : α) where
  /-- The underlying set of the sieve. -/
  carrier : Set α
  /-- Sieves are downward closed. -/
  downward_closed : ∀ x y, x ∈ carrier → y ≤ x → y ∈ carrier
  /-- Every element of a sieve on `d` lies below `d`. -/
  below_target : ∀ x, x ∈ carrier → x ≤ d

namespace SieveOn

variable {α : Type*} [Preorder α] {d : α}

@[ext] theorem ext {s t : SieveOn α d} (h : s.carrier = t.carrier) : s = t := by
  cases s; cases t; simp_all

instance : PartialOrder (SieveOn α d) where
  le s t := s.carrier ⊆ t.carrier
  le_refl s := subset_refl _
  le_trans _ _ _ hab hbc := subset_trans hab hbc
  le_antisymm _ _ hab hba := ext (subset_antisymm hab hba)

/-- The empty sieve. -/
def empty (d : α) : SieveOn α d where
  carrier := ∅
  downward_closed := by intro x y hx _; simp only [Set.mem_empty_iff_false] at hx
  below_target := by intro x hx; simp only [Set.mem_empty_iff_false] at hx

/-- The maximal sieve on `d`: everything below `d`. -/
def maximal (d : α) : SieveOn α d where
  carrier := {x | x ≤ d}
  downward_closed := fun _ _ hx hyx => le_trans hyx hx
  below_target := fun _ hx => hx

theorem empty_le (d : α) (s : SieveOn α d) : empty d ≤ s := by
  intro x hx; simp only [empty, Set.mem_empty_iff_false] at hx

theorem le_maximal (d : α) (s : SieveOn α d) : s ≤ maximal d :=
  fun x hx => s.below_target x hx

end SieveOn

end