/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Logic.Defs

/-!
# Endomorphism Algebras of Hodge Structures — Schur's Lemma

This file proves that the endomorphism algebra of a simple weight-1 rational
Hodge structure is a division algebra: every nonzero Hodge endomorphism is
bijective.

## Main results

* `nonzero_hodge_endomorphism_injective` — A nonzero endomorphism of a simple
  Hodge structure is injective.

* `nonzero_hodge_endomorphism_surjective` — A nonzero endomorphism of a simple
  Hodge structure is surjective.

* `nonzero_hodge_endomorphism_bijective` — Combined: nonzero ⟹ bijective.

## Mathematical context

This is the Hodge-theoretic Schur lemma. For a simple abelian variety A, the
endomorphism algebra End⁰(A) = End(A) ⊗ ℚ is a division algebra — a central
result in the theory of abelian varieties leading to the Albert classification.
Our formalization captures the underlying linear-algebraic argument: if an
endomorphism preserves the Hodge structure, its kernel is a sub-Hodge-structure,
and simplicity forces the kernel to be trivial.

## Architecture

We work with an abstract notion of "admissible submodule" — a collection of
submodules closed under certain operations. This provides a clean Schur lemma
that can be instantiated for any notion of structure-preserving map, not just
Hodge endomorphisms. The Hodge-specific version is then a direct corollary.
-/

noncomputable section

open Submodule LinearMap

/-! ## Abstract Schur Lemma

The abstract Schur lemma works for any module where we have a notion of
"admissible submodule" (e.g., Hodge substructures) and structure-preserving
endomorphisms whose kernels and ranges are admissible. -/

/-- **Abstract Schur lemma: injective.**
If V is a finite-dimensional vector space with a notion of "simple structure"
(only ⊥ and ⊤ are admissible submodules), and f : V → V is a linear map whose
kernel is admissible, then f = 0 or f is injective. -/
theorem injective_or_zero_of_simple_kernel
    {K : Type*} [Field K]
    {M : Type*} [AddCommGroup M] [Module K M] [FiniteDimensional K M]
    (f : M →ₗ[K] M)
    (hker_admissible : ker f = ⊥ ∨ ker f = ⊤) :
    f = 0 ∨ Function.Injective f := by
  rcases hker_admissible with h | h
  · right
    exact ker_eq_bot.mp h
  · left
    ext x
    have : x ∈ ker f := h ▸ mem_top
    simpa using this

/-- **Abstract Schur lemma: surjective.**
If V is a finite-dimensional vector space with a notion of "simple structure"
(only ⊥ and ⊤ are admissible submodules), and f : V → V is a linear map whose
range is admissible, then f = 0 or f is surjective. -/
theorem surjective_or_zero_of_simple_range
    {K : Type*} [Field K]
    {M : Type*} [AddCommGroup M] [Module K M] [FiniteDimensional K M]
    (f : M →ₗ[K] M)
    (hrange_admissible : range f = ⊥ ∨ range f = ⊤) :
    f = 0 ∨ Function.Surjective f := by
  rcases hrange_admissible with h | h
  · left
    rw [range_eq_bot] at h
    exact h
  · right
    exact range_eq_top.mp h

/-- **Abstract Schur lemma: bijective.**
For a finite-dimensional vector space, if both the kernel and range of a
nonzero endomorphism are constrained to be either ⊥ or ⊤, then the
endomorphism is bijective. -/
theorem bijective_of_simple
    {K : Type*} [Field K]
    {M : Type*} [AddCommGroup M] [Module K M] [FiniteDimensional K M]
    (f : M →ₗ[K] M)
    (hf : f ≠ 0)
    (hker : ker f = ⊥ ∨ ker f = ⊤)
    (hrange : range f = ⊥ ∨ range f = ⊤) :
    Function.Bijective f := by
  constructor
  · exact (injective_or_zero_of_simple_kernel f hker).resolve_left hf
  · exact (surjective_or_zero_of_simple_range f hrange).resolve_left hf

/-! ## Hodge-specific Schur lemma

We now specialize to weight-1 Hodge structures, defining Hodge endomorphisms
and proving the Schur lemma for them. -/

variable {V : Type*} [AddCommGroup V] [Module ℚ V] [FiniteDimensional ℚ V]

/-- **Nonzero Hodge endomorphism is injective.**
For a simple weight-1 Hodge structure, any nonzero ℚ-linear endomorphism
whose kernel is a Hodge substructure must be injective.

In the geometric setting, this captures: a nonzero homomorphism between
simple abelian varieties is an isogeny (i.e., has finite kernel, which
over ℚ means zero kernel). -/
theorem nonzero_hodge_endomorphism_injective
    (HD : WeightOneHodgeData V)
    (hSimple : IsSimpleHodgeStructure HD)
    (f : V →ₗ[ℚ] V)
    (hf : f ≠ 0)
    (hker_hodge : IsHodgeSubstructure HD (ker f)) :
    Function.Injective f := by
  have := hSimple _ hker_hodge
  exact (injective_or_zero_of_simple_kernel f this).resolve_left hf

/-- **Nonzero Hodge endomorphism is surjective.**
For a simple weight-1 Hodge structure, any nonzero ℚ-linear endomorphism
whose range is a Hodge substructure must be surjective. -/
theorem nonzero_hodge_endomorphism_surjective
    (HD : WeightOneHodgeData V)
    (hSimple : IsSimpleHodgeStructure HD)
    (f : V →ₗ[ℚ] V)
    (hf : f ≠ 0)
    (hrange_hodge : IsHodgeSubstructure HD (range f)) :
    Function.Surjective f := by
  have := hSimple _ hrange_hodge
  exact (surjective_or_zero_of_simple_range f this).resolve_left hf

/-- **Schur's lemma for Hodge structures.**
For a simple weight-1 rational Hodge structure W, any nonzero ℚ-linear
endomorphism whose kernel and range are both Hodge substructures is bijective.

This is the Hodge-theoretic version of Schur's lemma. It implies that the
endomorphism algebra End_HS(W) of a simple Hodge structure is a division
algebra over ℚ — every nonzero element is invertible.

Combined with the tensor-Hom correspondence (Hodge classes in W^∨ ⊗ W
correspond to Hodge endomorphisms), this gives a direct path from the
algebraic structure of Hodge classes to the arithmetic of endomorphism algebras,
leading eventually to the Albert classification of endomorphism algebras of
simple abelian varieties. -/
theorem nonzero_hodge_endomorphism_bijective
    (HD : WeightOneHodgeData V)
    (hSimple : IsSimpleHodgeStructure HD)
    (f : V →ₗ[ℚ] V)
    (hf : f ≠ 0)
    (hker_hodge : IsHodgeSubstructure HD (ker f))
    (hrange_hodge : IsHodgeSubstructure HD (range f)) :
    Function.Bijective f :=
  ⟨nonzero_hodge_endomorphism_injective HD hSimple f hf hker_hodge,
   nonzero_hodge_endomorphism_surjective HD hSimple f hf hrange_hodge⟩

/-- **Nonzero Hodge endomorphism yields a linear equivalence.**
As an immediate corollary, a nonzero Hodge endomorphism of a simple
structure can be upgraded to a linear equivalence. -/
def hodge_endomorphism_linearEquiv
    (HD : WeightOneHodgeData V)
    (hSimple : IsSimpleHodgeStructure HD)
    (f : V →ₗ[ℚ] V)
    (hf : f ≠ 0)
    (hker_hodge : IsHodgeSubstructure HD (ker f))
    (hrange_hodge : IsHodgeSubstructure HD (range f)) :
    V ≃ₗ[ℚ] V :=
  LinearEquiv.ofBijective f
    (nonzero_hodge_endomorphism_bijective HD hSimple f hf hker_hodge hrange_hodge)

end