/-
# Perfect Cuboid — Rational Surface Reduction

We prove that the perfect cuboid equations, when normalized by one edge,
define a rational point on the surface `w² = u² + v² - 1`. This connects
the Diophantine problem to arithmetic geometry on algebraic surfaces.
-/
import Mathlib

namespace PerfectCuboid

/-- **Rational surface reduction theorem.**
If `(x,y,z)` satisfies the perfect cuboid face/space diagonal equations
over ℚ with `x ≠ 0`, then the normalized diagonal ratios satisfy the
surface equation `(d/x)² = (a/x)² + (b/x)² - 1`.

This reduces the perfect cuboid problem to finding rational points on
a specific algebraic surface with additional square constraints. -/
theorem perfect_cuboid_rat_point_on_surface
    {x y z a b d : ℚ}
    (hx : x ≠ 0)
    (h1 : a ^ 2 = x ^ 2 + y ^ 2)
    (h2 : b ^ 2 = x ^ 2 + z ^ 2)
    (h3 : d ^ 2 = x ^ 2 + y ^ 2 + z ^ 2) :
    (d / x) ^ 2 = (a / x) ^ 2 + (b / x) ^ 2 - 1 := by
  grind

/-
**The third face diagonal is determined by the surface relation.**
Given three face-diagonal equations, the third face diagonal c satisfies
`(c/x)² = (a/x)² + (b/x)² - 2` when y² + z² = c².
-/
theorem third_face_diagonal_relation
    {x y z a b c : ℚ}
    (hx : x ≠ 0)
    (h1 : a ^ 2 = x ^ 2 + y ^ 2)
    (h2 : b ^ 2 = x ^ 2 + z ^ 2)
    (h3 : c ^ 2 = y ^ 2 + z ^ 2) :
    (c / x) ^ 2 = (a / x) ^ 2 + (b / x) ^ 2 - 2 := by
  grind

/-
**Surface relation in symmetric form.**
The perfect cuboid equations over ℚ, when all diagonal ratios are defined,
satisfy the quadric intersection: for any nonzero edge x, the ratios
u = a/x, v = b/x, w = d/x satisfy both `w² = u² + v² - 1` and
`u² - 1` and `v² - 1` are both perfect squares in ℚ (being (y/x)² and (z/x)²).
-/
theorem surface_with_square_constraints
    {x y z a b d : ℚ}
    (hx : x ≠ 0)
    (h1 : a ^ 2 = x ^ 2 + y ^ 2)
    (h2 : b ^ 2 = x ^ 2 + z ^ 2)
    (h3 : d ^ 2 = x ^ 2 + y ^ 2 + z ^ 2) :
    (d / x) ^ 2 = (a / x) ^ 2 + (b / x) ^ 2 - 1 ∧
    (a / x) ^ 2 - 1 = (y / x) ^ 2 ∧
    (b / x) ^ 2 - 1 = (z / x) ^ 2 := by
  grind

end PerfectCuboid