import Mathlib

/-!
# Quaternion Norm and Pythagorean Quadruples

This file formalizes the core algebraic identities connecting quaternion arithmetic
to integer factoring:
- Euler's four-square identity (norm multiplicativity)
- Pythagorean quadruple parametrization
- The Pell Obstacle theorem
- Dimensional advantage bounds
-/

open scoped BigOperators

set_option maxHeartbeats 800000

/-! ## Euler's Four-Square Identity -/

/-- Euler's four-square identity: the product of two sums of four squares
    is itself a sum of four squares. This is the algebraic foundation of
    quaternion factoring. -/
theorem euler_four_square_identity (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    (a₁^2 + b₁^2 + c₁^2 + d₁^2) * (a₂^2 + b₂^2 + c₂^2 + d₂^2) =
    (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)^2 +
    (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)^2 +
    (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)^2 +
    (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂)^2 := by ring

/-! ## Pythagorean Quadruple Parametrization -/

/-- The parametric formula for Pythagorean quadruples:
    given parameters (m, n, p, q), the tuple (a, b, c, d) where
    a = m² + n² - p² - q², b = 2(mq + np), c = 2(nq - mp),
    d = m² + n² + p² + q² satisfies a² + b² + c² = d². -/
theorem quadruple_from_params_valid (m n p q : ℤ) :
    let a := m^2 + n^2 - p^2 - q^2
    let b := 2*(m*q + n*p)
    let c := 2*(n*q - m*p)
    let d := m^2 + n^2 + p^2 + q^2
    a^2 + b^2 + c^2 = d^2 := by ring

/-! ## The Pell Obstacle -/

/-
**The Pell Obstacle Theorem**: λ² - μ² = 1 has only trivial solutions.
    This blocks the direct generalization of Berggren matrices to 3D.
-/
theorem pell_obstacle (l m : ℤ) (h : l^2 - m^2 = 1) : m = 0 := by
  -- Factor the difference of squares: $(l - m)(l + m) = 1$.
  have h_factor : (l - m) * (l + m) = 1 := by
    linear_combination' h;
  rw [ Int.mul_eq_one_iff_eq_one_or_neg_one ] at h_factor ; omega

/-
The Pell obstacle also determines λ.
-/
theorem pell_obstacle_lambda (l m : ℤ) (h : l^2 - m^2 = 1) :
    l = 1 ∨ l = -1 := by
      have := pell_obstacle l m h;
      exact eq_or_eq_neg_of_sq_eq_sq _ _ <| by subst this; linarith;

/-
Generalized Pell obstacle for n = 1.
-/
theorem pell_obstacle_n1 (l m : ℤ) (h : l^2 - 1 * m^2 = 1) : m = 0 := by
  -- Apply the Pell obstacle theorem to conclude that $m = 0$.
  apply pell_obstacle;
  simpa using h

/-- Contrast: for n = 2, Pell's equation has nontrivial solutions.
    This is why Berggren matrices WORK in 2D. -/
theorem pell_n2_fundamental : (3 : ℤ)^2 - 2 * (2 : ℤ)^2 = 1 := by norm_num

/-! ## Quaternion Norm Multiplicativity -/

/-- The quaternion norm function. -/
def quatNorm (a b c d : ℤ) : ℤ := a^2 + b^2 + c^2 + d^2

/-- Quaternion norm is multiplicative (restated using quatNorm). -/
theorem quatNorm_mul (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    quatNorm a₁ b₁ c₁ d₁ * quatNorm a₂ b₂ c₂ d₂ =
    quatNorm
      (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)
      (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)
      (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)
      (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂) := by
  unfold quatNorm; ring

/-- Quaternion norm is nonneg. -/
theorem quatNorm_nonneg (a b c d : ℤ) : 0 ≤ quatNorm a b c d := by
  unfold quatNorm; positivity

/-! ## Quaternion Factoring Principle -/

/-- If N = p * q and both p, q are sums of four squares, then N is the norm
    of a product quaternion. This is the algebraic basis of quaternion factoring. -/
theorem quaternion_factoring_principle
    (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (p q : ℤ) (hp : p = a₁^2 + b₁^2 + c₁^2 + d₁^2)
    (hq : q = a₂^2 + b₂^2 + c₂^2 + d₂^2) :
    p * q = quatNorm
      (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)
      (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)
      (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)
      (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂) := by
  subst hp; subst hq; exact quatNorm_mul a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂

/-! ## Dimensional Advantage -/

/-
For N ≥ 2 (as a real number), N^(1/3) ≤ N^(1/2).
-/
theorem dimensional_advantage {N : ℝ} (hN : 2 ≤ N) :
    N ^ ((1:ℝ)/3) ≤ N ^ ((1:ℝ)/2) := by
      exact Real.rpow_le_rpow_of_exponent_le ( by linarith ) ( by norm_num )

/-
For N ≥ 2, N^(1/4) ≤ N^(1/3).
-/
theorem dim4_beats_dim3 {N : ℝ} (hN : 2 ≤ N) :
    N ^ ((1:ℝ)/4) ≤ N ^ ((1:ℝ)/3) := by
      exact Real.rpow_le_rpow_of_exponent_le ( by linarith ) ( by norm_num )

/-! ## Two-Square Identity (Brahmagupta–Fibonacci) -/

/-- The two-square identity, corresponding to Gaussian integer norm multiplicativity. -/
theorem two_square_identity (a b c d : ℤ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c - b*d)^2 + (a*d + b*c)^2 := by ring

/-! ## Simplest Pythagorean Quadruple -/

/-- (1, 2, 2, 3) is the simplest primitive Pythagorean quadruple. -/
theorem simplest_primitive_quadruple : (1:ℤ)^2 + 2^2 + 2^2 = 3^2 := by norm_num

/-- Every Pythagorean triple (a,b,c) embeds as a quadruple (a,b,0,c). -/
theorem triple_embeds_as_quadruple (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    a^2 + b^2 + 0^2 = c^2 := by linarith