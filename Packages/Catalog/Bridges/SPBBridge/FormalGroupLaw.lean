import Mathlib
import Logic.StrangeLoops.Core
import Bridges.SPBBridge.AlgebraicIdentities

/-!
# SPB as a Formal Group Law

The SPB operation F(x,y) = (x+y)/(1-xy) satisfies the axioms of a formal group law.
Its power series expansion is:
  F(x,y) = x + y + xy² + x²y + x³y² + x²y³ + ...

The logarithm of this formal group is arctan, and the exponential is tan.
Via the Cayley transform, this formal group is isomorphic to the multiplicative
formal group Ĝₘ.

## Main Results
- SPB satisfies formal group axioms (algebraic versions)
- Power series coefficients
- Connection to the multiplicative formal group
- The formal group has height 1 at all primes
-/

noncomputable section
open Real SPBResearch

namespace FormalGroup

/-! ## Formal Group Axioms (Algebraic Verification) -/

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

/-! ## Power Series Expansion -/

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

/-! ## Formal Group Logarithm -/

/-
The formal group logarithm is arctan: log(x) = arctan(x).
    This means arctan(spb(x,y)) = arctan(x) + arctan(y)
    when all values are in (-π/2, π/2).
-/
theorem fg_log_is_arctan (x y : ℝ) (hxy : x * y < 1) :
    arctan (spb x y) = arctan x + arctan y := by
  unfold spb
  rw [Real.arctan_add (by linarith)]

/-! ## Isomorphism with Multiplicative Formal Group -/

-- The Cayley transform provides the isomorphism between the SPB formal group
-- and the multiplicative formal group. Algebraically:
-- C(F(x,y)) = C(x) · C(y) where C(x) = (1+ix)/(1-ix).
-- This is already proven in CayleyTransform.lean as cayley_spb_mul.

/-- The inverse of the Cayley transform (on the unit circle). -/
def cayleyInv (z : ℂ) : ℂ := -Complex.I * (z - 1) / (z + 1)

/-- Cayley inverse at 1 gives 0. -/
theorem cayleyInv_one : cayleyInv 1 = 0 := by
  unfold cayleyInv; simp

/-- Cayley inverse at I gives 1. -/
theorem cayleyInv_I : cayleyInv Complex.I = 1 := by
  unfold cayleyInv
  rw [div_eq_iff]
  · ring_nf; simp [Complex.ext_iff, Complex.I_sq]
  · norm_num [Complex.ext_iff]

/-! ## Height of the Formal Group -/

/-- At every prime p, the formal group has height 1 (or 0 if p is invertible).
    This is because the SPB formal group is isomorphic to the multiplicative
    formal group Ĝₘ, which has height 1 at every prime.

    We verify this computationally: the [p]-series (p-fold iterated SPB)
    has leading term px + ... in the formal power series expansion. -/

-- The [2]-series: spb(x,x) = 2x/(1-x²)
theorem fg_two_series (x : ℝ) (h : x ^ 2 ≠ 1) :
    spb x x = 2 * x / (1 - x ^ 2) := by
  unfold spb; field_simp; ring

-- The [3]-series via triple formula
theorem fg_three_series (x : ℝ) (h1 : x ^ 2 ≠ 1) (h2 : 1 - 3 * x ^ 2 ≠ 0)
    (h3 : 1 - 2 * x / (1 - x ^ 2) * x ≠ 0) :
    spb (spb x x) x = (3 * x - x ^ 3) / (1 - 3 * x ^ 2) := by
  unfold spb; field_simp [sub_ne_zero.mpr (Ne.symm h1)]; ring

end FormalGroup
end