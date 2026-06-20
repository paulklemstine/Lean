/-
Copyright (c) 2025. All rights reserved.

# Degree-1 tropical line counting

A *tropical line* in the plane `ℝ²` is the corner locus of a degree-1 tropical
polynomial.  Geometrically it is a single trivalent vertex `v` from which three
rays emanate, in the primitive integer directions

* `e1 = (-1, 0)`  (the "west" ray),
* `e2 = (0, -1)`  (the "south" ray),
* `e3 = (1, 1)`   (the "north-east" ray).

This file formalises the three basic facts of the degree-1 case of the tropical
line counting theorem:

* the **balancing condition** `e1 + e2 + e3 = 0`;
* the **vertex multiplicity** equals `1`, i.e. each pair of consecutive ray
  directions spans the integer lattice (the absolute value of the `2 × 2`
  determinant of the two directions is `1`);
* **uniqueness of the vertex** through two generic points: any two tropical
  lines passing through the same two generic points have the same vertex.
-/
import Mathlib
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic

namespace TropicalLine

/-! ## Primitive ray directions and balancing -/

/-- Direction of the west ray. -/
def e1 : ℤ × ℤ := (-1, 0)

/-- Direction of the south ray. -/
def e2 : ℤ × ℤ := (0, -1)

/-- Direction of the north-east ray. -/
def e3 : ℤ × ℤ := (1, 1)

/-- The balancing condition for a degree-1 tropical line: the three primitive
ray directions sum to zero. -/
theorem balancing : e1 + e2 + e3 = 0 := by decide

/-! ## Vertex multiplicity -/

/-- The multiplicity contributed by two ray directions `u` and `v`: the absolute
value of the determinant of the `2 × 2` matrix whose columns are `u` and `v`.
For a smooth (multiplicity one) vertex this number is `1` for each pair of
consecutive rays. -/
def mult (u v : ℤ × ℤ) : ℕ := (Matrix.det !![u.1, v.1; u.2, v.2]).natAbs

/-- The multiplicity of the west/south pair of rays is `1`. -/
theorem mult_e1_e2 : mult e1 e2 = 1 := by decide

/-- The multiplicity of the south/north-east pair of rays is `1`. -/
theorem mult_e2_e3 : mult e2 e3 = 1 := by decide

/-- The multiplicity of the north-east/west pair of rays is `1`. -/
theorem mult_e3_e1 : mult e3 e1 = 1 := by decide

/-- The vertex of a degree-1 tropical line has multiplicity one: every pair of
consecutive rays has multiplicity `1`. -/
theorem vertex_multiplicity_one :
    mult e1 e2 = 1 ∧ mult e2 e3 = 1 ∧ mult e3 e1 = 1 :=
  ⟨mult_e1_e2, mult_e2_e3, mult_e3_e1⟩

/-! ## Tropical lines and their vertices -/

/-- A point `p` lies on the tropical line with vertex `v` when it lies on one of
the three rays emanating from `v`:

* the north-east ray `{ (v.1 + t, v.2 + t) : t ≥ 0 }`,
* the west ray `{ (v.1 - t, v.2) : t ≥ 0 }`,
* the south ray `{ (v.1, v.2 - t) : t ≥ 0 }`.

Writing `a = p.1 - v.1` and `b = p.2 - v.2`, this is the corner locus condition
that the maximum of `{a, b, 0}` is attained at least twice. -/
def onLine (v p : ℝ × ℝ) : Prop :=
  (p.1 - v.1 = p.2 - v.2 ∧ 0 ≤ p.1 - v.1) ∨
  (p.2 - v.2 = 0 ∧ p.1 - v.1 ≤ 0) ∨
  (p.1 - v.1 = 0 ∧ p.2 - v.2 ≤ 0)

/-- Two points `p` and `q` are in **tropical general position** (are *generic*)
when their three tropical coordinates all differ:

* `p.1 ≠ q.1` (they do not share the south ray),
* `p.2 ≠ q.2` (they do not share the west ray),
* `p.1 - p.2 ≠ q.1 - q.2` (they do not share the north-east ray).

Equivalently, no single ray direction can contain both points, so each of the
two points lies on a distinct ray of any common tropical line. -/
def Generic (p q : ℝ × ℝ) : Prop :=
  p.1 ≠ q.1 ∧ p.2 ≠ q.2 ∧ p.1 - p.2 ≠ q.1 - q.2

/-
**Uniqueness of the vertex.** If two tropical lines, with vertices `v` and
`v'`, both pass through two generic points `p` and `q`, then they have the same
vertex `v = v'`. Hence two generic points determine at most one tropical line.
-/
theorem vertex_unique {p q v v' : ℝ × ℝ} (hpq : Generic p q)
    (hpv : onLine v p) (hqv : onLine v q)
    (hpv' : onLine v' p) (hqv' : onLine v' q) : v = v' := by
  obtain ⟨hp₁, hp₂⟩ := hpq
  unfold onLine at *
  simp_all +decide [sub_eq_iff_eq_add]
  grind

end TropicalLine