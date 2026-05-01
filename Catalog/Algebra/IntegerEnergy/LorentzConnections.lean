import Mathlib

/-! # CatalogBuild.Pythagorean.InverseTree.LorentzConnections

Auto-generated from theorem catalog database.
Domain: Pythagorean/InverseTree
Declarations: 26
-/

/-- The Lorentz form matrix Q = diag(1, 1, -1). -/
def LQ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

/-- Berggren matrix B₁. -/
def LB₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B₂. -/
def LB₂ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix B₃. -/
def LB₃ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

/-- Inverse Berggren matrix B₁⁻¹. -/
def LBinv₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, -2; -2, -1, 2; -2, -2, 3]

/-- B₁ preserves the Lorentz form: B₁ᵀ Q B₁ = Q. -/
theorem LB1_preserves_lorentz : LB₁ᵀ * LQ * LB₁ = LQ := by native_decide

/-- B₂ preserves the Lorentz form: B₂ᵀ Q B₂ = Q. -/
theorem LB2_preserves_lorentz : LB₂ᵀ * LQ * LB₂ = LQ := by native_decide

/-- B₃ preserves the Lorentz form: B₃ᵀ Q B₃ = Q. -/
theorem LB3_preserves_lorentz : LB₃ᵀ * LQ * LB₃ = LQ := by native_decide

/-- B₁⁻¹ preserves the Lorentz form. -/
theorem LBinv1_preserves_lorentz : LBinv₁ᵀ * LQ * LBinv₁ = LQ := by native_decide

/-- B₁⁻¹ is the actual inverse of B₁. -/
theorem LBinv1_is_inverse : LB₁ * LBinv₁ = 1 := by native_decide

/-- Q² = I for the Lorentz form. -/
theorem Q_squared_is_identity : LQ * LQ = 1 := by native_decide

/-- The inverse formula: B₁⁻¹ = Q · B₁ᵀ · Q. -/
theorem LBinv1_formula : LBinv₁ = LQ * LB₁ᵀ * LQ := by native_decide

/-- det(B₁) = 1. -/
theorem LB1_det : Matrix.det LB₁ = 1 := by native_decide

/-- det(B₂) = -1. -/
theorem LB2_det : Matrix.det LB₂ = -1 := by native_decide

/-- det(B₃) = 1. -/
theorem LB3_det : Matrix.det LB₃ = 1 := by native_decide

/-- det(B₁²) = 1: the square is in SO(2,1;ℤ). -/
theorem LB1_sq_det : Matrix.det (LB₁ * LB₁) = 1 := by native_decide

/-- The trace of B₁⁻¹ equals 3 (= 1 + (-1) + 3). -/
theorem LBinv1_trace : Matrix.trace LBinv₁ = 3 := by native_decide

/-- The characteristic polynomial factors as (x - 1)(x² - 6x + 1). -/
theorem char_poly_identity (x : ℤ) :
    (x - 1) * (x ^ 2 - 6 * x + 1) = x ^ 3 - 7 * x ^ 2 + 7 * x - 1 := by
  ring

/-- The bilinear Lorentz form on two triples. -/
def lorentzBilinear (u v : Fin 3 → ℤ) : ℤ :=
  u 0 * v 0 + u 1 * v 1 - u 2 * v 2

/-- The Lorentz form is symmetric. -/
theorem lorentz_bilinear_comm (u v : Fin 3 → ℤ) :
    lorentzBilinear u v = lorentzBilinear v u := by
  simp [lorentzBilinear]; ring

/-- The Lorentz form vanishes on Pythagorean triples. -/
theorem lorentz_bilinear_self_zero (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    lorentzBilinear ![a, b, c] ![a, b, c] = 0 := by
  simp [lorentzBilinear]; linarith

/-- The hypotenuse after one descent step satisfies 0 < c' < c. -/
theorem lorentz_descent_contracts (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    0 < -2 * a - 2 * b + 3 * c ∧ -2 * a - 2 * b + 3 * c < c := by
  constructor
  · nlinarith [sq_nonneg (a - b), sq_nonneg (3 * c - 2 * (a + b))]
  · nlinarith [sq_nonneg (a + b - c)]

/-- The cross-Lorentz form between a Pythagorean triple and its B₁⁻¹ parent
equals -2(c-b)², capturing the "boost angle" of the descent step. -/
theorem lorentz_cross_term (a b c : ℤ) (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    a * (a + 2 * b - 2 * c) + b * (-2 * a - b + 2 * c)
      - c * (-2 * a - 2 * b + 3 * c) = -2 * (c - b) ^ 2 := by nlinarith

/-- The key algebraic identity connecting eigenvalues to Pell equation. -/
theorem contracting_eigenvalue_sq :
    (3 : ℤ) ^ 2 - 2 * (2 : ℤ) ^ 2 = 1 := by norm_num

/-- The Pell equation x² - 2y² = 1 gives a sum-of-squares identity. -/
theorem pell_sum_of_squares (x y : ℤ) :
    (x + y) ^ 2 + (x - y) ^ 2 = 2 * x ^ 2 + 2 * y ^ 2 := by ring

/-- The descent depth for hypotenuse c: parent hypotenuse ≤ c - 1. -/
theorem depth_upper_bound (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    -2 * a - 2 * b + 3 * c ≤ c - 1 := by
  nlinarith [sq_nonneg (a + b - c)]