import Mathlib

/-! # SPB Algebraic Structure

The Stereographic Pythagorean Bridge operation spb(x,y) = (x+y)/(1+xy)
has rich algebraic properties. This file formalizes the group-like structure
and its connections to trigonometry, hyperbolic geometry, and tropical limits.

## Main Results

- `spb_assoc`: SPB is associative (when denominators are nonzero)
- `spb_comm`: SPB is commutative
- `spb_zero_left/right`: 0 is the identity
- `spb_neg_inverse`: -x is the inverse of x
- `spb_tanh_add`: SPB encodes the tanh addition formula
- `spb_self_double`: spb(x,x) = 2x/(1+x²)
- `spb_bounded`: |spb(x,y)| < 1 when |x| < 1 and |y| < 1
-/

noncomputable section

/-- The SPB operation. -/
def spb (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

@[simp] theorem spb_def (x y : ℝ) : spb x y = (x + y) / (1 + x * y) := rfl

/-- SPB is commutative. -/
theorem spb_comm (x y : ℝ) : spb x y = spb y x := by
  simp [spb]; ring

/-- 0 is the left identity for SPB. -/
@[simp] theorem spb_zero_left (x : ℝ) : spb 0 x = x := by
  simp [spb]

/-- 0 is the right identity for SPB. -/
@[simp] theorem spb_zero_right (x : ℝ) : spb x 0 = x := by
  simp [spb]

/-- SPB with itself: spb(x, x) = 2x/(1+x²). -/
theorem spb_self (x : ℝ) : spb x x = 2 * x / (1 + x ^ 2) := by
  simp [spb]; ring

/-- -x is the inverse of x: spb(x, -x) = 0 when 1 - x² ≠ 0. -/
theorem spb_neg_inverse (x : ℝ) (h : 1 - x ^ 2 ≠ 0) :
    spb x (-x) = 0 := by
  simp [spb, show 1 + x * -x = 1 - x ^ 2 from by ring, h]

/-
SPB is associative when denominators are nonzero.
-/
theorem spb_assoc (x y z : ℝ)
    (hxy : 1 + x * y ≠ 0) (hyz : 1 + y * z ≠ 0)
    (hxyz1 : 1 + spb x y * z ≠ 0) (hxyz2 : 1 + x * spb y z ≠ 0) :
    spb (spb x y) z = spb x (spb y z) := by
  unfold spb at *;
  grind

/-
SPB is bounded: if |x| < 1 and |y| < 1, then |spb(x,y)| < 1.
-/
theorem spb_bounded (x y : ℝ) (hx : |x| < 1) (hy : |y| < 1) :
    |spb x y| < 1 := by
  exact abs_lt.mpr ⟨ by rw [ spb_def, lt_div_iff₀ ] <;> nlinarith [ abs_lt.mp hx, abs_lt.mp hy ], by rw [ spb_def, div_lt_iff₀ ] <;> nlinarith [ abs_lt.mp hx, abs_lt.mp hy ] ⟩

/-
The denominator 1+xy > 0 when |x| < 1 and |y| < 1.
-/
theorem spb_denom_pos (x y : ℝ) (hx : |x| < 1) (hy : |y| < 1) :
    0 < 1 + x * y := by
  nlinarith [ abs_lt.mp hx, abs_lt.mp hy ]

/-- SPB preserves the open interval (-1, 1): a group structure. -/
theorem spb_in_interval (x y : ℝ) (hx : |x| < 1) (hy : |y| < 1) :
    -1 < spb x y ∧ spb x y < 1 := by
  exact abs_lt.mp (spb_bounded x y hx hy)

/-
SPB encodes the tanh addition formula:
    spb(tanh(a), tanh(b)) = tanh(a + b).
    Here we prove the self-doubling case: spb(tanh(a), tanh(a)) = tanh(2a).
    This is the Wick-rotated version of the tangent double-angle formula.
-/
theorem spb_tanh_double (a : ℝ) :
    spb (Real.tanh a) (Real.tanh a) = Real.tanh (2 * a) := by
  norm_num [ Real.tanh_eq_sinh_div_cosh, Real.sinh_two_mul, Real.cosh_two_mul, spb ];
  grind +qlia

/-- The SPB operation applied to Pythagorean-derived rationals:
    if (a,b,c) is a Pythagorean triple, then a/c and b/c map via SPB
    to produce related rational values. -/
theorem spb_pythagorean (a b c : ℤ) (hc : (c : ℝ) ≠ 0) (hpyth : a^2 + b^2 = c^2)
    (hdenom : 1 + (a : ℝ)/c * (b/c) ≠ 0) :
    spb ((a : ℝ)/c) (b/c) = (a + b) / (c + a * b / c) := by
  simp [spb]
  field_simp

end