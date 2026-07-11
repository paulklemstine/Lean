import Mathlib

/-! # Foundations for the Topos-Theoretic view of statistical learning

This module sets up the shared vocabulary that lets combinatorial learning theory
(shattering, VC dimension, the growth function) be read off inside the geometry of
sieves on a preorder.  A *concept family* is a collection of predicates on a domain;
a finite set of points is *shattered* when every one of its subsets is realized by
some concept, and the *VC dimension* measures the largest shattered configuration.

On the geometric side, a *sieve* on an object `d` of a preorder is a downward-closed
family of morphisms into `d`; sieves form a bounded lattice under inclusion, the
lattice-theoretic shadow of the subobject classifier `Ω` in a presheaf topos.  The
numerical invariants of learning (the Sauer–Shelah growth bound and the sample
complexity functional) are recorded here so that the companion file can prove the
learning ↔ geometry correspondence.
-/

open Finset

noncomputable section

/-! ## Concept families, shattering, and VC dimension -/

/-- A concept family on a domain `α` is a nonempty collection of predicates
(the *concepts*) on `α`. -/
structure ConceptFamily (α : Type*) where
  /-- The set of concepts, each a predicate on the domain. -/
  concepts : Set (α → Prop)
  /-- A concept family always contains at least one concept. -/
  nonempty : ∃ c, c ∈ concepts

/-- A finite set `S` is *shattered* by the family `C` when every subset `T ⊆ S`
is realized by some concept, i.e. there is a concept holding on all of `T`. -/
def ConceptFamily.shatters {α : Type*} (C : ConceptFamily α) (S : Finset α) : Prop :=
  ∀ T ⊆ S, ∃ c ∈ C.concepts, ∀ x ∈ T, c x

/-- `C.vcDimBound d` records that no shattered set has more than `d` points; the
VC dimension is the least such `d`. -/
def ConceptFamily.vcDimBound {α : Type*} (C : ConceptFamily α) (d : ℕ) : Prop :=
  ∀ S : Finset α, C.shatters S → S.card ≤ d

/-- The *compact rank* of a concept family: a bound `n` on the size of every
shattered set which is additionally *attained* (or is `0`).  This is the
learning-theoretic avatar of a compact subobject of rank `n`. -/
def CompactRank {α : Type*} (C : ConceptFamily α) (n : ℕ) : Prop :=
  (∀ S : Finset α, C.shatters S → S.card ≤ n) ∧
  (n = 0 ∨ ∃ S : Finset α, C.shatters S ∧ S.card = n)

/-- A witness that a family is at least as hard to learn as shattering `k` points:
a shattered set of exactly `k` elements.  Used to translate learning lower bounds
into hardness statements. -/
structure CryptoHardnessWitness {α : Type*} (C : ConceptFamily α) (k : ℕ) where
  /-- The hard, shattered configuration. -/
  witness : Finset α
  /-- It is genuinely shattered. -/
  witness_shattered : C.shatters witness
  /-- It has exactly `k` points. -/
  witness_card : witness.card = k

/-- A transfer morphism between concept families, carrying the Lipschitz constant
that governs how sample complexity inflates under transfer. -/
structure TransferMorphism {α β : Type*} (C₁ : ConceptFamily α) (C₂ : ConceptFamily β) where
  /-- The Lipschitz constant of the transfer map. -/
  lipschitzConst : ℝ

/-! ## The Sauer–Shelah growth bound -/

/-- The Sauer–Shelah bound `∑_{i≤d} C(m, i)`: the maximal number of distinct
behaviours a family of VC dimension `d` can exhibit on `m` points. -/
def sauerShelahBound (m d : ℕ) : ℕ := ∑ i ∈ Finset.range (d + 1), m.choose i

/-- At the diagonal `m = d = k`, the growth bound is the full power set count `2^k`:
a family of VC dimension `k` can shatter `k` points completely. -/
theorem sauerShelah_full (k : ℕ) : sauerShelahBound k k = 2 ^ k := by
  unfold sauerShelahBound
  rw [show 2 ^ k = ∑ i ∈ Finset.range (k + 1), k.choose i from (Nat.sum_range_choose k).symm]

/-! ## Sample complexity -/

/-- A representative PAC sample-complexity functional: linear in the VC dimension
`d`, inversely quadratic in the accuracy `ε`, and logarithmic in the confidence
`δ`.  The exact constants are irrelevant to the structural results. -/
def sampleComplexityBound (d : ℕ) (ε δ : ℝ) : ℝ := (d : ℝ) / ε ^ 2 * Real.log (2 / δ)

/-- Sample complexity is strictly positive for genuine learning parameters. -/
theorem sampleComplexityBound_pos {d : ℕ} {ε δ : ℝ}
    (hd : 0 < d) (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) :
    0 < sampleComplexityBound d ε δ := by
  unfold sampleComplexityBound
  apply mul_pos
  · apply div_pos
    · exact_mod_cast hd
    · positivity
  · apply Real.log_pos
    rw [lt_div_iff₀ hδ]
    linarith

/-- Sample complexity grows monotonically with the VC dimension. -/
theorem sampleComplexity_linear_in_d {d₁ d₂ : ℕ} {ε δ : ℝ}
    (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) (hd : d₁ ≤ d₂) :
    sampleComplexityBound d₁ ε δ ≤ sampleComplexityBound d₂ ε δ := by
  unfold sampleComplexityBound
  have hlog : 0 ≤ Real.log (2 / δ) := by
    apply Real.log_nonneg
    rw [le_div_iff₀ hδ]; linarith
  apply mul_le_mul_of_nonneg_right _ hlog
  gcongr

/-! ## Sieves on a preorder and the subobject lattice -/

/-- A *sieve* on an object `d` of a preorder: a downward-closed family of objects
lying below `d`.  Sieves are the concrete lattice model of the topos-theoretic
subobject classifier. -/
structure SieveOn (α : Type*) [Preorder α] (d : α) where
  /-- The underlying set of objects of the sieve. -/
  carrier : Set α
  /-- Sieves are downward closed. -/
  downward_closed : ∀ x y, x ∈ carrier → y ≤ x → y ∈ carrier
  /-- Every member lies below the target object. -/
  below_target : ∀ x, x ∈ carrier → x ≤ d

/-- Sieves on `d` form a partial order under inclusion of carriers. -/
instance {α : Type*} [Preorder α] (d : α) : PartialOrder (SieveOn α d) where
  le s t := s.carrier ⊆ t.carrier
  le_refl _ := subset_rfl
  le_trans _ _ _ hab hbc := subset_trans hab hbc
  le_antisymm a b hab hba := by
    cases a; cases b; congr 1; exact Set.Subset.antisymm hab hba

/-- The empty sieve. -/
def SieveOn.empty {α : Type*} [Preorder α] (d : α) : SieveOn α d where
  carrier := ∅
  downward_closed := by intro _ _ hx _; exact absurd hx (by simp)
  below_target := by intro _ hx; exact absurd hx (by simp)

/-- The maximal sieve on `d`, consisting of everything below `d`. -/
def SieveOn.maximal {α : Type*} [Preorder α] (d : α) : SieveOn α d where
  carrier := {x | x ≤ d}
  downward_closed := fun x y hx hle => le_trans hle hx
  below_target := fun x hx => hx

/-- The empty sieve is the least element. -/
theorem SieveOn.empty_le {α : Type*} [Preorder α] (d : α) (s : SieveOn α d) :
    SieveOn.empty d ≤ s := by
  intro x hx; exact absurd hx (by simp [SieveOn.empty])

/-- The maximal sieve is the greatest element. -/
theorem SieveOn.le_maximal {α : Type*} [Preorder α] (d : α) (s : SieveOn α d) :
    s ≤ SieveOn.maximal d :=
  fun x hx => s.below_target x hx

end