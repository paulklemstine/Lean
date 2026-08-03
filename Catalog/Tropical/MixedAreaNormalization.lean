import Mathlib

/-!
# Normalization in the plane tropical Bézout formula

For the standard lattice triangle dilated by a natural degree `d`, normalized
lattice area is `d²` when the primitive lattice triangle has area one.  This
file computes the corresponding polarization exactly.  The result exposes a
factor of two: the raw difference of normalized areas is `2de`, whereas the
Bézout intersection number is `de`.
-/

namespace TropicalMixedArea

/-- Normalized lattice area of the degree-`d` standard Newton triangle. -/
def normalizedTriangleArea (d : ℕ) : ℤ := (d : ℤ) ^ 2

/-- The raw area polarization for two standard Newton triangles. -/
def normalizedMixedAreaDifference (d e : ℕ) : ℤ :=
  normalizedTriangleArea (d + e) - normalizedTriangleArea d -
    normalizedTriangleArea e

/-- The normalized-area difference for degree triangles is twice the product
of their degrees. -/
theorem normalizedMixedAreaDifference_eq_twice (d e : ℕ) :
    normalizedMixedAreaDifference d e = 2 * (d : ℤ) * (e : ℤ) := by
  simp only [normalizedMixedAreaDifference, normalizedTriangleArea,
    Nat.cast_add]
  ring

/-- For two tropical lines, the raw normalized-area difference is two, not the
Bézout intersection number one. -/
theorem two_tropical_lines_normalized_area_counterexample :
    normalizedMixedAreaDifference 1 1 = 2 ∧
      normalizedMixedAreaDifference 1 1 ≠ 1 := by
  constructor <;> norm_num [normalizedMixedAreaDifference,
    normalizedTriangleArea]

/-- In every pair of positive degrees, the normalized-area difference cannot
be equal to the usual Bézout number `d * e`. -/
theorem normalized_area_formula_ne_bezout_of_pos
    {d e : ℕ} (hd : 0 < d) (he : 0 < e) :
    normalizedMixedAreaDifference d e ≠ ((d * e : ℕ) : ℤ) := by
  rw [normalizedMixedAreaDifference_eq_twice]
  norm_num [Nat.cast_mul]
  constructor
  · intro h
    have hd' : (0 : ℤ) < d := by exact_mod_cast hd
    nlinarith
  · omega

/-- The corrected plane formula divides the normalized-area polarization by
two: equivalently, the raw difference is twice the Bézout number. -/
theorem corrected_normalized_area_bezout (d e : ℕ) :
    normalizedMixedAreaDifference d e = 2 * ((d * e : ℕ) : ℤ) := by
  rw [normalizedMixedAreaDifference_eq_twice, Nat.cast_mul]
  ring

/-- The raw normalized mixed-area polarization is symmetric in the two
Newton-triangle degrees. -/
theorem normalizedMixedAreaDifference_comm (d e : ℕ) :
    normalizedMixedAreaDifference d e = normalizedMixedAreaDifference e d := by
  rw [normalizedMixedAreaDifference_eq_twice,
    normalizedMixedAreaDifference_eq_twice]
  ring

/-- The raw normalized mixed-area polarization is additive in its first
argument, as expected of a polarization. -/
theorem normalizedMixedAreaDifference_add_left (a b e : ℕ) :
    normalizedMixedAreaDifference (a + b) e =
      normalizedMixedAreaDifference a e +
        normalizedMixedAreaDifference b e := by
  simp only [normalizedMixedAreaDifference_eq_twice, Nat.cast_add]
  ring

end TropicalMixedArea