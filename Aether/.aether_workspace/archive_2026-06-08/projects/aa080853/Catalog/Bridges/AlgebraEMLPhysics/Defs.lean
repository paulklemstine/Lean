/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Idempotent Noether Correspondence: Core Definitions

This file establishes the foundational structures for the Idempotent Noether
Correspondence — a tropical/order-theoretic analogue of Noether's theorem
that works natively with closure operators, idempotent semirings, and
sup-preserving actions on finite lattices.

## Main Definitions

* `ClosureOp` — A closure operator on a preorder (extensive, monotone, idempotent)
* `ClosureSymmetry` — An endomorphism compatible with both dynamics and closure
* `ConservedCharge` — A monotone map invariant under dynamics
* `NoetherChargeData` — Package of symmetry + charge demonstrating the correspondence

## Mathematical Overview

In classical Noether theory, continuous symmetries of a Lagrangian yield conserved
quantities via variational calculus. Here we replace:
- smooth manifold → finite sup-semilattice with closure
- Lagrangian symmetry → closure-compatible commuting endomorphism
- conserved momentum → monotone τ-invariant valuation
- variational derivative → order-theoretic residual/fixed-point structure

The key insight: conservation follows from commutation + closure compatibility +
injectivity, without any differentiable structure.
-/
import Mathlib

namespace IdempotentNoether

/-! ## Closure Operators -/

/-- A closure operator on a preorder: extensive, monotone, idempotent. -/
structure ClosureOp (X : Type*) [Preorder X] where
  /-- The closure map -/
  cl : X → X
  /-- Closure is monotone -/
  mono : Monotone cl
  /-- Closure is extensive: x ≤ cl(x) -/
  ext : ∀ x, x ≤ cl x
  /-- Closure is idempotent: cl(cl(x)) = cl(x) -/
  idem : ∀ x, cl (cl x) = cl x

/-- An element is closed if cl(x) = x. -/
def ClosureOp.IsClosed {X : Type*} [Preorder X] (C : ClosureOp X) (x : X) : Prop :=
  C.cl x = x

/-- The set of closed elements. -/
def ClosureOp.closedSet {X : Type*} [Preorder X] (C : ClosureOp X) : Set X :=
  {x | C.IsClosed x}

/-! ## Symmetry Generators -/

/-- A closure symmetry is an endomorphism that commutes with both
dynamics τ and closure cl, serving as the tropical/idempotent analogue
of an infinitesimal symmetry generator. -/
structure ClosureSymmetry (X : Type*) [Preorder X] (C : ClosureOp X) (τ : X → X) where
  /-- The symmetry endomorphism -/
  σ : X → X
  /-- σ is monotone -/
  mono : Monotone σ
  /-- σ commutes with dynamics τ -/
  comm_τ : Function.Commute σ τ
  /-- σ is compatible with closure: cl(σ(x)) ≤ σ(cl(x)) -/
  compat_cl : ∀ x, C.cl (σ x) ≤ σ (C.cl x)

/-- A strong closure symmetry additionally commutes exactly with closure. -/
structure StrongClosureSymmetry (X : Type*) [Preorder X] (C : ClosureOp X) (τ : X → X)
    extends ClosureSymmetry X C τ where
  /-- σ commutes exactly with closure -/
  comm_cl : Function.Commute σ C.cl

/-! ## Conserved Charges -/

/-- A conserved charge is a monotone map Q : X → Γ that is invariant under dynamics τ. -/
structure ConservedCharge (X : Type*) (Γ : Type*) [Preorder X] [Preorder Γ]
    (τ : X → X) where
  /-- The charge map -/
  Q : X → Γ
  /-- The charge is monotone -/
  mono : Monotone Q
  /-- The charge is conserved under dynamics -/
  conserved : ∀ x, Q (τ x) = Q x

/-- A closure-compatible conserved charge is additionally invariant under closure. -/
structure ClosureConservedCharge (X : Type*) (Γ : Type*) [Preorder X] [Preorder Γ]
    (C : ClosureOp X) (τ : X → X) extends ConservedCharge X Γ τ where
  /-- The charge is invariant under closure -/
  closure_inv : ∀ x, Q (C.cl x) = Q x

/-! ## Descent and Fixed-Point Sets -/

/-- The descent set of σ: elements x with σ(x) ≤ x. -/
def descentSet {X : Type*} [Preorder X] (σ : X → X) : Set X :=
  {x | σ x ≤ x}

/-- The fixed-point set of σ. -/
def fixedPtSet {X : Type*} (σ : X → X) : Set X :=
  {x | σ x = x}

/-! ## Noether Charge Data -/

/-- A Noether charge datum pairs a symmetry with its associated conserved charge
and witnesses the correspondence between them. -/
structure NoetherChargeData (X : Type*) (Γ : Type*) [Preorder X] [Preorder Γ]
    (C : ClosureOp X) (τ : X → X) where
  /-- The symmetry generator -/
  sym : ClosureSymmetry X C τ
  /-- The conserved charge -/
  charge : ConservedCharge X Γ τ
  /-- The charge is σ-invariant -/
  sym_invariant : ∀ x, charge.Q (sym.σ x) = charge.Q x

/-! ## Symmetry Equivalence -/

/-- Two symmetries are charge-equivalent if they induce the same conserved charges
on all elements. -/
def SymmetryEquiv {X Γ : Type*} [Preorder X] [Preorder Γ] {C : ClosureOp X} {τ : X → X}
    (s₁ s₂ : ClosureSymmetry X C τ) (Q : X → Γ) : Prop :=
  ∀ x, Q (s₁.σ x) = Q (s₂.σ x)

end IdempotentNoether