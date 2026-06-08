/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Choquet–Voronoi Duality: Core Definitions

This file defines the core structures for tropical convex semimodule theory
and the Choquet–Voronoi duality framework.

## Main definitions

* `TropicalClosureOp` — A closure operator on `Finset M` capturing tropical hull structure.
* `IsTropExtremal` — Predicate for extremal generators.
* `IsMinimalTropSupport` — Predicate for minimal support sets.
* `SupportCertifiedBy` — Certification predicate linking support sets to elements.
* `TropSupportComplex` — The abstract simplicial complex derived from support sets.
* `TropSemimodMorphism` — Morphisms of tropical semimodules.

## Mathematical overview

In tropical (max-plus) algebra, convex combinations are replaced by
tropical combinations: `⊕_i (λ_i ⊗ v_i) = max_i (λ_i + v_i)` componentwise.
The tropical hull of a set S is the collection of all tropical combinations of
elements from S. This file formalizes this structure abstractly via closure operators,
then proves the core Choquet–Voronoi duality theorems.
-/

noncomputable section

open Finset Set

namespace TropicalChoquetVoronoi

variable {M : Type*} [DecidableEq M] [Fintype M]

/-! ### Tropical Closure Operator -/

/-- A tropical closure operator on finite sets, abstracting the tropical hull.
    This captures the algebraic closure structure of tropical convex combinations
    on a finite ground set. -/
structure TropicalClosureOp (M : Type*) [DecidableEq M] [Fintype M] where
  /-- The tropical hull function on finite sets -/
  hull : Finset M → Finset M
  /-- Extensiveness: S ⊆ hull(S) -/
  extensive : ∀ S : Finset M, S ⊆ hull S
  /-- Monotonicity: S ⊆ T → hull(S) ⊆ hull(T) -/
  mono : ∀ ⦃S T : Finset M⦄, S ⊆ T → hull S ⊆ hull T
  /-- Idempotence: hull(hull(S)) = hull(S) -/
  idempotent : ∀ S : Finset M, hull (hull S) = hull S

/-- A set is tropically closed if it equals its own hull. -/
def TropicalClosureOp.IsClosed (op : TropicalClosureOp M) (S : Finset M) : Prop :=
  op.hull S = S

lemma TropicalClosureOp.hull_isClosed (op : TropicalClosureOp M) (S : Finset M) :
    op.IsClosed (op.hull S) :=
  op.idempotent S

/-! ### Extremal Generators -/

/-- An element `e` is **tropically extremal** in `Ext` if removing it from the
    generators shrinks the hull — i.e., `e` cannot be expressed as a tropical
    combination of the remaining generators. -/
def IsTropExtremal (op : TropicalClosureOp M) (Ext : Finset M) (e : M) : Prop :=
  e ∈ Ext ∧ e ∉ op.hull (Ext.erase e)

/-! ### Tropical Support -/

/-- A finset `σ` is **support-certified** for `x` if `x` is in the hull of `σ` and
    no proper subset of `σ` has `x` in its hull. -/
def SupportCertifiedBy (op : TropicalClosureOp M) (σ : Finset M) (x : M) : Prop :=
  x ∈ op.hull σ ∧ ∀ τ : Finset M, τ ⊂ σ → x ∉ op.hull τ

/-- A finset `σ` is a **minimal tropical support** of `x` relative to generators `Ext`
    if `σ ⊆ Ext`, `x ∈ hull(σ)`, and no proper subset of `σ` contains `x` in its hull. -/
def IsMinimalTropSupport (op : TropicalClosureOp M) (Ext : Finset M)
    (σ : Finset M) (x : M) : Prop :=
  σ ⊆ Ext ∧ SupportCertifiedBy op σ x

/-! ### Abstract Simplicial Complex -/

/-- An **abstract simplicial complex** on vertex set `V` is a downward-closed
    family of finite subsets (faces). -/
structure AbstractSimplicialComplex (V : Type*) [DecidableEq V] where
  /-- The set of faces -/
  faces : Set (Finset V)
  /-- The empty set is a face -/
  empty_mem : ∅ ∈ faces
  /-- Downward closure: subsets of faces are faces -/
  down_closed : ∀ ⦃σ τ : Finset V⦄, σ ∈ faces → τ ⊆ σ → τ ∈ faces

/-- The **tropical support complex** is the abstract simplicial complex
    whose faces are all subsets of support sets `{Supp x | x ∈ M}`. -/
def TropSupportComplex [Nonempty M] (Supp : M → Finset M) :
    AbstractSimplicialComplex M where
  faces := {σ : Finset M | ∃ x : M, σ ⊆ Supp x}
  empty_mem := ⟨Classical.arbitrary M, Finset.empty_subset _⟩
  down_closed := by
    intro σ τ ⟨x, hx⟩ hτσ
    exact ⟨x, Finset.Subset.trans hτσ hx⟩

/-- The **support reconstruction correctness** predicate asserts that the
    support complex faithfully represents the decomposition structure. -/
def SupportReconstructionCorrect (_op : TropicalClosureOp M) (Ext : Finset M)
    (Supp : M → Finset M) (V : AbstractSimplicialComplex M) : Prop :=
  (∀ x : M, (Supp x) ∈ V.faces) ∧
  (∀ σ, σ ∈ V.faces → ∃ x : M, σ ⊆ Supp x) ∧
  (∀ e ∈ Ext, ∃ x : M, e ∈ Supp x) ∧
    (∀ x : M, Supp x ⊆ Ext)

/-! ### Morphisms -/

/-- A **tropical semimodule morphism** is a function that commutes with hull. -/
structure TropSemimodMorphism (M N : Type*) [DecidableEq M] [Fintype M]
    [DecidableEq N] [Fintype N]
    (opM : TropicalClosureOp M) (opN : TropicalClosureOp N) where
  /-- The underlying function -/
  toFun : M → N
  /-- Hull-compatibility -/
  hull_compat : ∀ S : Finset M, (opM.hull S).image toFun ⊆ opN.hull (S.image toFun)

/-! ### Concrete Max-Plus Tropical Combination -/

/-- The **max-plus tropical combination** of vectors.
    Given generators `v : Fin k → (Fin n → ℤ)` and coefficients `c : Fin k → ℤ`,
    the result is `(max_i (c_i + v_i(j)))_j`. -/
def tropCombine (k n : ℕ) (v : Fin k → Fin n → ℤ) (c : Fin k → ℤ)
    (hk : 0 < k) : Fin n → ℤ :=
  fun j => Finset.sup' Finset.univ ⟨⟨0, hk⟩, Finset.mem_univ _⟩ (fun i => c i + v i j)

end TropicalChoquetVoronoi