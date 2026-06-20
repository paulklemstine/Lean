/-
# Tropical Line Counting (degree 1)

This file develops the most basic case of tropical curve counting: the
degree-1 tropical line in the plane, its three primitive edge directions,
the balancing condition, the vertex multiplicity, and the tropical–classical
correspondence that determines the (unique) vertex of a tropical line passing
through two generic points.

Note on imports: the prompt requested `Mathlib.Data.Matrix.Det`, which does not
exist in this Mathlib version.  We use `Mathlib.LinearAlgebra.Matrix.Determinant.Basic`
instead, which provides `Matrix.det_fin_two`.
-/
import Mathlib.Data.Matrix.Basic
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic
import Mathlib.Tactic

/-- First primitive edge direction of the degree-1 tropical line. -/
def e1 : Fin 2 → ℤ := ![1, 0]

/-- Second primitive edge direction of the degree-1 tropical line. -/
def e2 : Fin 2 → ℤ := ![0, 1]

/-- Third primitive edge direction of the degree-1 tropical line. -/
def e3 : Fin 2 → ℤ := ![-1, -1]

/-- The balancing condition: the three primitive edge directions of a degree-1
tropical line sum to zero. -/
theorem balancing : e1 + e2 + e3 = 0 := by
  ext i; fin_cases i <;> simp [e1, e2, e3]

/-- The matrix whose columns are the two outgoing edge directions `e1`, `e2`
at the vertex of the tropical line. -/
def edgeMatrix : Matrix (Fin 2) (Fin 2) ℤ := Matrix.of ![![e1 0, e2 0], ![e1 1, e2 1]]

/-- The vertex multiplicity is the absolute value of the determinant of the
edge matrix. -/
def vertexMultiplicity : ℤ := |edgeMatrix.det|

/-- The vertex of the degree-1 tropical line has multiplicity one. -/
theorem vertexMultiplicity_eq_one : vertexMultiplicity = 1 := by
  unfold vertexMultiplicity edgeMatrix
  rw [Matrix.det_fin_two]
  simp [e1, e2]

/-- Two points are *generic* if their difference is not parallel to any of the
primitive edge directions `e1`, `e2`, `e3`. -/
def IsGenericPoints (p1 p2 : Fin 2 → ℤ) : Prop :=
  ∀ (i : Fin 3) (j : Fin 3), i ≠ j →
    ¬(∃ t : ℤ, p2 - p1 = t • ![e1, e2, e3] i)

/-- The tropical–classical correspondence for degree 1: given two points there
is a unique vertex `v` lying on the ray from `p1` in direction `e1` and on the
ray from `p2` in direction `e2`.  The intersection point is `v = (p2 0, p1 1)`.

(The genericity hypothesis `h_gen` was requested in the statement; it turns out
to be unnecessary, since the intersection is always uniquely determined.) -/
theorem tropical_classical_correspondence (p1 p2 : Fin 2 → ℤ)
    (h_gen : IsGenericPoints p1 p2) :
    ∃! (v : Fin 2 → ℤ),
      (∃ t1 t2 : ℤ, v = p1 + t1 • e1 ∧ v = p2 + t2 • e2) := by
  refine ⟨![p2 0, p1 1], ⟨p2 0 - p1 0, p1 1 - p2 1, ?_, ?_⟩, ?_⟩
  · ext i; fin_cases i <;> simp [e1]
  · ext i; fin_cases i <;> simp [e2]
  · rintro w ⟨t1, t2, hw1, hw2⟩
    ext i
    fin_cases i
    · have := congrFun hw2 0; simpa [e2] using this
    · have := congrFun hw1 1; simpa [e1] using this