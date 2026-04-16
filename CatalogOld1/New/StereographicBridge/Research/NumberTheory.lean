import Mathlib

/-!
# SPB Number Theory

Number-theoretic properties of the SPB operation, including:
- Pythagorean triple generation via SPB
- Connection to Gaussian integers / Brahmagupta-Fibonacci
- SPB over integers
- Connection to Chebyshev polynomials

## Key Insight
The SPB operation on rational numbers generates all rational points
on the unit circle via the Weierstrass substitution.
-/

noncomputable section
open Real

def spbNT (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-! ## Pythagorean Triple Generation -/

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

/-! ## SPB Integer Divisibility -/

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

/-! ## Brahmagupta-Fibonacci Identity -/

/-- Product of sums of two squares is a sum of two squares. -/
theorem brahmagupta_fibonacci (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by
  ring

/-- The Brahmagupta–Fibonacci identity IS SPB composition in disguise. -/
theorem brahmagupta_is_spb (a b c d : ℤ)
    (ha : (a : ℝ) ≠ 0) (hc : (c : ℝ) ≠ 0)
    (hd : (a : ℝ) * c - (b : ℝ) * d ≠ 0) :
    spbNT ((b : ℝ) / a) ((d : ℝ) / c) =
    ((a : ℝ) * d + b * c) / (a * c - b * d) := by
  unfold spbNT; field_simp; ring

/-! ## Weierstrass Substitution -/

/-
cos θ in terms of t = tan(θ/2).
-/
theorem weierstrass_cos (θ : ℝ) (h : Real.cos (θ / 2) ≠ 0) :
    Real.cos θ = (1 - Real.tan (θ / 2) ^ 2) / (1 + Real.tan (θ / 2) ^ 2) := by
  rw [ ← eq_comm, Real.tan_eq_sin_div_cos ];
  field_simp;
  rw [ Real.sin_sq, Real.cos_sq ] ; ring

/-
sin θ in terms of t = tan(θ/2).
-/
theorem weierstrass_sin (θ : ℝ) (h : Real.cos (θ / 2) ≠ 0) :
    Real.sin θ = 2 * Real.tan (θ / 2) / (1 + Real.tan (θ / 2) ^ 2) := by
  rw [ show θ = 2 * ( θ / 2 ) by ring, Real.sin_two_mul, Real.tan_eq_sin_div_cos ];
  field_simp;
  norm_num

/-! ## The χ₄ Character -/

/-- The character χ_{-4}. -/
def chi4 (n : ℤ) : ℤ :=
  if n % 2 = 0 then 0
  else if n % 4 = 1 then 1
  else -1

/-- χ₄(1) = 1. -/
theorem chi4_one : chi4 1 = 1 := by native_decide

/-- χ₄(3) = -1. -/
theorem chi4_three : chi4 3 = -1 := by native_decide

/-
χ₄ is multiplicative on odd numbers.
-/
theorem chi4_mul_odd (a b : ℤ) (ha : a % 2 = 1) (hb : b % 2 = 1) :
    chi4 (a * b) = chi4 a * chi4 b := by
  unfold chi4;
  rw [ ← Int.emod_add_mul_ediv a 2, ← Int.emod_add_mul_ediv b 2, ha, hb ] ; ring_nf; norm_num;
  grind

end