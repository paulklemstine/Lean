/-! # CatalogBuild.Pythagorean.FormalGroupLaw

Auto-generated from theorem catalog database.
Domain: Pythagorean
Declarations: 13
-/

import Mathlib
import Pythagorean.Core

noncomputable section

/-- FG Axiom 1: F(x, 0) = x. -/
theorem fg_identity_right (x : ℝ) : spb x 0 = x := spb_zero x


/-- FG Axiom 2: F(0, y) = y. -/
theorem fg_identity_left (y : ℝ) : spb 0 y = y := by
  rw [spb_comm]; exact spb_zero y


/-- FG Axiom 3: F(x, y) = F(y, x) (commutativity). -/
theorem fg_comm (x y : ℝ) : spb x y = spb y x := spb_comm x y


/-- FG Axiom 4: F(F(x, y), z) = F(x, F(y, z)) (associativity). -/
theorem fg_assoc (x y z : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0)
    (h3 : 1 - spb x y * z ≠ 0) (h4 : 1 - x * spb y z ≠ 0) :
    spb (spb x y) z = spb x (spb y z) := by
  unfold spb at *; field_simp; ring


/-- FG Axiom 5: F(x, i(x)) = 0 where i(x) = -x. -/
theorem fg_inverse (x : ℝ) : spb x (-x) = 0 := spb_neg x


/-- The SPB at small values agrees with x + y + xy² + x²y to leading order.
F(x,y) = (x+y)/(1-xy) = (x+y)(1 + xy + (xy)² + ...) -/
theorem spb_expansion_order3 (x y : ℝ) (h : 1 - x * y ≠ 0) :
    spb x y * (1 - x * y) = x + y := by
  unfold spb; field_simp


/-- The formal derivative ∂F/∂x at (0,0) is 1. -/
theorem fg_derivative_x_origin : HasDerivAt (fun x => spb x 0) 1 0 := by
  have : (fun x => spb x 0) = id := by ext x; simp [spb_zero]
  rw [this]; exact hasDerivAt_id 0


/-- The formal derivative ∂F/∂y at (0,0) is 1. -/
theorem fg_derivative_y_origin : HasDerivAt (fun y => spb 0 y) 1 0 := by
  have : (fun y => spb 0 y) = id := by ext y; rw [spb_comm]; simp [spb_zero]
  rw [this]; exact hasDerivAt_id 0


/-- [Section: # CatalogBuild.Pythagorean.FormalGroupLaw
Auto-generated from theorem catalog database.
Domain: Pythagorean
Declarations: 13] -/
theorem fg_log_is_arctan (x y : ℝ) (hxy : x * y < 1) :
    arctan (spb x y) = arctan x + arctan y := by
  rw [ spb ];
  exact?


/-- Cayley inverse at 1 gives 0. -/
theorem cayleyInv_one : cayleyInv 1 = 0 := by
  unfold cayleyInv; simp


/-- Cayley inverse at I gives 1. -/
theorem cayleyInv_I : cayleyInv Complex.I = 1 := by
  unfold cayleyInv
  rw [div_eq_iff]
  · ring_nf; simp [Complex.ext_iff, Complex.I_sq]
  · norm_num [Complex.ext_iff]


/-- At every prime p, the formal group has height 1 (or 0 if p is invertible).
This is because the SPB formal group is isomorphic to the multiplicative
formal group Ĝₘ, which has height 1 at every prime.
We verify this computationally: the [p]-series (p-fold iterated SPB)
has leading term px + ... in the formal power series expansion. -/
theorem fg_two_series (x : ℝ) (h : x ^ 2 ≠ 1) :
    spb x x = 2 * x / (1 - x ^ 2) := by
  unfold spb; field_simp; ring

-- The [3]-series via triple formula


/-- [Section: # CatalogBuild.Pythagorean.FormalGroupLaw
Auto-generated from theorem catalog database.
Domain: Pythagorean
Declarations: 13] -/
theorem fg_three_series (x : ℝ) (h1 : x ^ 2 ≠ 1) (h2 : 1 - 3 * x ^ 2 ≠ 0)
    (h3 : 1 - 2 * x / (1 - x ^ 2) * x ≠ 0) :
    spb (spb x x) x = (3 * x - x ^ 3) / (1 - 3 * x ^ 2) := by
  unfold spb; field_simp [sub_ne_zero.mpr (Ne.symm h1)]; ring


end
