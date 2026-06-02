/-
# Proof Refinement Systems: Definitions

A mathematical framework for studying how proofs improve over time.
A proof refinement system consists of:
- A type of "proofs" (abstract objects)
- A complexity measure (valued in a well-ordered type)
- A refinement relation: p refines q means p is a simpler proof of the same theorem

The key insight is that refinement is well-founded whenever the complexity measure
takes values in a well-ordered set, which yields existence of minimal proofs
and convergence of optimizers as consequences.
-/

import Mathlib

open scoped Classical

universe u v

/-- A `ProofRefinementSystem` captures the abstract structure of proof optimization.
    `Proof` is the type of proofs, `complexity` measures proof complexity in ℕ,
    and `refines` is a relation where `refines p q` means "p is a refinement of q"
    (p is simpler than q). The axiom `complexity_decreasing` ensures that refinement
    strictly decreases complexity. -/
structure ProofRefinementSystem where
  /-- The type of proofs -/
  Proof : Type u
  /-- Complexity measure on proofs -/
  complexity : Proof → ℕ
  /-- Refinement relation: `refines p q` means p is a simplification of q -/
  refines : Proof → Proof → Prop
  /-- Refinement strictly decreases complexity -/
  complexity_decreasing : ∀ p q, refines p q → complexity p < complexity q

/-- A proof is minimal in a refinement system if no further refinement is possible. -/
def ProofRefinementSystem.IsMinimal (S : ProofRefinementSystem) (p : S.Proof) : Prop :=
  ∀ q, ¬S.refines q p

/-- A proof optimizer is a function that maps proofs to proofs of lower or equal complexity.
    The key property is that the optimizer never increases complexity. -/
structure ProofOptimizer (S : ProofRefinementSystem) where
  /-- The optimization function -/
  optimize : S.Proof → S.Proof
  /-- Optimization never increases complexity -/
  complexity_nonincreasing : ∀ p, S.complexity (optimize p) ≤ S.complexity p

/-- A strict optimizer always strictly decreases complexity on non-minimal proofs. -/
structure StrictProofOptimizer (S : ProofRefinementSystem) extends ProofOptimizer S where
  /-- On non-minimal proofs, optimization strictly decreases complexity -/
  strict_on_nonminimal : ∀ p, ¬S.IsMinimal p →
    S.complexity (optimize p) < S.complexity p

/-- An optimizer's orbit: the sequence p, f(p), f²(p), ... -/
def ProofOptimizer.orbit (O : ProofOptimizer S) (p : S.Proof) : ℕ → S.Proof
  | 0 => p
  | n + 1 => O.optimize (O.orbit p n)

/-- The complexity sequence along an orbit -/
def ProofOptimizer.complexitySeq (O : ProofOptimizer S) (p : S.Proof) (n : ℕ) : ℕ :=
  S.complexity (O.orbit p n)

/-- A refinement chain is a finite sequence where each element refines the next. -/
structure RefinementChain (S : ProofRefinementSystem) where
  /-- Length of the chain -/
  length : ℕ
  /-- The chain as a function from Fin (length + 1) to proofs -/
  chain : Fin (length + 1) → S.Proof
  /-- Each element refines the next -/
  chain_refines : ∀ i : Fin length,
    S.refines (chain ⟨i.val + 1, by omega⟩) (chain ⟨i.val, by omega⟩)

/-- A generalized proof refinement system with ordinal-valued complexity.
    This extends the natural number case to allow transfinite complexity measures. -/
structure OrdinalProofRefinementSystem where
  /-- The type of proofs -/
  Proof : Type u
  /-- Complexity measure valued in ordinals -/
  complexity : Proof → Ordinal.{0}
  /-- Refinement relation -/
  refines : Proof → Proof → Prop
  /-- Refinement strictly decreases ordinal complexity -/
  complexity_decreasing : ∀ p q, refines p q → complexity p < complexity q

/-- Convert a ℕ-valued system to an ordinal-valued one by embedding ℕ ↪ Ordinal. -/
def ProofRefinementSystem.toOrdinal (S : ProofRefinementSystem) :
    OrdinalProofRefinementSystem where
  Proof := S.Proof
  complexity := fun p => (S.complexity p : Ordinal)
  refines := S.refines
  complexity_decreasing := fun p q h => by
    exact Nat.cast_lt.mpr (S.complexity_decreasing p q h)

/-- A proof optimizer for ordinal-valued systems. -/
structure OrdinalProofOptimizer (S : OrdinalProofRefinementSystem) where
  optimize : S.Proof → S.Proof
  complexity_nonincreasing : ∀ p, S.complexity (optimize p) ≤ S.complexity p

/-- A proof is minimal in an ordinal system. -/
def OrdinalProofRefinementSystem.IsMinimal
    (S : OrdinalProofRefinementSystem) (p : S.Proof) : Prop :=
  ∀ q, ¬S.refines q p

/-- The complexity gap of a refinement step: how much complexity decreases. -/
noncomputable def ProofRefinementSystem.complexityGap
    (S : ProofRefinementSystem) (p q : S.Proof) (_h : S.refines p q) : ℕ :=
  S.complexity q - S.complexity p

/-- A refinement system has bounded gap if there's a minimum gap size. -/
def ProofRefinementSystem.HasMinGap (S : ProofRefinementSystem) (g : ℕ) : Prop :=
  g ≥ 1 ∧ ∀ p q, S.refines p q → S.complexity q - S.complexity p ≥ g