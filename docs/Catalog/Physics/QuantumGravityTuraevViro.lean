/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# A finite state-sum model of 3-dimensional quantum gravity

This file formalizes the finite part of the Turaev--Viro construction.  A closed
triangulated three-manifold is represented by its finite set of admissible global
colourings and its tetrahedral weights.  The TQFT path integral sums the amplitude
of every colouring, while the Turaev--Viro state sum first contracts the local
weights and then applies the global normalization.  Distributivity proves that the
two presentations agree.

The boundary theory uses the abelian-anyon surface states already developed in
`TopologicalOrderGenus`.  Its state space is finite-dimensional.  Combinatorial
mapping classes permute the finite basis; pullback therefore preserves the standard
Hermitian inner product and gives a unitary action.
-/

import Mathlib
import Physics.PosetTheory.TopologicalOrderGenus

open Finset
open scoped ComplexConjugate

namespace QuantumGravityTuraevViro

/-! ## Closed three-manifolds and the state sum -/

/-- Finite state-sum data attached to a triangulation of a closed 3-manifold.
`Coloring` is the type of admissible global edge colourings and each colouring has
one local weight for every tetrahedron. -/
structure ClosedTriangulation where
  /-- Admissible global colourings. -/
  Coloring : Type
  /-- Finiteness of the label sum. -/
  coloringFintype : Fintype Coloring
  /-- Number of tetrahedra. -/
  tetrahedra : ℕ
  /-- Local quantum `6j` weight of a tetrahedron in a global colouring. -/
  localWeight : Coloring → Fin tetrahedra → ℂ
  /-- The conventional global vertex/quantum-dimension normalization. -/
  normalization : ℂ

attribute [instance] ClosedTriangulation.coloringFintype

namespace ClosedTriangulation

/-- Product of all tetrahedral weights for one admissible colouring. -/
noncomputable def contractedWeight (T : ClosedTriangulation) (c : T.Coloring) : ℂ :=
  ∏ t, T.localWeight c t

/-- The normalized path-integral amplitude of one global colouring. -/
noncomputable def pathAmplitude (T : ClosedTriangulation) (c : T.Coloring) : ℂ :=
  T.contractedWeight c * T.normalization

/-- The partition function obtained by summing normalized path amplitudes. -/
noncomputable def partitionFunction (T : ClosedTriangulation) : ℂ :=
  ∑ c, T.pathAmplitude c

/-- The Turaev--Viro state sum: contract local tetrahedral tensors, sum over
admissible labels, and apply the global normalization. -/
noncomputable def turaevViro (T : ClosedTriangulation) : ℂ :=
  T.normalization * ∑ c, T.contractedWeight c

/-- **TQFT/Turaev--Viro identification.**  On every closed triangulated
3-manifold in the finite state-sum model, the path-integral partition function is
the Turaev--Viro state sum. -/
theorem partitionFunction_eq_turaevViro (T : ClosedTriangulation) :
    T.partitionFunction = T.turaevViro := by
  rw [partitionFunction, turaevViro, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro c _
  rw [pathAmplitude, mul_comm]

/-- A change of triangulation data which bijects admissible colourings and preserves
the contracted local weight and global normalization.  This is the exact finite
content needed after a Pachner-move calculation. -/
structure StateSumEquiv (T U : ClosedTriangulation) where
  /-- Bijection between admissible colourings. -/
  coloringEquiv : T.Coloring ≃ U.Coloring
  /-- Equality of contracted weights under the bijection. -/
  weight_preserving : ∀ c, U.contractedWeight (coloringEquiv c) = T.contractedWeight c
  /-- Equality of global normalizations. -/
  normalization_preserving : U.normalization = T.normalization

/-- The Turaev--Viro state sum is unchanged by every weight-preserving finite
triangulation equivalence. -/
theorem turaevViro_invariant {T U : ClosedTriangulation} (e : StateSumEquiv T U) :
    T.turaevViro = U.turaevViro := by
  rw [turaevViro, turaevViro, e.normalization_preserving]
  congr 1
  calc
    ∑ c, T.contractedWeight c = ∑ c, U.contractedWeight (e.coloringEquiv c) := by
      apply Finset.sum_congr rfl
      intro c _
      exact (e.weight_preserving c).symm
    _ = ∑ c, U.contractedWeight c :=
      e.coloringEquiv.sum_comp U.contractedWeight

/-- Consequently the TQFT partition function is also invariant under a
weight-preserving change of triangulation. -/
theorem partitionFunction_invariant {T U : ClosedTriangulation}
    (e : StateSumEquiv T U) : T.partitionFunction = U.partitionFunction := by
  rw [T.partitionFunction_eq_turaevViro, U.partitionFunction_eq_turaevViro]
  exact turaevViro_invariant e

end ClosedTriangulation

/-! ## Boundary Hilbert spaces -/

/-- Basis labels for the genus-`g` surface in the finite abelian anyon model. -/
abbrev SurfaceConfiguration (A : Type*) (g : ℕ) := Fin g → A

/-- Wavefunctions on the finite set of surface configurations. -/
abbrev SurfaceHilbert (A : Type*) (g : ℕ) := SurfaceConfiguration A g → ℂ

/-- The standard finite-dimensional Hermitian inner product in the colouring basis. -/
noncomputable def surfaceInner {A : Type*} [Fintype A] {g : ℕ}
    (ψ φ : SurfaceHilbert A g) : ℂ :=
  ∑ x, conj (ψ x) * φ x

/-- **Finite-dimensionality.**  The boundary Hilbert space has dimension
`|A|^g`, exactly the ground-state degeneracy already defined in the catalog. -/
theorem surfaceHilbert_finrank (A : Type*) [Fintype A] (g : ℕ) :
    Module.finrank ℂ (SurfaceHilbert A g) = TopologicalOrderGenus.GSD A g := by
  rw [TopologicalOrderGenus.GSD]
  simp

/-- In particular, the torus state space has one basis state for every anyon label. -/
theorem torus_surfaceHilbert_finrank (A : Type*) [Fintype A] :
    Module.finrank ℂ (SurfaceHilbert A 1) = Fintype.card A := by
  rw [surfaceHilbert_finrank, TopologicalOrderGenus.GSD_torus]

/-! ## Unitary mapping-class action -/

/-- The finite combinatorial mapping-class model: a mapping class permutes the
colouring basis of the surface state space. -/
abbrev SurfaceMappingClass (A : Type*) (g : ℕ) :=
  Equiv.Perm (SurfaceConfiguration A g)

/-- Pullback of wavefunctions along a combinatorial mapping class. -/
def mappingClassAction {A : Type*} {g : ℕ} (σ : SurfaceMappingClass A g)
    (ψ : SurfaceHilbert A g) : SurfaceHilbert A g :=
  fun x => ψ (σ.symm x)

/-- The identity mapping class acts as the identity. -/
theorem mappingClassAction_one {A : Type*} {g : ℕ} (ψ : SurfaceHilbert A g) :
    mappingClassAction (1 : SurfaceMappingClass A g) ψ = ψ := by
  funext x
  simp [mappingClassAction]

/-- Pullback is a genuine left group action. -/
theorem mappingClassAction_mul {A : Type*} {g : ℕ}
    (σ τ : SurfaceMappingClass A g) (ψ : SurfaceHilbert A g) :
    mappingClassAction (σ * τ) ψ =
      mappingClassAction σ (mappingClassAction τ ψ) := by
  funext x
  rfl

/-- Pullback by a mapping class is complex-linear. -/
noncomputable def mappingClassLinear {A : Type*} {g : ℕ}
    (σ : SurfaceMappingClass A g) :
    SurfaceHilbert A g →ₗ[ℂ] SurfaceHilbert A g where
  toFun := mappingClassAction σ
  map_add' ψ φ := by
    funext x
    rfl
  map_smul' z ψ := by
    funext x
    rfl

/-- Pullback by a mapping class has pullback by its inverse as a two-sided inverse. -/
theorem mappingClassAction_inverse {A : Type*} {g : ℕ}
    (σ : SurfaceMappingClass A g) (ψ : SurfaceHilbert A g) :
    mappingClassAction σ.symm (mappingClassAction σ ψ) = ψ := by
  funext x
  simp [mappingClassAction]

/-- **Unitarity.** Every combinatorial mapping class preserves the standard
Hermitian inner product on the finite surface Hilbert space. -/
theorem mappingClassAction_unitary {A : Type*} [Fintype A] [DecidableEq A] {g : ℕ}
    (σ : SurfaceMappingClass A g) (ψ φ : SurfaceHilbert A g) :
    surfaceInner (mappingClassAction σ ψ) (mappingClassAction σ φ) =
      surfaceInner ψ φ := by
  unfold surfaceInner mappingClassAction
  exact Equiv.sum_comp σ.symm (fun x => conj (ψ x) * φ x)

/-- Norm preservation, the diagonal form of unitarity. -/
theorem mappingClassAction_normSq {A : Type*} [Fintype A] [DecidableEq A] {g : ℕ}
    (σ : SurfaceMappingClass A g) (ψ : SurfaceHilbert A g) :
    surfaceInner (mappingClassAction σ ψ) (mappingClassAction σ ψ) =
      surfaceInner ψ ψ :=
  mappingClassAction_unitary σ ψ ψ

end QuantumGravityTuraevViro