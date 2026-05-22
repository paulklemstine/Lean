/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Self-Adjoint Operator Invariant Subspace Theorem

Self-adjoint (symmetric) operators on complex inner product spaces have
nontrivial invariant subspaces. This file proves the result for finite-dimensional
spaces and establishes key infrastructure for the infinite-dimensional case.
-/
import Mathlib
import Speculative.InvariantSubspace.Defs

open Submodule Module

/-! ## Self-adjoint operators on finite-dimensional spaces -/

/-
The kernel of a nonzero linear map is a proper subspace.
-/
theorem ker_ne_top_of_ne_zero {𝕜 V : Type*} [Field 𝕜] [AddCommGroup V] [Module 𝕜 V]
    (T : V →ₗ[𝕜] V) (hT : T ≠ 0) : LinearMap.ker T ≠ ⊤ := by
  exact fun h => hT <| LinearMap.ker_eq_top.1 h ▸ rfl

/-
A symmetric (self-adjoint) operator on a finite-dimensional complex inner product space
of dimension at least 2 has a nontrivial invariant subspace.

This follows from the spectral theorem: such operators are diagonalizable with real eigenvalues.
Each eigenspace is invariant, and when the dimension is at least 2, at least one eigenspace
is a proper nontrivial subspace.
-/
theorem exists_nontrivial_invariantSubspace_of_isSymmetric_finiteDimensional
    {E : Type*}
    [NormedAddCommGroup E]
    [InnerProductSpace ℂ E]
    [FiniteDimensional ℂ E]
    (hdim : 2 ≤ Module.finrank ℂ E)
    (T : E →ₗ[ℂ] E)
    (hT : T.IsSymmetric) :
    ∃ M : Submodule ℂ E,
      M ≠ ⊥ ∧ M ≠ ⊤ ∧
      ∀ x ∈ M, T x ∈ M := by
  -- Let $\lambda$ be an eigenvalue of $T$.
  obtain ⟨lambda, hlambda⟩ : ∃ lambda : ℂ, Module.End.HasEigenvalue T lambda := by
    apply_rules [ Module.End.exists_eigenvalue ];
    exact Module.nontrivial_of_finrank_pos ( pos_of_gt hdim );
  -- Let $v$ be a corresponding eigenvector.
  obtain ⟨v, hv⟩ : ∃ v : E, v ≠ 0 ∧ T v = lambda • v := by
    have := hlambda.exists_hasEigenvector; obtain ⟨ v, hv ⟩ := this; use v; simp_all +decide [ Module.End.HasUnifEigenvector ] ;
  refine' ⟨ Submodule.span ℂ { v }, _, _, _ ⟩ <;> simp_all +decide [ Submodule.mem_span_singleton ];
  · have h_span : Module.finrank ℂ (Submodule.span ℂ {v}) = 1 := by
      rw [ finrank_span_singleton ] ; aesop;
    exact fun h => by rw [ h ] at h_span; simp +decide at h_span; linarith;
  · exact fun a => ⟨ a * lambda, by simp +decide [ mul_assoc, smul_smul ] ⟩

/-! ## Eigenspace properties for self-adjoint operators -/

/-- The eigenspace of a symmetric operator is an invariant closed subspace,
and the orthogonal complement of each eigenspace is also invariant. -/
theorem isSymmetric_eigenspace_orthogonal_invariant
    {𝕜 : Type*} {E : Type*}
    [RCLike 𝕜] [NormedAddCommGroup E] [InnerProductSpace 𝕜 E]
    (T : E →ₗ[𝕜] E) (hT : T.IsSymmetric) (μ : 𝕜) :
    ∀ v ∈ (Module.End.eigenspace T μ)ᗮ, T v ∈ (Module.End.eigenspace T μ)ᗮ :=
  hT.invariant_orthogonalComplement_eigenspace μ

/-! ## Self-adjoint operators and reducing subspaces -/

/-
For a symmetric operator, the eigenspace of any eigenvalue is a reducing subspace:
both the eigenspace and its orthogonal complement are invariant.
-/
theorem eigenspace_isReducingSubspace_of_isSymmetric
    {𝕜 : Type*} {E : Type*}
    [RCLike 𝕜] [NormedAddCommGroup E] [InnerProductSpace 𝕜 E]
    (T : E →ₗ[𝕜] E) (hT : T.IsSymmetric) (μ : 𝕜) :
    IsReducingSubspace T (Module.End.eigenspace T μ) := by
  exact ⟨ fun x hx => by simp_all +decide [ Module.End.mem_eigenspace_iff ], fun x hx => by simpa [ hT ] using LinearMap.IsSymmetric.invariant_orthogonalComplement_eigenspace hT μ x hx ⟩