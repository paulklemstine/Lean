/-! # CatalogBuild.EML.NumberTheory

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 9
-/

import Mathlib

noncomputable section

/-- [Section: # SPB Number Theory
Number-theoretic properties of the SPB operation, including:
- Pythagorean triple generation via SPB
- Connection to Gaussian integers / Brahmagupta-Fibonacci
- SPB over integers
- Connection to Chebyshev polynomials
## Key Insight
The SPB operation on rational numbers generates all rational points
on the unit circle via the Weierstrass substitution.] -/
def spbNT (x y : ℝ) : ℝ := (x + y) / (1 - x * y)


/-- For rational t = a/b, the point ((b²-a²)/(b²+a²), 2ab/(b²+a²)) lies on S¹.
These are the Pythagorean triples! -/
theorem pythagorean_from_spb (a b : ℤ)
    (hab : (a : ℝ) ^ 2 + (b : ℝ) ^ 2 ≠ 0) :
    (((b : ℝ) ^ 2 - (a : ℝ) ^ 2) / ((b : ℝ) ^ 2 + (a : ℝ) ^ 2)) ^ 2 +
    ((2 * (a : ℝ) * b) / ((b : ℝ) ^ 2 + (a : ℝ) ^ 2)) ^ 2 = 1 := by
  have hab' : (b : ℝ) ^ 2 + (a : ℝ) ^ 2 ≠ 0 := by
    rwa [show (b : ℝ) ^ 2 + (a : ℝ) ^ 2 = (a : ℝ) ^ 2 + (b : ℝ) ^ 2 from by ring]
  rw [div_pow, div_pow, div_add_div_same, div_eq_one_iff_eq (pow_ne_zero 2 hab')]
  ring


/-- Classic Pythagorean parametrization. -/
theorem pythagorean_triple (m n : ℤ) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by ring


/-- When spb(a, b) is an integer for a, b ∈ ℤ, we need (1 - ab) | (a + b). -/
theorem spb_integer_iff (a b : ℤ) (h : 1 - a * b ≠ 0) :
    (∃ n : ℤ, a + b = n * (1 - a * b)) ↔ (1 - a * b) ∣ (a + b) := by
  constructor
  · rintro ⟨n, hn⟩; exact ⟨n, by linarith⟩
  · rintro ⟨n, hn⟩; exact ⟨n, by linarith⟩


/-- spb(1, 0) = 1. -/
theorem spb_one_zero_int : spbNT 1 0 = 1 := by simp [spbNT]


/-- spb(2, 3) = -1. -/
theorem spb_two_three : spbNT 2 3 = -1 := by unfold spbNT; norm_num


/-- spb(1, 2) = -3. -/
theorem spb_one_two : spbNT 1 2 = -3 := by unfold spbNT; norm_num


/-- spb(1, -2) = -1/3. Not an integer! -/
theorem spb_one_neg_two : spbNT 1 (-2) = -(1/3) := by unfold spbNT; norm_num


/-- The Brahmagupta–Fibonacci identity IS SPB composition in disguise. -/
theorem brahmagupta_is_spb (a b c d : ℤ)
    (ha : (a : ℝ) ≠ 0) (hc : (c : ℝ) ≠ 0)
    (hd : (a : ℝ) * c - (b : ℝ) * d ≠ 0) :
    spbNT ((b : ℝ) / a) ((d : ℝ) / c) =
    ((a : ℝ) * d + b * c) / (a * c - b * d) := by
  unfold spbNT; field_simp; ring


end
