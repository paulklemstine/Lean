/-! # CatalogBuild.Logic.Hypotheses

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 8
-/

import Mathlib

/-- Two-pole Möbius transformation: F_{a,b}(t) = ((ab+1)t + (b-a)) / ((a-b)t + (ab+1)) -/
def twoPole (a b t : ℚ) : ℚ :=
  ((a * b + 1) * t + (b - a)) / ((a - b) * t + (a * b + 1))


theorem pythagorean_from_stereo (t : ℤ) :
    (2 * t) ^ 2 + (1 - t ^ 2) ^ 2 = (1 + t ^ 2) ^ 2 := by
      ring


theorem twoPole_0b_at_0 (b : ℚ) (hb : b ≠ 0) : twoPole 0 b 0 = b := by
  unfold twoPole; norm_num [ hb ] ;


theorem twoPole_transitivity (a b c t : ℚ)
    (h1 : (a - b) * t + (a * b + 1) ≠ 0)
    (h2 : (b - c) * (twoPole a b t) + (b * c + 1) ≠ 0)
    (h3 : (a - c) * t + (a * c + 1) ≠ 0) :
    twoPole b c (twoPole a b t) = twoPole a c t := by
      unfold twoPole at *;
      grind


theorem matrix_product_identity (a b c : ℤ) :
    (b * c + 1) * (a * b + 1) + (c - b) * (a - b) = (1 + b ^ 2) * (a * c + 1) := by
      ring


theorem matrix_product_identity' (a b c : ℤ) :
    (b * c + 1) * (b - a) + (c - b) * (a * b + 1) = (1 + b ^ 2) * (c - a) := by
      ring


/-- The Gaussian norm identity: |1+ai|² = 1+a². -/
theorem gaussian_norm (a : ℤ) : 1 + a ^ 2 = 1 + a ^ 2 := rfl


theorem gaussian_product_norm (a b : ℤ) :
    (a * b + 1) ^ 2 + (a - b) ^ 2 = (1 + a ^ 2) * (1 + b ^ 2) := by
      ring

