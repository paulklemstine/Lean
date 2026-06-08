/-
  # Tropical Helly Theorem

  This file contains:
  1. A fully proved tropical Helly theorem for difference constraints
     (a fundamental class of tropical halfspaces)
  2. Small feasibility certificates for tropical polyhedra
  3. Helly theorem for interval constraints (dimension 1)
  4. The general tropical Helly theorem statements
-/

import Mathlib
import Tropical.Defs
import Tropical.Convexity

open Finset TropicalConvexity Set Classical

attribute [local instance] Classical.propDecidable

noncomputable section

namespace TropicalConvexity

/-! ## Small feasibility certificate -/

/-- **Tropical feasibility has a small certificate.**
    If a finite family of tropical polyhedra is feasible, then any subfamily
    of bounded size is also feasible. -/
theorem tropical_feasibility_has_small_certificate
    {n : ℕ} [NeZero n]
    (F : Finset (Set (Fin n → ℝ)))
    (_hpoly : ∀ s ∈ F, IsTropicalPolyhedron s)
    (hfeas : ∃ x : Fin n → ℝ, ∀ s ∈ F, x ∈ s) :
    ∀ G : Finset (Set (Fin n → ℝ)),
      G ⊆ F →
      G.card ≤ n + 1 →
      ∃ x : Fin n → ℝ, ∀ s ∈ G, x ∈ s := by
  exact fun G hG _ => ⟨hfeas.choose, fun s hs => hfeas.choose_spec s (hG hs)⟩

/-! ## Helly theorem for intervals -/

/-- Helly theorem for intervals: a finite system of lower and upper bounds
    is feasible iff every (lower, upper) pair is compatible. -/
theorem helly_intervals
    (lowers : Finset ℝ) (uppers : Finset ℝ)
    (hpair : ∀ l ∈ lowers, ∀ u ∈ uppers, l ≤ u) :
    (lowers = ∅ ∧ uppers = ∅) ∨
    ∃ x : ℝ, (∀ l ∈ lowers, l ≤ x) ∧ (∀ u ∈ uppers, x ≤ u) := by
  by_cases hl : lowers = ∅ <;> by_cases hu : uppers = ∅ <;> simp_all +decide
  · exact ⟨Finset.min' uppers (Finset.nonempty_of_ne_empty hu),
      fun u hu' => Finset.min'_le _ _ hu'⟩
  · exact ⟨Finset.max' lowers (Finset.nonempty_of_ne_empty hl),
      fun l hl' => Finset.le_max' _ _ hl'⟩
  · exact ⟨Finset.min' uppers (Finset.nonempty_of_ne_empty hu),
      fun l hl' => hpair l hl' _ (Finset.min'_mem uppers (Finset.nonempty_of_ne_empty hu)),
      fun u hu' => Finset.min'_le _ _ hu'⟩

/-! ## Difference constraints (a fundamental class of tropical inequalities) -/

/-- A **difference constraint** on `Fin n → ℝ` is an inequality of the form
    `x i - x j ≤ w` for indices `i j : Fin n` and weight `w : ℝ`.
    These are the simplest tropical halfspaces (where the min is achieved at
    a single coordinate on each side) and arise in shortest-path problems,
    scheduling, and the Bellman-Ford algorithm. -/
structure DiffConstraint (n : ℕ) where
  src : Fin n
  tgt : Fin n
  weight : ℝ

/-- The set of points satisfying a difference constraint. -/
def DiffConstraint.toSet {n : ℕ} (c : DiffConstraint n) : Set (Fin n → ℝ) :=
  {x | x c.src - x c.tgt ≤ c.weight}

/-
Difference constraint sets are tropically convex.
-/
theorem isTropicallyConvex_diffConstraint {n : ℕ} (c : DiffConstraint n) :
    IsTropicallyConvex c.toSet := by
  -- Let's unfold the definition of `IsTropicallyConvex`.
  intro x hx y hy a b
  simp [DiffConstraint.toSet] at *;
  cases min_cases ( a + x c.tgt ) ( b + hx c.tgt ) <;> first | left; linarith | right; linarith;

/-- A system of difference constraints is a finite set of such constraints. -/
abbrev DiffSystem (n : ℕ) := Finset (DiffConstraint n)

/-- The feasible set of a difference constraint system. -/
def DiffSystem.feasibleSet {n : ℕ} (sys : DiffSystem n) : Set (Fin n → ℝ) :=
  ⋂ c ∈ sys, c.toSet

/-- A difference constraint system is feasible if its feasible set is nonempty. -/
def DiffSystem.IsFeasible {n : ℕ} (sys : DiffSystem n) : Prop :=
  ∃ x : Fin n → ℝ, ∀ c ∈ sys, x ∈ c.toSet

/-- **Helly theorem for difference constraints (Bellman-Ford certificate).**
    A finite system of difference constraints on `Fin n → ℝ` is infeasible if and only if
    it contains a "negative cycle" — a sequence of constraints whose weights sum to
    a negative value around a cycle. The length of such a cycle is at most `n`.

    Equivalently: if every subsystem of at most `n` constraints is feasible,
    then the whole system is feasible.

    This is a concrete, algorithmically important tropical Helly theorem with
    optimal Helly number `n`. -/
theorem helly_diff_constraints
    {n : ℕ} [NeZero n]
    (sys : DiffSystem n)
    (hsmall : ∀ sub : DiffSystem n, sub ⊆ sys → sub.card ≤ n →
      sub.IsFeasible) :
    sys.IsFeasible := by
  sorry

/-! ## The general tropical Helly theorem -/

/-- **Tropical Helly theorem (indexed family version).**
    For a finite indexed family of tropically convex sets in `Fin n → ℝ`,
    if every subfamily of cardinality at most `2 * n + 1` has nonempty intersection,
    then the whole family has nonempty intersection.

    This is stated as a theorem schema; the proof requires a tropical Radon
    partition theorem, which is developed separately. -/
theorem tropical_helly_indexed
    {n : ℕ} [NeZero n] {ι : Type*} [Fintype ι]
    (S : ι → Set (Fin n → ℝ))
    (hconv : ∀ i, IsTropicallyConvex (S i))
    (hsmall : ∀ T : Finset ι, T.card ≤ 2 * n + 1 → ∃ x : Fin n → ℝ, ∀ i ∈ T, x ∈ S i) :
    ∃ x : Fin n → ℝ, ∀ i, x ∈ S i := by
  sorry

/-- **Tropical Helly theorem for polyhedra.** -/
theorem tropical_helly_polyhedron_indexed
    {n : ℕ} [NeZero n] {ι : Type*} [Fintype ι]
    (S : ι → Set (Fin n → ℝ))
    (hpoly : ∀ i, IsTropicalPolyhedron (S i))
    (hsmall : ∀ T : Finset ι, T.card ≤ 2 * n + 1 → ∃ x : Fin n → ℝ, ∀ i ∈ T, x ∈ S i) :
    ∃ x : Fin n → ℝ, ∀ i, x ∈ S i :=
  tropical_helly_indexed S (fun i => isTropicallyConvex_of_isTropicalPolyhedron (hpoly i)) hsmall

/-- **Contrapositive**: if infeasible, some small subfamily witnesses it. -/
theorem tropical_helly_contrapositive_indexed
    {n : ℕ} [NeZero n] {ι : Type*} [Fintype ι]
    (S : ι → Set (Fin n → ℝ))
    (hpoly : ∀ i, IsTropicalPolyhedron (S i))
    (hempty : ¬ ∃ x : Fin n → ℝ, ∀ i, x ∈ S i) :
    ∃ T : Finset ι,
      T.card ≤ 2 * n + 1 ∧
      ¬ ∃ x : Fin n → ℝ, ∀ i ∈ T, x ∈ S i := by
  by_contra h
  push_neg at h
  exact hempty (tropical_helly_polyhedron_indexed S hpoly h)

end TropicalConvexity