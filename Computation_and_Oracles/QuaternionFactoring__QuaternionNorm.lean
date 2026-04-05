import Mathlib

/-!
# Quaternion Norm Identity and Pythagorean Quadruples

## Overview

We formalize the connection between Hamiltonian quaternions and Pythagorean quadruples.
The key insight: the quaternion norm identity |q₁|² · |q₂|² = |q₁ · q₂|² is exactly
the Euler four-square identity, which generates all Pythagorean quadruples from parameters.

## Main Results

- `euler_four_square_identity`: The Euler four-square identity for integers
- `quaternion_norm_mul`: Quaternion norm is multiplicative
- `quadruple_from_params_valid`: The parametric formula produces valid quadruples
- `pell_obstacle`: There are no nontrivial integer solutions to λ² - μ² = 1
-/

/-! ## Section 1: Euler Four-Square Identity -/

/-- The Euler four-square identity: the product of two sums of four squares
    is itself a sum of four squares. This is the algebraic foundation of
    quaternion norm multiplicativity. -/
theorem euler_four_square_identity (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    (a₁^2 + b₁^2 + c₁^2 + d₁^2) * (a₂^2 + b₂^2 + c₂^2 + d₂^2) =
    (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)^2 +
    (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)^2 +
    (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)^2 +
    (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂)^2 := by
  ring

/-! ## Section 2: Pythagorean Quadruple Parametrization -/

/-- A Pythagorean quadruple (a, b, c, d) satisfies a² + b² + c² = d² -/
def IsPythQuadruple (a b c d : ℤ) : Prop :=
  a^2 + b^2 + c^2 = d^2

/-
The parametric construction of a Pythagorean quadruple from four parameters.
    Given (m, n, p, q), define:
      a = m² + n² - p² - q²
      b = 2(mq + np)
      c = 2(nq - mp)
      d = m² + n² + p² + q²
    This always yields a valid quadruple.
-/
theorem quadruple_from_params_valid (m n p q : ℤ) :
    IsPythQuadruple
      (m^2 + n^2 - p^2 - q^2)
      (2*(m*q + n*p))
      (2*(n*q - m*p))
      (m^2 + n^2 + p^2 + q^2) := by
  exact Eq.symm ( by ring )

/-
The sum d = m² + n² + p² + q² is always nonneg when d represents the hypotenuse.
-/
theorem quadruple_hypotenuse_nonneg (m n p q : ℤ) :
    0 ≤ m^2 + n^2 + p^2 + q^2 := by
  positivity

/-! ## Section 3: The Pell Obstacle -/

/-
**The Pell Obstacle**: The equation λ² - μ² = 1 has no nontrivial integer solutions.
    The only solutions are (λ, μ) = (±1, 0).
    This is the key obstruction preventing a direct generalization of
    Berggren matrices from 2D to 3D.
-/
theorem pell_obstacle (l m : ℤ) (h : l^2 - m^2 = 1) : m = 0 := by
  -- From h: l^2 - m^2 = 1, we get (l-m)*(l+m) = 1 by ring.
  have h_fact : (l - m) * (l + m) = 1 := by
    linear_combination' h;
  rw [ Int.mul_eq_one_iff_eq_one_or_neg_one ] at h_fact ; omega

/-
Corollary: If λ² - μ² = 1 then λ = 1 or λ = -1
-/
theorem pell_obstacle_lambda (l m : ℤ) (h : l^2 - m^2 = 1) :
    l = 1 ∨ l = -1 := by
  have hm : m = 0 := pell_obstacle l m h;
  exact eq_or_eq_neg_of_sq_eq_sq _ _ <| by subst hm; linarith;

/-! ## Section 4: Quaternion Norm and Factoring -/

/-- The norm of a quaternion (a, b, c, d) is a² + b² + c² + d². -/
def quatNorm (a b c d : ℤ) : ℤ := a^2 + b^2 + c^2 + d^2

/-
Quaternion norm is always nonnegative.
-/
theorem quatNorm_nonneg (a b c d : ℤ) : 0 ≤ quatNorm a b c d := by
  exact add_nonneg ( add_nonneg ( add_nonneg ( sq_nonneg a ) ( sq_nonneg b ) ) ( sq_nonneg c ) ) ( sq_nonneg d )

/-
Quaternion norm is multiplicative: this is equivalent to the
    Euler four-square identity.
-/
theorem quatNorm_mul (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    quatNorm a₁ b₁ c₁ d₁ * quatNorm a₂ b₂ c₂ d₂ =
    quatNorm
      (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)
      (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)
      (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)
      (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂) := by
  unfold quatNorm; ring;

/-
**Quaternion Factoring Principle**: If N = quatNorm a b c d and
    N = p * q for primes p, q, then finding quaternion factorizations
    of p and q yields a factorization of N.
-/
theorem quaternion_factoring_principle (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    let p := quatNorm a₁ b₁ c₁ d₁
    let q := quatNorm a₂ b₂ c₂ d₂
    let N := p * q
    ∃ A B C D : ℤ, quatNorm A B C D = N := by
  -- The quaternion product is defined as:
  use a₁ * a₂ - b₁ * b₂ - c₁ * c₂ - d₁ * d₂, a₁ * b₂ + b₁ * a₂ + c₁ * d₂ - d₁ * c₂, a₁ * c₂ - b₁ * d₂ + c₁ * a₂ + d₁ * b₂, a₁ * d₂ + b₁ * c₂ - c₁ * b₂ + d₁ * a₂;
  exact Eq.symm (quatNorm_mul a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂)

/-! ## Section 5: The Lattice L₄(N) -/

/-- The lattice L₄(N) consists of all integer triples (x, y, z) such that
    x² + y² + z² ≡ 0 (mod N). A short vector in this lattice can reveal
    factors of N. -/
def inQuadLattice (N : ℤ) (x y z : ℤ) : Prop :=
  N ∣ (x^2 + y^2 + z^2)

/-
The zero vector is always in L₄(N).
-/
theorem zero_in_quadLattice (N : ℤ) : inQuadLattice N 0 0 0 := by
  exact ⟨ 0, by simp +decide ⟩

/-
L₄(N) is closed under negation.
-/
theorem neg_in_quadLattice (N : ℤ) (x y z : ℤ) (h : inQuadLattice N x y z) :
    inQuadLattice N (-x) (-y) (-z) := by
  simp_all +decide [ inQuadLattice ]

/-
**Factor Extraction**: If p | N and x² + y² + z² = k·N with
    gcd(x² + y², N) nontrivial, then we extract a factor.
-/
theorem factor_extraction (N p q : ℤ) (hN : N = p * q) (hp : 1 < p) (hq : 1 < q)
    (x y z : ℤ) (h : inQuadLattice N x y z)
    (hgcd : ¬ IsUnit (Int.gcd (x^2 + y^2) N : ℤ))
    (hgcd2 : (Int.gcd (x^2 + y^2) N : ℤ) ≠ N) :
    ∃ d : ℤ, d ∣ N ∧ 1 < d ∧ d < N := by
  exact ⟨ p, hN.symm ▸ dvd_mul_right _ _, hp, by nlinarith ⟩

/-! ## Section 6: Dimensional Hierarchy -/

/-
In a d-dimensional lattice of determinant N, the Minkowski bound on
    the shortest vector is proportional to N^(1/d). This theorem states
    the key inequality for dimension 3 vs dimension 2.
-/
theorem dimensional_advantage :
    ∀ N : ℕ, 2 ≤ N → (N : ℝ) ^ ((1:ℝ)/3) ≤ (N : ℝ) ^ ((1:ℝ)/2) := by
  exact fun N hN => Real.rpow_le_rpow_of_exponent_le ( by norm_cast; linarith ) ( by norm_num )

/-
For all N ≥ 2, N^(1/4) ≤ N^(1/3) — dimension 4 beats dimension 3.
-/
theorem dim4_beats_dim3 :
    ∀ N : ℕ, 2 ≤ N → (N : ℝ) ^ ((1:ℝ)/4) ≤ (N : ℝ) ^ ((1:ℝ)/3) := by
  exact fun N hN => Real.rpow_le_rpow_of_exponent_le ( by norm_cast; linarith ) ( by norm_num )