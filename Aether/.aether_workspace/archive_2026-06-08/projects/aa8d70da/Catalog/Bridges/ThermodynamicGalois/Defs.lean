/-
Copyright (c) 2024 Thermodynamic Galois Duality Project. All rights reserved.
-/
import Mathlib

/-!
# Thermodynamic Galois Duality — Core Definitions

This module defines the fundamental objects for thermodynamic Galois duality
in finite closure dynamical systems:

* `transferMatrix` — weighted transfer matrix from step relations and weights
* `partitionSum` — partition function Z_n as total mass of length-n paths
* `StateFunctional` — normalized positive functionals (probability measures)
* `SemiringCharacter` — normalized multiplicative functionals on semirings
* `faceKernel` / `quotientFace` — Galois connection maps

## Mathematical Overview

Given a finite state space `X`, generators `Gen`, step relations
`step : Gen → X → X → Prop`, and weights `w : Gen → ℝ`, we construct
the weighted transfer matrix `A` with entries
  `A x y = Σ_g exp(w(g)) · [step g y x]`
and study the partition function `Z_n = Σ_{x,y} (A^n)(x,y)`.

The thermodynamic Galois duality connects:
- **Closure quotients**: equivalence relations on X compatible with dynamics
- **Equilibrium faces**: convex faces of the space of normalized eigenmeasures

These are linked by a Galois connection: coarser quotients correspond to
smaller equilibrium faces, and larger equilibrium faces detect finer structure.
-/

open Finset BigOperators Matrix

noncomputable section

variable {X : Type*} [Fintype X] [DecidableEq X]
variable {Gen : Type*} [Fintype Gen] [DecidableEq Gen]

/-! ### Transfer Matrix -/

/-- The weighted transfer matrix for a closure dynamical system.
    Entry `A x y` counts the total weight of one-step transitions from state `y`
    to state `x`, summed over all generators:
    `A x y = Σ_g exp(w(g)) · [step g y x]` -/
def transferMatrix (step : Gen → X → X → Prop)
    [∀ g x y, Decidable (step g x y)]
    (w : Gen → ℝ) : Matrix X X ℝ :=
  fun x y => ∑ g : Gen, if step g y x then Real.exp (w g) else 0

/-! ### Partition Function -/

/-- The partition function `Z_n`: total weighted mass of all length-n paths.
    Defined as the sum of all entries of `A^n`. -/
def partitionSum (A : Matrix X X ℝ) (n : ℕ) : ℝ :=
  ∑ x : X, ∑ y : X, (A ^ n) x y

/-! ### Thermodynamic Pressure -/

/-- The thermodynamic pressure: asymptotic growth rate of the partition function.
    `P = limsup_{n→∞} (1/n) · log(Z_n)` -/
def closurePressure (A : Matrix X X ℝ) : ℝ :=
  Filter.limsup (fun n : ℕ => (1 / (n : ℝ)) * Real.log (partitionSum A n)) Filter.atTop

/-! ### State Functionals (Probability Measures on Finite State Space) -/

/-- A state functional on a finite type X: a normalized nonnegative-real-valued
    function representing a probability distribution / equilibrium measure. -/
structure StateFunctional (X : Type*) [Fintype X] where
  /-- The measure/weight function -/
  val : X → NNReal
  /-- Normalization: total mass equals 1 -/
  normalized : ∑ x : X, val x = 1

/-- A state functional factors through a setoid Q if it assigns equal values
    to equivalent states. This captures the notion that the functional
    "cannot distinguish" states related by Q. -/
def StateFunctional.factorsThrough (μ : StateFunctional X) (Q : Setoid X) : Prop :=
  ∀ x y : X, Q.r x y → μ.val x = μ.val y

/-- The kernel setoid of a state functional: the equivalence relation identifying
    states that receive equal measure. -/
def StateFunctional.kernel (μ : StateFunctional X) : Setoid X where
  r x y := μ.val x = μ.val y
  iseqv := ⟨fun _ => rfl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩

/-! ### Galois Connection Maps -/

/-- Given a set F of state functionals, the face kernel is the coarsest
    equivalence relation on which all functionals in F agree.
    `faceKernel(F).r x y ↔ ∀ μ ∈ F, μ(x) = μ(y)` -/
def faceKernel (F : Set (StateFunctional X)) : Setoid X where
  r x y := ∀ μ ∈ F, μ.val x = μ.val y
  iseqv := ⟨fun _ _ _ => rfl, fun h μ hμ => (h μ hμ).symm,
            fun h₁ h₂ μ hμ => (h₁ μ hμ).trans (h₂ μ hμ)⟩

/-- The face of functionals compatible with a quotient Q: all state functionals
    that are constant on Q-equivalence classes.
    `quotientFace(Q) = {μ | μ factors through Q}` -/
def quotientFace (Q : Setoid X) : Set (StateFunctional X) :=
  {μ | μ.factorsThrough Q}

/-! ### Setoid ordering for Galois connection -/

/-- Ordering on setoids: Q₁ ≤ Q₂ means Q₁ is finer
    (Q₁-equivalence implies Q₂-equivalence). -/
instance setoidLE : LE (Setoid X) where
  le Q₁ Q₂ := ∀ x y : X, Q₁.r x y → Q₂.r x y

instance setoidPreorder : Preorder (Setoid X) where
  le := setoidLE.le
  le_refl _ _ _ h := h
  le_trans _ _ _ h₁₂ h₂₃ x y hxy := h₂₃ x y (h₁₂ x y hxy)

/-! ### Semiring Characters -/

/-- A normalized semiring character: a multiplicative, additive map from a semiring
    to NNReal, sending 0 to 0 and 1 to 1. These are the algebraic duals of
    equilibrium measures in thermodynamic Galois duality. -/
structure SemiringCharacter (S : Type*) [Semiring S] where
  /-- The character map -/
  toFun : S → NNReal
  /-- Characters send zero to zero -/
  map_zero' : toFun 0 = 0
  /-- Characters send one to one -/
  map_one' : toFun 1 = 1
  /-- Characters are additive -/
  map_add' : ∀ a b : S, toFun (a + b) = toFun a + toFun b
  /-- Characters are multiplicative -/
  map_mul' : ∀ a b : S, toFun (a * b) = toFun a * toFun b

/-- A semiring character is closure-stable with respect to a congruence if
    it is constant on congruence classes. -/
def SemiringCharacter.closureStable {S : Type*} [Semiring S]
    (χ : SemiringCharacter S) (C : RingCon S) : Prop :=
  ∀ a b : S, C.r a b → χ.toFun a = χ.toFun b

/-- The kernel congruence of a semiring character: the congruence relation
    identifying elements with equal character values. -/
def SemiringCharacter.kernelRingCon {S : Type*} [Semiring S]
    (χ : SemiringCharacter S) : RingCon S where
  r a b := χ.toFun a = χ.toFun b
  iseqv := ⟨fun _ => rfl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩
  mul' h₁ h₂ := by simp [χ.map_mul', h₁, h₂]
  add' h₁ h₂ := by simp [χ.map_add', h₁, h₂]

/-! ### Equilibrium Functionals -/

/-- An equilibrium functional for a nonneg matrix A: a positive normalized
    distribution that is a left eigenvector of A (up to scaling by eigenvalue r).
    This captures thermodynamic equilibrium without requiring entropy. -/
structure EquilibriumFunctional (X : Type*) [Fintype X] (A : Matrix X X NNReal) where
  /-- The underlying state functional -/
  toStateFunctional : StateFunctional X
  /-- The eigenvalue -/
  eigenvalue : NNReal
  /-- Positive eigenvalue -/
  eigenvalue_pos : 0 < eigenvalue
  /-- Eigenvector equation: μ · A = eigenvalue · μ -/
  eigenvector_eq : ∀ x : X,
    ∑ y : X, A x y * toStateFunctional.val y = eigenvalue * toStateFunctional.val x

/-! ### Closure Compatibility -/

/-- A setoid on X is closure-compatible with a matrix A if the matrix respects
    the equivalence classes: equivalent source states yield equal weighted
    sums over each equivalence class. -/
def ClosureCompatible (Q : Setoid X) (A : Matrix X X NNReal)
    [DecidableRel Q.r] : Prop :=
  ∀ x₁ x₂ : X, Q.r x₁ x₂ →
    ∀ c : X, (∑ y : X, if Q.r y c then A x₁ y else 0) =
             (∑ y : X, if Q.r y c then A x₂ y else 0)

end