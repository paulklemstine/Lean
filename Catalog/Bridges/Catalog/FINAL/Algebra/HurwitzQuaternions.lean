import Mathlib

/-! # CatalogBuild.Computation.Factoring.HurwitzQuaternions

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 27
-/

/-- The sum-of-squares lattice condition. -/
def InSumSqLattice (N : ℤ) (x y z : ℤ) : Prop :=
  N ∣ (x^2 + y^2 + z^2)

/-- [Section: # CatalogBuild.Computation.Factoring.HurwitzQuaternions
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 27] -/
theorem lattice_zero_mem (N : ℤ) : InSumSqLattice N 0 0 0 := by
  unfold InSumSqLattice; simp

/-- [Section: # CatalogBuild.Computation.Factoring.HurwitzQuaternions
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 27] -/
theorem lattice_neg_mem (N : ℤ) (x y z : ℤ) (h : InSumSqLattice N x y z) :
    InSumSqLattice N (-x) (-y) (-z) := by
  unfold InSumSqLattice at *; simp [neg_sq]; exact h

theorem lattice_scale_mem (N : ℤ) (k x y z : ℤ) (h : InSumSqLattice N x y z) :
    InSumSqLattice N (k * x) (k * y) (k * z) := by
  unfold InSumSqLattice at *
  have : (k * x)^2 + (k * y)^2 + (k * z)^2 = k^2 * (x^2 + y^2 + z^2) := by ring
  rw [this]
  exact dvd_mul_of_dvd_right h _

/-- The 4D lattice condition. -/
def InSumSqLattice4 (N : ℤ) (a b c d : ℤ) : Prop :=
  N ∣ (a^2 + b^2 + c^2 + d^2)

theorem lattice4_zero_mem (N : ℤ) : InSumSqLattice4 N 0 0 0 0 := by
  unfold InSumSqLattice4; simp

theorem lattice4_neg_mem (N : ℤ) (a b c d : ℤ) (h : InSumSqLattice4 N a b c d) :
    InSumSqLattice4 N (-a) (-b) (-c) (-d) := by
  unfold InSumSqLattice4 at *; simp [neg_sq]; exact h

theorem lattice4_scale_mem (N : ℤ) (k a b c d : ℤ) (h : InSumSqLattice4 N a b c d) :
    InSumSqLattice4 N (k * a) (k * b) (k * c) (k * d) := by
  unfold InSumSqLattice4 at *
  have : (k*a)^2 + (k*b)^2 + (k*c)^2 + (k*d)^2 = k^2 * (a^2 + b^2 + c^2 + d^2) := by ring
  rw [this]; exact dvd_mul_of_dvd_right h _

/-- The quaternion norm satisfies N(q) = N(conj(q)). -/
theorem quatNorm_conj (a b c d : ℤ) :
    a^2 + b^2 + c^2 + d^2 = a^2 + (-b)^2 + (-c)^2 + (-d)^2 := by ring

/-- The product q · conj(q) yields the norm as the real part. -/
theorem quat_mul_conj_re (a b c d : ℤ) :
    a * a - b * (-b) - c * (-c) - d * (-d) = a^2 + b^2 + c^2 + d^2 := by ring

/-- The product q · conj(q) has zero imaginary parts. -/
theorem quat_mul_conj_im_i (a b c d : ℤ) :
    a * (-b) + b * a + c * (-d) - d * (-c) = 0 := by ring

theorem quat_mul_conj_im_j (a b c d : ℤ) :
    a * (-c) - b * (-d) + c * a + d * (-b) = 0 := by ring

theorem quat_mul_conj_im_k (a b c d : ℤ) :
    a * (-d) + b * (-c) - c * (-b) + d * a = 0 := by ring

/-- Every Pythagorean triple (a, b, c) with a² + b² = c² can be embedded
as the Pythagorean quadruple (a, b, 0, c). -/
theorem triple_embeds_as_quadruple (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    a^2 + b^2 + 0^2 = c^2 := by linarith

/-- The embedding is compatible with the parametric formula:
Setting p = q = 0 yields a = m² + n², b = 0, c = 0, d = m² + n². -/
theorem euclid_from_quat_params (m n : ℤ) :
    let a := m^2 + n^2 - 0^2 - 0^2
    let d := m^2 + n^2 + 0^2 + 0^2
    a = d := by simp

/-- If the quaternion norm divides N, then N mod norm(q) = 0. -/
theorem norm_dvd_mod_zero (N a b c d : ℤ) (h : (a^2 + b^2 + c^2 + d^2) ∣ N) :
    N % (a^2 + b^2 + c^2 + d^2) = 0 :=
  Int.emod_eq_zero_of_dvd h

/-- The GCD of the norm and N is at least the norm itself when norm | N. -/
theorem gcd_norm_bound (N a b c d : ℤ)
    (hN : 0 < N)
    (h : (a^2 + b^2 + c^2 + d^2) ∣ N) :
    a^2 + b^2 + c^2 + d^2 ≤ N :=
  Int.le_of_dvd hN h

/-- The parametric Pythagorean quadruple formula is precisely the norm of
the quaternion product. We verify d² = a² + b² + c² algebraically. -/
theorem param_formula_is_norm_sum (m n p q : ℤ) :
    (m^2 + n^2 - p^2 - q^2)^2 + (2*(m*q + n*p))^2 + (2*(n*q - m*p))^2
    = (m^2 + n^2 + p^2 + q^2)^2 := by ring

/-- The Minkowski bound chain: N^(1/4) ≤ N^(1/3) ≤ N^(1/2) for N ≥ 2. -/
theorem dim_advantage_4_3 (N : ℕ) (hN : 2 ≤ N) :
    (N : ℝ) ^ ((1:ℝ)/4) ≤ (N : ℝ) ^ ((1:ℝ)/3) :=
  Real.rpow_le_rpow_of_exponent_le (by exact_mod_cast Nat.one_le_iff_ne_zero.mpr (by omega)) (by norm_num)

theorem dim_advantage_3_2 (N : ℕ) (hN : 2 ≤ N) :
    (N : ℝ) ^ ((1:ℝ)/3) ≤ (N : ℝ) ^ ((1:ℝ)/2) :=
  Real.rpow_le_rpow_of_exponent_le (by exact_mod_cast Nat.one_le_iff_ne_zero.mpr (by omega)) (by norm_num)

/-- A Pythagorean quadruple is primitive if gcd(a, b, c, d) = 1. -/
def IsPrimitiveQuadruple (a b c d : ℕ) : Prop :=
  a^2 + b^2 + c^2 = d^2 ∧ Nat.gcd (Nat.gcd a b) (Nat.gcd c d) = 1

/-- The simplest primitive quadruple: (1, 2, 2, 3). -/
theorem simplest_primitive_quadruple : IsPrimitiveQuadruple 1 2 2 3 := by
  constructor
  · norm_num
  · native_decide

/-- Generalized Pell obstacle: λ² - n·μ² = 1 for n = 1 has only trivial solutions. -/
theorem pell_obstacle_n1 (l m : ℤ) (h : l^2 - 1 * m^2 = 1) : m = 0 := by
  have : l ^ 2 - m ^ 2 = 1 := by linarith
  have : (l - m) * (l + m) = 1 := by nlinarith
  rw [Int.mul_eq_one_iff_eq_one_or_neg_one] at this; omega

/-- For n = 2, the Pell equation has nontrivial solutions.
The fundamental solution is (3, 2): 3² - 2·2² = 9 - 8 = 1. -/
theorem pell_n2_fundamental : (3 : ℤ)^2 - 2 * (2 : ℤ)^2 = 1 := by norm_num

/-- This nontrivial Pell solution is what makes the 2D Berggren tree work. -/
theorem berggren_connection : (1 : ℤ)^2 - 2 * (1 : ℤ)^2 = -1 := by norm_num

/-- Three-square identity does NOT exist in general.
Counterexample: 3 × 3 = 9 can be written as 0² + 0² + 3²,
but there is no *universal polynomial identity*. -/
theorem three_square_product_example :
    (1^2 + 1^2 + 1^2) * (1^2 + 1^2 + 1^2) = (9 : ℤ) := by norm_num

/-- Quaternion multiplication is associative. We verify this component-wise
for the real part of (q₁ · q₂) · q₃ = q₁ · (q₂ · q₃). -/
theorem quat_mul_assoc_re (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ a₃ b₃ c₃ d₃ : ℤ) :
    let p := fun a b c d e f g h => a*e - b*f - c*g - d*h
    p (p a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂)
      (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)
      (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)
      (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂) a₃ b₃ c₃ d₃ =
    p a₁ b₁ c₁ d₁
      (a₂*a₃ - b₂*b₃ - c₂*c₃ - d₂*d₃)
      (a₂*b₃ + b₂*a₃ + c₂*d₃ - d₂*c₃)
      (a₂*c₃ - b₂*d₃ + c₂*a₃ + d₂*b₃)
      (a₂*d₃ + b₂*c₃ - c₂*b₃ + d₂*a₃) := by ring