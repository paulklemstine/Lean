/-! # CatalogBuild.Bridges.SPBAlgebra

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 8
-/

import Mathlib

noncomputable section

/-- SPB with itself: spb(x, x) = 2x/(1+x²). -/
theorem spb_self (x : ℝ) : spb x x = 2 * x / (1 + x ^ 2) := by
  simp [spb]; ring


/-- -x is the inverse of x: spb(x, -x) = 0 when 1 - x² ≠ 0. -/
theorem spb_neg_inverse (x : ℝ) (h : 1 - x ^ 2 ≠ 0) :
    spb x (-x) = 0 := by
  simp [spb, show 1 + x * -x = 1 - x ^ 2 from by ring, h]


/-- [Section: # SPB Algebraic Structure
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
- `spb_bounded`: |spb(x,y)| < 1 when |x| < 1 and |y| < 1] -/
theorem spb_assoc (x y z : ℝ)
    (hxy : 1 + x * y ≠ 0) (hyz : 1 + y * z ≠ 0)
    (hxyz1 : 1 + spb x y * z ≠ 0) (hxyz2 : 1 + x * spb y z ≠ 0) :
    spb (spb x y) z = spb x (spb y z) := by
  unfold spb at *;
  grind


theorem spb_bounded (x y : ℝ) (hx : |x| < 1) (hy : |y| < 1) :
    |spb x y| < 1 := by
  exact abs_lt.mpr ⟨ by rw [ spb_def, lt_div_iff₀ ] <;> nlinarith [ abs_lt.mp hx, abs_lt.mp hy ], by rw [ spb_def, div_lt_iff₀ ] <;> nlinarith [ abs_lt.mp hx, abs_lt.mp hy ] ⟩


theorem spb_denom_pos (x y : ℝ) (hx : |x| < 1) (hy : |y| < 1) :
    0 < 1 + x * y := by
  nlinarith [ abs_lt.mp hx, abs_lt.mp hy ]


/-- SPB preserves the open interval (-1, 1): a group structure. -/
theorem spb_in_interval (x y : ℝ) (hx : |x| < 1) (hy : |y| < 1) :
    -1 < spb x y ∧ spb x y < 1 := by
  exact abs_lt.mp (spb_bounded x y hx hy)


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
