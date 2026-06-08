/-
Copyright (c) 2025 Harmonic. All rights reserved.

# Orbit Cost: Triangle inequality for symmetry-reduced transport costs

## Overview

Given a cost function `Wc : α → α → ℝ` satisfying a triangle inequality, and a group `G`
acting on `α` by `Wc`-isometries, define the **orbit cost**:

  `orbitCost Wc μ ν := ⨅_{g ∈ G} Wc(μ, g • ν)`

We prove that this quotient cost again satisfies a triangle inequality.

The proof is driven by **composability of near-optimal alignments**: if `g₁` nearly aligns
`ν` to `μ` and `g₂` nearly aligns `ρ` to `ν`, then `g₁ * g₂` nearly aligns `ρ` to `μ`.

## Mathematical significance

This theorem establishes a general **descent principle**: triangle inequalities descend
through isometric group quotienting. It is the formal seed for:
- quotient optimal transport / symmetry-reduced Wasserstein geometry,
- orbit pseudometrics and moduli-space geometry,
- equivariant metric learning with certified metric structure,
- canonicalization-free comparison of structured objects (graphs, point clouds, molecules).
-/

import Mathlib

namespace OrbitCost

/-! ## Definition of orbit cost -/

/-- The **orbit cost** of two elements `μ` and `ν` under a group action is the infimum
of `Wc μ (g • ν)` over all group elements `g : G`. This quotients out the symmetry
of the group action, producing a cost that is invariant under the action on the
second argument. -/
noncomputable def orbitCost
    (G : Type*) {α : Type*} [Group G] [MulAction G α]
    (Wc : α → α → ℝ) (μ ν : α) : ℝ :=
  iInf (fun (g : G) => Wc μ (g • ν))

/-! ## Helper lemmas -/

/-
The orbit cost is at most the cost for any specific group element.
-/
theorem orbitCost_le_candidate
    (G : Type*) {α : Type*} [Group G] [MulAction G α]
    (Wc : α → α → ℝ) (μ ν : α) (g : G)
    (hbd : BddBelow (Set.range fun (g : G) => Wc μ (g • ν))) :
    orbitCost G Wc μ ν ≤ Wc μ (g • ν) := by
  exact ciInf_le hbd g

/-
**Composition lemma** (the algebraic heart):
  `Wc μ ((g₁ * g₂) • ρ) ≤ Wc μ (g₁ • ν) + Wc ν (g₂ • ρ)`.

This works by using the triangle inequality with midpoint `g₁ • ν`, then rewriting
`Wc (g₁ • ν) ((g₁ * g₂) • ρ)` via invariance as `Wc ν (g₂ • ρ)`.
-/
theorem comp_candidate_bound
    {G α : Type*} [Group G] [MulAction G α]
    (Wc : α → α → ℝ)
    (htri : ∀ x y z : α, Wc x z ≤ Wc x y + Wc y z)
    (hinv : ∀ (x y : α) (g : G), Wc (g • x) (g • y) = Wc x y)
    (μ ν ρ : α) (g₁ g₂ : G) :
    Wc μ ((g₁ * g₂) • ρ) ≤ Wc μ (g₁ • ν) + Wc ν (g₂ • ρ) := by
  convert htri μ ( g₁ • ν ) ( ( g₁ * g₂ ) • ρ ) using 1;
  simp +decide [ mul_smul, hinv ]

/-
For any `ε > 0`, there exists a group element `g` achieving cost within `ε`
of the orbit cost (ε-near-minimizer).
-/
theorem exists_near_minimizer
    (G : Type*) {α : Type*} [Group G] [MulAction G α]
    (Wc : α → α → ℝ) (μ ν : α) :
    ∀ ε : ℝ, 0 < ε → ∃ g : G, Wc μ (g • ν) < orbitCost G Wc μ ν + ε := by
  intro ε hε;
  convert exists_lt_of_ciInf_lt ( show InfSet.sInf ( Set.range fun g : G => Wc μ ( g • ν ) ) < InfSet.sInf ( Set.range fun g : G => Wc μ ( g • ν ) ) + ε from lt_add_of_pos_right _ hε ) using 1

/-! ## Main theorem -/

/-
**Orbit-cost triangle inequality.**

If `Wc` satisfies a triangle inequality and `G` acts by `Wc`-isometries, then the
orbit cost `orbitCost Wc` also satisfies a triangle inequality:

  `orbitCost Wc μ ρ ≤ orbitCost Wc μ ν + orbitCost Wc ν ρ`

The proof uses ε-near-optimal witnesses and the composition lemma.
-/
theorem orbitCost_triangle
    (G : Type*) {α : Type*} [Group G] [MulAction G α]
    (Wc : α → α → ℝ)
    (htri : ∀ x y z : α, Wc x z ≤ Wc x y + Wc y z)
    (hinv : ∀ (x y : α) (g : G), Wc (g • x) (g • y) = Wc x y)
    (hbd : ∀ μ ν : α, BddBelow (Set.range fun (g : G) => Wc μ (g • ν))) :
    ∀ μ ν ρ : α, orbitCost G Wc μ ρ ≤ orbitCost G Wc μ ν + orbitCost G Wc ν ρ := by
  intro μ ν ρ;
  refine' le_of_forall_pos_le_add fun ε εpos => _;
  -- Use the existence of near-optimal witnesses to find $g₁$ and $g₂$ such that $Wc μ (g₁ • ν) < orbitCost G Wc μ ν + ε / 2$ and $Wc ν (g₂ • ρ) < orbitCost G Wc ν ρ + ε / 2$.
  obtain ⟨g₁, hg₁⟩ : ∃ g₁ : G, Wc μ (g₁ • ν) < orbitCost G Wc μ ν + ε / 2 := by
    exact exists_near_minimizer G Wc μ ν ( ε / 2 ) ( half_pos εpos )
  obtain ⟨g₂, hg₂⟩ : ∃ g₂ : G, Wc ν (g₂ • ρ) < orbitCost G Wc ν ρ + ε / 2 := by
    exact exists_near_minimizer G Wc ν ρ ( ε / 2 ) ( half_pos εpos );
  refine' le_trans ( orbitCost_le_candidate G Wc μ ρ ( g₁ * g₂ ) ( hbd μ ρ ) ) _;
  linarith [ comp_candidate_bound Wc htri hinv μ ν ρ g₁ g₂ ]

/-! ## Concrete instantiation: finite group action -/

/-
For finite groups, the orbit cost range is automatically bounded below.
-/
theorem orbitCost_bddBelow_of_fintype
    (G : Type*) {α : Type*} [Group G] [Fintype G] [MulAction G α]
    (Wc : α → α → ℝ) (μ ν : α) :
    BddBelow (Set.range fun (g : G) => Wc μ (g • ν)) := by
  exact Set.finite_range _ |> Set.Finite.bddBelow

/-
**Triangle inequality for orbit cost under finite group actions.**
This version eliminates the `BddBelow` hypothesis entirely.
-/
theorem orbitCost_triangle_fintype
    (G : Type*) {α : Type*} [Group G] [Fintype G] [MulAction G α]
    (Wc : α → α → ℝ)
    (htri : ∀ x y z : α, Wc x z ≤ Wc x y + Wc y z)
    (hinv : ∀ (x y : α) (g : G), Wc (g • x) (g • y) = Wc x y) :
    ∀ μ ν ρ : α, orbitCost G Wc μ ρ ≤ orbitCost G Wc μ ν + orbitCost G Wc ν ρ := by
  apply orbitCost_triangle;
  · exact htri;
  · exact hinv;
  · exact fun μ ν => Set.finite_range _ |> Set.Finite.bddBelow

/-! ## Orbit cost equivariance properties -/

/-
The orbit cost is invariant under the group action on the second argument.
-/
theorem orbitCost_smul_right
    (G : Type*) {α : Type*} [Group G] [MulAction G α]
    (Wc : α → α → ℝ) (μ ν : α) (h : G) :
    orbitCost G Wc μ (h • ν) = orbitCost G Wc μ ν := by
  unfold orbitCost
  rw [← Equiv.iInf_comp (Equiv.mulRight h)]
  simp +decide [← mul_smul]
  exact Equiv.iInf_congr (Equiv.mulRight (h * h)) fun g => by simp +decide [mul_assoc]

/-! ## Pseudometric structure -/

/-
If `Wc` is reflexive and nonnegative, then `orbitCost Wc μ μ = 0`.
-/
theorem orbitCost_self
    (G : Type*) {α : Type*} [Group G] [MulAction G α]
    (Wc : α → α → ℝ) (μ : α)
    (hrefl : ∀ x : α, Wc x x = 0)
    (hnn : ∀ x y : α, 0 ≤ Wc x y)
    (hbd : BddBelow (Set.range fun (g : G) => Wc μ (g • μ))) :
    orbitCost G Wc μ μ = 0 := by
  exact le_antisymm ( ciInf_le hbd 1 |> le_trans <| by simp +decide [ hrefl ] ) ( le_ciInf fun g => hnn _ _ )

end OrbitCost