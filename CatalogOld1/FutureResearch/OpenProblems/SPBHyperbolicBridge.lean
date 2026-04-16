import Mathlib

/-!
# The SPB–Hyperbolic Bridge: Wick Rotation and Einstein Velocity Addition

## Main Results

The sign flip in the SPB denominator (1-xy → 1+xy) transforms the circular SPB
into the hyperbolic SPB, which IS Einstein's relativistic velocity addition (c=1).

We prove:
1. spbH is associative, commutative, with identity 0 and inverse -x
2. The velocity bound: |spbH(u,v)| < 1 for |u|, |v| < 1
3. The rapidity product formula connecting to artanh
4. The norm identity (1+xy)²(1-spbH²) = (1-x²)(1-y²)
-/

noncomputable section

open Real

/-- Hyperbolic SPB (Einstein velocity addition with c=1). -/
def spbHyp (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-- Circular SPB (tangent addition). -/
def spbCirc (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

theorem spbHyp_comm (x y : ℝ) : spbHyp x y = spbHyp y x := by
  simp [spbHyp, add_comm, mul_comm]

theorem spbHyp_zero (x : ℝ) : spbHyp x 0 = x := by simp [spbHyp]

theorem spbHyp_neg (x : ℝ) : spbHyp x (-x) = 0 := by simp [spbHyp]

theorem spbHyp_assoc (x y z : ℝ)
    (h1 : 1 + x * y ≠ 0) (h2 : 1 + y * z ≠ 0)
    (h3 : 1 + spbHyp x y * z ≠ 0) (h4 : 1 + x * spbHyp y z ≠ 0) :
    spbHyp (spbHyp x y) z = spbHyp x (spbHyp y z) := by
  simp only [spbHyp]; field_simp; ring

/-- 1 - spbH(u,v)² has a nice factored form. -/
theorem spbHyp_one_minus_sq (u v : ℝ) (h : 1 + u * v ≠ 0) :
    1 - spbHyp u v ^ 2 = (1 - u ^ 2) * (1 - v ^ 2) / (1 + u * v) ^ 2 := by
  unfold spbHyp; field_simp; ring

/-
Einstein velocity addition preserves the speed-of-light bound.
-/
theorem spbHyp_velocity_bound (u v : ℝ) (hu : |u| < 1) (hv : |v| < 1) :
    |spbHyp u v| < 1 := by
  exact abs_lt.mpr ⟨ by rw [ spbHyp ] ; rw [ lt_div_iff₀ ] <;> nlinarith [ abs_lt.mp hu, abs_lt.mp hv ], by rw [ spbHyp ] ; rw [ div_lt_iff₀ ] <;> nlinarith [ abs_lt.mp hu, abs_lt.mp hv ] ⟩

/-- The rapidity product formula:
    (1+spbH)/(1-spbH) = ((1+x)/(1-x))·((1+y)/(1-y)). -/
theorem rapidity_product (x y : ℝ)
    (hx : x ≠ 1) (hy : y ≠ 1) (hxy : 1 + x * y ≠ 0)
    (hs : spbHyp x y ≠ 1) :
    (1 + spbHyp x y) / (1 - spbHyp x y) =
    ((1 + x) / (1 - x)) * ((1 + y) / (1 - y)) := by
  unfold spbHyp; field_simp; ring

/-- The hyperbolic norm identity. -/
theorem spbHyp_norm_identity (x y : ℝ) (h : 1 + x * y ≠ 0) :
    (1 + x * y) ^ 2 * (1 - spbHyp x y ^ 2) = (1 - x ^ 2) * (1 - y ^ 2) := by
  unfold spbHyp; field_simp; ring

end