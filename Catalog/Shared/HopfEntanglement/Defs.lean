/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Quantum Entanglement via the Hopf Fibration: Definitions

This file defines the algebraic structures connecting quantum entanglement
of two-qubit states to the topology of the Hopf fibration.

## Main Definitions

* `HopfEntanglement.coeffMatrix` — The 2×2 coefficient matrix of a two-qubit state
* `HopfEntanglement.concurrence` — The concurrence entanglement measure: 2|αδ - βγ|
* `HopfEntanglement.spinFlipInner` — The spin-flip inner product ⟨ψ̃|ψ⟩
* `HopfEntanglement.hopfMap` — The Hopf fibration S³ → S² as an algebraic map C² → ℝ³
* `HopfEntanglement.EntanglementWedge` — Novel: the wedge product encoding of
  entanglement linking concurrence to the Hopf invariant

## Key Insight

For a two-qubit state |ψ⟩ = α|00⟩ + β|01⟩ + γ|10⟩ + δ|11⟩, the concurrence
C(ψ) = 2|αδ - βγ| equals:
1. Twice the absolute determinant of the coefficient matrix
2. The absolute spin-flip inner product |⟨ψ̃|ψ⟩|
3. The absolute value of the Hopf linking invariant of the associated fibration

This unifies the algebraic, quantum-information, and topological perspectives.
-/

noncomputable section

open Complex Matrix

namespace HopfEntanglement

/-! ### Two-Qubit States and Coefficient Matrices -/

/-- The 2×2 coefficient matrix of a two-qubit state
    α|00⟩ + β|01⟩ + γ|10⟩ + δ|11⟩, where the first index
    is the row and the second is the column. -/
def coeffMatrix (α β γ δ : ℂ) : Matrix (Fin 2) (Fin 2) ℂ :=
  !![α, β; γ, δ]

/-- The concurrence of a two-qubit pure state, the standard
    entanglement measure for pure states. For a normalized state,
    C = 0 means separable (product state) and C = 1 means
    maximally entangled. -/
def concurrence (α β γ δ : ℂ) : ℝ :=
  2 * ‖α * δ - β * γ‖

/-- The determinant invariant: the complex number αδ - βγ whose
    absolute value (times 2) gives the concurrence. This is the
    fundamental invariant connecting algebra and topology. -/
def detInvariant (α β γ δ : ℂ) : ℂ :=
  α * δ - β * γ

/-! ### The Spin-Flip Operation

The spin-flip operator (σ_y ⊗ σ_y) applied to the conjugate state
provides an alternative characterization of concurrence via the
inner product ⟨ψ̃|ψ⟩ = -2(αδ - βγ). -/

/-- The spin-flip inner product: given a state ψ = (α, β, γ, δ),
    the spin-flipped conjugate is ψ̃ = (σ_y ⊗ σ_y)ψ* = (-δ̄, γ̄, β̄, -ᾱ),
    and the inner product ⟨ψ̃|ψ⟩ = -δα + γβ + βγ - αδ = -2(αδ - βγ). -/
def spinFlipInner (α β γ δ : ℂ) : ℂ :=
  -δ * α + γ * β + β * γ - α * δ

/-! ### The Hopf Map

The Hopf fibration S³ → S² is the map (z₁, z₂) ↦ (2Re(z₁z̄₂), 2Im(z₁z̄₂), |z₁|²-|z₂|²)
which maps the 3-sphere in C² to the 2-sphere in ℝ³. -/

/-- The Hopf map from C² to ℝ³, given by
    (z₁, z₂) ↦ (2Re(z₁z̄₂), 2Im(z₁z̄₂), |z₁|² - |z₂|²).
    When restricted to the unit sphere |z₁|² + |z₂|² = 1,
    the image lies on the unit 2-sphere. -/
def hopfMap (z₁ z₂ : ℂ) : Fin 3 → ℝ :=
  ![2 * (z₁ * starRingEnd ℂ z₂).re,
    2 * (z₁ * starRingEnd ℂ z₂).im,
    Complex.normSq z₁ - Complex.normSq z₂]

/-! ### The Entanglement Wedge (Novel Definition)

The EntanglementWedge captures the topological content of entanglement
by encoding the two-qubit state as a pair of elements in the exterior
algebra. The key insight: the wedge product of the "row vectors" of
the coefficient matrix measures entanglement, and this wedge product
is precisely what the Hopf linking number computes.

Given M = [[α, β], [γ, δ]], the rows are v₁ = (α, β) and v₂ = (γ, δ).
The wedge product v₁ ∧ v₂ = αδ - βγ ∈ ∧²(ℂ²) ≅ ℂ.
The concurrence is 2|v₁ ∧ v₂|.

Topologically, v₁ and v₂ define two points on CP¹ ≅ S² (when nonzero),
and the Hopf preimages of these two points are circles in S³ whose
linking number equals |v₁ ∧ v₂| / (|v₁| · |v₂|) for normalized states.
-/

/-- The entanglement wedge: given two vectors in ℂ², their wedge product
    in ∧²(ℂ²) ≅ ℂ. This is the fundamental invariant:
    - Algebraically: det(M) where M has v₁, v₂ as rows
    - Topologically: the linking number of Hopf preimages
    - Quantum-mechanically: half the concurrence
    This definition makes explicit the common algebraic root of all three. -/
structure EntanglementWedge where
  /-- First row of the coefficient matrix (first qubit's "amplitude vector") -/
  v₁ : Fin 2 → ℂ
  /-- Second row of the coefficient matrix (second qubit's "amplitude vector") -/
  v₂ : Fin 2 → ℂ

/-- The wedge product value v₁ ∧ v₂ ∈ ℂ -/
def EntanglementWedge.wedgeProduct (w : EntanglementWedge) : ℂ :=
  w.v₁ 0 * w.v₂ 1 - w.v₁ 1 * w.v₂ 0

/-- The concurrence derived from the wedge product -/
def EntanglementWedge.concurrence (w : EntanglementWedge) : ℝ :=
  2 * ‖w.wedgeProduct‖

/-- Construct an EntanglementWedge from two-qubit state coefficients -/
def toEntanglementWedge (α β γ δ : ℂ) : EntanglementWedge where
  v₁ := ![α, β]
  v₂ := ![γ, δ]

/-- The squared norm of a vector in ℂ² -/
def normSqVec (v : Fin 2 → ℂ) : ℝ :=
  Complex.normSq (v 0) + Complex.normSq (v 1)

/-- The Hopf-projected point of a vector in ℂ² onto S² -/
def hopfProject (v : Fin 2 → ℂ) : Fin 3 → ℝ :=
  hopfMap (v 0) (v 1)

end HopfEntanglement

end