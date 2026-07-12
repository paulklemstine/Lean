import Mathlib

/-! # Topos-Theoretic Machine Learning: Foundations

This file provides the basic definitions shared by the topos-theoretic machine
learning development (see `Bridges.VCCompactness`):

* `ConceptFamily` — a nonempty family of concepts (subsets of the instance space);
* shattering (`ConceptFamily.shatters`) and the VC-dimension bound predicate
  (`ConceptFamily.vcDimBound`);
* `CompactRank` — the topos-theoretic "compact rank" of a concept family;
* `CryptoHardnessWitness` — a shattered witness set of a fixed size;
* the Sauer–Shelah growth bound `sauerShelahBound`;
* a PAC-style `sampleComplexityBound` together with its positivity and
  monotonicity lemmas;
* `TransferMorphism` between concept families with a Lipschitz constant;
* sieves on a preorder (`SieveOn`) with their bounded-lattice structure.

Everything is elementary and `sorry`-free.
-/

noncomputable section

/-! ## Concept families, shattering and VC dimension -/

/-- A concept family on an instance space `α` is a nonempty family of concepts,
each concept being a subset of `α`. -/
structure ConceptFamily (α : Type*) where
  /-- The underlying set of concepts. -/
  concepts : Set (Set α)
  /-- The family is nonempty. -/
  nonempty : ∃ c, c ∈ concepts

/-- A finite set `S` is *shattered* by `C` if every subset `T ⊆ S` is realized by
some concept `c` in the family, i.e. `c ∩ S = T`. -/
def ConceptFamily.shatters {α : Type*} (C : ConceptFamily α) (S : Finset α) : Prop :=
  ∀ T ⊆ S, ∃ c ∈ C.concepts, ∀ x ∈ S, (x ∈ c ↔ x ∈ T)

/-- `C.vcDimBound d` states that no shattered set has more than `d` elements. -/
def ConceptFamily.vcDimBound {α : Type*} (C : ConceptFamily α) (d : ℕ) : Prop :=
  ∀ S : Finset α, C.shatters S → S.card ≤ d

/-- The *compact rank* of a concept family: `n` bounds every shattered set and is
either `0` or itself realized by a shattered set of size `n`. -/
def CompactRank {α : Type*} (C : ConceptFamily α) (n : ℕ) : Prop :=
  C.vcDimBound n ∧ (n = 0 ∨ ∃ S : Finset α, C.shatters S ∧ S.card = n)

/-- A cryptographic-hardness witness: a shattered set of a prescribed size `k`. -/
structure CryptoHardnessWitness {α : Type*} (C : ConceptFamily α) (k : ℕ) where
  /-- The witnessing finite set. -/
  witness : Finset α
  /-- The witness is shattered by `C`. -/
  witness_shattered : C.shatters witness
  /-- The witness has exactly `k` elements. -/
  witness_card : witness.card = k

/-! ## Sauer–Shelah growth function -/

/-- The Sauer–Shelah growth bound `∑_{i ≤ d} C(m, i)`. -/
def sauerShelahBound (m d : ℕ) : ℕ := ∑ i ∈ Finset.range (d + 1), m.choose i

/-- At full dimension `d = m` the Sauer–Shelah bound equals `2 ^ m`. -/
theorem sauerShelah_full (k : ℕ) : sauerShelahBound k k = 2 ^ k := by
  unfold sauerShelahBound
  exact Nat.sum_range_choose k

/-! ## PAC sample complexity -/

/-- A PAC-style sample-complexity bound, linear in the VC dimension `d` and
inversely proportional to `ε ^ 2`. -/
def sampleComplexityBound (d : ℕ) (ε δ : ℝ) : ℝ := (d : ℝ) * (1 - δ) / ε ^ 2

/-- The sample-complexity bound is positive for valid parameters. -/
theorem sampleComplexityBound_pos {d : ℕ} {ε δ : ℝ}
    (hd : 0 < d) (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) :
    0 < sampleComplexityBound d ε δ := by
  unfold sampleComplexityBound
  have hd' : (0 : ℝ) < (d : ℝ) := by exact_mod_cast hd
  apply div_pos
  · nlinarith
  · positivity

/-- The sample-complexity bound is monotone in the VC dimension. -/
theorem sampleComplexity_linear_in_d {d₁ d₂ : ℕ} {ε δ : ℝ}
    (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) (hd : d₁ ≤ d₂) :
    sampleComplexityBound d₁ ε δ ≤ sampleComplexityBound d₂ ε δ := by
  unfold sampleComplexityBound
  have hc : (d₁ : ℝ) ≤ (d₂ : ℝ) := by exact_mod_cast hd
  have hδ' : (0 : ℝ) ≤ 1 - δ := by linarith
  gcongr

/-! ## Transfer morphisms -/

/-- A transfer morphism between concept families carries a map on concepts and a
Lipschitz constant governing sample-complexity inflation. -/
structure TransferMorphism {α β : Type*}
    (C₁ : ConceptFamily α) (C₂ : ConceptFamily β) where
  /-- The underlying map on concepts. -/
  map : Set α → Set β
  /-- The Lipschitz constant of the transfer. -/
  lipschitzConst : ℝ

/-! ## Sieves on a preorder -/

/-- A sieve on `d` in a preorder `α`: a downward-closed set of elements below `d`. -/
structure SieveOn (α : Type*) [Preorder α] (d : α) where
  /-- The underlying set of the sieve. -/
  carrier : Set α
  /-- Sieves are downward closed. -/
  downward_closed : ∀ x y, x ∈ carrier → y ≤ x → y ∈ carrier
  /-- Every element of the sieve lies below the target `d`. -/
  below_target : ∀ x, x ∈ carrier → x ≤ d

namespace SieveOn

variable {α : Type*} [Preorder α] {d : α}

instance : PartialOrder (SieveOn α d) where
  le s t := s.carrier ⊆ t.carrier
  le_refl s := le_refl s.carrier
  le_trans _ _ _ h1 h2 := Set.Subset.trans h1 h2
  le_antisymm s t h1 h2 := by
    cases s; cases t; congr 1; exact Set.Subset.antisymm h1 h2

/-- The empty sieve. -/
def empty (d : α) : SieveOn α d where
  carrier := ∅
  downward_closed := fun _ _ h _ => absurd h (by simp)
  below_target := fun _ h => absurd h (by simp)

/-- The maximal sieve on `d`: everything below `d`. -/
def maximal (d : α) : SieveOn α d where
  carrier := {x | x ≤ d}
  downward_closed := fun _ _ hx hyx => le_trans hyx hx
  below_target := fun _ hx => hx

theorem empty_le (d : α) (s : SieveOn α d) : empty d ≤ s :=
  Set.empty_subset _

theorem le_maximal (d : α) (s : SieveOn α d) : s ≤ maximal d :=
  fun x hx => s.below_target x hx

end SieveOn

end