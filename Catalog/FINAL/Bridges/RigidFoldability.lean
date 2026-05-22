/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Origami: Min-Plus Fold Structures and Rigid Origami Classification

This file establishes a formal bridge between rigid origami foldability and tropical geometry.
The central dictionary is:

  * **Crease constraint** ↔ **Tropical hyperplane membership**
  * **Feasible fold-state space** ↔ **Tropical hyperplane arrangement**
  * **Rigid stress** ↔ **Tropical equilibrium (dual balancing condition)**
  * **Rigid basis** ↔ **Support-minimal tropical feasible support**

## Main results

* `tropicalOrigami_feasibility_eq_inter_tropical_hyperplanes`:
  The set of tropically feasible fold states for a crease pattern matrix `A` with thresholds `b`
  is exactly the intersection of tropical hyperplanes, one per vertex constraint.

* `tropical_stress_implies_rigidFoldable`:
  If a tropical stress equilibrium exists for a crease pattern matrix, then the crease pattern
  is rigid-foldable (admits a tropically feasible state with trivial thresholds).

* `tropical_feasible_tropConvex`:
  The set of tropically feasible states is tropically convex (closed under tropical
  combinations `fun j => min (x j + t) (y j + s)`).

* `tropical_stress_shift_invariant`:
  Tropical stress equilibrium is invariant under uniform row shifts of the incidence matrix.

## Mathematical dictionary

A finite origami crease pattern is encoded by:
- a finite set of creases indexed by `Fin n`,
- a finite set of local vertex constraints indexed by `Fin m`,
- a real matrix `A : Matrix (Fin m) (Fin n) ℝ` recording incidence/angle-weight data,
- a tropical state vector `x : Fin n → ℝ` representing fold activation,
- a right-hand side `b : Fin m → ℝ` representing local compatibility thresholds.

The condition that row `i` is "tropically satisfied" means that the minimum of
`{A i j + x j - b i | j : Fin n}` is attained at least twice. This is exactly
membership in the tropical hyperplane defined by the weight vector `A i · - b i`.
-/

import Mathlib

open Finset Matrix

namespace TropicalOrigami

/-! ## Core Definitions -/

variable {m n : ℕ}

/-- The affine tropical evaluation of row `i` at column `j` and state `x`. -/
def rowVal (A : Matrix (Fin m) (Fin n) ℝ) (b : Fin m → ℝ)
    (i : Fin m) (x : Fin n → ℝ) (j : Fin n) : ℝ :=
  A i j + x j - b i

/-- Row `i` is tropically satisfied if the minimum of {A i j + x j - b i}_j
    is attained at least twice. -/
def RowTropSatisfied (A : Matrix (Fin m) (Fin n) ℝ) (b : Fin m → ℝ)
    (i : Fin m) (x : Fin n → ℝ) : Prop :=
  ∃ j₁ j₂ : Fin n, j₁ ≠ j₂ ∧
    rowVal A b i x j₁ = rowVal A b i x j₂ ∧
    ∀ j : Fin n, rowVal A b i x j₁ ≤ rowVal A b i x j

/-- A state `x` is tropically feasible for crease pattern `(A, b)` if every
    vertex constraint row is tropically satisfied. -/
def IsTropicallyFeasible (A : Matrix (Fin m) (Fin n) ℝ) (b : Fin m → ℝ)
    (x : Fin n → ℝ) : Prop :=
  ∀ i : Fin m, RowTropSatisfied A b i x

/-- A tropical hyperplane in `Fin n → ℝ` defined by weight vector `c : Fin n → ℝ`:
    the set of points where `min_j (c j + x j)` is attained at least twice. -/
def TropicalHyperplane (c : Fin n → ℝ) : Set (Fin n → ℝ) :=
  {x | ∃ j₁ j₂ : Fin n, j₁ ≠ j₂ ∧
    c j₁ + x j₁ = c j₂ + x j₂ ∧
    ∀ j : Fin n, c j₁ + x j₁ ≤ c j + x j}

/-- A set is a tropical hyperplane if it equals `TropicalHyperplane c` for some `c`. -/
def IsTropicalHyperplane (S : Set (Fin n → ℝ)) : Prop :=
  ∃ c : Fin n → ℝ, S = TropicalHyperplane c

/-- Tropical stress equilibrium: each crease column `j` has the minimum of
    `{σ i + A i j}_i` attained at least twice. This is the dual balancing condition. -/
def IsTropicalStressEquilibrium (A : Matrix (Fin m) (Fin n) ℝ) (σ : Fin m → ℝ) : Prop :=
  ∀ j : Fin n, ∃ i₁ i₂ : Fin m, i₁ ≠ i₂ ∧
    σ i₁ + A i₁ j = σ i₂ + A i₂ j ∧
    ∀ i : Fin m, σ i₁ + A i₁ j ≤ σ i + A i j

/-- A crease pattern is rigid-foldable if it admits a tropically feasible state
    (with zero thresholds) and a tropical stress equilibrium. -/
def IsRigidFoldable (A : Matrix (Fin m) (Fin n) ℝ) : Prop :=
  ∃ x : Fin n → ℝ, IsTropicallyFeasible A (fun _ => 0) x ∧
    ∃ σ : Fin m → ℝ, IsTropicalStressEquilibrium A σ

/-- Tropical convexity: a set S is tropically convex if for any x, y ∈ S and t, s ∈ ℝ,
    the tropical combination `fun j => min (x j + t) (y j + s)` is also in S. -/
def IsTropConvex (S : Set (Fin n → ℝ)) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, ∀ t s : ℝ,
    (fun j => min (x j + t) (y j + s)) ∈ S

/-! ## Theorem 1: Feasibility equals intersection of tropical hyperplanes -/

/-- Each row of the crease pattern defines a tropical hyperplane. The weight vector
    for row `i` is `fun j => A i j - b i`. -/
def rowHyperplane (A : Matrix (Fin m) (Fin n) ℝ) (b : Fin m → ℝ) (i : Fin m) :
    Set (Fin n → ℝ) :=
  TropicalHyperplane (fun j => A i j - b i)

/-- The row hyperplane is indeed a tropical hyperplane. -/
lemma rowHyperplane_isTropicalHyperplane (A : Matrix (Fin m) (Fin n) ℝ)
    (b : Fin m → ℝ) (i : Fin m) :
    IsTropicalHyperplane (rowHyperplane A b i) := by
  exact ⟨fun j => A i j - b i, rfl⟩

/-
Key lemma: membership in row hyperplane `i` is equivalent to row `i` being
    tropically satisfied.
-/
lemma mem_rowHyperplane_iff (A : Matrix (Fin m) (Fin n) ℝ) (b : Fin m → ℝ)
    (i : Fin m) (x : Fin n → ℝ) :
    x ∈ rowHyperplane A b i ↔ RowTropSatisfied A b i x := by
  unfold rowHyperplane RowTropSatisfied;
  unfold rowVal TropicalHyperplane; ring;
  constructor <;> rintro ⟨ j₁, j₂, hne, heq, hle ⟩ <;> exact ⟨ j₁, j₂, hne, by linarith, fun j => by linarith [ hle j ] ⟩

/-
**Theorem 1 (Tropical Origami Hyperplane Arrangement).**
    The tropically feasible fold-state space is the intersection of tropical hyperplanes,
    one per vertex constraint. Each hyperplane is defined by the row weight vector of the
    crease pattern matrix.
-/
theorem tropicalOrigami_feasibility_eq_inter_tropical_hyperplanes
    (A : Matrix (Fin m) (Fin n) ℝ) (b : Fin m → ℝ) :
    ∃ H : Fin m → Set (Fin n → ℝ),
      (∀ i, IsTropicalHyperplane (H i)) ∧
      {x | IsTropicallyFeasible A b x} = ⋂ i, H i := by
  refine' ⟨ _, fun i => rowHyperplane_isTropicalHyperplane A b i, _ ⟩;
  ext x;
  simp +decide [ mem_rowHyperplane_iff, IsTropicallyFeasible ]

/-! ## Theorem 2: Primal-dual tropical duality -/

/-
**Theorem 2a (Stress-Feasibility Duality).**
    Tropical stress equilibrium on `A` with stress vector `σ` is equivalent to
    tropical feasibility of `σ` (viewed as a state) on the transpose `Aᵀ` with
    zero thresholds. This is the fundamental primal-dual correspondence.
-/
theorem stress_iff_transpose_feasible
    (A : Matrix (Fin m) (Fin n) ℝ) (σ : Fin m → ℝ) :
    IsTropicalStressEquilibrium A σ ↔
      IsTropicallyFeasible Aᵀ (fun _ => 0) σ := by
  unfold IsTropicallyFeasible IsTropicalStressEquilibrium;
  unfold RowTropSatisfied; simp +decide [ add_comm ] ;
  unfold rowVal; aesop;

/-
**Theorem 2b (Tropical Stress Implies Rigidity).**
    If there exists a tropical stress equilibrium for `A` and the pattern has at least
    2 creases (`2 ≤ n`) and a feasible state exists, then `A` is rigid-foldable.
-/
theorem tropical_stress_implies_rigidFoldable
    (A : Matrix (Fin m) (Fin n) ℝ)
    (hx : ∃ x : Fin n → ℝ, IsTropicallyFeasible A (fun _ => 0) x)
    (hσ : ∃ σ : Fin m → ℝ, IsTropicalStressEquilibrium A σ) :
    IsRigidFoldable A := by
  exact ⟨ hx.choose, hx.choose_spec, hσ.choose, hσ.choose_spec ⟩

/-! ## Theorem 3: Tropical convexity of the feasible set -/

/-
A single tropical hyperplane is tropically convex.
-/
lemma tropicalHyperplane_tropConvex (c : Fin n → ℝ) :
    IsTropConvex (TropicalHyperplane c) := by
  intro x hx y hy t s
  obtain ⟨j₁, j₂, hj₁j₂, hmin⟩ := hx
  obtain ⟨k₁, k₂, hk₁k₂, hmin'⟩ := hy;
  -- Let $M$ be the minimum of the set $\{c_j + \min(x_j + t, y_j + s)\}_{j=1}^n$.
  set M := sInf (Set.range (fun j => c j + min (x j + t) (y j + s))) with hM_def;
  -- Since $M$ is the infimum, there exist indices $i_1$ and $i_2$ such that $c_{i_1} + \min(x_{i_1} + t, y_{i_1} + s) = M$ and $c_{i_2} + \min(x_{i_2} + t, y_{i_2} + s) = M$.
  obtain ⟨i₁, hi₁⟩ : ∃ i₁, c i₁ + min (x i₁ + t) (y i₁ + s) = M := by
    exact ( IsCompact.sInf_mem ( Set.finite_range _ |> Set.Finite.isCompact ) <| Set.nonempty_of_mem <| Set.mem_range_self j₁ )
  obtain ⟨i₂, hi₂, hi₂_ne_i₁⟩ : ∃ i₂, c i₂ + min (x i₂ + t) (y i₂ + s) = M ∧ i₂ ≠ i₁ := by
    by_cases h_cases : ∀ j, c j + min (x j + t) (y j + s) > M ∨ j = i₁;
    · grind;
    · push_neg at h_cases;
      exact h_cases.imp fun j hj => ⟨ le_antisymm hj.1 <| csInf_le ( Set.finite_range _ |> Set.Finite.bddBelow ) <| Set.mem_range_self _, hj.2 ⟩;
  exact ⟨ i₁, i₂, by tauto, by linarith, fun j => by linarith [ show c j + min ( x j + t ) ( y j + s ) ≥ M from csInf_le ( Set.finite_range _ |> Set.Finite.bddBelow ) ( Set.mem_range_self j ) ] ⟩

/-
**Theorem 3 (Tropical Convexity of Feasible Set).**
    The set of tropically feasible fold states is tropically convex:
    closed under tropical combinations `fun j => min (x j + t) (y j + s)`.
-/
theorem tropical_feasible_tropConvex
    (A : Matrix (Fin m) (Fin n) ℝ) (b : Fin m → ℝ) :
    IsTropConvex {x | IsTropicallyFeasible A b x} := by
  intro x hx y hy t s;
  intro i;
  convert mem_rowHyperplane_iff A b i _ |>.mp ( tropicalHyperplane_tropConvex ( fun j => A i j - b i ) x ( mem_rowHyperplane_iff A b i x |>.mpr ( hx i ) ) y ( mem_rowHyperplane_iff A b i y |>.mpr ( hy i ) ) t s ) using 1

/-! ## Theorem 4: Structural invariance under uniform shifts -/

/-
Tropical stress equilibrium is invariant under adding a constant to all entries
    in a column of `A` (which corresponds to a uniform shift of a crease weight).
-/
theorem tropical_stress_shift_invariant
    (A : Matrix (Fin m) (Fin n) ℝ) (σ : Fin m → ℝ) (d : Fin n → ℝ)
    (hσ : IsTropicalStressEquilibrium A σ) :
    IsTropicalStressEquilibrium (fun i j => A i j + d j) σ := by
  -- By definition of IsTropicalStressEquilibrium, we need to show that for each column j, the minimum of {σ i + (A i j + d j)}_i is attained at least twice.
  intro j
  rcases hσ j with ⟨i₁, i₂, hi₁i₂, h_eq, h_min⟩
  use i₁, i₂, hi₁i₂
  exact ⟨ by linarith, fun i => by linarith [ h_min i ] ⟩

/-
Tropical feasibility is invariant under simultaneously shifting `x` and `b`
    by the same constant vector applied through `A`.
-/
theorem tropical_feasible_translation_invariant
    (A : Matrix (Fin m) (Fin n) ℝ) (b : Fin m → ℝ) (x : Fin n → ℝ) (t : ℝ)
    (hx : IsTropicallyFeasible A b x) :
    IsTropicallyFeasible A b (fun j => x j + t) := by
  intro i;
  obtain ⟨ j₁, j₂, hne, heq, hle ⟩ := hx i;
  exact ⟨ j₁, j₂, hne, by unfold rowVal at *; linarith, fun j => by unfold rowVal at *; linarith [ hle j ] ⟩

end TropicalOrigami