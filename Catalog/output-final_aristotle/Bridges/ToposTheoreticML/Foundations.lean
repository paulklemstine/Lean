import Mathlib

/-! # Foundations for Topos-Theoretic Machine Learning

This file sets up the basic vocabulary shared by the learning-theoretic and
topos-theoretic sides of the bridge developed in `VCCompactness.lean`:

* concept families and their **shattering** relation on finite samples,
* the **VC dimension bound** and the derived notion of **compact rank**,
* a **growth function** (Sauer–Shelah style bound),
* an abstract **sample-complexity** quantity,
* **sieves** on a preorder, forming the classifying object `Ω` of a presheaf topos,
  organised here as a bounded partial order.

All of these are elementary structures; the substantive theorems relating them
(No-Free-Lunch, VC-characterisation of learnability, the sieve lattice laws, and
the concept-to-sieve encoding) are proved in `VCCompactness.lean`.
-/

noncomputable section

open Finset

/-! ## Concept families and shattering -/

/-- A **concept family** on a domain `α` is a nonempty collection of concepts,
each concept being a subset of `α` (its set of positive instances). -/
structure ConceptFamily (α : Type*) where
  /-- The underlying collection of concepts. -/
  concepts : Set (Set α)
  /-- A concept family is required to be nonempty. -/
  nonempty : ∃ c, c ∈ concepts

/-- A finite sample `S` is **shattered** by `C` when every subset `T ⊆ S` is cut
out of `S` by some concept: there is `c ∈ C.concepts` agreeing with `T` on `S`. -/
def ConceptFamily.shatters {α : Type*} (C : ConceptFamily α) (S : Finset α) : Prop :=
  ∀ T : Finset α, T ⊆ S → ∃ c ∈ C.concepts, ∀ x ∈ S, (x ∈ c ↔ x ∈ T)

/-- `C.vcDimBound d` says that `d` is an upper bound for the size of every
shattered sample; i.e. the VC dimension of `C` is at most `d`. -/
def ConceptFamily.vcDimBound {α : Type*} (C : ConceptFamily α) (d : ℕ) : Prop :=
  ∀ S : Finset α, C.shatters S → S.card ≤ d

/-- `CompactRank C n` records that `n` is the VC dimension of `C` realised as a
"compact rank": it bounds every shattered sample and is either `0` or attained by
an actual shattered sample. -/
def CompactRank {α : Type*} (C : ConceptFamily α) (n : ℕ) : Prop :=
  (∀ S : Finset α, C.shatters S → S.card ≤ n) ∧
    (n = 0 ∨ ∃ S : Finset α, C.shatters S ∧ S.card = n)

/-- A **cryptographic hardness witness** at level `k`: an explicit shattered
sample of size exactly `k`, certifying that the VC dimension is at least `k`. -/
structure CryptoHardnessWitness {α : Type*} (C : ConceptFamily α) (k : ℕ) where
  /-- The witnessing sample. -/
  witness : Finset α
  /-- The sample is shattered by `C`. -/
  witness_shattered : C.shatters witness
  /-- The sample has exactly `k` points. -/
  witness_card : witness.card = k

/-- A **transfer morphism** between concept families, carrying a set-level map and
a Lipschitz constant governing how sample complexity transfers along it. -/
structure TransferMorphism {α β : Type*} (C₁ : ConceptFamily α) (C₂ : ConceptFamily β) where
  /-- The underlying map on concepts. -/
  map : Set α → Set β
  /-- The Lipschitz constant controlling sample-complexity inflation. -/
  lipschitzConst : ℝ

/-! ## Growth function -/

/-- The **Sauer–Shelah bound** `∑_{i ≤ d} C(m, i)`: the maximal number of distinct
behaviours a class of VC dimension `d` can exhibit on `m` points. -/
def sauerShelahBound (m d : ℕ) : ℕ := ∑ i ∈ Finset.range (d + 1), m.choose i

/-- When the VC dimension matches the sample size the Sauer–Shelah bound is
the full power set count `2 ^ k`. -/
theorem sauerShelah_full (k : ℕ) : sauerShelahBound k k = 2 ^ k := by
  unfold sauerShelahBound
  exact Nat.sum_range_choose k

/-! ## Sample complexity -/

/-- An abstract PAC **sample-complexity** quantity, proportional to the VC
dimension `d` and to `1 / ε²`, with confidence factor `1 - δ`. -/
def sampleComplexityBound (d : ℕ) (ε δ : ℝ) : ℝ := (d : ℝ) * (1 - δ) / ε ^ 2

/-- The sample-complexity bound is strictly positive for valid parameters. -/
theorem sampleComplexityBound_pos {d : ℕ} {ε δ : ℝ}
    (hd : 0 < d) (hε : 0 < ε) (_hδ : 0 < δ) (hδ1 : δ < 1) :
    0 < sampleComplexityBound d ε δ := by
  unfold sampleComplexityBound
  apply div_pos
  · exact mul_pos (by exact_mod_cast hd) (by linarith)
  · positivity

/-- The sample-complexity bound is monotone in the VC dimension. -/
theorem sampleComplexity_linear_in_d {d₁ d₂ : ℕ} {ε δ : ℝ}
    (hε : 0 < ε) (_hδ : 0 < δ) (hδ1 : δ < 1) (hd : d₁ ≤ d₂) :
    sampleComplexityBound d₁ ε δ ≤ sampleComplexityBound d₂ ε δ := by
  unfold sampleComplexityBound
  have h1 : (0 : ℝ) ≤ 1 - δ := by linarith
  have h2 : (d₁ : ℝ) ≤ d₂ := by exact_mod_cast hd
  gcongr

/-! ## Sieves on a preorder -/

/-- A **sieve** on `d` in a preorder `α`: a downward-closed set of elements all
lying below the target `d`.  These are the elements of the subobject classifier
`Ω(d)` of the presheaf topos on `α`. -/
structure SieveOn (α : Type*) [Preorder α] (d : α) where
  /-- The elements selected by the sieve. -/
  carrier : Set α
  /-- Sieves are downward closed. -/
  downward_closed : ∀ x y, x ∈ carrier → y ≤ x → y ∈ carrier
  /-- Every selected element lies below the target `d`. -/
  below_target : ∀ x, x ∈ carrier → x ≤ d

namespace SieveOn

variable {α : Type*} [Preorder α] {d : α}

@[ext] theorem ext {a b : SieveOn α d} (h : a.carrier = b.carrier) : a = b := by
  cases a; cases b; cases h; rfl

/-- Sieves on `d` are ordered by inclusion of carriers, forming a partial order. -/
instance : PartialOrder (SieveOn α d) where
  le a b := a.carrier ⊆ b.carrier
  le_refl a := subset_refl _
  le_trans a b c hab hbc := subset_trans hab hbc
  le_antisymm a b hab hba := ext (Set.Subset.antisymm hab hba)

/-- The empty sieve, the bottom of the sieve lattice. -/
def empty (d : α) : SieveOn α d where
  carrier := ∅
  downward_closed := fun _x _y hx _ => absurd hx (by simp)
  below_target := fun _x hx => absurd hx (by simp)

/-- The maximal sieve `{x | x ≤ d}`, the top of the sieve lattice. -/
def maximal (d : α) : SieveOn α d where
  carrier := {x | x ≤ d}
  downward_closed := fun _x _y hx hyx => le_trans hyx hx
  below_target := fun _x hx => hx

theorem empty_le (d : α) (s : SieveOn α d) : empty d ≤ s := Set.empty_subset _

theorem le_maximal (d : α) (s : SieveOn α d) : s ≤ maximal d :=
  fun x hx => s.below_target x hx

end SieveOn