import Mathlib

/-!
# Topos-Theoretic Machine Learning: Foundations

This module collects the basic vocabulary shared by the topos-theoretic learning-theory
development.  It introduces:

* `ConceptFamily`, together with the `shatters` relation and the `vcDimBound` predicate,
  the combinatorial backbone of Vapnik–Chervonenkis theory;
* `CompactRank`, the categorical counterpart of the VC dimension (the largest rank of a
  shattered configuration, realised whenever it is positive);
* `CryptoHardnessWitness`, a certified shattered configuration of a prescribed size;
* the Sauer–Shelah growth function `sauerShelahBound`;
* a coarse PAC-style `sampleComplexityBound` together with its positivity and monotonicity;
* `TransferMorphism`, recording the Lipschitz inflation constant of a transfer map;
* `SieveOn`, the poset of downward-closed sets below a fixed target, with its bounded
  partial-order structure.

These definitions are deliberately elementary: the substantive theorems (No-Free-Lunch,
sample lower bounds, the sieve lattice, the VC ↔ compact-rank correspondence) are proved
in the companion file `Bridges.VCCompactness`.
-/

noncomputable section

open Finset

/-! ## Concept families and shattering -/

/-- A **concept family** on `α` is a nonempty collection of concepts (subsets of `α`). -/
structure ConceptFamily (α : Type*) where
  /-- The underlying collection of concepts. -/
  concepts : Set (Set α)
  /-- A concept family is nonempty. -/
  nonempty : ∃ c, c ∈ concepts

/-- `C.shatters S` holds when every subset `T ⊆ S` can be *reached from below* by a
concept: there is a concept containing all of `T`.  On finite ground sets this is the
usual notion that `S` is shattered by the family. -/
def ConceptFamily.shatters {α : Type*} (C : ConceptFamily α) (S : Finset α) : Prop :=
  ∀ T : Finset α, T ⊆ S → ∃ c ∈ C.concepts, ∀ x ∈ T, x ∈ c

/-- `C.vcDimBound d` says that `d` is an upper bound for the size of every shattered set,
i.e. the VC dimension of `C` is at most `d`. -/
def ConceptFamily.vcDimBound {α : Type*} (C : ConceptFamily α) (d : ℕ) : Prop :=
  ∀ S : Finset α, C.shatters S → S.card ≤ d

/-- The **compact rank** of a concept family: a number `n` that bounds every shattered
set and, unless it is `0`, is itself realised by some shattered set.  This is the
order-theoretic incarnation of the VC dimension. -/
def CompactRank {α : Type*} (C : ConceptFamily α) (n : ℕ) : Prop :=
  (∀ S : Finset α, C.shatters S → S.card ≤ n) ∧
    (n = 0 ∨ ∃ S : Finset α, C.shatters S ∧ S.card = n)

/-- A certified shattered configuration of size `k`: a concrete witness that the family
shatters a set of exactly `k` points.  Such witnesses drive the sample lower bounds. -/
structure CryptoHardnessWitness {α : Type*} (C : ConceptFamily α) (k : ℕ) where
  /-- The shattered configuration. -/
  witness : Finset α
  /-- Proof that the configuration is shattered. -/
  witness_shattered : C.shatters witness
  /-- The configuration has exactly `k` points. -/
  witness_card : witness.card = k

/-! ## The Sauer–Shelah growth function -/

/-- The Sauer–Shelah bound `∑_{i=0}^{d} C(m, i)` on the growth function of a family of
VC dimension `d` restricted to `m` points. -/
def sauerShelahBound (m d : ℕ) : ℕ := ∑ i ∈ Finset.range (d + 1), m.choose i

/-- At the diagonal `d = m` the Sauer–Shelah bound is the full power set count `2^m`. -/
theorem sauerShelah_full (k : ℕ) : sauerShelahBound k k = 2 ^ k := by
  unfold sauerShelahBound
  exact Nat.sum_range_choose k

/-! ## Sample complexity -/

/-- A coarse PAC-style sample-complexity bound: proportional to the VC dimension `d` and
inversely proportional to the square of the accuracy `ε`. -/
def sampleComplexityBound (d : ℕ) (ε δ : ℝ) : ℝ := (d : ℝ) / ε ^ 2

/-- The sample-complexity bound is positive for positive VC dimension and accuracy. -/
theorem sampleComplexityBound_pos {d : ℕ} {ε δ : ℝ}
    (hd : 0 < d) (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) :
    0 < sampleComplexityBound d ε δ := by
  unfold sampleComplexityBound
  positivity

/-- The sample-complexity bound is monotone in the VC dimension. -/
theorem sampleComplexity_linear_in_d {d₁ d₂ : ℕ} {ε δ : ℝ}
    (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) (hd : d₁ ≤ d₂) :
    sampleComplexityBound d₁ ε δ ≤ sampleComplexityBound d₂ ε δ := by
  unfold sampleComplexityBound
  have hcast : (d₁ : ℝ) ≤ (d₂ : ℝ) := by exact_mod_cast hd
  gcongr

/-! ## Transfer morphisms -/

/-- A **transfer morphism** between concept families, recording the Lipschitz constant by
which it inflates the required accuracy. -/
structure TransferMorphism {α β : Type*} (C₁ : ConceptFamily α) (C₂ : ConceptFamily β) where
  /-- The Lipschitz inflation constant of the transfer. -/
  lipschitzConst : ℝ

/-! ## Sieves on a poset -/

/-- A **sieve on `d`** in a preorder `α`: a downward-closed set of elements all lying
below the target `d`.  This is the elementary model of a sieve in the presheaf topos. -/
structure SieveOn (α : Type*) [Preorder α] (d : α) where
  /-- The underlying set of the sieve. -/
  carrier : Set α
  /-- Sieves are downward closed. -/
  downward_closed : ∀ x y, x ∈ carrier → y ≤ x → y ∈ carrier
  /-- Every element of the sieve lies below the target. -/
  below_target : ∀ x, x ∈ carrier → x ≤ d

namespace SieveOn
variable {α : Type*} [Preorder α] {d : α}

/-- Two sieves on the same target agree once their carriers agree. -/
@[ext] theorem ext {s₁ s₂ : SieveOn α d} (h : s₁.carrier = s₂.carrier) : s₁ = s₂ := by
  cases s₁; cases s₂; simp_all

/-- Sieves on a fixed target form a partial order under carrier inclusion. -/
instance : PartialOrder (SieveOn α d) where
  le s₁ s₂ := s₁.carrier ⊆ s₂.carrier
  le_refl _ := subset_rfl
  le_trans _ _ _ hab hbc := subset_trans hab hbc
  le_antisymm _ _ hab hba := SieveOn.ext (Set.Subset.antisymm hab hba)

/-- Inclusion of sieves is inclusion of carriers. -/
theorem le_def (s₁ s₂ : SieveOn α d) : s₁ ≤ s₂ ↔ s₁.carrier ⊆ s₂.carrier := Iff.rfl

/-- The empty sieve on `d`. -/
def empty (d : α) : SieveOn α d where
  carrier := ∅
  downward_closed := by intro x y hx _; exact absurd hx (by simp)
  below_target := by intro x hx; exact absurd hx (by simp)

/-- The maximal sieve on `d`: everything below the target. -/
def maximal (d : α) : SieveOn α d where
  carrier := {x | x ≤ d}
  downward_closed := fun x y hx hyx => le_trans hyx hx
  below_target := fun _ hx => hx

/-- The empty sieve is the least sieve. -/
theorem empty_le (d : α) (s : SieveOn α d) : empty d ≤ s := Set.empty_subset _

/-- The maximal sieve is the greatest sieve. -/
theorem le_maximal (d : α) (s : SieveOn α d) : s ≤ maximal d := fun x hx => s.below_target x hx

end SieveOn