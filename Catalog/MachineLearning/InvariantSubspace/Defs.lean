/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Invariant Subspace Definitions

This file defines the basic notions of invariant subspaces, reducing subspaces,
and nontrivial closed subspaces for linear and continuous linear operators.
These definitions form the foundation of a certified operator-theoretic platform
for spectral theory, quantum mechanics, and functional analysis.
-/
import Mathlib

open Submodule

/-! ## Invariant subspaces for linear maps -/

/-- A submodule `M` is invariant under a linear map `T` if `T` maps `M` into itself. -/
def IsInvariantSubspace {𝕜 : Type*} {H : Type*} [Semiring 𝕜] [AddCommMonoid H] [Module 𝕜 H]
    (T : H →ₗ[𝕜] H) (M : Submodule 𝕜 H) : Prop :=
  ∀ x ∈ M, T x ∈ M

/-! ## Invariant closed subspaces for continuous linear maps -/

/-- A submodule `M` is a closed invariant subspace for a continuous linear map `T` if
`M` is closed as a set and `T` maps `M` into itself. -/
def IsInvariantClosedSubspace {𝕜 : Type*} {H : Type*}
    [NormedField 𝕜] [NormedAddCommGroup H] [NormedSpace 𝕜 H]
    (T : H →L[𝕜] H) (M : Submodule 𝕜 H) : Prop :=
  IsClosed (M : Set H) ∧ ∀ x ∈ M, T x ∈ M

/-- A submodule `M` is a nontrivial subspace if it is neither `⊥` nor `⊤`. -/
def IsNontrivialSubspace {𝕜 : Type*} {H : Type*} [Semiring 𝕜] [AddCommMonoid H] [Module 𝕜 H]
    (M : Submodule 𝕜 H) : Prop :=
  M ≠ ⊥ ∧ M ≠ ⊤

/-- A submodule `M` is a nontrivial closed subspace if it is closed and neither `⊥` nor `⊤`. -/
def IsNontrivialClosedSubspace {𝕜 : Type*} {H : Type*}
    [NormedField 𝕜] [NormedAddCommGroup H] [NormedSpace 𝕜 H]
    (M : Submodule 𝕜 H) : Prop :=
  IsClosed (M : Set H) ∧ M ≠ ⊥ ∧ M ≠ ⊤

/-- A submodule `M` is a reducing subspace for `T` if both `M` and its orthogonal complement
are invariant under `T`. In a Hilbert space context, this corresponds to `T` commuting with
the orthogonal projection onto `M`. -/
def IsReducingSubspace {𝕜 : Type*} {H : Type*}
    [RCLike 𝕜] [NormedAddCommGroup H] [InnerProductSpace 𝕜 H]
    (T : H →ₗ[𝕜] H) (M : Submodule 𝕜 H) : Prop :=
  IsInvariantSubspace T M ∧ IsInvariantSubspace T (Submodule.orthogonal M)

/-! ## Basic lemmas about invariant subspaces -/

/-- The bottom subspace `⊥` is invariant under any linear map. -/
theorem isInvariantSubspace_bot {𝕜 : Type*} {H : Type*} [Semiring 𝕜] [AddCommMonoid H]
    [Module 𝕜 H] (T : H →ₗ[𝕜] H) : IsInvariantSubspace T (⊥ : Submodule 𝕜 H) := by
  intro x hx
  simp [Submodule.mem_bot] at hx ⊢
  simp [hx]

/-- The top subspace `⊤` is invariant under any linear map. -/
theorem isInvariantSubspace_top {𝕜 : Type*} {H : Type*} [Semiring 𝕜] [AddCommMonoid H]
    [Module 𝕜 H] (T : H →ₗ[𝕜] H) : IsInvariantSubspace T (⊤ : Submodule 𝕜 H) := by
  intro x _
  exact Submodule.mem_top

/-
The eigenspace of a linear map is invariant under that map.
-/
theorem eigenspace_isInvariantSubspace {𝕜 : Type*} {H : Type*}
    [CommRing 𝕜] [AddCommGroup H] [Module 𝕜 H]
    (T : Module.End 𝕜 H) (μ : 𝕜) :
    IsInvariantSubspace T (T.eigenspace μ) := by
  intro x hx
  rw [Module.End.mem_eigenspace_iff] at hx
  rw [Module.End.mem_eigenspace_iff]
  simp [hx]

/-
The span of an eigenvector is an invariant subspace.
-/
theorem span_singleton_isInvariant_of_eigenvector {𝕜 : Type*} {H : Type*}
    [CommRing 𝕜] [AddCommGroup H] [Module 𝕜 H]
    (T : Module.End 𝕜 H) (μ : 𝕜) (v : H) (hv : T.HasEigenvector μ v) :
    IsInvariantSubspace T (Submodule.span 𝕜 {v}) := by
  intro x hx;
  obtain ⟨ c, rfl ⟩ := Submodule.mem_span_singleton.mp hx;
  have := hv.1;
  simp_all +decide [ Submodule.mem_iSup, Module.End.eigenspace ];
  exact Submodule.smul_mem _ _ ( Submodule.smul_mem _ _ ( Submodule.mem_span_singleton_self _ ) )

/-
The orthogonal complement of an invariant subspace under a self-adjoint operator
is invariant under the adjoint, hence under the operator itself.
-/
theorem orthogonalComplement_invariant_of_selfAdjoint
    {𝕜 : Type*} {H : Type*}
    [RCLike 𝕜] [NormedAddCommGroup H] [InnerProductSpace 𝕜 H] [CompleteSpace H]
    (T : H →L[𝕜] H) (hT : IsSelfAdjoint T) (M : Submodule 𝕜 H)
    (hM : ∀ x ∈ M, T x ∈ M) :
    ∀ x ∈ Submodule.orthogonal M, T x ∈ Submodule.orthogonal M := by
  intro x hx hz;
  intro hz'
  have hz_inner : inner 𝕜 hz (T x) = inner 𝕜 (T hz) x := by
    rw [ ← ContinuousLinearMap.adjoint_inner_right, hT.adjoint_eq ];
  exact hz_inner.trans ( hx _ ( hM _ hz' ) )