/-
Copyright (c) 2024 Thermodynamic Galois Duality Project. All rights reserved.
-/
import Bridges.ThermodynamicGalois.Defs

/-!
# Thermodynamic Galois Duality — The Galois Connection

This module proves the central Galois connection theorem: closure quotients
(equivalence relations on the state space) and equilibrium faces (sets of
normalized eigenmeasures) form a Galois connection via the maps
`faceKernel` and `quotientFace`.

## Main Results

* `quotient_face_galois` — The fundamental Galois connection:
  `Q ≤ faceKernel F ↔ F ⊆ quotientFace Q`
* `quotientFace_antitone` — `quotientFace` is antitone
* `faceKernel_antitone` — `faceKernel` is antitone
* `galoisConnection_quotientFace_faceKernel` — Formal Mathlib `GaloisConnection`
* `closure_quotient_le_kernel_iff` — Quotient-kernel relationship

## Mathematical Significance

This theorem establishes that thermodynamic equilibrium data (which states
are "equally probable" in equilibrium) exactly corresponds to the algebraic
structure of closure-compatible quotients. Coarsening the quotient (merging
equivalence classes) restricts the equilibrium face; expanding the equilibrium
face refines the detectable quotient structure.

This is the thermodynamic analogue of the fundamental theorem of Galois theory:
where Galois theory relates field extensions to subgroups of the Galois group,
thermodynamic Galois duality relates closure quotients to faces of the
equilibrium simplex.
-/

open Finset BigOperators

variable {X : Type*} [Fintype X] [DecidableEq X]

/-! ### Monotonicity Properties -/

omit [DecidableEq X] in
/-- `quotientFace` is antitone: coarser quotients yield smaller equilibrium faces.
    If Q₁ ≤ Q₂ (Q₁ finer), then quotientFace Q₂ ⊆ quotientFace Q₁. -/
theorem quotientFace_antitone :
    Antitone (quotientFace (X := X)) := by
  intro Q₁ Q₂ h μ hμ x y hxy
  exact hμ x y (h x y hxy)

omit [DecidableEq X] in
/-- `faceKernel` is antitone: larger functional sets yield finer kernels.
    If F₁ ⊆ F₂, then faceKernel F₂ ≤ faceKernel F₁. -/
theorem faceKernel_antitone :
    Antitone (faceKernel (X := X)) := by
  intro F₁ F₂ h x y hxy μ hμ
  exact hxy μ (h hμ)

/-! ### The Fundamental Galois Connection -/

/-
**Thermodynamic Galois Duality (Fundamental Theorem)**:
    Closure quotients and equilibrium faces form a Galois connection.

    `Q ≤ faceKernel F ↔ F ⊆ quotientFace Q`

    Left-to-right: if Q is finer than the face kernel of F, then every
    functional in F factors through Q.

    Right-to-left: if every functional in F factors through Q, then Q
    is contained in the common kernel of F.

    This is equivalent to saying: the semantic coarse-graining (quotient)
    is invisible to the thermodynamic data (equilibrium functionals) if
    and only if the data factors through the coarse-graining.
-/
omit [DecidableEq X] in
theorem quotient_face_galois (Q : Setoid X) (F : Set (StateFunctional X)) :
    Q ≤ faceKernel F ↔ F ⊆ quotientFace Q := by
  constructor;
  · exact fun h μ hμ => fun x y hxy => h x y hxy μ hμ;
  · exact fun h x y hxy => fun μ hμ => h hμ x y hxy

/-
The Galois connection as a formal `GaloisConnection` between
    `(Setoid X)ᵒᵈ` (reverse order) and `Set (StateFunctional X)`.

    Since both `quotientFace` and `faceKernel` are antitone, the Galois
    connection is between the dual order on setoids and the subset order
    on functional sets.
-/
omit [DecidableEq X] in
theorem galoisConnection_quotientFace_faceKernel :
    GaloisConnection
      (OrderDual.toDual ∘ faceKernel (X := X))
      (quotientFace ∘ OrderDual.ofDual) := by
  intro Q F;
  convert quotient_face_galois F Q using 1

/-! ### Closure-Idempotence Properties -/

/-
Applying faceKernel then quotientFace enlarges the face:
    F ⊆ quotientFace (faceKernel F).
-/
omit [DecidableEq X] in
theorem subset_quotientFace_faceKernel (F : Set (StateFunctional X)) :
    F ⊆ quotientFace (faceKernel F) := by
  exact fun μ hμ => fun x y hxy => hxy μ hμ

/-
Applying quotientFace then faceKernel coarsens the quotient:
    Q ≤ faceKernel (quotientFace Q).
-/
omit [DecidableEq X] in
theorem le_faceKernel_quotientFace (Q : Setoid X) :
    Q ≤ faceKernel (quotientFace Q) := by
  exact (quotient_face_galois Q (quotientFace Q)).mpr fun ⦃a⦄ a_1 => a_1

/-! ### Character Kernel Galois Connection -/

/-
A semiring character is closure-stable for a congruence C if and only if
    C is contained in the character's kernel congruence.
-/
theorem character_closureStable_iff_le_kernel {S : Type*} [Semiring S]
    (χ : SemiringCharacter S) (C : RingCon S) :
    χ.closureStable C ↔ (∀ a b : S, C.r a b → χ.kernelRingCon.r a b) := by
  exact Iff.symm (Eq.to_iff rfl)

/-! ### Equilibrium Face Structure -/

omit [DecidableEq X] in
/-- The quotient face of the discrete setoid (identity relation) is the
    full set of state functionals. -/
theorem quotientFace_bot :
    quotientFace (⊥ : Setoid X) = Set.univ := by
  -- By definition of `quotientFace`, we know that every state functional factors through the discrete setoid.
  ext μ
  simp [quotientFace, StateFunctional.factorsThrough]

omit [DecidableEq X] in
/-- The face kernel of the empty set is the indiscrete setoid
    (all states equivalent). -/
theorem faceKernel_empty :
    faceKernel (∅ : Set (StateFunctional X)) = ⊤ := by
  ext; simp [faceKernel]