import Mathlib
import Tropical.Convexity.Basic

/-!
# Tropical Convexity of Difference-Constraint Polyhedra

This file proves that polyhedra defined by difference constraints `x i - x j ≤ c i j`
are tropically convex, and establishes a tropical Minkowski–Weyl theorem for the
special case of closed (Floyd–Warshall closure) difference-constraint systems.

## Main definitions

* `DiffConstraintPolyhedron` — the set of points satisfying difference constraints
* `closureGenerators` — canonical generators from the negated closure matrix columns

## Main results

* `diffConstraint_tropConvex` — difference-constraint polyhedra are tropically convex
* `closureGenerator_feasible` — each closure column satisfies the constraints
* `closureMatrix_generates` — every normalized feasible point is in the tropical hull
* `diffConstraint_finitelyGenerated_normalized` — tropical Minkowski–Weyl for alcoved polyhedra

## Mathematical background

For a closed system of difference constraints `c` (satisfying `c i i = 0` and the
triangle inequality `c i k ≤ c i j + c j k`), the canonical generators are the columns
of the negated matrix: generator `j` has coordinates `V j i = -c j i`. These generators
satisfy the constraints, and every normalized feasible point is their tropical convex
combination with coefficients `λ j = x j`.

## References

* Gaubert, S. and Katz, R., "The Minkowski Theorem for Max-Plus Convex Sets", 2007
* Butkovič, P., "Max-linear Systems: Theory and Algorithms", 2010
-/

open Finset

noncomputable section

/-- The polyhedron defined by difference constraints: `{x | ∀ i j, x i - x j ≤ c i j}`. -/
def DiffConstraintPolyhedron {n : ℕ} (c : Fin n → Fin n → ℝ) : Set (Fin n → ℝ) :=
  {x | ∀ i j, x i - x j ≤ c i j}

/-- **Difference-constraint polyhedra are tropically convex.** -/
theorem diffConstraint_tropConvex {n : ℕ} (c : Fin n → Fin n → ℝ) :
    IsTropConvex (DiffConstraintPolyhedron c) := by
  intro x y hx hy a b hab i j
  unfold tadd tscale
  cases max_cases a b <;> cases max_cases (a + x i) (b + y i) <;>
    cases max_cases (a + x j) (b + y j) <;> linarith [hx i j, hy i j]

/-- The canonical generators for the tropical Minkowski–Weyl theorem.
    Generator `j` has coordinates `V j i = -c j i`. These are the columns of
    the negated constraint matrix, which serve as extremal points of the
    difference-constraint polyhedron. -/
def closureGenerators {n : ℕ} (c : Fin n → Fin n → ℝ) : Fin n → Fin n → ℝ :=
  fun j i => -c j i

/-
Each column of a closed constraint matrix satisfies the constraints.
-/
theorem closureGenerator_feasible {n : ℕ} (c : Fin n → Fin n → ℝ)
    (_hclosed : ∀ i, c i i = 0)
    (htri : ∀ i j k, c i k ≤ c i j + c j k)
    (j : Fin n) :
    closureGenerators c j ∈ DiffConstraintPolyhedron c := by
  -- By definition of `closureGenerators`, we know that `closureGenerators c j i = -c j i` for all `i`.
  intro i k
  simp [closureGenerators];
  exact htri _ _ _

/-
Every feasible point in a closed difference-constraint system is a tropical
    convex combination of the canonical generators.

    The key insight: set `λ j = x j`. Then `max_j (x j + (-c j i)) ≤ x i` because
    the constraints give `x j - x i ≤ c j i`, i.e., `x j - c j i ≤ x i`. And at
    `j = i` we get `x i - c i i = x i - 0 = x i`, so the maximum equals `x i`.
-/
theorem closureMatrix_generates {n : ℕ} [NeZero n] (c : Fin n → Fin n → ℝ)
    (hclosed : ∀ i, c i i = 0)
    (_htri : ∀ i j k, c i k ≤ c i j + c j k)
    (x : Fin n → ℝ) (hx : x ∈ DiffConstraintPolyhedron c)
    (hnorm : Finset.univ.sup' univ_nonempty x = 0) :
    x ∈ TropConvHull (closureGenerators c) := by
  refine' ⟨ fun j => x j, _, _ ⟩ <;> simp_all +decide [ univ ];
  intro i; refine' le_antisymm _ _ <;> simp_all +decide [ closureGenerators ];
  · exact ⟨ i, Finset.mem_univ _, by linarith [ hx i i, hclosed i ] ⟩;
  · exact fun j _ => by linarith [ hx j i ] ;

/-- **Tropical Minkowski–Weyl theorem for alcoved polyhedra.**
Every closed system of difference constraints defines a set whose normalized
feasible points are contained in the tropical convex hull of the canonical generators. -/
theorem diffConstraint_finitelyGenerated_normalized {n : ℕ} [NeZero n]
    (c : Fin n → Fin n → ℝ)
    (hclosed : ∀ i, c i i = 0)
    (htri : ∀ i j k, c i k ≤ c i j + c j k) :
    {x | x ∈ DiffConstraintPolyhedron c ∧ Finset.univ.sup' univ_nonempty x = 0} ⊆
      TropConvHull (closureGenerators c) := by
  intro x ⟨hx, hnorm⟩
  exact closureMatrix_generates c hclosed htri x hx hnorm

end