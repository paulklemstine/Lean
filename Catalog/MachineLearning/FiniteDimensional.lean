/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Finite-Dimensional Invariant Subspace Theorem

Every linear operator on a finite-dimensional complex vector space of dimension at least 2
has a nontrivial invariant subspace. This is the gateway result that follows from the
fundamental theorem of algebra (existence of eigenvalues over ℂ).
-/
import Mathlib
import Speculative.InvariantSubspace.Defs

open Submodule Module

/-
**Finite-Dimensional Invariant Subspace Theorem.**
Every linear operator on a finite-dimensional complex vector space of dimension ≥ 2
has a nontrivial invariant subspace. The proof uses the fundamental theorem of algebra:
over ℂ (an algebraically closed field), every endomorphism has an eigenvalue.
The eigenspace is invariant. If the eigenspace is proper, we're done.
If the eigenspace is all of V, then T = μ·I is scalar, and any 1-dimensional
subspace is invariant and nontrivial (since dim V ≥ 2).
-/
theorem exists_nontrivial_invariantSubspace_of_finiteDimensional
    {V : Type*}
    [AddCommGroup V]
    [Module ℂ V]
    [FiniteDimensional ℂ V]
    (hdim : 2 ≤ Module.finrank ℂ V)
    (T : V →ₗ[ℂ] V) :
    ∃ M : Submodule ℂ V,
      M ≠ ⊥ ∧ M ≠ ⊤ ∧
      ∀ x ∈ M, T x ∈ M := by
  -- Since $V$ is finite-dimensional over $\mathbb{C}$ (algebraically closed) and nontrivial (dim $\geq$ 2 $\geq$ 1), by Module.End.exists_eigenvalue there exists an eigenvalue $\mu$ of $T$.
  obtain ⟨μ, hμ⟩ : ∃ μ : ℂ, Module.End.HasEigenvalue T μ := by
    apply_rules [ Module.End.exists_eigenvalue ];
    exact ( Module.nontrivial_of_finrank_pos ( pos_of_gt hdim ) );
  obtain ⟨ v, hv₁, hv₂ ⟩ := hμ.exists_hasEigenvector;
  refine' ⟨ Submodule.span ℂ { v }, _, _, _ ⟩;
  · aesop;
  · have h_lin_ind : Module.finrank ℂ (Submodule.span ℂ {v}) = 1 := by
      exact finrank_span_singleton hv₂;
    exact fun h => by rw [ h ] at h_lin_ind; norm_num at h_lin_ind; linarith;
  · simp_all +decide [ LinearMap.map_smul, Submodule.mem_span_singleton, smul_smul ]