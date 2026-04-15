/-! # CatalogBuild.Pythagorean.Core.GaussianConnections

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 34
-/

import Mathlib

theorem pyth_iff_gaussNorm_sq (a b c : ℤ) :
    a ^ 2 + b ^ 2 = c ^ 2 ↔ gaussNorm a b = c ^ 2 := by
  simp [gaussNorm]

/-- The Gaussian norm is multiplicative: N(z₁)·N(z₂) = N(z₁z₂). -/

theorem gauss_conj_product (a b : ℤ) :
    (a + b) * (a - b) = a ^ 2 - b ^ 2 := by ring

/-- Brahmagupta–Fibonacci identity: product of sums of two squares is a sum of two squares. -/

theorem gaussNorm_nonneg (a b : ℤ) : 0 ≤ gaussNorm a b := by
  simp [gaussNorm]; positivity

/-- If a² + b² = c², then (c-a)(c+a) = b². -/

theorem factor_from_leg_b (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (c - a) * (c + a) = b ^ 2 := by nlinarith

/-- If a² + b² = c², then (c-b)(c+b) = a². -/

theorem factor_from_leg_a (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (c - b) * (c + b) = a ^ 2 := by nlinarith

/-! ## §2. The 2×2 Parametrization and SL₂(ℤ) -/

/-- Every primitive Pythagorean triple arises from (m,n) with
    a = m² - n², b = 2mn, c = m² + n². This is the standard parametrization.
    The associated 2×2 matrix is [[m, -n], [n, m]] with det = m² + n². -/

def paramMatrix (m n : ℤ) : Matrix (Fin 2) (Fin 2) ℤ :=
  !![m, -n; n, m]


theorem paramMatrix_det (m n : ℤ) :
    Matrix.det (paramMatrix m n) = m ^ 2 + n ^ 2 := by
  simp [paramMatrix, Matrix.det_fin_two]; ring

/-- The product of two param matrices corresponds to Gaussian multiplication. -/

theorem paramMatrix_mul (m₁ n₁ m₂ n₂ : ℤ) :
    paramMatrix m₁ n₁ * paramMatrix m₂ n₂ =
    paramMatrix (m₁ * m₂ - n₁ * n₂) (m₁ * n₂ + n₁ * m₂) := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [paramMatrix, Matrix.mul_apply,
    Fin.sum_univ_two] <;> ring

/-- Triple from parameters (a, b, c) = (m²-n², 2mn, m²+n²). -/

def tripleFromParams (m n : ℤ) : Fin 3 → ℤ :=
  ![m ^ 2 - n ^ 2, 2 * m * n, m ^ 2 + n ^ 2]

/-- The parametric triple is always Pythagorean. -/

theorem param_triple_pythagorean (m n : ℤ) :
    (tripleFromParams m n) 0 ^ 2 + (tripleFromParams m n) 1 ^ 2 =
    (tripleFromParams m n) 2 ^ 2 := by
  simp [tripleFromParams]; ring

/-- The root (3,4,5) comes from m=2, n=1. -/

theorem S_det : Matrix.det S_mat = 1 := by native_decide

theorem T_det : Matrix.det T_mat = 1 := by native_decide

theorem S_as_param : S_mat = paramMatrix 0 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [S_mat, paramMatrix]

/-! ## §3. Integer Lorentz Group and Physics -/

/-- The Berggren matrices. -/

theorem B₂_boost_cosh : B₂ 2 2 = 3 := by native_decide

/-- The trace of a Lorentz boost matrix relates to the rapidity.
    For B₂: tr = 1 + 1 + 3 = 5 = 1 + 2·cosh(φ) in the continuous case. -/

theorem B₂_trace : Matrix.trace B₂ = 5 := by native_decide

/-- B₁ is a proper Lorentz transformation (det = +1). -/

theorem B₁_proper : Matrix.det B₁ = 1 := by native_decide

/-- B₂ is an improper Lorentz transformation (det = -1), including a spatial reflection. -/

theorem B₂_improper : Matrix.det B₂ = -1 := by native_decide

/-- B₃ is a proper Lorentz transformation (det = +1). -/

theorem B₃_proper : Matrix.det B₃ = 1 := by native_decide

/-- A "double boost" B₂² is always proper (det = +1). -/

theorem B₂_sq_proper : Matrix.det (B₂ * B₂) = 1 := by native_decide

/-- B₂² preserves the Lorentz form. -/

theorem B₂_sq_preserves_Q : (B₂ * B₂)ᵀ * Q * (B₂ * B₂) = Q := by native_decide

/-- The "cosh" of the double boost: (B₂²)₂₂ = 17 = 2·9 - 1 = 2·cosh²(φ) - 1. -/

theorem B₂_sq_cosh : (B₂ * B₂) 2 2 = 17 := by native_decide

/-- Velocity parameter: for B₂, β = v/c corresponds to the ratio
    of off-diagonal to diagonal elements. The "velocity" is 2/3 (< 1). -/

theorem B₂_subluminal : B₂ 2 0 < B₂ 2 2 := by native_decide

/-! ## §4. Practical Factoring Lemmas -/

/-- GCD extraction: if a² + b² = c² and d | a, then d² | (c² - b²). -/

theorem sum_of_squares_factor (N a b : ℤ) (h : N = a ^ 2 + b ^ 2) :
    N = (a + b) ^ 2 - 2 * a * b := by ring_nf; linarith

/-- Descent bound: B₂⁻¹ strictly decreases the hypotenuse for any valid triple. -/

theorem descent_decreases (a b c : ℤ)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc : 5 < c) :
    -2 * a - 2 * b + 3 * c < c := by nlinarith [sq_nonneg a, sq_nonneg b]

/-- The inverse Berggren descent preserves the Pythagorean property. -/

theorem B₃_inv_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2*b + 2*c)^2 + (-2*a + b + 2*c)^2 = (-2*a + 2*b + 3*c)^2 := by nlinarith

/-! ## §5. Power Preservation -/

/-
Power of a single Lorentz matrix preserves Q.
-/

theorem power_preserves_Q (d : Matrix (Fin 3) (Fin 3) ℤ) (k : ℕ) (hd : dᵀ * Q * d = Q) :
    (d ^ k)ᵀ * Q * (d ^ k) = Q := by
  induction k with
  | zero => simp [Q]
  | succ n ih =>
  simp_all +decide [ mul_assoc, pow_succ ];
  simp_all +decide [ ← mul_assoc ]

/-- B₂ powers give increasingly large boosts, all preserving Q. -/

theorem B₂_power_preserves (k : ℕ) : (B₂ ^ k)ᵀ * Q * (B₂ ^ k) = Q :=
  power_preserves_Q B₂ k (by native_decide)

/-- The (2,2) entry of B₂² = 17. -/

theorem B₂_power_growth_base : (B₂ ^ 2) 2 2 = 17 := by native_decide

/-- The (2,2) entry of B₂³ = 99. -/

theorem B₂_cube_entry : (B₂ ^ 3) 2 2 = 99 := by native_decide

/-! ## §6. Number-Theoretic Properties of Tree Triples -/

/-- Sum of legs bound: a + b > c for any positive Pythagorean triple. -/

theorem leg_sum_bound (a b c : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2) (ha : 0 < a) (hb : 0 < b) :
    a + b > c := by
  nlinarith [sq_nonneg (a + b - c), sq_nonneg a, sq_nonneg b]

/-- Hypotenuse is largest: c > a for positive triples. -/

theorem hypotenuse_largest_a (a b c : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c > a := by nlinarith [sq_nonneg b]

/-- Hypotenuse is largest: c > b for positive triples. -/

theorem hypotenuse_largest_b (a b c : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c > b := by nlinarith [sq_nonneg a]

/-
In a primitive triple, the legs cannot both be even.
-/

theorem primitive_not_both_even (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (hprim : Int.gcd a b = 1) : ¬ (2 ∣ a ∧ 2 ∣ b) := by
  exact fun h' => absurd ( Int.dvd_coe_gcd h'.left h'.right ) ( by norm_num [ hprim ] )

/-- The Gaussian norm of a Pythagorean triple's legs equals the square of the hypotenuse. -/

theorem gaussNorm_of_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    gaussNorm a b = c ^ 2 := by
  simp [gaussNorm]; linarith

