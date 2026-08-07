import Mathlib

/-! # CatalogBuild.Shared.Spb_zero_right

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 14

The `spb` ("stereographic projection bridge") operation is the tangent addition law,
`spb x y = (x + y) / (1 - x * y)`.  This file establishes its algebraic structure
(commutativity, identity, inverses, associativity), its trigonometric realisation,
and the fact that the Cayley transform intertwines `spb` with multiplication on the
unit circle.
-/

noncomputable section

open Real

/-- The SPB (Stereographic Projection Bridge) operation.
`spb x y = (x + y) / (1 - x * y)` -/
def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The Cayley transform sending a real number to a point of the unit circle. -/
def cayley (x : ℝ) : ℂ := (1 + (x : ℂ) * Complex.I) / (1 - (x : ℂ) * Complex.I)

/-- The denominator of the Cayley transform never vanishes. -/
theorem one_sub_real_mul_I_ne_zero (t : ℝ) : (1 : ℂ) - (t : ℂ) * Complex.I ≠ 0 := by
  intro h
  have := congrArg Complex.re h
  simp at this

/-- Zero is a left identity for SPB. -/
theorem spb_zero_left (x : ℝ) : spb 0 x = x := by
  simp [spb]

theorem spb_assoc (x y z : ℝ) (hxy : x * y ≠ 1) (hyz : y * z ≠ 1)
    (hxyz : x * spb y z ≠ 1) (hxyz' : spb x y * z ≠ 1) :
    spb (spb x y) z = spb x (spb y z) := by
  have hA : (1:ℝ) - x * y ≠ 0 := sub_ne_zero.mpr (Ne.symm hxy)
  have hB : (1:ℝ) - y * z ≠ 0 := sub_ne_zero.mpr (Ne.symm hyz)
  have h1 : (1:ℝ) - spb x y * z ≠ 0 := sub_ne_zero.mpr (Ne.symm hxyz')
  have h2 : (1:ℝ) - x * spb y z ≠ 0 := sub_ne_zero.mpr (Ne.symm hxyz)
  have hD : (1:ℝ) - x * y - y * z - x * z ≠ 0 := by
    have e : (1 - x * y) * (1 - spb x y * z) = 1 - x * y - y * z - x * z := by
      unfold spb; field_simp; ring
    rw [← e]; exact mul_ne_zero hA h1
  have e1 : spb (spb x y) z = (x + y + z - x * y * z) / (1 - x * y - y * z - x * z) := by
    unfold spb at h1 ⊢
    rw [div_eq_div_iff (by intro h; exact h1 (by rw [h])) hD]
    field_simp
    ring
  have e2 : spb x (spb y z) = (x + y + z - x * y * z) / (1 - x * y - y * z - x * z) := by
    unfold spb at h2 ⊢
    rw [div_eq_div_iff (by intro h; exact h2 (by rw [h])) hD]
    field_simp
    ring
  rw [e1, e2]

theorem spb_tan_add (a b : ℝ) (ha : cos a ≠ 0) (hb : cos b ≠ 0)
    (hab : cos (a + b) ≠ 0) :
    tan (a + b) = spb (tan a) (tan b) := by
  have hab' : cos a * cos b - sin a * sin b ≠ 0 := by rwa [Real.cos_add] at hab
  unfold spb
  rw [Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos,
    Real.sin_add, Real.cos_add]
  rw [div_eq_div_iff hab' (by
    have h : 1 - sin a / cos a * (sin b / cos b)
        = (cos a * cos b - sin a * sin b) / (cos a * cos b) := by field_simp
    rw [h]
    exact div_ne_zero hab' (mul_ne_zero ha hb))]
  field_simp

theorem spb_double (a : ℝ) (ha : cos a ≠ 0) (h2a : cos (2 * a) ≠ 0) :
    tan (2 * a) = spb (tan a) (tan a) := by
  have h : (2:ℝ) * a = a + a := by ring
  rw [h] at h2a ⊢
  exact spb_tan_add a a ha ha h2a

/-- The SPB inverse of `x` is `-x`: `spb(x, -x) = 0`. -/
theorem spb_neg_self (x : ℝ) : spb x (-x) = 0 := by
  simp [spb]

/-- SPB of `x` with itself gives the double formula: `2x/(1-x²)`. -/
theorem spb_self (x : ℝ) (h : x * x ≠ 1) : spb x x = 2 * x / (1 - x * x) := by
  unfold spb; ring

/-- SPB distributes over negation: `spb(-x, -y) = -spb(x, y)`. -/
theorem spb_neg_neg (x y : ℝ) : spb (-x) (-y) = -spb x y := by
  unfold spb; ring

theorem spb_cancel_right (x y : ℝ) (hxy : x * y ≠ 1)
    (hy : y ^ 2 ≠ 1) (h : spb x y * (-y) ≠ 1) :
    spb (spb x y) (-y) = x := by
  have hA : (1:ℝ) - x * y ≠ 0 := sub_ne_zero.mpr (Ne.symm hxy)
  have hy2 : (1:ℝ) + y ^ 2 ≠ 0 := by positivity
  unfold spb
  rw [show (1 - (x + y) / (1 - x * y) * -y) = (1 + y ^ 2) / (1 - x * y) from by
    field_simp; ring]
  rw [show ((x + y) / (1 - x * y) + -y) = x * (1 + y ^ 2) / (1 - x * y) from by
    field_simp; ring]
  field_simp

/-- SPB is commutative. -/
theorem spb_comm (x y : ℝ) : spb x y = spb y x := by
  unfold spb; ring

/-- Zero is a right identity for SPB. -/
theorem spb_zero_right (x : ℝ) : spb x 0 = x := by
  simp [spb]

theorem spb_triple (a : ℝ) (ha : cos a ≠ 0) (h2a : cos (2 * a) ≠ 0)
    (h3a : cos (3 * a) ≠ 0) :
    tan (3 * a) = spb (spb (tan a) (tan a)) (tan a) := by
  have h : (3:ℝ) * a = 2 * a + a := by ring
  rw [h] at h3a ⊢
  rw [spb_tan_add (2 * a) a h2a ha h3a, spb_double a ha h2a]

theorem spb_cocycle (x y z : ℝ) (hxy : x * y ≠ 1) (hyz : y * z ≠ 1) :
    (1 - x * y) * (1 - spb x y * z) = (1 - y * z) * (1 - x * spb y z) := by
  have hA : (1:ℝ) - x * y ≠ 0 := sub_ne_zero.mpr (Ne.symm hxy)
  have hB : (1:ℝ) - y * z ≠ 0 := sub_ne_zero.mpr (Ne.symm hyz)
  unfold spb; field_simp; ring

/-- The Cayley transform turns the SPB law into multiplication. -/
theorem spb_cayley (x y : ℝ) (hxy : x * y ≠ 1) :
    cayley (spb x y) = cayley x * cayley y := by
  have hA : (1:ℝ) - x * y ≠ 0 := sub_ne_zero.mpr (Ne.symm hxy)
  have hAc : (1:ℂ) - (x:ℂ) * (y:ℂ) ≠ 0 := by
    intro h
    apply hA
    have : ((1 - x * y : ℝ) : ℂ) = 0 := by push_cast; linear_combination h
    exact_mod_cast this
  have hsA : ((spb x y : ℝ) : ℂ) * (1 - (x:ℂ) * (y:ℂ)) = (x:ℂ) + (y:ℂ) := by
    unfold spb; push_cast; field_simp
  unfold cayley
  rw [div_mul_div_comm, div_eq_div_iff (one_sub_real_mul_I_ne_zero _)
    (mul_ne_zero (one_sub_real_mul_I_ne_zero x) (one_sub_real_mul_I_ne_zero y))]
  linear_combination (2 * Complex.I) * hsA
    + (2 * ((spb x y : ℝ) : ℂ) * (x:ℂ) * (y:ℂ) * Complex.I) * Complex.I_sq

end