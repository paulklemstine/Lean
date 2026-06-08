import Mathlib

/-!
# Transfinite Proof Dynamics: Ordinal-Valued Energy Framework

## Overview

This file extends the `ProofRefinementSystem` framework from ℕ-valued to
**ordinal-valued** energy functions. This captures proof systems with
transfinite normalization chains — e.g., cut-elimination for higher-order
logic, where normalization length can exceed any primitive recursive bound.

The key insight is that ordinals `Ordinal` are well-ordered, so the strict
descent condition `energy q < energy p` still guarantees termination, but
now normalization can traverse transfinite chains indexed by ordinals up to
ε₀ and beyond.

## Mathematical Content

- `OrdinalPRS`: Proof refinement system with `energy : α → Ordinal`
- `FinitaryPRS`: ℕ-valued PRS (wrapping the original `ProofRefinementSystem`)
- `EnergySpectrum`: The downward-closed set of ordinal energies reachable from a state
- `OrdinalRank`: Classification of PRS by their ordinal energy bound
- Embedding theorem: every finitary PRS embeds into an ordinal PRS
- Product construction: combining two PRS via ordinal arithmetic

## Catalog References

Extends `Pythagorean/ProofDynamics/Defs.lean` and `Pythagorean/ProofDynamics/Theorems.lean`.
-/

universe u v w

/-! ## Core Structure: Ordinal Proof Refinement System -/

/-- An **Ordinal Proof Refinement System** generalizes `ProofRefinementSystem` to
    ordinal-valued energy functions. This enables analysis of proof systems with
    transfinite normalization chains.

    The axioms are identical to `ProofRefinementSystem` except `energy` maps into
    `Ordinal` instead of `ℕ`. Well-foundedness of `<` on `Ordinal` ensures termination. -/
structure OrdinalPRS (α : Type u) (σ : Type v) where
  /-- One-step reduction relation -/
  step : α → α → Prop
  /-- Semantic extraction map -/
  sem : α → σ
  /-- Ordinal-valued energy function -/
  energy : α → Ordinal
  /-- Semantic invariance: reduction preserves meaning -/
  sem_invariant : ∀ {p q}, step p q → sem p = sem q
  /-- Strict ordinal descent: reduction strictly decreases energy -/
  energy_strict : ∀ {p q}, step p q → energy q < energy p

/-- Normal form for an ordinal PRS: no further reduction applies. -/
def OPRS_NormalForm {α : Type u} {σ : Type v} (S : OrdinalPRS α σ) (p : α) : Prop :=
  ¬∃ q, S.step p q

/-! ## Energy Spectrum -/

/-- The **energy spectrum** of a state `p` is the set of ordinal energy values
    achievable by states reachable from `p` via the reflexive-transitive closure
    of the step relation. This captures the "landscape" of possible normalizations. -/
def energySpectrum {α : Type u} {σ : Type v}
    (S : OrdinalPRS α σ) (p : α) : Set Ordinal :=
  { o | ∃ q, Relation.ReflTransGen S.step p q ∧ S.energy q = o }

/-! ## Ordinal Rank Classification -/

/-- The **ordinal rank** of a PRS is the supremum of the energies of all states.
    This classifies the proof system by its ordinal complexity.
    A PRS with rank ω corresponds to finitary systems; rank ε₀ corresponds
    to first-order arithmetic cut-elimination. -/
noncomputable def ordinalRank {α : Type u} {σ : Type v}
    (S : OrdinalPRS α σ) : Ordinal :=
  ⨆ (p : α), S.energy p

/-! ## Stratified Proof Refinement System -/

/-- A **Stratified PRS** is an ordinal PRS equipped with a stratification:
    a decomposition of the state space into ordinal-indexed levels, where
    each level is closed under reduction and the level index decreases
    along reduction chains.

    This captures the structure of ordinal analysis, where proof-theoretic
    ordinals arise from stratifying a proof system by formula complexity. -/
structure StratifiedPRS (α : Type u) (σ : Type v) extends OrdinalPRS α σ where
  /-- Level assignment: each state belongs to an ordinal-indexed stratum -/
  level : α → Ordinal
  /-- The level is bounded by the energy -/
  level_le_energy : ∀ p, level p ≤ energy p
  /-- Reduction does not increase the level -/
  level_nonincreasing : ∀ {p q}, step p q → level q ≤ level p

/-! ## Product Construction -/

/-- The **product** of two ordinal PRS systems, using ordinal addition for energy.
    If `S₁` operates on proofs of type `α₁` and `S₂` on `α₂`, the product
    operates on pairs `(α₁ × α₂)` with combined energy.

    The step relation allows stepping in either component (interleaving).
    This models concurrent proof simplification of independent subproofs. -/
noncomputable def OrdinalPRS.prod {α₁ : Type u} {α₂ : Type v}
    {σ₁ : Type w} {σ₂ : Type*}
    (S₁ : OrdinalPRS α₁ σ₁) (S₂ : OrdinalPRS α₂ σ₂) :
    OrdinalPRS (α₁ × α₂) (σ₁ × σ₂) where
  step := fun p q =>
    (S₁.step p.1 q.1 ∧ p.2 = q.2) ∨ (p.1 = q.1 ∧ S₂.step p.2 q.2)
  sem := fun p => (S₁.sem p.1, S₂.sem p.2)
  energy := fun p => (S₁.energy p.1).nadd (S₂.energy p.2)
  sem_invariant := by
    intro ⟨a1, a2⟩ ⟨b1, b2⟩ h
    rcases h with ⟨h1, rfl⟩ | ⟨rfl, h2⟩
    · exact Prod.ext (S₁.sem_invariant h1) rfl
    · exact Prod.ext rfl (S₂.sem_invariant h2)
  energy_strict := by
    intro ⟨a1, a2⟩ ⟨b1, b2⟩ h
    rcases h with ⟨h1, rfl⟩ | ⟨rfl, h2⟩
    · exact Ordinal.nadd_lt_nadd_right (S₁.energy_strict h1) _
    · exact Ordinal.nadd_lt_nadd_left (S₂.energy_strict h2) _

/-! ## Embedding of Finitary into Ordinal PRS -/

/-- Embed a natural number into an ordinal. -/
noncomputable def natToOrdinal (n : ℕ) : Ordinal := (n : Ordinal)

/-- Lift a finitary PRS (ℕ-valued energy) into an ordinal PRS.
    This is a faithful embedding: the step relation and semantics are identical,
    and the energy is lifted via the canonical embedding ℕ ↪ Ordinal. -/
noncomputable def liftToOrdinalPRS {α : Type u} {σ : Type v}
    (step : α → α → Prop)
    (sem : α → σ)
    (energy : α → ℕ)
    (sem_inv : ∀ {p q}, step p q → sem p = sem q)
    (energy_str : ∀ {p q}, step p q → energy q < energy p) :
    OrdinalPRS α σ where
  step := step
  sem := sem
  energy := fun p => (energy p : Ordinal)
  sem_invariant := sem_inv
  energy_strict := by
    intro p q h
    exact Nat.cast_lt.mpr (energy_str h)

/-! ## Step Chains -/

/-- A step chain of length `n` witnessing `n` reduction steps from `p` to `q`. -/
inductive OStepChain {α : Type u} (r : α → α → Prop) : α → α → ℕ → Prop where
  | refl (p : α) : OStepChain r p p 0
  | cons {p m q : α} {n : ℕ} : r p m → OStepChain r m q n → OStepChain r p q (n + 1)

/-! ## Convergent System Definition -/

/-- A **convergent** ordinal PRS is one that is both terminating (well-founded)
    and confluent. In such a system, every state has a unique normal form. -/
structure ConvergentOPRS (α : Type u) (σ : Type v) extends OrdinalPRS α σ where
  /-- Local confluence of the step relation -/
  locally_confluent : ∀ a b c, step a b → step a c →
    ∃ d, Relation.ReflTransGen step b d ∧ Relation.ReflTransGen step c d