/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Compact Operator Invariant Subspace Theory

This file develops the theory of invariant subspaces for compact operators
on complex Hilbert spaces.

## Main results

* Helper lemmas establishing that kernels and closures of ranges provide
  closed invariant subspaces.
* Conditional result: given the Riesz-Schauder spectral theorem (nonzero compact
  operator has nonzero eigenvalue), the invariant subspace theorem for compact
  operators follows.

## Missing Mathlib dependency

The Riesz-Schauder theorem — that every nonzero compact operator on an
infinite-dimensional Banach/Hilbert space has a nonzero eigenvalue — is not
currently available in Mathlib (as of v4.28.0). This is the single missing
ingredient for the full compact operator invariant subspace theorem.
-/
import Mathlib
import Speculative.InvariantSubspace.Defs

open Submodule Module

/-! ## Kernel and range as invariant subspaces -/

/-- The kernel of a continuous linear map is a closed subspace. -/
theorem ker_isClosed_of_continuous {𝕜 : Type*} {H : Type*}
    [NontriviallyNormedField 𝕜] [NormedAddCommGroup H] [NormedSpace 𝕜 H]
    (T : H →L[𝕜] H) :
    IsClosed (LinearMap.ker (T : H →ₗ[𝕜] H) : Set H) := by
  convert T.isClosed_ker

/-- The kernel of a linear map is invariant under that map. -/
theorem ker_isInvariantSubspace {𝕜 : Type*} {H : Type*}
    [CommRing 𝕜] [AddCommGroup H] [Module 𝕜 H]
    (T : H →ₗ[𝕜] H) :
    IsInvariantSubspace T (LinearMap.ker T) := by
  exact fun x hx => by simp [LinearMap.mem_ker.1 hx]

/-- The closure of the range of a continuous linear map is invariant under that map. -/
theorem range_closure_isInvariantSubspace {𝕜 : Type*} {H : Type*}
    [NontriviallyNormedField 𝕜] [NormedAddCommGroup H] [NormedSpace 𝕜 H] [CompleteSpace H]
    (T : H →L[𝕜] H) :
    ∀ x ∈ (LinearMap.range (T : H →ₗ[𝕜] H)).topologicalClosure,
      T x ∈ (LinearMap.range (T : H →ₗ[𝕜] H)).topologicalClosure := by
  intro x hx
  obtain ⟨y, hy⟩ : ∃ y : ℕ → H, Filter.Tendsto (fun n => T (y n)) Filter.atTop (nhds x) :=
    mem_closure_iff_seq_limit.mp hx |>.elim fun y hy =>
      ⟨fun n => Classical.choose (hy.1 n),
       hy.2.congr fun n => (Classical.choose_spec (hy.1 n)) |> Eq.symm⟩
  exact mem_closure_of_tendsto (T.continuous.continuousAt.tendsto.comp hy) (by simp +decide)

/-- The closure of the range of a continuous linear map is a closed subspace. -/
theorem range_closure_isClosed {𝕜 : Type*} {H : Type*}
    [NontriviallyNormedField 𝕜] [NormedAddCommGroup H] [NormedSpace 𝕜 H]
    (T : H →L[𝕜] H) :
    IsClosed ((LinearMap.range (T : H →ₗ[𝕜] H)).topologicalClosure : Set H) := by
  exact isClosed_closure

/-- If T ≠ 0, the kernel of T is not ⊤. -/
theorem ker_ne_top_of_ne_zero' {𝕜 : Type*} {H : Type*}
    [NontriviallyNormedField 𝕜] [NormedAddCommGroup H] [NormedSpace 𝕜 H]
    (T : H →L[𝕜] H) (hT : T ≠ 0) :
    LinearMap.ker (T : H →ₗ[𝕜] H) ≠ ⊤ := by
  exact fun h => hT <| ContinuousLinearMap.ext fun x =>
    by simpa using SetLike.ext_iff.mp h x

/-- If T ≠ 0, the closure of the range of T is not ⊥. -/
theorem range_closure_ne_bot_of_ne_zero {𝕜 : Type*} {H : Type*}
    [NontriviallyNormedField 𝕜] [NormedAddCommGroup H] [NormedSpace 𝕜 H]
    (T : H →L[𝕜] H) (hT : T ≠ 0) :
    (LinearMap.range (T : H →ₗ[𝕜] H)).topologicalClosure ≠ ⊥ := by
  contrapose! hT
  simp_all +decide [Submodule.eq_bot_iff]
  exact ContinuousLinearMap.ext fun x => hT _ (subset_closure <| Set.mem_range_self x)

/-! ## Nontrivial kernel gives nontrivial closed invariant subspace -/

/-
If a continuous linear map has a nontrivial kernel (neither ⊥ nor ⊤),
then the kernel is a nontrivial closed invariant subspace.
-/
theorem nontrivial_ker_gives_invariantSubspace {𝕜 : Type*} {H : Type*}
    [NontriviallyNormedField 𝕜] [NormedAddCommGroup H] [NormedSpace 𝕜 H]
    (T : H →L[𝕜] H)
    (hbot : LinearMap.ker (T : H →ₗ[𝕜] H) ≠ ⊥)
    (hT : T ≠ 0) :
    ∃ M : Submodule 𝕜 H,
      IsClosed (M : Set H) ∧ M ≠ ⊥ ∧ M ≠ ⊤ ∧ ∀ x ∈ M, T x ∈ M := by
  refine' ⟨ LinearMap.ker ( T : H →ₗ[𝕜] H ), _, _, _, _ ⟩;
  · exact?;
  · exact hbot;
  · exact?;
  · aesop

/-! ## Eigenvalue gives nontrivial closed invariant subspace -/

/-
The eigenspace of a continuous linear map on a complete normed space is closed.
-/
theorem eigenspace_isClosed {𝕜 : Type*} {H : Type*}
    [NontriviallyNormedField 𝕜] [NormedAddCommGroup H] [NormedSpace 𝕜 H]
    (T : H →L[𝕜] H) (μ : 𝕜) :
    IsClosed (Module.End.eigenspace (T : H →ₗ[𝕜] H) μ : Set H) := by
  convert ( ContinuousLinearMap.isClosed_ker ( T - μ • ContinuousLinearMap.id 𝕜 H ) );
  ext; simp +decide [ sub_eq_zero, Module.End.mem_eigenspace_iff ] ;

/-
If a continuous linear map has an eigenvalue, the eigenspace is a nontrivial
closed invariant subspace (provided it's not all of H).
-/
theorem eigenspace_nontrivial_of_hasEigenvalue {𝕜 : Type*} {H : Type*}
    [NontriviallyNormedField 𝕜] [NormedAddCommGroup H] [NormedSpace 𝕜 H]
    (T : H →L[𝕜] H) (μ : 𝕜)
    (hμ : Module.End.HasEigenvalue (T : H →ₗ[𝕜] H) μ)
    (hne_top : Module.End.eigenspace (T : H →ₗ[𝕜] H) μ ≠ ⊤) :
    ∃ M : Submodule 𝕜 H,
      IsClosed (M : Set H) ∧ M ≠ ⊥ ∧ M ≠ ⊤ ∧ ∀ x ∈ M, T x ∈ M := by
  refine' ⟨ End.eigenspace ( T : H →ₗ[𝕜] H ) μ, _, _, _, _ ⟩;
  · convert eigenspace_isClosed T μ;
  · exact?;
  · exact hne_top;
  · simp_all +decide [ Module.End.mem_eigenspace_iff ]

/-! ## The Riesz-Schauder theorem (stated as a key dependency)

The following is the **Riesz-Schauder spectral theorem** for compact operators.
This is a classical result in functional analysis that is not yet available in Mathlib.
It states that every nonzero compact operator on an infinite-dimensional Banach/Hilbert
space has a nonzero eigenvalue. This is the key missing ingredient for the full
compact operator invariant subspace theorem.

The proof would require:
1. The Fredholm alternative for compact operators
2. Riesz's lemma on approximate eigenvalues
3. The spectral theory of compact operators (spectrum is countable with 0 as the only
   possible accumulation point)
-/

/-- **Riesz-Schauder Spectral Theorem** (compact operator has nonzero eigenvalue).
A nonzero compact operator on an infinite-dimensional complex Hilbert space
has a nonzero eigenvalue.

*Status:* This is a classical theorem in functional analysis. Its proof requires
the Fredholm alternative and spectral theory for compact operators, which are
not yet formalized in Mathlib (v4.28.0). We state it here as the key missing
dependency for the compact operator invariant subspace theorem. -/
theorem compact_operator_has_nonzero_eigenvalue
    {H : Type*}
    [NormedAddCommGroup H]
    [InnerProductSpace ℂ H]
    [CompleteSpace H]
    (hInfDim : ¬ FiniteDimensional ℂ H)
    (T : H →L[ℂ] H)
    (hTcomp : IsCompactOperator T)
    (hTnonzero : T ≠ 0) :
    ∃ μ : ℂ, μ ≠ 0 ∧ Module.End.HasEigenvalue (T : H →ₗ[ℂ] H) μ := by
  sorry

/-
**Compact Operator Invariant Subspace Theorem.**
Every nonzero compact operator on an infinite-dimensional complex Hilbert space
has a nontrivial closed invariant subspace.

The proof uses the Riesz-Schauder theorem: a nonzero compact operator has a nonzero
eigenvalue μ. The eigenspace of μ is closed (as a kernel of a continuous map),
nontrivial (μ is an eigenvalue), and proper (if it were all of H, then T = μI,
but the identity is not compact on infinite-dimensional spaces when μ ≠ 0).
-/
theorem exists_nontrivial_closed_invariantSubspace_of_isCompact
    {H : Type*}
    [NormedAddCommGroup H]
    [InnerProductSpace ℂ H]
    [CompleteSpace H]
    (hInfDim : ¬ FiniteDimensional ℂ H)
    (T : H →L[ℂ] H)
    (hTcomp : IsCompactOperator T)
    (hTnonzero : T ≠ 0) :
    ∃ M : Submodule ℂ H,
      IsClosed (M : Set H) ∧
      M ≠ ⊥ ∧ M ≠ ⊤ ∧
      ∀ x ∈ M, T x ∈ M := by
  -- Use compact_operator_has_nonzero_eigenvalue to get nonzero eigenvalue μ.
  obtain ⟨μ, hμ⟩ : ∃ μ : ℂ, μ ≠ 0 ∧ Module.End.HasEigenvalue (T : H →ₗ[ℂ] H) μ := by
    exact?;
  refine' ⟨ Module.End.eigenspace ( T : H →ₗ[ℂ] H ) μ, _, _, _, _ ⟩;
  · convert eigenspace_isClosed T μ;
  · exact hμ.2;
  · contrapose! hInfDim;
    have h_contra : IsCompactOperator (μ • (1 : H →L[ℂ] H)) := by
      have h_contra : T = μ • (1 : H →L[ℂ] H) := by
        ext x; replace hInfDim := SetLike.ext_iff.mp hInfDim x; aesop;
      exact h_contra ▸ hTcomp;
    have h_contra : IsCompactOperator (1 : H →L[ℂ] H) := by
      convert h_contra.smul ( μ⁻¹ ) using 1 ; aesop;
    have := h_contra.isCompact_closure_image_closedBall 1;
    simp +zetaDelta at *;
    exact FiniteDimensional.of_isCompact_closedBall _ zero_lt_one this;
  · simp +contextual [ End.mem_eigenspace_iff, mul_comm μ ]