import Mathlib

/-!
# Proof Dynamics: Abstract Rewriting-Theoretic Framework

## Overview

This file establishes the foundational definitions for treating proof simplification
as a **rewriting-theoretic dynamical system**. The central abstraction is
`ProofRefinementSystem`, which packages:

- A **step relation** (abstract rewrite rule),
- A **semantic map** (meaning extraction, invariant under rewriting),
- An **energy function** (discrete Lyapunov / ranking function into ℕ).

The axioms enforce that every step preserves semantics and strictly decreases energy.
This makes every `ProofRefinementSystem` a **semantics-preserving terminating abstract
rewrite system** with a built-in complexity measure.

## Convention

We use the convention where `step p q` means **"p reduces to q in one step"**
(forward reduction direction). Thus `energy q < energy p`: the target has
strictly less energy than the source. The well-founded order is on the
*inverse* of `step` — i.e., `WellFounded (fun q p => S.step p q)` — because
reduction chains go "downward" in energy.

## Cross-Domain Connections

- **Rewriting theory:** `ProofRefinementSystem` is a terminating ARS with semantic invariance.
- **Dynamical systems:** `energy` is a strict discrete Lyapunov function; normal forms are attractors.
- **Information theory:** The gap `energy p - energy (nf p)` measures compressible redundancy.
- **Order theory:** `energy_strict` induces well-foundedness via pullback from `(ℕ, <)`.

## Catalog References

Builds on the proof dynamics framework in `Catalog/MachineLearning/ProofDynamics/Defs.lean`
and `Catalog/MachineLearning/ProofDynamics/Theorems.lean`, abstracting their concrete
`ProofSketch`/`RefinementStep` machinery into a general algebraic framework.
-/

universe u v

/-! ## Core Structure: Proof Refinement System -/

/-- A **Proof Refinement System** packages a step relation on proof objects
    together with a semantic map and an energy (Lyapunov) function.

    Convention: `step p q` means "p reduces/simplifies to q in one step".

    The axioms enforce two fundamental properties:
    1. **Semantic invariance**: every refinement step preserves the meaning of a proof.
    2. **Strict energy descent**: every refinement step strictly decreases a ℕ-valued energy.

    These two properties together make the system a **semantics-preserving terminating
    abstract rewrite system** — the mathematical backbone of certified proof simplification. -/
structure ProofRefinementSystem (α : Type u) (σ : Type v) where
  /-- The one-step reduction relation: `step p q` means "p simplifies to q in one step". -/
  step : α → α → Prop
  /-- Semantic extraction: maps a proof object to its meaning (e.g., the theorem it proves). -/
  sem  : α → σ
  /-- Energy / Lyapunov function: measures the complexity of a proof object. -/
  energy : α → ℕ
  /-- **Semantic invariance axiom**: reduction preserves meaning. -/
  sem_invariant : ∀ {p q}, step p q → sem p = sem q
  /-- **Strict descent axiom**: reduction strictly decreases energy.
      `step p q` (p reduces to q) implies `energy q < energy p`. -/
  energy_strict : ∀ {p q}, step p q → energy q < energy p

/-! ## Normal Forms -/

/-- A proof object `p` is in **normal form** w.r.t. a PRS if no further reduction
    step applies to it. Normal forms are the fixed points / ground states of the
    refinement dynamics. `step p q` means "p reduces to q", so normal form means
    there is no q that p can reduce to. -/
def PRS_NormalForm {α : Type u} {σ : Type v} (S : ProofRefinementSystem α σ) (p : α) : Prop :=
  ¬ ∃ q, S.step p q

/-- Normal form for an abstract relation (no PRS structure needed).
    `NormalFormRel r a` means `a` has no `r`-successors. -/
def NormalFormRel {α : Type u} (r : α → α → Prop) (a : α) : Prop :=
  ¬ ∃ b, r a b

/-! ## Derivations (Finite Reduction Chains) -/

/-- A **StepChain** of length `n` from `p` to `q` under relation `r` is a
    witness that `p` reduces to `q` in exactly `n` steps. This is the
    length-indexed version of the reflexive-transitive closure.

    `StepChain r p q n` means: there is a chain `p = x₀ →ᵣ x₁ →ᵣ ... →ᵣ xₙ = q`. -/
inductive StepChain {α : Type u} (r : α → α → Prop) : α → α → ℕ → Prop where
  /-- Zero-step chain: `p` reduces to itself in 0 steps. -/
  | refl (p : α) : StepChain r p p 0
  /-- Extension: if `r p m` and `StepChain r m q n`, then `StepChain r p q (n+1)`. -/
  | cons {p m q : α} {n : ℕ} : r p m → StepChain r m q n → StepChain r p q (n + 1)

/-! ## Confluence Definitions -/

/-- **Local confluence** (weak Church-Rosser): whenever `a` reduces to both `b` and `c`
    in one step, there exists a common reduct `d` reachable from both `b` and `c`. -/
def LocalConfluent {α : Type u} (r : α → α → Prop) : Prop :=
  ∀ a b c, r a b → r a c → ∃ d, Relation.ReflTransGen r b d ∧ Relation.ReflTransGen r c d

/-- **Confluence** (Church-Rosser): whenever `a` multi-step reduces to both `b` and `c`,
    there exists a common reduct `d`. -/
def Confluent {α : Type u} (r : α → α → Prop) : Prop :=
  ∀ a b c, Relation.ReflTransGen r a b → Relation.ReflTransGen r a c →
    ∃ d, Relation.ReflTransGen r b d ∧ Relation.ReflTransGen r c d

/-- **Unique normal form property**: any two normal forms reachable from the same
    source must be equal. -/
def UniqueNormalFormProp {α : Type u} (r : α → α → Prop) : Prop :=
  ∀ a n₁ n₂, Relation.ReflTransGen r a n₁ → Relation.ReflTransGen r a n₂ →
    NormalFormRel r n₁ → NormalFormRel r n₂ → n₁ = n₂

/-! ## Redundancy Index (Cross-Domain: Information/Compression) -/

/-- The **redundancy index** measures how much energy can be removed by normalization.
    It is defined as `energy(p) - energy(nf(p))`, where `nf` is a normal form operator.

    From the information-theoretic perspective, this quantifies the compressible
    redundancy in a proof: the amount of "wasted complexity" that normalization removes
    while preserving semantic content.

    - `redundancyIndex = 0` iff `p` is already in normal form (incompressible).
    - Large `redundancyIndex` indicates a highly redundant, compressible proof. -/
def redundancyIndex {α : Type u} {σ : Type v}
    (S : ProofRefinementSystem α σ) (nf : α → α) (p : α) : ℕ :=
  S.energy p - S.energy (nf p)