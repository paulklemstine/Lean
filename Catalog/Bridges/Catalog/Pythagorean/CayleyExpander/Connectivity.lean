/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Cayley Graph Connectivity from Generation

This file proves that if a symmetric set S generates a finite group G,
then the Cayley graph Cay(G, S) is connected: every pair of elements
is joined by a walk using generators from S.

This is the algebraic backbone that links group-theoretic generation
results to graph-theoretic and spectral properties.

## Main results

* `cayley_connected_of_closure_eq_top` — generation implies walk connectivity
* `word_in_generators_of_mem_closure` — elements of the closure are words in S
* `cayleyDirichletEnergy_zero_imp_generator_invariant` — zero energy implies
  invariance under each generator
* `cayleyDirichletEnergy_eq_zero_iff_constant` — zero energy iff constant (Theorem 2)
-/
import Mathlib
import Pythagorean.CayleyExpander.Defs

open Finset BigOperators

/-! ## Word reachability from generation -/

/-
Any element of the subgroup closure of S is representable as a product
    of elements from the symmetric set S.
-/
theorem word_in_generators_of_mem_closure
    {G : Type*} [Group G]
    (S : Finset G)
    (hSsymm : ∀ g ∈ S, g⁻¹ ∈ S)
    {g : G}
    (hg : g ∈ Subgroup.closure (↑S : Set G)) :
    ∃ l : List G, (∀ s, s ∈ l → s ∈ S) ∧ l.prod = g := by
  refine' Subgroup.closure_induction _ _ _ _ hg;
  · exact fun x hx => ⟨ [ x ], by simpa using hx ⟩;
  · exact ⟨ [ ], by simp +decide ⟩;
  · rintro x y hx hy ⟨ l₁, hl₁, rfl ⟩ ⟨ l₂, hl₂, rfl ⟩ ; exact ⟨ l₁ ++ l₂, by aesop ⟩;
  · rintro x hx ⟨ l, hl, rfl ⟩;
    refine' ⟨ l.reverse.map fun s => s⁻¹, _, _ ⟩ <;> simp_all +decide [ List.prod_inv_reverse ];
    exact fun s hs => by simpa using hSsymm _ ( hl _ hs ) ;

/-
**Theorem 1 (Cayley connectivity from generation)**:
    If S is a symmetric generating set for a finite group G,
    then for any x, y ∈ G there exists a walk in the generators
    connecting x to y. This is the algebraic backbone that converts
    `Subgroup.closure = ⊤` into a path-construction principle.
-/
theorem cayley_connected_of_closure_eq_top
    {G : Type*} [Fintype G] [Group G]
    (S : Finset G)
    (hSsymm : ∀ g ∈ S, g⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤) :
    ∀ x y : G, ∃ l : List G,
      (∀ s, s ∈ l → s ∈ S) ∧ l.prod * x = y := by
  intro x y
  obtain ⟨l, hl⟩ := word_in_generators_of_mem_closure S hSsymm (show y * x⁻¹ ∈ Subgroup.closure (S : Set G) from by
                                                                  aesop);
  exact ⟨ l, hl.1, by rw [ hl.2, mul_assoc, inv_mul_cancel, mul_one ] ⟩

/-! ## Dirichlet energy characterization -/

/-
Zero Dirichlet energy implies the function is invariant under
    each generator: f(s·x) = f(x) for all s ∈ S and x ∈ G.
-/
theorem cayleyDirichletEnergy_zero_imp_generator_invariant
    {G : Type*} [Fintype G] [Group G]
    (S : Finset G)
    (f : G → ℝ)
    (hE : cayleyDirichletEnergy S f = 0) :
    ∀ s ∈ S, ∀ x : G, f (s * x) = f x := by
  unfold cayleyDirichletEnergy at hE;
  rw [ Finset.sum_eq_zero_iff_of_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _ ] at hE;
  simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg, sq_nonneg, sub_eq_zero ]

/-
If f is invariant under each generator of a generating set,
    then f is constant.
-/
theorem constant_of_generator_invariant
    {G : Type*} [Fintype G] [Group G]
    (S : Finset G)
    (hSsymm : ∀ g ∈ S, g⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (f : G → ℝ)
    (hinv : ∀ s ∈ S, ∀ x : G, f (s * x) = f x) :
    ∃ c : ℝ, ∀ x : G, f x = c := by
  -- By `word_in_generators_of_mem_closure`, since `x ∈ closure S`, choose `l : List G`,
  -- `l.prod = x`, `∀ s, s ∈ l → s ∈ S`.
  have h_homogenize : ∀ x : G, ∃ l : List G, (∀ s, s ∈ l → s ∈ S) ∧ l.prod = x := by
    intro x
    apply word_in_generators_of_mem_closure S hSsymm
    exact hgen.symm ▸ Subgroup.mem_top x;
  use f 1;
  intro x; obtain ⟨ l, hlS, rfl ⟩ := h_homogenize x; induction l <;> simp_all +decide ;

/-- **Theorem 2 (Zero-energy characterization)**:
    For a symmetric generating set S of a finite group G,
    the Dirichlet energy E_S(f) = 0 iff f is constant.

    This is the formalized principle that *connectivity kills
    nontrivial harmonic defects*. It is the finite-group analogue
    of ergodicity implying uniqueness of equilibrium. -/
theorem cayleyDirichletEnergy_eq_zero_iff_constant
    {G : Type*} [Fintype G] [Group G]
    (S : Finset G)
    (hSsymm : ∀ g ∈ S, g⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (f : G → ℝ) :
    cayleyDirichletEnergy S f = 0 ↔ ∃ c : ℝ, ∀ x : G, f x = c := by
  constructor
  · intro hE
    exact constant_of_generator_invariant S hSsymm hgen f
      (cayleyDirichletEnergy_zero_imp_generator_invariant S f hE)
  · rintro ⟨c, hc⟩
    have : f = fun _ => c := funext hc
    rw [this]
    exact cayleyDirichletEnergy_const S c