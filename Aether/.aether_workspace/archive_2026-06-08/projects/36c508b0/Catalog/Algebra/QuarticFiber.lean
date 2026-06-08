/-
# Perfect Cuboid — Quartic Fiber Reduction

Starting from the perfect cuboid surface equation `w² = u² + v² - 1`
with square constraints `u² - 1 = (y/x)²` and `v² - 1 = (z/x)²`,
we apply the standard rational parametrizations
  `u = (r² + 1)/(2r)`,  `v = (s² + 1)/(2s)`
and derive the quartic fiber equation:
  `W² = r²s⁴ + (r⁴ + 1)s² + r²`
where `W = 2rsw`.

**Note:** The prompt originally stated the quartic as
`W² = r²s⁴ + (r⁴ - 2r² + 1)s² + r²`, but this is incorrect.
The correct coefficient of `s²` is `r⁴ + 1`, not `(r² - 1)² = r⁴ - 2r² + 1`.
The error arose from a miscalculation when clearing denominators.

## Main results

* `cuboid_parametrized_quartic` — the algebraic reduction from the surface
  equation to the quartic fiber.
* `quarticFiber` — the defining predicate for the quartic fiber curve.
* `quarticFiber_symmetric` — the quartic is even in `s`.
* `conicFiber` — descent to a conic in `t = s²`.
-/
import Mathlib

namespace PerfectCuboid

/-! ## The quartic fiber equation -/

/-- The quartic fiber curve: `W² = r²s⁴ + (r⁴ + 1)s² + r²`.
For fixed rational `r ≠ 0`, this is a quartic curve in `(s, W)`. -/
def quarticFiber (r s W : ℚ) : Prop :=
  W ^ 2 = r ^ 2 * s ^ 4 + (r ^ 4 + 1) * s ^ 2 + r ^ 2

/-
**Quartic fiber reduction.**
If `(r, s, w)` satisfy the perfect cuboid surface equation through the
standard Pythagorean parametrization, then `(s, 2rsw)` lies on the
quartic fiber curve.
-/
theorem cuboid_parametrized_quartic
    {r s w : ℚ}
    (hr : r ≠ 0) (hs : s ≠ 0)
    (hw : w ^ 2 = ((r ^ 2 + 1) / (2 * r)) ^ 2 +
                   ((s ^ 2 + 1) / (2 * s)) ^ 2 - 1) :
    quarticFiber r s (2 * r * s * w) := by
  unfold quarticFiber;
  grind

/-- The Pythagorean parametrization identity: `u² - 1 = ((r² - 1)/(2r))²`
when `u = (r² + 1)/(2r)`. -/
theorem pythagorean_param_identity (r : ℚ) (hr : r ≠ 0) :
    ((r ^ 2 + 1) / (2 * r)) ^ 2 - 1 = ((r ^ 2 - 1) / (2 * r)) ^ 2 := by
  field_simp
  ring

/-- The quartic fiber is even in `s`: replacing `s` by `-s` gives the
same equation. This means the quartic descends to a conic in `t = s²`. -/
theorem quarticFiber_symmetric (r s W : ℚ) :
    quarticFiber r s W ↔ quarticFiber r (-s) W := by
  simp [quarticFiber]; ring_nf

/-- **Conic descent.** Setting `t = s²`, the quartic fiber becomes the
conic `W² = r²t² + (r⁴ + 1)t + r²` in `(t, W)`. -/
def conicFiber (r t W : ℚ) : Prop :=
  W ^ 2 = r ^ 2 * t ^ 2 + (r ^ 4 + 1) * t + r ^ 2

/-- The quartic fiber at `s` is equivalent to the conic fiber at `t = s²`. -/
theorem quarticFiber_eq_conicFiber (r s W : ℚ) :
    quarticFiber r s W ↔ conicFiber r (s ^ 2) W := by
  simp [quarticFiber, conicFiber]; ring_nf

/-
**Discriminant of the conic fiber.**
The discriminant of the quadratic `r²t² + (r⁴+1)t + r² - W²` in `t` is
`(r⁴+1)² - 4r²(r² - W²)`. Using the conic fiber relation, this simplifies
to a perfect square.
-/
theorem conicFiber_discriminant (r t W : ℚ) (_hr : r ≠ 0)
    (hc : conicFiber r t W) :
    (r ^ 4 + 1) ^ 2 - 4 * r ^ 2 * r ^ 2 + 4 * r ^ 2 * W ^ 2 =
    (2 * r ^ 2 * t + (r ^ 4 + 1)) ^ 2 := by
  unfold conicFiber at hc; linear_combination hc * 4 * r ^ 2;

end PerfectCuboid