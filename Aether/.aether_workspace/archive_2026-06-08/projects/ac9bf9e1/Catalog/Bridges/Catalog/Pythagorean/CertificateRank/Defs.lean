import Mathlib

/-!
# Certificate Rank Barriers: Core Definitions

This module defines the mathematical framework for studying certificate rank
barriers in coefficient-comparison proof systems for the powerset identity.

## Main Definitions

* `powersetCoeff` — The subset monomial coefficient: `c_f(S) = ∏_{i ∈ S} f(i)`
* `CertificateSystem` — A linearized certificate system for subset coefficient constraints
* `certificateRank` — The rank (dimension of row span) of a certificate system
* `canonicalCertificateSystem` — The canonical system whose rows are subset delta functionals
* `certificateRankBarrierInstance` — Connection to proof compression theory

## Mathematical Context

The powerset identity `∏ (1 + f_i) = ∑_{S ⊆ [n]} ∏_{i∈S} f_i` packages exponentially
many multiplicative dependencies into a compact algebraic object. Any proof system
that verifies this identity by coefficient consistency must represent all 2^n subset
monomial coordinates independently, leading to an exponential rank barrier.

The key insight is that subset delta functionals form a basis of the function space
`Finset (Fin n) → K`, and any certificate system that can isolate each subset
coordinate inherits this full-rank property.
-/

open Finset Function

/-! ## Powerset Coefficients -/

/-- The powerset coefficient function: for an assignment `f : Fin n → α` and a subset
    `S ⊆ Fin n`, the coefficient `c_f(S) = ∏_{i ∈ S} f(i)` is the product of `f`
    over the elements of `S`. This is the monomial coefficient in the powerset expansion
    `∏ (1 + f_i) = ∑_S c_f(S)`. -/
def powersetCoeff {α : Type*} [CommMonoid α] {n : ℕ}
    (f : Fin n → α) (S : Finset (Fin n)) : α :=
  ∏ i ∈ S, f i

/-! ## Certificate Systems -/

/-- A linearized certificate system for subset coefficient constraints.
    The system has:
    - `cols`: the type indexing certificate variables (column coordinates)
    - `constraintVec`: for each subset `S`, a row vector in `cols → K` encoding
      the constraint that must be satisfied for coordinate `S`

    The rank of this system measures the minimum dimension required to represent
    all subset constraints, serving as a lower bound on proof certificate size. -/
structure CertificateSystem (K : Type*) [Field K] (n : ℕ) where
  /-- The type indexing certificate variables -/
  cols : Type*
  /-- Finiteness of the column index -/
  [colsFintype : Fintype cols]
  /-- Decidable equality on columns -/
  [colsDecEq : DecidableEq cols]
  /-- The constraint vector for each subset: row S maps to a function `cols → K` -/
  constraintVec : Finset (Fin n) → (cols → K)

attribute [instance] CertificateSystem.colsFintype CertificateSystem.colsDecEq

/-- The rank of a certificate system, defined as the `finrank` of the span of its
    row vectors. This measures how many independent constraints the system imposes,
    equivalently the minimum dimension of any faithful representation. -/
noncomputable def certificateRank {K : Type*} [Field K] {n : ℕ}
    (CS : CertificateSystem K n) : ℕ :=
  Module.finrank K (Submodule.span K (Set.range CS.constraintVec))

/-! ## Canonical Certificate System -/

/-- The canonical certificate system for powerset coefficient verification.
    Each subset `S` gets the delta functional `e_S` as its constraint vector,
    meaning the system reads off each subset coordinate independently.
    This is the "identity" system: its constraint matrix is the identity matrix
    on `Finset (Fin n)`. -/
noncomputable def canonicalCertificateSystem (K : Type*) [Field K] (n : ℕ) :
    CertificateSystem K n where
  cols := Finset (Fin n)
  constraintVec S := Pi.single S (1 : K)

/-- A certificate system has the subset-separation property if for each subset `S`,
    there exists a certificate variable `v` that is nonzero at `S` and zero at all
    other subsets. This means each subset coordinate can be isolated. -/
def CertificateSystem.IsSeparating {K : Type*} [Field K] {n : ℕ}
    (CS : CertificateSystem K n) : Prop :=
  ∀ S : Finset (Fin n), ∃ v : CS.cols,
    CS.constraintVec S v ≠ 0 ∧ ∀ T : Finset (Fin n), T ≠ S → CS.constraintVec T v = 0

/-! ## Proof Compression Connection -/

/-- A compression instance models a family of theorems equipped with
    semantic complexity, human proof cost, and automation cost. Replicates the
    definition from `MachineLearning.ProofCompression.Defs` for self-containedness. -/
structure CertCompressionInstance where
  /-- The type of theorem identifiers -/
  theorem_id : Type
  /-- Semantic complexity measure -/
  semanticComplexity : theorem_id → ℕ
  /-- Cost of structured human proof with lemma reuse -/
  humanCost : theorem_id → ℕ
  /-- Cost of naive automation without lemma invention -/
  autoCost : theorem_id → ℕ

/-- A theorem family has an asymptotic gap if the compression ratio is unbounded. -/
def CertHasAsymptoticGap (I : CertCompressionInstance) (T : ℕ → I.theorem_id) : Prop :=
  ∀ K : ℕ, ∃ n : ℕ, K * I.humanCost (T n) < I.autoCost (T n)

/-- The certificate rank barrier as a `CertCompressionInstance`: the automation cost
    for coefficient-comparison proofs is `2^n` (the certificate rank), while
    structured proofs using induction cost `n + 1`. -/
noncomputable def certificateRankBarrierInstance : CertCompressionInstance where
  theorem_id := ℕ
  semanticComplexity := id
  humanCost := fun n => n + 1
  autoCost := fun n => 2 ^ n