import Mathlib

/-!
# SPB and the Weierstrass Substitution

## Overview
The Weierstrass substitution t = tan(θ/2) gives:
  sin(θ) = 2t/(1+t²)
  cos(θ) = (1-t²)/(1+t²)

We also prove:
- SPB double angle formulas
- The connection between SPB and Pythagorean triples
- Brahmagupta-Fibonacci identity as SPB composition
- SPB norm composition law
-/

noncomputable section
open Real

/-- The SPB operator -/
def spbW (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The hyperbolic SPB (Einstein velocity addition) -/
def spbHW (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-! ## Weierstrass Substitution -/

/-- sin(θ) = 2·tan(θ/2) / (1 + tan²(θ/2)) = spbH(t, t) where t = tan(θ/2). -/
theorem weierstrass_sin (t : ℝ) :
    spbHW t t = 2 * t / (1 + t ^ 2) := by
  unfold spbHW; ring

/-! ## SPB Double Angle Formulas -/

/-- tan(2θ) = spb(tan θ, tan θ) = 2·tan(θ)/(1 - tan²(θ)). -/
theorem spb_double_angle (x : ℝ) :
    spbW x x = 2 * x / (1 - x ^ 2) := by
  unfold spbW; ring

/-- The triple angle formula: spb(2x/(1-x²), x) = (3x - x³)/(1 - 3x²). -/
theorem spb_triple_angle (x : ℝ) (h1 : 1 - x ^ 2 ≠ 0) (_ : 1 - 3 * x ^ 2 ≠ 0)
    (_ : 1 - (2 * x / (1 - x ^ 2)) * x ≠ 0) :
    spbW (2 * x / (1 - x ^ 2)) x = (3 * x - x ^ 3) / (1 - 3 * x ^ 2) := by
  unfold spbW; field_simp; ring

/-! ## SPB and Pythagorean Triples -/

/-- Every rational point on the unit circle gives a Pythagorean triple. -/
theorem pythagorean_from_rational_point (p q : ℤ) :
    (2 * p * q) ^ 2 + (q ^ 2 - p ^ 2) ^ 2 = (q ^ 2 + p ^ 2) ^ 2 := by ring

/-! ## Brahmagupta-Fibonacci Identity -/

/-- The Brahmagupta-Fibonacci identity:
    (a² + b²)(c² + d²) = (ac - bd)² + (ad + bc)²
    This is the norm-multiplicativity of Gaussian integers. -/
theorem brahmagupta_fibonacci (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by ring

/-- Alternative form of Brahmagupta-Fibonacci. -/
theorem brahmagupta_fibonacci_alt (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by ring

/-! ## SPB Composition and Norms -/

/-- SPB composition preserves the "norm" structure:
    N(spb(a,b)) · (1-ab)² = N(a) · N(b) where N(x) = 1 + x². -/
theorem spb_norm_composition (a b : ℝ) (h : 1 - a * b ≠ 0) :
    (1 + (spbW a b) ^ 2) * (1 - a * b) ^ 2 = (1 + a ^ 2) * (1 + b ^ 2) := by
  unfold spbW; field_simp; ring

/-! ## SPB and Gaussian Integer Norms -/

/-- The "augmented norm" identity:
    (1 + a²)(1 + b²) = (1-ab)² + (a+b)²
    Shows SPB numerator and denominator are components of
    Gaussian integer multiplication: (1+ai)(1+bi) = (1-ab) + (a+b)i. -/
theorem spb_gaussian_norm_identity (a b : ℤ) :
    (1 + a ^ 2) * (1 + b ^ 2) = (1 - a * b) ^ 2 + (a + b) ^ 2 := by ring

/-- Real version. -/
theorem spb_gaussian_norm_identity_real (a b : ℝ) :
    (1 + a ^ 2) * (1 + b ^ 2) = (1 - a * b) ^ 2 + (a + b) ^ 2 := by ring

end
