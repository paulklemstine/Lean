/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Definitions for Non-Group Markov Chain Comparison

Core definitions for comparing reversible Markov chains without group structure.
This file liberates spectral-gap certification from group symmetry by defining
the Dirichlet form, weighted variance, and Poincaré inequality for arbitrary
finite reversible chains.

## Main definitions

* `weightedMean` — weighted mean of a function under a measure
* `weightedVariance` — variance of a function under a weighted measure
* `dirichletForm` — Dirichlet form E_π,P(f,f) for a reversible chain
* `IsPoincare` — Poincaré inequality characterization of spectral gap
* `PathCongestion` — novel: edge congestion of transported flow through paths

## Catalog lineage

Extends `Pythagorean/CayleyExpander/Defs.lean` by removing group structure.
The `dirichletForm` here generalizes `cayleyDirichletEnergy` to arbitrary kernels.

## References

* Diaconis, P., Saloff-Coste, L. (1993). Comparison theorems for reversible Markov chains.
* Jerrum, M., Sinclair, A. (1989). Approximating the permanent.
-/
import Mathlib

open Finset BigOperators

noncomputable section

/-! ## Weighted mean and variance for general measures -/

/-- Weighted mean of a function under a measure π.
    When π is a probability measure (∑ π = 1), this is the expectation E_π[f]. -/
def weightedMean {α : Type*} [Fintype α] (π : α → ℝ) (f : α → ℝ) : ℝ :=
  ∑ x : α, π x * f x

/-- Weighted variance of a function under a measure π.
    Var_π(f) = ∑_x π(x) · (f(x) - E_π[f])².
    When π is a probability distribution, this is the statistical variance. -/
def weightedVariance {α : Type*} [Fintype α] (π : α → ℝ) (f : α → ℝ) : ℝ :=
  ∑ x : α, π x * (f x - weightedMean π f) ^ 2

/-- Dirichlet form for a general Markov kernel P with stationary measure π.
    E_π,P(f,f) = (1/2) ∑_{x,y} π(x) P(x,y) (f(x) - f(y))².
    This is the quadratic form of the Laplacian I - P in the weighted L² space. -/
def dirichletForm {α : Type*} [Fintype α]
    (π : α → ℝ) (P : α → α → ℝ) (f : α → ℝ) : ℝ :=
  (1 / 2) * ∑ x : α, ∑ y : α, π x * P x y * (f x - f y) ^ 2

/-- The Poincaré inequality: λ₀ is a lower bound on the spectral gap if
    λ₀ · Var_π(f) ≤ E_π,P(f,f) for all functions f.
    The spectral gap is the supremum of all such λ₀. -/
def IsPoincare {α : Type*} [Fintype α]
    (π : α → ℝ) (P : α → α → ℝ) (gap : ℝ) : Prop :=
  ∀ f : α → ℝ, gap * weightedVariance π f ≤ dirichletForm π P f

/-! ## Path congestion for non-group chains (Novel definition) -/

/-- Whether a pair (u,v) appears as a consecutive pair in a list.
    This checks if the directed edge (u,v) is used by the path. -/
def List.hasEdge {α : Type*} [DecidableEq α] (l : List α) (u v : α) : Bool :=
  match l with
  | [] => false
  | [_] => false
  | a :: b :: rest => (a == u && b == v) || (b :: rest).hasEdge u v

/-- **PathCongestion** (Novel definition): The congestion of a path routing scheme.

Given reversible chains P, Q on the same state space with stationary
measure π, and a path system Γ routing each P-edge through Q-edges,
the congestion measures the maximum load on any single Q-edge.

This is the key quantity controlling how well P-flow can be routed
through Q-edges without bottlenecks. It generalizes the congestion
concept from Cayley graphs to arbitrary reversible chains. -/
structure PathCongestion {α : Type*} [Fintype α] [DecidableEq α]
    (π : α → ℝ) (P Q : α → α → ℝ) (Γ : α → α → List α) where
  /-- The congestion bound -/
  bound : ℝ
  /-- The bound is positive -/
  bound_pos : 0 < bound
  /-- The congestion inequality holds for each Q-edge:
      For each (u,v) with Q(u,v) > 0, the total flow through (u,v) is bounded. -/
  congestion_le : ∀ u v : α, Q u v > 0 →
    (∑ x : α, ∑ y : α,
      if (Γ x y).hasEdge u v
      then π x * P x y * (Γ x y).length
      else 0) ≤ bound * (π u * Q u v)

/-- **ReversibleChainComparison** (Novel structure): packages all data
    needed to compare two reversible Markov chains through path transport.

    This is the central abstraction that liberates canonical-path methods
    from group symmetry. Instead of using group multiplication to construct
    paths, we use an arbitrary path routing scheme Γ with controlled congestion. -/
structure ReversibleChainComparison
    (α : Type*) [Fintype α] [DecidableEq α] where
  /-- Stationary measure for chain P -/
  πP : α → ℝ
  /-- Stationary measure for chain Q -/
  πQ : α → ℝ
  /-- Transition kernel P -/
  P : α → α → ℝ
  /-- Transition kernel Q -/
  Q : α → α → ℝ
  /-- πP is a probability measure -/
  πP_prob : ∑ x : α, πP x = 1
  /-- πQ is a probability measure -/
  πQ_prob : ∑ x : α, πQ x = 1
  /-- πP is nonneg -/
  πP_nonneg : ∀ x, 0 ≤ πP x
  /-- πQ is nonneg -/
  πQ_nonneg : ∀ x, 0 ≤ πQ x
  /-- P is reversible w.r.t. πP -/
  revP : ∀ x y, πP x * P x y = πP y * P y x
  /-- Q is reversible w.r.t. πQ -/
  revQ : ∀ x y, πQ x * Q x y = πQ y * Q y x
  /-- Dirichlet form comparison constant -/
  C : ℝ
  /-- Lower bound on stationary measure ratio -/
  a : ℝ
  /-- Upper bound on stationary measure ratio -/
  b : ℝ
  /-- a is positive -/
  ha : 0 < a
  /-- b is positive -/
  hb : 0 < b
  /-- C is positive -/
  hC : 0 < C
  /-- Dirichlet form comparison: E_Q ≤ C · E_P -/
  energy_comparison : ∀ f : α → ℝ,
    dirichletForm πQ Q f ≤ C * dirichletForm πP P f
  /-- Lower comparison of stationary measures -/
  measure_lower : ∀ x, a * πQ x ≤ πP x
  /-- Upper comparison of stationary measures -/
  measure_upper : ∀ x, πP x ≤ b * πQ x

/-! ## Basic properties -/

theorem dirichletForm_nonneg {α : Type*} [Fintype α]
    (π : α → ℝ) (P : α → α → ℝ) (f : α → ℝ)
    (hπ : ∀ x, 0 ≤ π x) (hP : ∀ x y, 0 ≤ P x y) :
    0 ≤ dirichletForm π P f := by
  unfold dirichletForm
  apply mul_nonneg (by norm_num)
  apply Finset.sum_nonneg; intro x _
  apply Finset.sum_nonneg; intro y _
  apply mul_nonneg
  · exact mul_nonneg (hπ x) (hP x y)
  · exact sq_nonneg _

theorem weightedVariance_nonneg {α : Type*} [Fintype α]
    (π : α → ℝ) (f : α → ℝ) (hπ : ∀ x, 0 ≤ π x) :
    0 ≤ weightedVariance π f := by
  unfold weightedVariance
  apply Finset.sum_nonneg; intro x _
  exact mul_nonneg (hπ x) (sq_nonneg _)

theorem dirichletForm_const {α : Type*} [Fintype α]
    (π : α → ℝ) (P : α → α → ℝ) (c : ℝ) :
    dirichletForm π P (fun _ => c) = 0 := by
  unfold dirichletForm; simp

/-
The weighted variance can be bounded using any reference point c:
    Var_π(f) ≤ ∑_x π(x) (f(x) - c)² when π sums to 1.
    This is the key inequality used in variance comparison.
-/
theorem weightedVariance_le_sum_sq_sub {α : Type*} [Fintype α]
    (π : α → ℝ) (f : α → ℝ) (c : ℝ)
    (hπ_nonneg : ∀ x, 0 ≤ π x)
    (hπ_sum : ∑ x : α, π x = 1) :
    weightedVariance π f ≤ ∑ x : α, π x * (f x - c) ^ 2 := by
  have h_sum_zero : ∑ x, π x * (f x - c) ^ 2 = ∑ x, π x * (f x - weightedMean π f) ^ 2 + (c - weightedMean π f) ^ 2 * ∑ x, π x := by
    simp_all +decide [ mul_comm, Finset.mul_sum _ _ _, Finset.sum_add_distrib, sub_sq ];
    simp +decide [ mul_add, mul_sub, Finset.sum_add_distrib, Finset.sum_sub_distrib, mul_assoc, mul_comm, mul_left_comm, hπ_sum, weightedMean ];
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, hπ_sum ] ; ring;
    simp +decide [ ← Finset.sum_mul _ _ _, ← Finset.mul_sum, ← Finset.sum_mul, hπ_sum ] ; ring;
  exact h_sum_zero ▸ le_add_of_le_of_nonneg ( le_rfl ) ( mul_nonneg ( sq_nonneg _ ) ( Finset.sum_nonneg fun _ _ => hπ_nonneg _ ) )

/-
Monotonicity of weighted sums: if π₁ ≤ b · π₂ pointwise,
    then ∑ π₁(x) g(x) ≤ b · ∑ π₂(x) g(x) for nonneg g.
-/
theorem weighted_sum_le_of_measure_le {α : Type*} [Fintype α]
    (π₁ π₂ : α → ℝ) (g : α → ℝ) (b : ℝ)
    (hg : ∀ x, 0 ≤ g x)
    (hcmp : ∀ x, π₁ x ≤ b * π₂ x) :
    ∑ x : α, π₁ x * g x ≤ b * ∑ x : α, π₂ x * g x := by
  simpa only [ Finset.mul_sum _ _ _, mul_assoc ] using Finset.sum_le_sum fun x _ => mul_le_mul_of_nonneg_right ( hcmp x ) ( hg x )

end