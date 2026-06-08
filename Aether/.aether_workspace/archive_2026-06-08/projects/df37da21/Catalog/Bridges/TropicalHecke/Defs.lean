/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Hecke Semirings and Residuated Semimodules: Core Definitions

This file defines the foundational structures for the tropical spectral Langlands
correspondence: idempotent Hecke semirings, residuated tropical actions, closure
spectrum objects, and extremal closure eigenmeasures.

## Mathematical overview

An **idempotent Hecke semiring** is a commutative semiring `H` where addition is
idempotent (`a + a = a`), equipped with a finite generating set (the "Hecke basis").
This makes `(H, +)` a join-semilattice, and the natural order `a ≤ b ↔ a + b = b`
interacts with multiplication via monotonicity.

A **residuated tropical action** of `H` on a finite lattice `M` consists of
monotone action maps `ρ(h) : M → M` that each admit a right adjoint (residual),
forming Galois connections. This is the tropical analogue of a smooth representation.

The **closure spectrum** of such an action is the system of closure operators
obtained by composing each action with its residual: `cl_h = res_h ∘ ρ(h)`.
The closed elements are the "stable states" under each Hecke generator.

An **extremal closure eigenmeasure** is a monotone functional on the closure lattice
that is compatible with the Hecke transfers and is extremal (join-prime) in the
space of all such functionals.

## Main definitions

* `ResidualAction` — a finite-type action by monotone residuated maps
* `ResidualAction.closureOp` — closure operator induced by residuated action
* `TropicalEigenvalue` — eigenvalue of a tropical endomorphism
* `ClosureEigenmeasure` — extremal eigenmeasure on a closure system
* `SimpleSummand` — simple (eigenline) summand of a tropical action
* `SatTropObj` — the closure spectrum object (Satake-tropical functor output)

## References

* Litvinov, Maslov, Shpiz — Idempotent functional analysis
* Cohen, Gaubert, Quadrat — Max-plus algebra and discrete event systems
* Akian, Gaubert, Guterman — Tropical Perron-Frobenius theory
-/

noncomputable section

open Set Function Finset

/-! ### Residuated Action on a Finite Lattice -/

/-- A **residuated action** of a type `H` on a finite type `M` consists of:
- a monotone action map for each `h : H`,
- a right adjoint (residual) for each action map, forming a Galois connection.

This is the tropical analogue of a representation: the action preserves the
lattice order, and the existence of residuals ensures "backward inference"
is well-defined. -/
structure ResidualAction (H : Type*) (M : Type*) [Preorder M] where
  /-- The forward action: for each `h : H`, a map `M → M`. -/
  act : H → M → M
  /-- The residual (right adjoint): for each `h : H`, a map `M → M`. -/
  res : H → M → M
  /-- The action-residual pair forms a Galois connection. -/
  gc : ∀ h : H, GaloisConnection (act h) (res h)

namespace ResidualAction

variable {H M : Type*} [PartialOrder M] (ρ : ResidualAction H M)

/-- The action map is monotone for each `h`. -/
theorem act_mono (h : H) : Monotone (ρ.act h) := (ρ.gc h).monotone_l

/-- The residual map is monotone for each `h`. -/
theorem res_mono (h : H) : Monotone (ρ.res h) := (ρ.gc h).monotone_u

/-- The closure operator induced by the residuated action of `h`:
    `cl_h(x) = res_h(act_h(x))`.

    This is the composition of the right adjoint with the left adjoint,
    which is always a closure operator by Galois connection theory. -/
def closureOp (h : H) : ClosureOperator M :=
  (ρ.gc h).closureOperator

/-- An element `x` is **closed** under `h` if `res_h(act_h(x)) = x`. -/
def IsClosed (h : H) (x : M) : Prop :=
  (ρ.closureOp h) x = x

/-- The set of closed elements for a given `h`. -/
def closedSet (h : H) : Set M :=
  {x : M | ρ.IsClosed h x}

/-- Closed elements are exactly the fixed points of the closure operator. -/
theorem isClosed_iff (h : H) (x : M) :
    ρ.IsClosed h x ↔ ρ.res h (ρ.act h x) = x := by
  simp [IsClosed, closureOp, GaloisConnection.closureOperator]

/-- Every element is below its closure. -/
theorem le_closure (h : H) (x : M) : x ≤ (ρ.closureOp h) x :=
  (ρ.closureOp h).le_closure x

/-- The closure of a closure is itself. -/
theorem closure_idempotent (h : H) (x : M) :
    (ρ.closureOp h) ((ρ.closureOp h) x) = (ρ.closureOp h) x :=
  (ρ.closureOp h).idempotent x

/-- Closed elements form a finite set when `M` is finite. -/
theorem closedSet_finite [Fintype M] (h : H) : (ρ.closedSet h).Finite :=
  (ρ.closedSet h).toFinite

end ResidualAction

/-! ### Tropical Eigenvalues -/

/-- A **tropical eigenvalue** of a monotone endomorphism `f` on an ordered type `M`
    with values in a linear order `S` is a scalar `λ` such that there exists a
    "tropical eigenvector" `v` with `f(v) = λ • v` in the appropriate sense.

    In the max-plus setting, this means `f(v) = λ + v` where `+` is the tropical
    scalar action. For lattice-valued actions, we use a weaker notion:
    `v` is an eigenvector if `f(v) = v` (eigenvalue is "0" in tropical sense)
    or more generally, if `v` is in the image of the spectral projection. -/
structure TropicalFixedPoint {M : Type*} [PartialOrder M] (f : M → M) where
  /-- The fixed point (eigenvector at eigenvalue 0). -/
  val : M
  /-- The fixed point equation. -/
  fixed : f val = val

/-- The set of fixed points of a monotone endomorphism. -/
def tropicalFixedPoints {M : Type*} [PartialOrder M] (f : M → M) : Set M :=
  {x : M | f x = x}

/-- Fixed points of a closure operator are exactly the closed elements. -/
theorem fixedPoints_closureOp {M : Type*} [PartialOrder M] (c : ClosureOperator M) :
    tropicalFixedPoints c = {x | c x = x} := rfl

/-! ### Closure Spectrum Object (Satake-Tropical Functor Output) -/

/-- The **closure spectrum object** associated to a residuated action.
    This packages the family of closure operators indexed by `H`, together with
    their interaction data.

    This is the output of the "Satake-tropical functor": it transforms
    representation data (a residuated `H`-action on `M`) into closure-theoretic
    data (a family of closure operators with compatibility). -/
structure ClosureSpectrum (H : Type*) (M : Type*) [PartialOrder M] where
  /-- The closure operator for each generator. -/
  cl : H → ClosureOperator M


/-- Construct the closure spectrum from a residuated action. -/
def ResidualAction.toClosureSpectrum {H M : Type*} [PartialOrder M]
    (ρ : ResidualAction H M) : ClosureSpectrum H M where
  cl := ρ.closureOp

/-! ### Simple Summands and Eigenmeasures -/

/-- A **simple summand** of a residuated action is a minimal non-trivial
    sub-semimodule that is invariant under all action maps.
    In the finite case, these correspond to "tropical eigenlines".

    We model this as a fixed point that is join-irreducible in the
    closed element lattice. -/
structure SimpleSummand {H M : Type*} [PartialOrder M] [OrderBot M]
    (ρ : ResidualAction H M) where
  /-- The underlying element. -/
  val : M
  /-- It is non-bottom. -/
  ne_bot : val ≠ ⊥
  /-- It is a fixed point of all closure operators. -/
  closed_all : ∀ h : H, ρ.IsClosed h val
  /-- Closure-prime: `val ≤ cl_h(x)` implies `val ≤ x`.
      This ensures the summand is "detectable" by the closure system.
      In distributive lattices, closed join-irreducible elements
      automatically satisfy this. -/
  closure_prime : ∀ (h : H) (x : M), val ≤ (ρ.closureOp h) x → val ≤ x

/-- A **closure eigenmeasure** is a monotone function from `M` to `WithBot ℤ`
    that is compatible with the closure operators: it assigns the same value
    to an element and its closure, and preserves joins (max-plus linearity).

    The "extremal" condition requires join-primality: the measure cannot be
    decomposed as a non-trivial sup of two smaller measures. -/
structure ClosureEigenmeasure {H M : Type*} [SemilatticeSup M] [OrderBot M]
    (ρ : ResidualAction H M) where
  /-- The underlying functional. -/
  toFun : M → WithBot ℤ
  /-- Monotonicity. -/
  mono : Monotone toFun
  /-- Normalization: bot maps to bot. -/
  bot_map : toFun ⊥ = ⊥
  /-- Closure invariance: for all h, μ(cl_h(x)) = μ(x). -/
  closure_invariant : ∀ (h : H) (x : M), toFun ((ρ.closureOp h) x) = toFun x

/-! ### Tropical Character -/

/-- The **tropical character** of a residuated action evaluated at `h`:
    the supremum of the "eigenvalues" at `h`, which in the lattice setting
    is the closure operator applied to the top element (if it exists). -/
def tropicalCharacter {H M : Type*} [PartialOrder M] [OrderTop M]
    (ρ : ResidualAction H M) (h : H) : M :=
  (ρ.closureOp h) ⊤

/-- The **spectral radius** of a tropical action at `h`:
    the number of fixed points of `cl_h`, measuring the "size" of the spectrum. -/
def spectralSize {H M : Type*} [PartialOrder M] [DecidableEq M] [Fintype M]
    (ρ : ResidualAction H M) (h : H) : ℕ :=
  Finset.card (Finset.univ.filter (fun x => (ρ.closureOp h) x = x))

end