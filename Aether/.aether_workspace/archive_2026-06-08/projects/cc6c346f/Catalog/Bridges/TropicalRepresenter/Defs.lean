/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-! # Tropical Representer Theorem: Definitions and Core Infrastructure

## Convention

We work in the **max-plus** convention:
- **Tropical addition** = `⊔` (supremum / max)
- **Tropical scalar multiplication** = `*` (ring multiplication)
- The natural order is: `a ≤ b ↔ a ⊔ b = b`

For the abstract representer theorem (Theorem A), we work over a general `PartialOrder`
and impose no algebraic structure — the theorem is purely order-theoretic.

For the kernel-specific results, we work over a `CompleteLattice` with compatible
ordered multiplication (`MulLeftMono`).

## Main Definitions

* `TropicalRepresenter.KernelSection` — the kernel section `K(x, ·)` at a point
* `TropicalRepresenter.tropicalCombination` — `f(z) = ⨆ i, c i * K(x i, z)`
* `TropicalRepresenter.sampleEval` — evaluation at sample points
* `TropicalRepresenter.gramMatrix` — the tropical Gram matrix `G i j = K(x i, x j)`
* `TropicalRepresenter.predictFromCoeff` — prediction via Gram action
* `TropicalRepresenter.objective` — the regularized empirical objective
* `TropicalRepresenter.SampleSpanRetract` — structure packaging retraction hypotheses
-/

noncomputable section

namespace TropicalRepresenter

/-! ## §1. Core Definitions -/

/-- **Kernel section**: The function `K(x, ·)` for a fixed input `x`. -/
def KernelSection {S X : Type*} (K : X → X → S) (x : X) : X → S :=
  fun z => K x z

/-- **Tropical linear combination** of kernel sections.
    `f(z) = ⨆ i, c i * K(x i, z)` in max-plus convention.
    Bridge: connects tropical algebra to kernel methods. -/
def tropicalCombination {S X : Type*} [CompleteLattice S] [Mul S]
    {n : ℕ} (K : X → X → S) (x : Fin n → X) (c : Fin n → S) : X → S :=
  fun z => ⨆ i, c i * K (x i) z

/-- **Sample evaluation**: restriction of a function to sample points. -/
def sampleEval {X S : Type*} {n : ℕ} (x : Fin n → X) (f : X → S) : Fin n → S :=
  fun i => f (x i)

/-- **Tropical Gram matrix**: `G i j = K(x i, x j)`.
    The tropical analogue of the classical kernel Gram matrix.
    Bridge: connects kernel learning to finite-dimensional tropical linear algebra. -/
def gramMatrix {S X : Type*} {n : ℕ} (K : X → X → S) (x : Fin n → X) :
    Matrix (Fin n) (Fin n) S :=
  fun i j => K (x i) (x j)

/-- **Prediction from coefficients** via tropical Gram action.
    `pred(i) = ⨆ j, c j * G j i` — tropical matrix-vector multiplication. -/
def predictFromCoeff {S : Type*} [CompleteLattice S] [Mul S]
    {n : ℕ} (G : Matrix (Fin n) (Fin n) S) (c : Fin n → S) :
    Fin n → S :=
  fun i => ⨆ j, c j * G j i

/-- **Regularized empirical objective** in tropical (max-plus) form.
    `F(f) = L(eval_x f, y) ⊔ (λ * Ω(f))`
    Here `⊔` is tropical addition and `*` is tropical multiplication. -/
def objective {S X : Type*} [SemilatticeSup S] [Mul S]
    {n : ℕ}
    (L : (Fin n → S) → (Fin n → S) → S)
    (x : Fin n → X) (y : Fin n → S)
    (Ω : (X → S) → S)
    (lam : S) (f : X → S) : S :=
  L (sampleEval x f) y ⊔ (lam * Ω f)

/-! ## §2. Sample-Span Retraction Structure -/

/-- **SampleSpanRetract**: A structure packaging the hypotheses of the tropical
    representer theorem. Given a function class with a designated sample span,
    this provides a retraction that:
    1. lands in the sample span,
    2. preserves sample evaluations,
    3. does not increase complexity.

    This is the correct tropical analogue of orthogonal projection in RKHS theory.
    Bridge: replaces Hilbert orthogonal decomposition with order-theoretic retraction. -/
structure SampleSpanRetract
    {S X : Type*} [Preorder S]
    {n : ℕ}
    (x : Fin n → X)
    (SampleSpan : Set (X → S))
    (Ω : (X → S) → S) where
  /-- The retraction map -/
  retract : (X → S) → (X → S)
  /-- The retraction lands in the sample span -/
  retract_mem : ∀ f, retract f ∈ SampleSpan
  /-- The retraction preserves evaluations at sample points -/
  eval_retract : ∀ f i, retract f (x i) = f (x i)
  /-- The retraction does not increase the complexity functional -/
  Ω_retract : ∀ f, Ω (retract f) ≤ Ω f

/-! ## §3. Tropical Kernel Structure -/

/-- **TropicalKernel**: A symmetric kernel function.
    Level 1 of the tropical positivity hierarchy — no positivity axiom needed,
    only symmetry and the retraction principle.
    Bridge: connects tropical kernel theory to certified optimization. -/
structure TropicalKernel (S X : Type*) [CompleteLattice S] [Mul S] where
  /-- The kernel function -/
  toFun : X → X → S
  /-- Symmetry -/
  symm : ∀ x y, toFun x y = toFun y x

/-- The set of tropical combinations of kernel sections at sample points. -/
def kernelSpan {S X : Type*} [CompleteLattice S] [Mul S]
    {n : ℕ} (K : X → X → S) (x : Fin n → X) : Set (X → S) :=
  { f | ∃ c : Fin n → S, f = tropicalCombination K x c }

end TropicalRepresenter

end