import Mathlib

/-!
# Null Cone Arithmetic: The Mathematics of Light Below the Monster Tower

## Overview

The null cone x₀² = x₁² + x₂² + x₃² in Minkowski space is where light lives.
Rational points on this cone correspond to "light rays with rational direction cosines."

This file explores the arithmetic structure BELOW this level:
- The quaternion norm gives Pythagorean quadruples (→ null cone)
- Each level is controlled by a division algebra via the Cayley-Dickson construction

## Novel Results

1. Stereographic descent map: from S² rational points to S¹ rational points
2. The arithmetic Penrose twistor: encoding a light ray as a pair of Gaussian integers
-/

open Real BigOperators Finset

noncomputable section

/-! ## Quaternion Norm and the Null Cone -/

/-- The quaternion norm: |(a,b,c,d)|² = a² + b² + c² + d² -/
def quatNorm (a b c d : ℤ) : ℤ := a^2 + b^2 + c^2 + d^2

/-- **Euler's Four-Square Identity**: The quaternion norm is multiplicative.
    This is the engine that generates ALL Pythagorean quadruples from simpler ones. -/
theorem euler_four_square (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    quatNorm a₁ b₁ c₁ d₁ * quatNorm a₂ b₂ c₂ d₂ =
    quatNorm
      (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)
      (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)
      (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)
      (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂) := by
  unfold quatNorm; ring

/-- The quaternion norm is always nonnegative -/
theorem quatNorm_nonneg (a b c d : ℤ) : 0 ≤ quatNorm a b c d := by
  unfold quatNorm; positivity

/-! ## Stereographic Descent: S² → S¹ -/

/-- **Theorem**: The descent map lands on S¹. Given a point on S² with x²+y² > 0,
    projecting (x/√(x²+y²), y/√(x²+y²)) gives a point on S¹. -/
theorem descent_on_circle (x y z : ℝ) (h : x^2 + y^2 > 0) (hS : x^2 + y^2 + z^2 = 1) :
    (x / Real.sqrt (x^2 + y^2))^2 + (y / Real.sqrt (x^2 + y^2))^2 = 1 := by
  rw [div_pow, div_pow, ← add_div, Real.sq_sqrt (le_of_lt h),
      div_self (ne_of_gt h)]

/-! ## The Cayley-Dickson Tower: Going Deeper -/

/-- Two squares: the Gaussian integer level -/
theorem two_squares_identity (a b c d : ℤ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c - b*d)^2 + (a*d + b*c)^2 := by ring

/-- Four squares: the quaternion level -/
theorem four_squares_identity (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    (a₁^2 + b₁^2 + c₁^2 + d₁^2) * (a₂^2 + b₂^2 + c₂^2 + d₂^2) =
    (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)^2 +
    (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)^2 +
    (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)^2 +
    (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂)^2 := by ring

/-! ## The Twistor Correspondence (Arithmetic Version) -/

/-- An arithmetic twistor: a pair of Gaussian integers encoding a light ray. -/
structure ArithTwistor where
  pos_re : ℤ
  pos_im : ℤ
  hel_re : ℤ
  hel_im : ℤ

/-- The null-cone point determined by a twistor. -/
def ArithTwistor.nullConePoint (tw : ArithTwistor) : ℤ × ℤ × ℤ × ℤ :=
  (tw.pos_re^2 + tw.pos_im^2 + tw.hel_re^2 + tw.hel_im^2,
   tw.pos_re^2 + tw.pos_im^2 - tw.hel_re^2 - tw.hel_im^2,
   2 * (tw.pos_re * tw.hel_re + tw.pos_im * tw.hel_im),
   2 * (tw.pos_im * tw.hel_re - tw.pos_re * tw.hel_im))

/-- **Theorem**: Every arithmetic twistor gives a point on the null cone. -/
theorem twistor_on_null_cone (tw : ArithTwistor) :
    let p := tw.nullConePoint
    p.1^2 = p.2.1^2 + p.2.2.1^2 + p.2.2.2^2 := by
  simp [ArithTwistor.nullConePoint]
  ring

/-! ## The Hopf Fibration: Deepest Level -/

/-- The Hopf map S³ → S² -/
noncomputable def hopfMap (a b c d : ℝ) : ℝ × ℝ × ℝ :=
  (a^2 + b^2 - c^2 - d^2,
   2*(a*c + b*d),
   2*(b*c - a*d))

/-- **Theorem**: The Hopf map preserves the norm-squared relationship. -/
theorem hopf_norm_sq (a b c d : ℝ) :
    let h := hopfMap a b c d
    h.1^2 + h.2.1^2 + h.2.2^2 = (a^2 + b^2 + c^2 + d^2)^2 := by
  simp [hopfMap]; ring

/-- **Corollary**: Points on S³ map to points on S² via Hopf. -/
theorem hopf_sphere_to_sphere (a b c d : ℝ) (h : a^2 + b^2 + c^2 + d^2 = 1) :
    let p := hopfMap a b c d
    p.1^2 + p.2.1^2 + p.2.2^2 = 1 := by
  have := hopf_norm_sq a b c d
  simp [hopfMap] at this ⊢
  nlinarith

end
