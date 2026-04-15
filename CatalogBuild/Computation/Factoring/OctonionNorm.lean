/-! # CatalogBuild.Computation.Factoring.OctonionNorm

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 7
-/

import Mathlib

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

theorem quatNorm_mul (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    quatNorm a₁ b₁ c₁ d₁ * quatNorm a₂ b₂ c₂ d₂ =
    quatNorm
      (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)
      (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)
      (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)
      (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂) := by
  unfold quatNorm; ring

/-- Quaternion norm is nonneg. -/

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
