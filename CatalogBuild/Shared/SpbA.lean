/-! # CatalogBuild.Shared.SpbA

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 10
-/

import Mathlib

noncomputable section

/-- The SPB operator. -/
def spbA (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The hyperbolic SPB operator. -/

theorem spbA_cancel (x y : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 - spbA x y * (-y) ≠ 0) :
    spbA (spbA x y) (-y) = x := by
  simp +decide [ *, spbA ];
  -- Combine and simplify the fractions in the numerator and denominator.
  field_simp [h1, h2]
  ring;
  linarith [ inv_mul_cancel_left₀ ( by positivity : ( 1 + y ^ 2 ) ≠ 0 ) x ]

/-! ## SPB as Möbius Transformation: Composition Law -/

/-
Composing two SPB translations is associativity of SPB.
-/

theorem spbA_neg (x : ℝ) : spbA x (-x) = 0 := by simp [spbA]


theorem spbA_compose (x a b : ℝ)
    (h1 : 1 - x * b ≠ 0) (h2 : 1 - b * a ≠ 0)
    (h3 : 1 - spbA x b * a ≠ 0) (h4 : 1 - x * spbA b a ≠ 0) :
    spbA (spbA x b) a = spbA x (spbA b a) := by
  unfold spbA at *;
  grind

/-! ## SPB Derivative -/

/-
The derivative of x ↦ spbA(x, a) is (1 + a²)/(1 - xa)².
-/

theorem spbA_comm (x y : ℝ) : spbA x y = spbA y x := by
  simp [spbA, add_comm, mul_comm]


theorem spbA_rat (p q r s : ℤ) (hq : (q : ℝ) ≠ 0) (hs : (s : ℝ) ≠ 0)
    (hd : (q * s - p * r : ℝ) ≠ 0) :
    spbA (p / q) (r / s) = (p * s + r * q) / (q * s - p * r) := by
  unfold spbA;
  grind

/-! ## SPB Power-of-Two Doubling -/

/-- spbPowA(x, 2) = spbA(x, x). -/

theorem spbA_hasDerivAt (x a : ℝ) (h : 1 - x * a ≠ 0) :
    HasDerivAt (fun x' => spbA x' a) ((1 + a ^ 2) / (1 - x * a) ^ 2) x := by
  convert HasDerivAt.div ( HasDerivAt.add ( hasDerivAt_id x ) ( hasDerivAt_const _ _ ) ) ( HasDerivAt.sub ( hasDerivAt_const _ _ ) ( HasDerivAt.mul ( hasDerivAt_id x ) ( hasDerivAt_const _ _ ) ) ) _ using 1 <;> norm_num [ h ] ; ring

/-! ## SPB and arctan: The Group Homomorphism -/

/-- arctan is an SPB homomorphism: arctan(spb(x, y)) = arctan(x) + arctan(y)
    when xy < 1 (the principal branch condition). -/

theorem spbA_zero (x : ℝ) : spbA x 0 = x := by simp [spbA]


theorem spbA_denom_pos (x y : ℝ) (hx : |x| < 1) (hy : |y| < 1) :
    1 - x * y > 0 := by
  nlinarith [ abs_lt.mp hx, abs_lt.mp hy ]

/-
If |x| < 1 and |y| < 1, then 1 + xy > 0.
-/

theorem spbA_deriv_pos (x a : ℝ) (h : 1 - x * a ≠ 0) :
    (1 + a ^ 2) / (1 - x * a) ^ 2 > 0 := by
  apply div_pos
  · linarith [sq_nonneg a]
  · positivity


end
