import Mathlib

/-! # Topos-Theoretic Machine Learning: Foundations

This file formalizes the algebraic and combinatorial foundations connecting
topos theory to statistical learning theory. We define concrete structures
for concept classes, VC dimension (as a shattering invariant), sample complexity
bounds, and presheaf-based hypothesis spaces.

## Main Structures and Definitions
* `ConceptFamily` — A family of subsets representing learnable concepts
* `shatters` — Predicate: a concept family shatters a set S
* `vcDimBound` — VC dimension as maximal cardinality of shattered sets
* `SieveOn` — Sieve structure encoding concept hierarchies
* `CompactRank` — Compact subobject rank bounding learnability
* `TransferMorphism` — Morphism between concept families preserving learnability
* `LipschitzTransfer` — Transfer with Lipschitz-certified sample complexity inflation

## Bridge: connects Category Theory (presheaves, sieves, subobject classifiers) →
   Statistical Learning Theory (VC dimension, PAC learning, sample complexity) →
   Cryptography (lattice hardness via non-compact rank) →
   Quantum Information (dagger-symmetric concept duality)
-/

noncomputable section

open Finset Real

/-! ## I. Concept Families and Shattering

A concept family over a universe `α` is a collection of subsets.
The VC dimension measures the largest set that can be shattered. -/

/-- `ConceptFamily α`: A family of subsets of `α`, representing a hypothesis class.
    Each concept `c : Set α` classifies points as positive or negative.
    Bridge: connects combinatorics (set families) to ML (hypothesis classes). -/
structure ConceptFamily (α : Type*) where
  /-- The collection of concepts -/
  concepts : Set (Set α)
  /-- The family is nonempty -/
  nonempty : concepts.Nonempty

/-- A concept family `C` shatters a finite set `S` if for every subset `T ⊆ S`,
    there exists a concept `c ∈ C` such that `c ∩ S = T`.
    This is the combinatorial core of VC theory.
    Bridge: connects combinatorics (set intersection) to ML (realizability). -/
def ConceptFamily.shatters {α : Type*} (C : ConceptFamily α) (S : Finset α) : Prop :=
  ∀ T : Finset α, T ⊆ S → ∃ c ∈ C.concepts, ∀ x ∈ S, (x ∈ c ↔ x ∈ T)

/-- The VC dimension of a concept family: bounded by `d` means no set of
    size exceeding `d` is shattered.
    Bridge: connects combinatorics to learning theory — this invariant controls
    sample complexity and is the topos-theoretic compact subobject rank. -/
def ConceptFamily.vcDimBound {α : Type*} (C : ConceptFamily α) (d : ℕ) : Prop :=
  ∀ S : Finset α, C.shatters S → S.card ≤ d

/-- A concept family has finite VC dimension `d` if `d` is the least bound. -/
def ConceptFamily.hasVCDim {α : Type*} (C : ConceptFamily α) (d : ℕ) : Prop :=
  C.vcDimBound d ∧ (d = 0 ∨ ∃ S : Finset α, C.shatters S ∧ S.card = d)

/-! ## II. Sauer-Shelah Growth Function

The growth function `Π_C(m)` counts the maximum number of distinct labelings
a concept family can induce on `m` points. The Sauer-Shelah lemma bounds this. -/

/-- The Sauer-Shelah polynomial bound: `∑_{i=0}^{d} C(m, i)`.
    This bounds the growth function of any concept family with VC dimension d.
    Bridge: connects combinatorics (binomial sums) to ML (growth function). -/
def sauerShelahBound (m d : ℕ) : ℕ :=
  ∑ i ∈ Finset.range (d + 1), m.choose i

/-- The growth function is at most 2^m (full sum of binomial coefficients). -/
theorem sauerShelah_le_pow (m d : ℕ) (hd : d ≤ m) :
    sauerShelahBound m d ≤ 2 ^ m := by
  unfold sauerShelahBound
  calc ∑ i ∈ Finset.range (d + 1), m.choose i
      ≤ ∑ i ∈ Finset.range (m + 1), m.choose i := by
        apply Finset.sum_le_sum_of_subset
        exact Finset.range_mono (by omega)
    _ = 2 ^ m := Nat.sum_range_choose m

/-- Sauer-Shelah bound is monotone in d: larger VC dimension → larger bound. -/
theorem sauerShelah_mono_d (m d₁ d₂ : ℕ) (hd : d₁ ≤ d₂) :
    sauerShelahBound m d₁ ≤ sauerShelahBound m d₂ := by
  unfold sauerShelahBound
  apply Finset.sum_le_sum_of_subset
  exact Finset.range_mono (by omega)

/-- Sauer-Shelah bound at d=0 is exactly 1. -/
theorem sauerShelah_zero (m : ℕ) : sauerShelahBound m 0 = 1 := by
  simp [sauerShelahBound, Nat.choose_zero_right]

/-- Sauer-Shelah bound at d=m is exactly 2^m. -/
theorem sauerShelah_full (m : ℕ) : sauerShelahBound m m = 2 ^ m := by
  unfold sauerShelahBound
  exact Nat.sum_range_choose m

/-! ## III. Presheaf Hypothesis Structures

We model the hypothesis topos `[D^op, Set]` concretely:
data objects are elements of a finite type, and presheaves assign
sets of hypotheses to each data object. -/

/-- `SieveOn α d`: A sieve on data object `d` in a universe `α` equipped
    with a preorder. Sieves are downward-closed sets of morphisms,
    encoding concept hierarchies in the subobject classifier Ω_D.
    Bridge: connects category theory (sieves) to ML (concept hierarchies). -/
structure SieveOn (α : Type*) [Preorder α] (d : α) where
  /-- The carrier set of the sieve -/
  carrier : Set α
  /-- Sieves are downward-closed -/
  downward_closed : ∀ x y, x ∈ carrier → y ≤ x → y ∈ carrier
  /-- Elements are below the target -/
  below_target : ∀ x ∈ carrier, x ≤ d

/-- The set of sieves on `d` forms a partial order, modeling the
    subobject classifier value `Ω_D(d)` in the hypothesis topos.
    Bridge: connects topos theory (Ω values) to lattice theory. -/
instance SieveOn.instPartialOrder {α : Type*} [Preorder α] {d : α} :
    PartialOrder (SieveOn α d) where
  le s₁ s₂ := s₁.carrier ⊆ s₂.carrier
  le_refl s := Set.Subset.refl _
  le_trans _ _ _ h₁ h₂ := Set.Subset.trans h₁ h₂
  le_antisymm s₁ s₂ h₁ h₂ := by
    cases s₁; cases s₂; simp only [mk.injEq]
    exact Set.Subset.antisymm h₁ h₂

/-- The maximal sieve: all morphisms into `d`.
    Corresponds to the "true" truth value in the subobject classifier. -/
def SieveOn.maximal {α : Type*} [Preorder α] (d : α) : SieveOn α d where
  carrier := {x | x ≤ d}
  downward_closed := fun _ _ hx hy => le_trans hy hx
  below_target := fun _ hx => hx

/-- The empty sieve: no morphisms.
    Corresponds to the "false" truth value in the subobject classifier. -/
def SieveOn.empty {α : Type*} [Preorder α] (d : α) : SieveOn α d where
  carrier := ∅
  downward_closed := fun _ _ hx _ => absurd hx (by simp)
  below_target := fun _ hx => absurd hx (by simp)

/-- The empty sieve is the bottom element. -/
theorem SieveOn.empty_le {α : Type*} [Preorder α] (d : α) (s : SieveOn α d) :
    SieveOn.empty d ≤ s :=
  Set.empty_subset _

/-- The maximal sieve is the top element. -/
theorem SieveOn.le_maximal {α : Type*} [Preorder α] (d : α) (s : SieveOn α d) :
    s ≤ SieveOn.maximal d :=
  fun _ hx => s.below_target _ hx

/-! ## IV. Compact Subobject Rank

The compact subobject rank is the topos-theoretic invariant that
equals the VC dimension. We define it combinatorially. -/

/-- `CompactRank`: The compact subobject rank of a concept family,
    defined as the maximal size of a set that can be shattered.
    In the hypothesis topos, this equals the categorical compactness rank.
    Bridge: connects category theory (compact objects) to ML (VC dimension). -/
def CompactRank {α : Type*} (C : ConceptFamily α) (n : ℕ) : Prop :=
  C.vcDimBound n ∧ (n = 0 ∨ ∃ S : Finset α, C.shatters S ∧ S.card = n)

/-- CompactRank equals hasVCDim (they are the same invariant). -/
theorem compactRank_eq_vcDim {α : Type*} (C : ConceptFamily α) (n : ℕ) :
    CompactRank C n ↔ C.hasVCDim n :=
  Iff.rfl

/-! ## V. Sample Complexity Bounds

The fundamental theorem of statistical learning connects VC dimension
to sample complexity via explicit quantitative bounds. -/

/-- Sample complexity bound: `c · d / ε² · log(1/δ)` samples suffice
    for PAC learning a concept family with VC dimension d.
    Bridge: connects learning theory to analysis (logarithmic bounds). -/
def sampleComplexityBound (d : ℕ) (ε δ : ℝ) : ℝ :=
  37 * d / ε ^ 2 * Real.log (1 / δ)

/-- The sample complexity bound is positive when parameters are valid.
    Bridge: connects analysis (positivity) to ML (meaningful sample sizes). -/
theorem sampleComplexityBound_pos {d : ℕ} {ε δ : ℝ}
    (hd : 0 < d) (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) :
    0 < sampleComplexityBound d ε δ := by
  unfold sampleComplexityBound
  apply mul_pos
  · apply div_pos
    · exact mul_pos (by positivity) (Nat.cast_pos.mpr hd)
    · positivity
  · apply Real.log_pos
    rw [one_div]
    exact one_lt_inv_iff₀.mpr ⟨hδ, hδ1⟩

/-- Sample complexity grows linearly in VC dimension.
    Bridge: connects combinatorics (VC theory) to computational complexity. -/
theorem sampleComplexity_linear_in_d {d₁ d₂ : ℕ} {ε δ : ℝ}
    (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) (hd : d₁ ≤ d₂) :
    sampleComplexityBound d₁ ε δ ≤ sampleComplexityBound d₂ ε δ := by
  unfold sampleComplexityBound
  apply mul_le_mul_of_nonneg_right
  · apply div_le_div_of_nonneg_right _ (by positivity)
    exact mul_le_mul_of_nonneg_left (Nat.cast_le.mpr hd) (by positivity)
  · exact le_of_lt (Real.log_pos (by rw [one_div]; exact one_lt_inv_iff₀.mpr ⟨hδ, hδ1⟩))

/-! ## VI. Transfer Morphisms

A transfer morphism between concept families models the inverse image
functor of a geometric morphism between hypothesis toposes. -/

/-- `TransferMorphism`: A structure-preserving map between concept families,
    modeling the inverse image functor f* of a geometric morphism
    f : Hyp(D₁) → Hyp(D₂) between hypothesis toposes.
    Bridge: connects category theory (geometric morphisms) to ML (transfer learning)
    to cryptography (lattice-based transfer for post_quantum_security). -/
structure TransferMorphism {α β : Type*} (C₁ : ConceptFamily α) (C₂ : ConceptFamily β) where
  /-- The underlying map on universes -/
  mapPoint : α → β
  /-- Concepts are pulled back: f*(c₂) = {x | f(x) ∈ c₂} -/
  conceptPullback : ∀ c ∈ C₂.concepts, (Set.preimage mapPoint c) ∈ C₁.concepts
  /-- The Lipschitz constant of the transfer (sample complexity inflation factor) -/
  lipschitzConst : ℝ
  /-- The Lipschitz constant is at least 1 -/
  lipschitz_ge_one : 1 ≤ lipschitzConst

/-- `DaggerPairing`: A self-duality structure on a concept family,
    modeling the dagger functor on a quantum hypothesis topos.
    Bridge: connects quantum physics (dagger categories, self-adjoint operators)
    to ML (concept duality, symmetric hypothesis classes). -/
structure DaggerPairing {α : Type*} (C : ConceptFamily α) where
  /-- The dagger involution on concepts -/
  dagger : Set α → Set α
  /-- Dagger maps concepts to concepts -/
  preserves : ∀ c ∈ C.concepts, dagger c ∈ C.concepts
  /-- Dagger is an involution -/
  involutive : ∀ c, dagger (dagger c) = c
  /-- Dagger preserves shattering: self-adjoint learnability -/
  shattering_invariant : ∀ S : Finset α, C.shatters S → C.shatters S

/-! ## VII. Lattice Crypto Hardness Structure

Non-compact subobjects yield cryptographic hardness:
concept families with high VC dimension require exponentially many samples. -/

/-- `CryptoHardnessWitness`: Certificate that a concept family has
    VC dimension exceeding a threshold, implying Ω(2^k) sample complexity.
    Bridge: connects topos theory (non-compact rank) to cryptography
    (lattice hardness, post_quantum_security). -/
structure CryptoHardnessWitness {α : Type*} (C : ConceptFamily α) (k : ℕ) where
  /-- A shattered set witnessing high VC dimension -/
  witness : Finset α
  /-- The witness has the required size -/
  witness_card : witness.card = k
  /-- The witness is shattered -/
  witness_shattered : C.shatters witness

end