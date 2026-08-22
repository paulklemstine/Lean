-- Repaired copy: this module was a stale, non-compiling duplicate of `Shared.AbstractAlgebra.Spb_zero_left`.
-- Its content is synchronised with that (compiling) module.
import Mathlib

open Real

/-! # CatalogBuild.Shared.Spb_zero_left

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 14
-/


noncomputable section

/-- The Cayley transform `cayley x = (1 + x i) / (1 - x i)`. -/
def cayley (x : ℝ) : ℂ := (1 + x * Complex.I) / (1 - x * Complex.I)

/-- The SPB (Stereographic Projection Bridge) operation.
`spb x y = (x + y) / (1 - x * y)` -/
def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

theorem spb_assoc (x y z : ℝ) (hxy : x * y ≠ 1) (hyz : y * z ≠ 1)
    (hxyz : x * spb y z ≠ 1) (hxyz' : spb x y * z ≠ 1) :
    spb (spb x y) z = spb x (spb y z) := by
  rw [ spb, spb ];
  rw [ div_add', div_mul_eq_mul_div, sub_div' ];
  · rw [ div_div_div_cancel_right₀ ( sub_ne_zero_of_ne <| Ne.symm hxy ) ];
    rw [ spb, div_eq_div_iff ];
    · unfold spb; ring;
      cases lt_or_gt_of_ne hyz <;> nlinarith [ inv_mul_cancel_left₀ ( by linarith : ( 1 - y * z ) ≠ 0 ) x, inv_mul_cancel_left₀ ( by linarith : ( 1 - y * z ) ≠ 0 ) y, inv_mul_cancel_left₀ ( by linarith : ( 1 - y * z ) ≠ 0 ) z ];
    · contrapose! hxyz';
      rw [ spb, div_mul_eq_mul_div, div_eq_iff ] <;> cases lt_or_gt_of_ne hxy <;> cases lt_or_gt_of_ne hyz <;> nlinarith;
    · exact sub_ne_zero_of_ne <| Ne.symm hxyz;
  · contrapose! hxy; linarith;
  · contrapose! hxy; linarith

/-- The SPB inverse of `x` is `-x`: `spb(x, -x) = 0`. -/
theorem spb_neg_self (x : ℝ) : spb x (-x) = 0 := by
  simp [spb]

theorem spb_tan_add (a b : ℝ) (ha : cos a ≠ 0) (hb : cos b ≠ 0)
    (hab : cos (a + b) ≠ 0) :
    tan (a + b) = spb (tan a) (tan b) := by
  unfold spb;
  simp_all +decide [ Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add ];
  grind

/-- SPB of `x` with itself gives the double formula: `2x/(1-x²)`. -/
theorem spb_self (x : ℝ) (h : x * x ≠ 1) : spb x x = 2 * x / (1 - x * x) := by
  have h1 : 1 - x * x ≠ 0 := sub_ne_zero.mpr (Ne.symm h)
  simp [spb]
  rw [div_eq_div_iff h1 h1]
  ring

/-- SPB distributes over negation: `spb(-x, -y) = -spb(x, y)`. -/
theorem spb_neg_neg (x y : ℝ) : spb (-x) (-y) = -spb x y := by
  simp [spb, neg_mul, neg_neg]
  ring_nf

theorem spb_cancel_right (x y : ℝ) (hxy : x * y ≠ 1)
    (hy : y ^ 2 ≠ 1) (h : spb x y * (-y) ≠ 1) :
    spb (spb x y) (-y) = x := by
  unfold spb at *;
  rw [ div_eq_iff ];
  · linarith [ div_mul_cancel₀ ( x + y ) ( sub_ne_zero_of_ne <| Ne.symm hxy ) ];
  · grind +locals

/-- SPB is commutative. -/
theorem spb_comm (x y : ℝ) : spb x y = spb y x := by
  simp [spb, add_comm, mul_comm]

/-- Zero is a right identity for SPB. -/
theorem spb_zero_right (x : ℝ) : spb x 0 = x := by
  simp [spb]

theorem spb_triple (a : ℝ) (ha : cos a ≠ 0) (h2a : cos (2 * a) ≠ 0)
    (h3a : cos (3 * a) ≠ 0)
    (h12 : tan a * tan a ≠ 1) (h_spb : spb (tan a) (tan a) * tan a ≠ 1) :
    tan (3 * a) = spb (spb (tan a) (tan a)) (tan a) := by
  norm_num [ ( by ring : 3 * a = 2 * a + a ), Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add, Real.sin_two_mul, Real.cos_two_mul' ] at *;
  unfold spb;
  field_simp;
  ring

theorem spb_cocycle (x y z : ℝ) (hxy : x * y ≠ 1) (hyz : y * z ≠ 1) :
    (1 - x * y) * (1 - spb x y * z) = (1 - y * z) * (1 - x * spb y z) := by
  unfold spb;
  grind

theorem spb_cayley (x y : ℝ) (hxy : x * y ≠ 1) :
    cayley (spb x y) = cayley x * cayley y := by
  unfold cayley spb;
  norm_num [ Complex.ext_iff, div_eq_mul_inv ];
  norm_num [ Complex.normSq ] ; ring;
  grind

/-- Zero is a left identity for SPB. -/
theorem spb_zero_left (x : ℝ) : spb 0 x = x := by
  simp [spb]

theorem spb_double (a : ℝ) (ha : cos a ≠ 0) (h2a : cos (2 * a) ≠ 0) :
    tan (2 * a) = spb (tan a) (tan a) := by
  convert spb_tan_add a a _ _ _ using 1 <;> simp_all +decide [ Real.tan_eq_sin_div_cos, Real.sin_two_mul, Real.cos_two_mul ];
  · rw [ Real.sin_add, Real.cos_add ] ; ring;
    rw [ Real.sin_sq ] ; ring;
  · rw [ ← two_mul, Real.cos_two_mul ] ; aesop

end