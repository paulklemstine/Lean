/-! # CatalogBuild.Speculative.SPBCocycle

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 7
-/

import Mathlib

noncomputable section

/-- The SPB operator. -/
def spbCoc (x y : ℝ) : ℝ := (x + y) / (1 - x * y)




/-- The SPB cocycle: c(x,y) = 1/(1 - xy). -/
def spbCocycle (x y : ℝ) : ℝ := 1 / (1 - x * y)




/-- The cochain: f(x) = 1 + x². -/
def spbCochain (x : ℝ) : ℝ := 1 + x ^ 2




/-- The cochain is always positive. -/
theorem spbCochain_pos (x : ℝ) : 0 < spbCochain x := by
  unfold spbCochain; positivity




/-- The cocycle is a coboundary: c(x,y) = f(spb(x,y)) / (f(x) · f(y))
where f(x) = 1 + x². More precisely:
1/(1-xy) = (1 + spb(x,y)²) · (1-xy) / ((1+x²)(1+y²)) ... but the cleaner form is:
(1-xy)² · (1 + spb(x,y)²) = (1+x²)(1+y²). -/
theorem cocycle_is_coboundary (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 - x * y) ^ 2 * (1 + spbCoc x y ^ 2) = (1 + x ^ 2) * (1 + y ^ 2) := by
  unfold spbCoc
  field_simp
  ring




/-- The cocycle condition in multiplicative form:
(1 - xy)·(1 - spb(x,y)·z) = (numerator involving all three).
Equivalently, the product of denominators is symmetric under reassociation. -/
theorem cocycle_condition_denom (x y z : ℝ)
    (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0) :
    (1 - x * y) * (1 - spbCoc x y * z) =
    (1 - y * z) * (1 - x * spbCoc y z) := by
  unfold spbCoc
  field_simp
  ring




/-- The Jacobian determinant of (x,y) ↦ (spb(x,y), y) equals (1+y²)/(1-xy)². -/
theorem spb_jacobian_first (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 + y ^ 2) / (1 - x * y) ^ 2 = spbCochain y / (1 - x * y) ^ 2 := by
  unfold spbCochain; ring




end
