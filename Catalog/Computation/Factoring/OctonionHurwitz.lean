import Mathlib

/-!
# Hurwitz Quaternions and Lattice Properties

This file formalizes:
- Lattice membership and closure properties for L_d(N)
- The dimensional advantage chain
- The Pell obstacle (generalized)
- Gaussian integer norm multiplicativity
-/

set_option maxHeartbeats 800000

/-! ## Lattice L₃(N) Properties -/

/-- Membership in L₃(N): the sum-of-squares constraint mod N. -/
def mem_lattice3 (N : ℤ) (x y z : ℤ) : Prop :=
  N ∣ (x^2 + y^2 + z^2)

/-- L₃(N) contains the zero vector. -/
theorem lattice3_zero_mem (N : ℤ) : mem_lattice3 N 0 0 0 := by
  simp [mem_lattice3]

/-- L₃(N) is closed under negation. -/
theorem lattice3_neg_mem (N : ℤ) (x y z : ℤ) (h : mem_lattice3 N x y z) :
    mem_lattice3 N (-x) (-y) (-z) := by
  simp only [mem_lattice3, neg_sq]
  exact h

/-
L₃(N) is closed under scalar multiplication.
-/
theorem lattice_scale_mem (N : ℤ) (x y z k : ℤ) (h : mem_lattice3 N x y z) :
    mem_lattice3 N (k*x) (k*y) (k*z) := by
      exact dvd_trans h ( by exact ⟨ k ^ 2, by ring ⟩ )

/-! ## Lattice L₄(N) Properties -/

/-- Membership in L₄(N). -/
def mem_lattice4 (N : ℤ) (x y z w : ℤ) : Prop :=
  N ∣ (x^2 + y^2 + z^2 + w^2)

/-- L₄(N) contains the zero vector. -/
theorem lattice4_zero_mem (N : ℤ) : mem_lattice4 N 0 0 0 0 := by
  simp [mem_lattice4]

/-
L₄(N) is closed under scalar multiplication.
-/
theorem lattice4_scale_mem (N : ℤ) (x y z w k : ℤ) (h : mem_lattice4 N x y z w) :
    mem_lattice4 N (k*x) (k*y) (k*z) (k*w) := by
      exact dvd_trans h ( by exact ⟨ k ^ 2, by ring ⟩ )

/-! ## Dimensional Advantage Chain -/

/-
For N ≥ 2, N^(1/4) ≤ N^(1/3).
-/
theorem dim_advantage_4_3 {N : ℝ} (hN : 2 ≤ N) :
    N ^ ((1:ℝ)/4) ≤ N ^ ((1:ℝ)/3) := by
      exact Real.rpow_le_rpow_of_exponent_le ( by linarith ) ( by norm_num )

/-
For N ≥ 2, N^(1/3) ≤ N^(1/2).
-/
theorem dim_advantage_3_2 {N : ℝ} (hN : 2 ≤ N) :
    N ^ ((1:ℝ)/3) ≤ N ^ ((1:ℝ)/2) := by
      exact Real.rpow_le_rpow_of_exponent_le ( by linarith ) ( by norm_num )

/-
For N ≥ 2, N^(1/2) ≤ N.
-/
theorem dim_advantage_2_1 {N : ℝ} (hN : 2 ≤ N) :
    N ^ ((1:ℝ)/2) ≤ N := by
      rw [ ← Real.sqrt_eq_rpow, Real.sqrt_le_left ] <;> nlinarith

/-- Full dimensional chain: N^(1/4) ≤ N^(1/3) ≤ N^(1/2) ≤ N. -/
theorem full_dim_chain {N : ℝ} (hN : 2 ≤ N) :
    N ^ ((1:ℝ)/4) ≤ N := by
  calc N ^ ((1:ℝ)/4) ≤ N ^ ((1:ℝ)/3) := dim_advantage_4_3 hN
    _ ≤ N ^ ((1:ℝ)/2) := dim_advantage_3_2 hN
    _ ≤ N := dim_advantage_2_1 hN

/-! ## Generalized Pell Obstacle -/

/-
λ² − 1·μ² = 1 implies μ = 0 (generalized form).
-/
theorem pell_obstacle_n1 (l m : ℤ) (h : l^2 - 1 * m^2 = 1) : m = 0 := by
  -- We can factor the equation as $(l - m)(l + m) = 1$.
  have h_factor : (l - m) * (l + m) = 1 := by
    grind;
  rw [ Int.mul_eq_one_iff_eq_one_or_neg_one ] at h_factor ; omega

/-- For n = 2, Pell's equation has the fundamental solution (3,2). -/
theorem pell_n2_fundamental : (3 : ℤ)^2 - 2 * (2 : ℤ)^2 = 1 := by norm_num

/-! ## Two-Square (Brahmagupta–Fibonacci) Identity -/

/-- The two-square identity corresponding to Gaussian integer norm multiplicativity. -/
theorem two_square_identity (a b c d : ℤ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c - b*d)^2 + (a*d + b*c)^2 := by ring

/-- Gaussian integer norm multiplicativity. -/
theorem gaussian_norm_mul (a b c d : ℤ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c - b*d)^2 + (a*d + b*c)^2 := by ring

/-! ## Pythagorean Triple/Quadruple Embedding -/

/-- (1, 2, 2, 3) is a primitive Pythagorean quadruple. -/
theorem simplest_primitive_quadruple : (1:ℤ)^2 + 2^2 + 2^2 = 3^2 := by norm_num

/-- Every Pythagorean triple embeds as a quadruple with zero third component. -/
theorem triple_embeds_as_quadruple (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    a^2 + b^2 + 0^2 = c^2 := by linarith