import Probability.AbstractAlgebra.SpbCore

/-! # `spb` as the tangent addition law, and the Cayley transform

The operation `spb x y = (x + y)/(1 - xy)` of `Shared.AbstractAlgebra.SpbCore` is
exactly the tangent addition law, and it is turned into ordinary multiplication by
the Cayley transform `c(x) = (1 + i x)/(1 - i x)`.  This file proves:

* `tan_add_eq_spb` : `tan (a + b) = spb (tan a) (tan b)` whenever `cos a, cos b ≠ 0`
  — including the degenerate case `cos (a + b) = 0`, where both sides vanish;
* the double- and triple-angle instances, the cocycle identity, and
  `SPB.spb_cayley : cayley (spb x y) = cayley x * cayley y`.

The auto-generated catalog files `Shared.AbstractAlgebra.Spb_zero_left` and
`Shared.AbstractAlgebra.Spb_zero_right` state these results (in the namespace
`SPB`) before the definitions they need; they now re-export this module.
-/

noncomputable section

open Real

/-- **`spb` is the tangent addition law.**  No hypothesis on `cos (a + b)` is
needed: when `cos (a + b) = 0` both sides are zero, because `1 - tan a * tan b`
then vanishes as well. -/
theorem tan_add_eq_spb (a b : ℝ) (ha : Real.cos a ≠ 0) (hb : Real.cos b ≠ 0) :
    Real.tan (a + b) = spb (Real.tan a) (Real.tan b) := by
  have hkey : 1 - Real.tan a * Real.tan b
      = Real.cos (a + b) / (Real.cos a * Real.cos b) := by
    rw [Real.cos_add, Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
    field_simp
  by_cases hab : Real.cos (a + b) = 0
  · have h1 : 1 - Real.tan a * Real.tan b = 0 := by rw [hkey, hab]; simp
    rw [Real.tan_eq_sin_div_cos, hab, spb, h1]
    simp
  · have h1 : 1 - Real.tan a * Real.tan b ≠ 0 := by
      rw [hkey]
      exact div_ne_zero hab (mul_ne_zero ha hb)
    rw [spb, eq_div_iff h1, hkey, Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos,
      Real.tan_eq_sin_div_cos, Real.sin_add]
    field_simp

/-- The Cayley transform of a real number, a point of the unit circle. -/
def cayley (x : ℝ) : ℂ := (1 + Complex.I * x) / (1 - Complex.I * x)

theorem cayley_den_ne_zero (x : ℝ) : (1 : ℂ) - Complex.I * x ≠ 0 := by
  intro h
  have : ((1 : ℂ) - Complex.I * x).re = 0 := by rw [h]; simp
  simp at this

namespace SPB

/-- Zero is a left identity for SPB. -/
theorem spb_zero_left (x : ℝ) : spb 0 x = x := _root_.spb_zero_left x

/-- Zero is a right identity for SPB. -/
theorem spb_zero_right (x : ℝ) : spb x 0 = x := _root_.spb_zero_right x

/-- SPB is commutative. -/
theorem spb_comm (x y : ℝ) : spb x y = spb y x := _root_.spb_comm x y

/-- The SPB inverse of `x` is `-x`: `spb(x, -x) = 0`. -/
theorem spb_neg_self (x : ℝ) : spb x (-x) = 0 := spb_neg_right x

/-- SPB distributes over negation: `spb(-x, -y) = -spb(x, y)`. -/
theorem spb_neg_neg (x y : ℝ) : spb (-x) (-y) = -spb x y := spb_odd x y

/-- SPB of `x` with itself gives the double formula: `2x/(1-x²)`. -/
theorem spb_self (x : ℝ) (_h : x * x ≠ 1) : spb x x = 2 * x / (1 - x * x) :=
  _root_.spb_double x

theorem spb_assoc (x y z : ℝ) (hxy : x * y ≠ 1) (hyz : y * z ≠ 1)
    (hxyz : x * spb y z ≠ 1) (hxyz' : spb x y * z ≠ 1) :
    spb (spb x y) z = spb x (spb y z) :=
  _root_.spb_assoc x y z (sub_ne_zero.mpr (Ne.symm hxy)) (sub_ne_zero.mpr (Ne.symm hyz))
    (sub_ne_zero.mpr (Ne.symm hxyz')) (sub_ne_zero.mpr (Ne.symm hxyz))

theorem spb_cancel_right (x y : ℝ) (hxy : x * y ≠ 1)
    (_hy : y ^ 2 ≠ 1) (_h : spb x y * (-y) ≠ 1) :
    spb (spb x y) (-y) = x :=
  _root_.spb_cancel_right x y (sub_ne_zero.mpr (Ne.symm hxy)) (by positivity)

/-- The `spb` cocycle identity. -/
theorem spb_cocycle (x y z : ℝ) (hxy : x * y ≠ 1) (hyz : y * z ≠ 1) :
    (1 - x * y) * (1 - spb x y * z) = (1 - y * z) * (1 - x * spb y z) := by
  rw [spb_three_body x y z (sub_ne_zero.mpr (Ne.symm hxy)), mul_comm x (spb y z),
    spb_three_body y z x (sub_ne_zero.mpr (Ne.symm hyz))]
  ring

theorem spb_tan_add (a b : ℝ) (ha : Real.cos a ≠ 0) (hb : Real.cos b ≠ 0)
    (_hab : Real.cos (a + b) ≠ 0) :
    Real.tan (a + b) = spb (Real.tan a) (Real.tan b) :=
  tan_add_eq_spb a b ha hb

theorem spb_double (a : ℝ) (ha : Real.cos a ≠ 0) (_h2a : Real.cos (2 * a) ≠ 0) :
    Real.tan (2 * a) = spb (Real.tan a) (Real.tan a) := by
  rw [two_mul]
  exact tan_add_eq_spb a a ha ha

theorem spb_triple (a : ℝ) (ha : Real.cos a ≠ 0) (h2a : Real.cos (2 * a) ≠ 0)
    (_h3a : Real.cos (3 * a) ≠ 0)
    (_h12 : Real.tan a * Real.tan a ≠ 1)
    (_h_spb : spb (Real.tan a) (Real.tan a) * Real.tan a ≠ 1) :
    Real.tan (3 * a) = spb (spb (Real.tan a) (Real.tan a)) (Real.tan a) := by
  have h3 : (3 : ℝ) * a = 2 * a + a := by ring
  rw [h3, tan_add_eq_spb (2 * a) a h2a ha, spb_double a ha h2a]

/-- **The Cayley transform linearises `spb`.** -/
theorem spb_cayley (x y : ℝ) (hxy : x * y ≠ 1) :
    cayley (spb x y) = cayley x * cayley y := by
  have hd : (1 : ℝ) - x * y ≠ 0 := sub_ne_zero.mpr (Ne.symm hxy)
  have hdC : ((1 : ℂ) - (x : ℂ) * (y : ℂ)) ≠ 0 := by
    simpa using (Complex.ofReal_ne_zero.mpr hd)
  have hs : ((spb x y : ℝ) : ℂ) = ((x : ℂ) + (y : ℂ)) / (1 - (x : ℂ) * (y : ℂ)) := by
    rw [spb]; push_cast; ring
  have hden : ((1 : ℂ) - (x : ℂ) * (y : ℂ)) - Complex.I * ((x : ℂ) + (y : ℂ))
      = (1 - Complex.I * x) * (1 - Complex.I * y) := by
    have : Complex.I * Complex.I = -1 := Complex.I_mul_I
    linear_combination (-(x : ℂ) * (y : ℂ)) * this
  have hnum : ((1 : ℂ) - (x : ℂ) * (y : ℂ)) + Complex.I * ((x : ℂ) + (y : ℂ))
      = (1 + Complex.I * x) * (1 + Complex.I * y) := by
    have : Complex.I * Complex.I = -1 := Complex.I_mul_I
    linear_combination (-(x : ℂ) * (y : ℂ)) * this
  have hdenne : ((1 : ℂ) - (x : ℂ) * (y : ℂ)) - Complex.I * ((x : ℂ) + (y : ℂ)) ≠ 0 := by
    rw [hden]
    exact mul_ne_zero (cayley_den_ne_zero x) (cayley_den_ne_zero y)
  have h1 : (1 : ℂ) + Complex.I * ((spb x y : ℝ) : ℂ)
      = (((1 : ℂ) - (x : ℂ) * (y : ℂ)) + Complex.I * ((x : ℂ) + (y : ℂ)))
        / (1 - (x : ℂ) * (y : ℂ)) := by
    rw [hs]; field_simp
  have h2 : (1 : ℂ) - Complex.I * ((spb x y : ℝ) : ℂ)
      = (((1 : ℂ) - (x : ℂ) * (y : ℂ)) - Complex.I * ((x : ℂ) + (y : ℂ)))
        / (1 - (x : ℂ) * (y : ℂ)) := by
    rw [hs]; field_simp
  have hquot : ∀ p r q : ℂ, q ≠ 0 → r ≠ 0 → (p / q) / (r / q) = p / r := by
    intro p r q hq hr; field_simp
  unfold cayley
  rw [h1, h2, hquot _ _ _ hdC hdenne, hnum, hden, div_mul_div_comm]

end SPB

end