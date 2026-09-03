import Mathlib

/-! # CatalogBuild.Bridges.SPBFiniteFields

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 13
-/

noncomputable section

/-- SPB preserves the "norm" `1 + x²`:
`(1 + spb(x,y)²) * (1 - xy)² = (1 + x²)(1 + y²)`. -/
theorem spb_norm_multiplicativity (x y : ℝ) (hxy : x * y ≠ 1) :
    (1 + ((x + y) / (1 - x * y))^2) * (1 - x * y)^2 = (1 + x^2) * (1 + y^2) := by
  have h : (1 - x * y) ≠ 0 := sub_ne_zero.mpr (Ne.symm hxy)
  field_simp
  ring

/-- The Cayley transform parametrizes the unit circle:
`((1-t²)/(1+t²))² + (2t/(1+t²))² = 1`. -/
theorem spb_pythagorean_parametrization (t : ℝ) :
    ((1 - t^2) / (1 + t^2))^2 + (2 * t / (1 + t^2))^2 = 1 := by
  have ht : (1 + t^2) ≠ 0 := by positivity
  field_simp
  ring

/-- The double-SPB formula: `spb(x, x) = 2x/(1 - x²)`. -/
theorem spb_double_formula (x : ℝ) :
    (x + x) / (1 - x * x) = 2 * x / (1 - x^2) := by
  congr 1 <;> ring

/-- Triple-SPB formula algebraically. -/
theorem spb_triple_formula (x : ℝ) (hx : x^2 ≠ 1)
    (h2 : (2 * x / (1 - x^2)) * x ≠ 1) :
    ((2 * x / (1 - x^2)) + x) / (1 - (2 * x / (1 - x^2)) * x) =
    (3 * x - x^3) / (1 - 3 * x^2) := by
  have h1 : (1 - x^2) ≠ 0 := sub_ne_zero.mpr (Ne.symm hx)
  field_simp
  ring

/-- SPB approximates addition; the error is `xy(x+y)/(1-xy)`. -/
theorem spb_perturbation (x y : ℝ) (hxy : x * y ≠ 1) :
    (x + y) / (1 - x * y) - (x + y) = x * y * (x + y) / (1 - x * y) := by
  have h : (1 - x * y) ≠ 0 := sub_ne_zero.mpr (Ne.symm hxy)
  field_simp
  ring

/-- SpbH maps (-1,1) × (-1,1) into (-1,1): Einstein's velocity bound. -/
theorem spbH_internal_op (u v : ℝ) (hu : -1 < u) (hu' : u < 1)
    (hv : -1 < v) (hv' : v < 1) :
    -1 < (u + v) / (1 + u * v) ∧ (u + v) / (1 + u * v) < 1 := by
  have hd : 0 < 1 + u * v := by nlinarith
  constructor
  · rw [lt_div_iff₀ hd]; nlinarith
  · rw [div_lt_iff₀ hd]; nlinarith

/-- [Section: # CatalogBuild.Bridges.SPBFiniteFields
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 13] -/
theorem spb_right_cancel (x y : ℝ) (hxy : x * y ≠ 1) (hysq : y^2 ≠ 1) :
    ((x + y) / (1 - x * y) + (-y)) / (1 - (x + y) / (1 - x * y) * (-y)) = x := by
  rw [ div_eq_iff ];
  · grind;
  · -- Combine like terms and simplify the expression.
    field_simp;
    cases lt_or_gt_of_ne hxy <;> cases lt_or_gt_of_ne hysq <;> nlinarith [ mul_div_cancel₀ ( y * ( x + y ) ) ( by linarith : ( 1 - x * y ) ≠ 0 ) ]

/-- [Section: # CatalogBuild.Bridges.SPBFiniteFields
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 13] -/
theorem spb_deriv_positive (x y : ℝ) (hxy : x * y ≠ 1) :
    (1 + y^2) / (1 - x * y)^2 > 0 := by
  exact div_pos ( by positivity ) ( by contrapose! hxy; nlinarith )

/-- Quadruple SPB formula: tan(4θ) via two applications of doubling. -/
theorem spb_quadruple_formula (x : ℝ) (hx : x^2 ≠ 1) :
    let d := 2 * x / (1 - x^2)
    (d + d) / (1 - d * d) = 4 * x * (1 - x^2) / ((1 - x^2)^2 - 4 * x^2) := by
  simp only
  have h1 : (1 - x^2) ≠ 0 := sub_ne_zero.mpr (Ne.symm hx)
  field_simp
  ring

/-- SPB preserves positivity when xy < 1 and both positive. -/
theorem spb_pos_pos (x y : ℝ) (hx : 0 < x) (hy : 0 < y) (hxy : x * y < 1) :
    0 < (x + y) / (1 - x * y) := by
  exact div_pos (by linarith) (by linarith)

/-- SPB of opposite signs: if 0 < x < y and xy < 1, then spb(x, -y) < 0. -/
theorem spb_pos_neg (x y : ℝ) (hx : 0 < x) (hy : x < y) :
    (x + (-y)) / (1 - x * (-y)) < 0 := by
  apply div_neg_of_neg_of_pos
  · linarith
  · nlinarith

/-- The quintuple angle formula via SPB:
tan(5θ) = (5t - 10t³ + t⁵) / (1 - 10t² + 5t⁴) where t = tan θ. -/
theorem spb_quintuple_numerator (t : ℝ) :
    5 * t - 10 * t^3 + t^5 = t * (5 - 10 * t^2 + t^4) := by ring

theorem spb_quintuple_denominator (t : ℝ) :
    1 - 10 * t^2 + 5 * t^4 = 1 - 10 * t^2 + 5 * t^4 := by ring

end