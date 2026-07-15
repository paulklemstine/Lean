import Mathlib

/-! # Topos-Theoretic Machine Learning: Foundations

This file develops the shared vocabulary connecting statistical learning theory to
topos-theoretic geometry.  It introduces concept families and their shattering /
Vapnik–Chervonenkis dimension, the Sauer–Shelah growth function, an abstract
sample-complexity functional, sieves on a preorder together with their lattice
structure, and the auxiliary data (cryptographic hardness witnesses, transfer
morphisms) used to phrase transfer and lower-bound results.

The downstream file `Bridges/VCCompactness.lean` builds the actual bridge theorems
on top of these definitions.
-/

open Finset

/-! ## Concept families, shattering and VC dimension -/

/-- A **concept family** on `α` is a nonempty collection of subsets of `α`
(the *concepts*), presented by their membership predicate `mem`. -/
structure ConceptFamily (α : Type*) where
  /-- `mem c` holds when `c` is one of the concepts of the family. -/
  mem : Set α → Prop
  /-- A concept family contains at least one concept. -/
  nonempty : ∃ c, mem c

namespace ConceptFamily

variable {α : Type*}

/-- A finite set `S` is **shattered** by the family if every subset `T ⊆ S` is cut
out on `S` by some concept: there is a concept `c` with `c ∩ S = T`. -/
def shatters (C : ConceptFamily α) (S : Finset α) : Prop :=
  ∀ T ⊆ S, ∃ c, C.mem c ∧ ∀ x ∈ S, (x ∈ c ↔ x ∈ T)

/-- `C.vcDimBound d` states that the VC dimension of `C` is at most `d`: no set of
cardinality exceeding `d` is shattered. -/
def vcDimBound (C : ConceptFamily α) (d : ℕ) : Prop :=
  ∀ S : Finset α, C.shatters S → S.card ≤ d

end ConceptFamily

/-- `CompactRank C n` records that `n` is the *compact rank* of the family `C`:
it bounds every shattered set and is either `0` or attained by some shattered set.
This is the learning-theoretic incarnation of a compact subobject rank. -/
def CompactRank {α : Type*} (C : ConceptFamily α) (n : ℕ) : Prop :=
  (∀ S : Finset α, C.shatters S → S.card ≤ n) ∧
    (n = 0 ∨ ∃ S : Finset α, C.shatters S ∧ S.card = n)

/-- A **cryptographic hardness witness** at level `k`: a shattered set of exactly
`k` points, certifying that learning the family is at least as hard as
distinguishing all `2^k` labelings of those points. -/
structure CryptoHardnessWitness {α : Type*} (C : ConceptFamily α) (k : ℕ) where
  /-- The shattered witness set. -/
  witness : Finset α
  /-- The witness set is shattered by the family. -/
  witness_shattered : C.shatters witness
  /-- The witness set has exactly `k` elements. -/
  witness_card : witness.card = k

/-! ## The Sauer–Shelah growth function -/

/-- The **Sauer–Shelah bound** `∑_{i ≤ d} C(m, i)`, the maximal number of distinct
labelings a family of VC dimension `d` can realize on `m` points. -/
def sauerShelahBound (m d : ℕ) : ℕ :=
  ∑ i ∈ Finset.range (d + 1), m.choose i

/-- At full dimension the Sauer–Shelah bound collapses to the exponential `2^k`. -/
theorem sauerShelah_full (k : ℕ) : sauerShelahBound k k = 2 ^ k := by
  unfold sauerShelahBound
  exact Nat.sum_range_choose k

/-! ## Sample complexity -/

/-- An abstract **sample-complexity functional** `d / ε² · log(1/δ)`, capturing the
standard dependence on VC dimension `d`, accuracy `ε`, and confidence `δ`. -/
noncomputable def sampleComplexityBound (d : ℕ) (ε δ : ℝ) : ℝ :=
  (d : ℝ) / ε ^ 2 * Real.log (1 / δ)

/-- The sample-complexity functional is strictly positive for admissible
parameters. -/
theorem sampleComplexityBound_pos {d : ℕ} {ε δ : ℝ}
    (hd : 0 < d) (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) :
    0 < sampleComplexityBound d ε δ := by
  unfold sampleComplexityBound
  have h1 : (0:ℝ) < (d:ℝ) / ε ^ 2 := by positivity
  have h2 : 0 < Real.log (1 / δ) := by
    apply Real.log_pos
    rw [lt_div_iff₀ hδ]; linarith
  positivity

/-- The sample-complexity functional is monotone in the VC dimension. -/
theorem sampleComplexity_linear_in_d {d₁ d₂ : ℕ} {ε δ : ℝ}
    (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) (hd : d₁ ≤ d₂) :
    sampleComplexityBound d₁ ε δ ≤ sampleComplexityBound d₂ ε δ := by
  unfold sampleComplexityBound
  have hlog : 0 < Real.log (1 / δ) := by
    apply Real.log_pos; rw [lt_div_iff₀ hδ]; linarith
  have hcast : (d₁:ℝ) ≤ (d₂:ℝ) := by exact_mod_cast hd
  gcongr

/-! ## Sieves on a preorder and their lattice structure -/

/-- A **sieve on `d`** in a preorder `α`: a downward-closed set of elements, all of
which lie below the target `d`.  Sieves are the topos-theoretic classifiers used to
encode downward-closed concepts. -/
structure SieveOn (α : Type*) [Preorder α] (d : α) where
  /-- The underlying set of the sieve. -/
  carrier : Set α
  /-- Sieves are closed downward under the order. -/
  downward_closed : ∀ x y, x ∈ carrier → y ≤ x → y ∈ carrier
  /-- Every element of a sieve lies below the target. -/
  below_target : ∀ x, x ∈ carrier → x ≤ d

namespace SieveOn

variable {α : Type*} [Preorder α] {d : α}

@[ext] theorem ext {s t : SieveOn α d} (h : s.carrier = t.carrier) : s = t := by
  cases s; cases t; simp_all

/-- Sieves on `d` form a partial order under inclusion of carriers. -/
instance : PartialOrder (SieveOn α d) where
  le s t := s.carrier ⊆ t.carrier
  le_refl _ := subset_rfl
  le_trans _ _ _ h1 h2 := subset_trans h1 h2
  le_antisymm _ _ h1 h2 := SieveOn.ext (Set.Subset.antisymm h1 h2)

/-- The empty sieve. -/
def empty (d : α) : SieveOn α d where
  carrier := ∅
  downward_closed := by intro _ _ hx _; exact absurd hx (by simp)
  below_target := by intro _ hx; exact absurd hx (by simp)

/-- The maximal sieve on `d`, consisting of everything below `d`. -/
def maximal (d : α) : SieveOn α d where
  carrier := {x | x ≤ d}
  downward_closed := fun _ _ hx hle => le_trans hle hx
  below_target := fun _ hx => hx

/-- The empty sieve is the bottom element. -/
theorem empty_le (d : α) (s : SieveOn α d) : empty d ≤ s := by
  intro x hx; exact absurd hx (by simp [empty])

/-- The maximal sieve is the top element. -/
theorem le_maximal (d : α) (s : SieveOn α d) : s ≤ maximal d :=
  fun x hx => s.below_target x hx

end SieveOn

/-! ## Transfer morphisms -/

/-- A **transfer morphism** between concept families records the Lipschitz constant
governing how accuracy inflates when transporting a learner from one family to
another. -/
structure TransferMorphism {α β : Type*} (C₁ : ConceptFamily α)
    (C₂ : ConceptFamily β) where
  /-- The Lipschitz constant of the transfer map. -/
  lipschitzConst : ℝ