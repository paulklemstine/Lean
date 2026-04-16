import Mathlib

/-! # SPB and Complex Analysis -/

noncomputable section

open Complex Real

/-- The complex SPB -/
def spbC (z w : ℂ) : ℂ := (z + w) / (1 - z * w)

/-- The SPB-adapted Cayley transform -/
def cayley (x : ℝ) : ℂ := (1 + ↑x * I) / (1 - ↑x * I)

/-- Complex SPB is commutative -/
theorem spbC_comm (z w : ℂ) : spbC z w = spbC w z := by
  simp [spbC, add_comm, mul_comm]

/-- Complex SPB identity -/
theorem spbC_zero (z : ℂ) : spbC z 0 = z := by simp [spbC]

/-- Complex SPB inverse -/
theorem spbC_neg (z : ℂ) : spbC z (-z) = 0 := by simp [spbC]

/-- The Cayley transform maps 0 to 1 -/
theorem cayley_zero : cayley 0 = 1 := by simp [cayley]

/-- The norm-squared identity for numerator and denominator -/
theorem cayley_normSq_eq (x : ℝ) :
    Complex.normSq (1 + ↑x * I) = Complex.normSq (1 - ↑x * I) := by
  simp [Complex.normSq_apply]

/-- Re(C(x)) = (1 - x²)/(1 + x²) -/
theorem cayley_re (x : ℝ) : (cayley x).re = (1 - x ^ 2) / (1 + x ^ 2) := by
  unfold cayley; simp [Complex.div_re, Complex.normSq_apply]; ring

/-- Im(C(x)) = 2x/(1 + x²) -/
theorem cayley_im (x : ℝ) : (cayley x).im = 2 * x / (1 + x ^ 2) := by
  unfold cayley; simp [Complex.div_im, Complex.normSq_apply]; ring

/-- The Gaussian norm of 1 + ix is 1 + x² -/
theorem gaussian_norm_one_plus_ix (x : ℝ) :
    Complex.normSq (1 + ↑x * I) = 1 + x ^ 2 := by
  simp [Complex.normSq_apply]; ring

/-- The Gaussian norm is multiplicative -/
theorem gaussian_norm_mul (z w : ℂ) :
    Complex.normSq (z * w) = Complex.normSq z * Complex.normSq w :=
  map_mul Complex.normSq z w

/-- The factorization (1+ix)(1+iy) = (1-xy) + i(x+y) -/
theorem gaussian_spb_factorization (x y : ℝ) :
    (1 + ↑x * I) * (1 + ↑y * I) = ↑(1 - x * y) + ↑(x + y) * I := by
  push_cast; apply Complex.ext <;> simp <;> ring

/-- The norm of the product -/
theorem gaussian_product_norm (x y : ℝ) :
    Complex.normSq ((1 + ↑x * I) * (1 + ↑y * I)) = (1 + x ^ 2) * (1 + y ^ 2) := by
  rw [gaussian_norm_mul, gaussian_norm_one_plus_ix, gaussian_norm_one_plus_ix]

/-- Also: |(1-xy) + i(x+y)|² = (1+x²)(1+y²) -/
theorem gaussian_product_norm_alt (x y : ℝ) :
    Complex.normSq (↑(1 - x * y) + ↑(x + y) * I) = (1 + x ^ 2) * (1 + y ^ 2) := by
  simp [Complex.normSq_apply]; ring

/-- C(0) = 1 for the complex Cayley -/
def cayleyC (z : ℂ) : ℂ := (1 + I * z) / (1 - I * z)

theorem cayleyC_zero : cayleyC 0 = 1 := by simp [cayleyC]

/-- The inverse Cayley -/
def cayleyInv (w : ℂ) : ℂ := (w - 1) / (I * (w + 1))

/-- C⁻¹(1) = 0 -/
theorem cayleyInv_one : cayleyInv 1 = 0 := by simp [cayleyInv]

/-- The conformal factor is positive -/
theorem cayley_conformal_factor (x : ℝ) : 2 / (1 + x ^ 2) > 0 := by positivity

end
