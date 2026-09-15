import Combinatorics.BerggrenCongruentDefs

/-!
# The elliptic curve side: rational right triangles ↔ points on `y² = x³ − N²x`

The classical correspondence between rational right triangles of area `N` and rational
points on the congruent number curve `E_N : y² = x³ − N² x`, formalised as an explicit
pair of inverse constructions:

```
(a, b, c)  ↦  (X, Y) = (a(a+c)/2, a²(a+c)/2)
(X, Y)     ↦  (a, b, c) = ((X² − N²)/Y, 2NX/Y, (X² + N²)/Y)
```

## Main results

* `curve_point_of_congruent`, `congruent_of_curve_point` — the two constructions.
* `isCongruentNumber_iff_curve` — the resulting criterion.
-/

namespace BerggrenCongruent

/-- The congruent number curve `E_N : y² = x³ − N²x`. -/
def OnCongruentCurve (N x y : ℚ) : Prop := y ^ 2 = x ^ 3 - N ^ 2 * x

/-- From a rational right triangle of area `N` to a point of `E_N` with `x > 0`,
`y > 0`.  With `a` a leg and `c` the hypotenuse, the point is
`(a(a+c)/2, a²(a+c)/2)`. -/
theorem curve_point_of_congruent {N : ℚ} (h : IsCongruentNumber N) :
    ∃ x y : ℚ, 0 < x ∧ 0 < y ∧ OnCongruentCurve N x y := by
  obtain ⟨a, b, c, ha, hb, hc, hpy, harea⟩ := h
  refine ⟨a * (a + c) / 2, a ^ 2 * (a + c) / 2, by positivity, by positivity, ?_⟩
  -- with `2N = ab` and `c² = a² + b²` the identity is polynomial
  have hN2 : N = a * b / 2 := by linarith
  simp only [OnCongruentCurve, hN2]
  have hc2 : c ^ 2 = a ^ 2 + b ^ 2 := hpy.symm
  field_simp
  nlinarith [hc2, sq_nonneg (a + c), sq_nonneg a, sq_nonneg b, mul_pos ha hc]

/-- From a point of `E_N` with positive `x` and nonzero `y` back to a rational right
triangle of area `N`: the triangle is `((x² − N²)/y, 2Nx/y, (x² + N²)/y)`. -/
theorem congruent_of_curve_point {N x y : ℚ} (hN : 0 < N) (hx : 0 < x) (hy : y ≠ 0)
    (h : OnCongruentCurve N x y) : IsCongruentNumber N := by
  -- replacing `y` by `|y|` we may assume `y > 0`
  wlog hpos : 0 < y generalizing y
  · refine this (y := -y) (by simpa using hy) ?_ ?_
    · simpa [OnCongruentCurve] using h
    · rcases lt_trichotomy y 0 with h' | h' | h'
      · linarith
      · exact absurd h' hy
      · exact absurd h' hpos
  have hxN : N < x := by
    -- `y² > 0` forces `x(x − N)(x + N) > 0`, hence `x > N`
    have hy2 : 0 < y ^ 2 := by positivity
    rw [h] at hy2
    by_contra hcon
    push_neg at hcon
    nlinarith [hy2, mul_nonneg (mul_nonneg hx.le (sub_nonneg.mpr hcon))
      (by positivity : (0 : ℚ) ≤ N + x)]
  refine ⟨(x ^ 2 - N ^ 2) / y, 2 * N * x / y, (x ^ 2 + N ^ 2) / y, ?_, ?_, ?_, ?_, ?_⟩
  · have : 0 < x ^ 2 - N ^ 2 := by nlinarith
    positivity
  · positivity
  · positivity
  · field_simp
    ring
  · -- area: `(x² − N²)(2Nx)/(2y²) = N` because `y² = x³ − N²x`
    have hy2 : y ^ 2 = x ^ 3 - N ^ 2 * x := h
    field_simp
    nlinarith [hy2]

/-- **The congruent number curve criterion.**  `N > 0` is a congruent number exactly when
`E_N : y² = x³ − N²x` has a rational point with `x > 0` and `y ≠ 0`. -/
theorem isCongruentNumber_iff_curve {N : ℚ} (hN : 0 < N) :
    IsCongruentNumber N ↔ ∃ x y : ℚ, 0 < x ∧ y ≠ 0 ∧ OnCongruentCurve N x y := by
  constructor
  · intro h
    obtain ⟨x, y, hx, hy, hxy⟩ := curve_point_of_congruent h
    exact ⟨x, y, hx, ne_of_gt hy, hxy⟩
  · rintro ⟨x, y, hx, hy, hxy⟩
    exact congruent_of_curve_point hN hx hy hxy

end BerggrenCongruent