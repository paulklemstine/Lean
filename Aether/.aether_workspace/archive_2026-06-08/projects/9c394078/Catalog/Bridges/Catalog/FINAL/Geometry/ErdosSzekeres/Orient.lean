/-
# Properties of the Orientation Function

This file proves algebraic and geometric properties of the orientation
predicate, including antisymmetry, sign behavior under permutations,
and relationships to collinearity.
-/
import Mathlib
import Geometry.ErdosSzekeres.Defs

namespace ErdosSzekeres

/-! ## Basic algebraic properties of orient -/

/-- Orientation is antisymmetric in the first two arguments. -/
theorem orient_swap12 (a b c : ℝ × ℝ) :
    orient b a c = -orient a b c := by
  simp [orient]; ring

/-- Orientation is antisymmetric in the last two arguments. -/
theorem orient_swap23 (a b c : ℝ × ℝ) :
    orient a c b = -orient a b c := by
  simp [orient]; ring

/-- Orientation is invariant under cyclic permutation. -/
theorem orient_cyclic (a b c : ℝ × ℝ) :
    orient b c a = orient a b c := by
  simp [orient]; ring

/-- orient is zero when two points coincide. -/
theorem orient_self_left (a b : ℝ × ℝ) :
    orient a a b = 0 := by
  unfold orient; ring

theorem orient_self_mid (a b : ℝ × ℝ) :
    orient a b b = 0 := by
  unfold orient; ring

theorem orient_self_right (a b : ℝ × ℝ) :
    orient a b a = 0 := by
  unfold orient; ring

/-- orient expressed as a determinant-style formula. -/
theorem orient_eq (a b c : ℝ × ℝ) :
    orient a b c = a.1 * (b.2 - c.2) + b.1 * (c.2 - a.2) + c.1 * (a.2 - b.2) := by
  simp [orient]; ring

/-- Orientation changes sign under full reversal. -/
theorem orient_reverse (a b c : ℝ × ℝ) :
    orient c b a = -orient a b c := by
  simp [orient]; ring

/-- orient is translation-invariant. -/
theorem orient_translate (a b c v : ℝ × ℝ) :
    orient (a.1 + v.1, a.2 + v.2) (b.1 + v.1, b.2 + v.2) (c.1 + v.1, c.2 + v.2) =
    orient a b c := by
  unfold orient; ring

/-- orient scales quadratically under uniform scaling. -/
theorem orient_scale (a b c : ℝ × ℝ) (r : ℝ) :
    orient (r * a.1, r * a.2) (r * b.1, r * b.2) (r * c.1, r * c.2) =
    r ^ 2 * orient a b c := by
  simp [orient]; ring

/-- Orientation sign determines whether c is above or below the line through a, b. -/
theorem orient_pos_iff (a b c : ℝ × ℝ) :
    orient a b c > 0 ↔
      (b.1 - a.1) * (c.2 - a.2) > (b.2 - a.2) * (c.1 - a.1) := by
  constructor
  · intro h; simp [orient] at h; linarith
  · intro h; simp [orient]; linarith

/-- If points are in general position, orient gives a definite sign. -/
theorem orient_sign_of_gp {m : ℕ} {p : Fin m → ℝ × ℝ}
    (hgp : GeneralPosition p)
    {i j k : Fin m} (hij : i ≠ j) (hjk : j ≠ k) (hik : i ≠ k) :
    orient (p i) (p j) (p k) > 0 ∨ orient (p i) (p j) (p k) < 0 := by
  have h := hgp i j k hij hjk hik
  rcases lt_or_gt_of_ne h with h | h
  · exact Or.inr h
  · exact Or.inl h

end ErdosSzekeres