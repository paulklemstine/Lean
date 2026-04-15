/-! # CatalogBuild.Best.12_QuadrupleFactorTheory

Auto-generated from theorem catalog database.
Domain: Best
Declarations: 25
-/

import Mathlib

/-- A Pythagorean quadruple is a 4-tuple (a,b,c,d) with a² + b² + c² = d². -/
structure PythagoreanQuadruple where
  a : ℤ
  b : ℤ
  c : ℤ
  d : ℤ
  quad_eq : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2


/-- The fundamental example: (1, 2, 2, 3). -/
def pq_1223 : PythagoreanQuadruple where
  a := 1; b := 2; c := 2; d := 3
  quad_eq := by norm_num


/-- The quadruple (2, 3, 6, 7). -/
def pq_2367 : PythagoreanQuadruple where
  a := 2; b := 3; c := 6; d := 7
  quad_eq := by norm_num


/-- The quadruple (1, 4, 8, 9). -/
def pq_1489 : PythagoreanQuadruple where
  a := 1; b := 4; c := 8; d := 9
  quad_eq := by norm_num


/-- The quadruple (4, 4, 7, 9). -/
def pq_4479 : PythagoreanQuadruple where
  a := 4; b := 4; c := 7; d := 9
  quad_eq := by norm_num


/-- **Core Factoring Identity**: For any Pythagorean quadruple,
(d - c)(d + c) = a² + b². This bridges quadruples to factoring. -/
theorem quad_difference_of_squares (q : PythagoreanQuadruple) :
    (q.d - q.c) * (q.d + q.c) = q.a ^ 2 + q.b ^ 2 := by
  have h := q.quad_eq
  nlinarith


/-- The sum d + c is always positive when d > 0 and c ≥ 0. -/
theorem quad_sum_pos (q : PythagoreanQuadruple) (hd : q.d > 0) (hc : q.c ≥ 0) :
    q.d + q.c > 0 := by
  omega


/-- The difference d - c is nonneg when d ≥ c. -/
theorem quad_diff_nonneg (q : PythagoreanQuadruple) (hd : q.d ≥ q.c) :
    q.d - q.c ≥ 0 := by
  omega


/-- The standard parametrization of Pythagorean quadruples.
Given parameters (m,n,p,q), produce a quadruple. -/
def quadFromParams (m n p q : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (m^2 + n^2 - p^2 - q^2,
   2 * (m * q + n * p),
   2 * (n * q - m * p),
   m^2 + n^2 + p^2 + q^2)


/-- **Parametric Validity**: The parametrization always produces a valid quadruple. -/
theorem param_produces_quadruple (m n p q : ℤ) :
    let (a, b, c, d) := quadFromParams m n p q
    a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 := by
  simp only [quadFromParams]
  ring


/-- **Parametric Factor Revelation**: In the parametrization,
d = (m² + n²) + (p² + q²), decomposing d as a sum of two
sums-of-two-squares. This reveals multiplicative structure. -/
theorem param_d_decomposition (m n p q : ℤ) :
    (quadFromParams m n p q).2.2.2 = (m^2 + n^2) + (p^2 + q^2) := by
  simp [quadFromParams]; ring


/-- **Parametric a² + b² factorization**: a² + b² = (d-c)(d+c). -/
theorem param_ab_factorization (m n p q : ℤ) :
    let (a, b, c, d) := quadFromParams m n p q
    a ^ 2 + b ^ 2 = (d - c) * (d + c) := by
  simp only [quadFromParams]
  ring


theorem collision_factor_extraction (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h₁ : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h₂ : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    c₁ ^ 2 - c₂ ^ 2 = (a₂ ^ 2 - a₁ ^ 2) + (b₂ ^ 2 - b₁ ^ 2) := by
  grind


/-- The collision identity in factored form: (c₁-c₂)(c₁+c₂). -/
theorem collision_difference_product (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h₁ : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h₂ : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    (c₁ - c₂) * (c₁ + c₂) = (a₂ ^ 2 - a₁ ^ 2) + (b₂ ^ 2 - b₁ ^ 2) := by
  nlinarith


theorem quadruple_scaling (a b c d k : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    (k*a)^2 + (k*b)^2 + (k*c)^2 = (k*d)^2 := by
  linear_combination' k ^ 2 * h


/-- **Scaling produces valid quadruple structure**. -/
def PythagoreanQuadruple.scale (q : PythagoreanQuadruple) (k : ℤ) : PythagoreanQuadruple where
  a := k * q.a
  b := k * q.b
  c := k * q.c
  d := k * q.d
  quad_eq := quadruple_scaling q.a q.b q.c q.d k q.quad_eq


/-- **Lattice Factor Pairs**: For two quadruples with the same hypotenuse d,
the pairwise differences of their components carry factor information:
(a₁²-a₂²) + (b₁²-b₂²) = (c₂²-c₁²). -/
theorem lattice_factor_pairs (q₁ q₂ : PythagoreanQuadruple) (hd : q₁.d = q₂.d) :
    (q₁.a - q₂.a) * (q₁.a + q₂.a) + (q₁.b - q₂.b) * (q₁.b + q₂.b) =
    (q₂.c - q₁.c) * (q₂.c + q₁.c) := by
  have h1 := q₁.quad_eq
  have h2 := q₂.quad_eq
  have hd2 : q₁.d ^ 2 = q₂.d ^ 2 := by rw [hd]
  nlinarith


/-- The norm-squared of a Gaussian integer z = a + bi is a² + b². -/
def gaussianNormSq (a b : ℤ) : ℤ := a ^ 2 + b ^ 2


/-- For any quadruple, (d-c)(d+c) equals the Gaussian norm-squared of (a,b). -/
theorem gaussian_quad_connection (q : PythagoreanQuadruple) :
    gaussianNormSq q.a q.b = (q.d - q.c) * (q.d + q.c) := by
  unfold gaussianNormSq
  have h := q.quad_eq
  nlinarith


/-- **Gaussian Factoring Principle**: a² + b² = d² - c². -/
theorem gaussian_factor_principle (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    a ^ 2 + b ^ 2 = d ^ 2 - c ^ 2 := by
  linarith


/-- If p divides both (d-c) and (d+c), then p divides 2d. -/
theorem divisor_sum_from_factors (c d p : ℤ) (h1 : p ∣ (d - c)) (h2 : p ∣ (d + c)) :
    p ∣ (2 * d) := by
  obtain ⟨k1, hk1⟩ := h1
  obtain ⟨k2, hk2⟩ := h2
  use k1 + k2
  linarith


/-- If p divides both (d-c) and (d+c), then p divides 2c. -/
theorem divisor_diff_from_factors (c d p : ℤ) (h1 : p ∣ (d - c)) (h2 : p ∣ (d + c)) :
    p ∣ (2 * c) := by
  obtain ⟨k1, hk1⟩ := h1
  obtain ⟨k2, hk2⟩ := h2
  use k2 - k1
  linarith


theorem prime_divisor_dichotomy (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2)
    (p : ℤ) (hp_prime : Prime p) (hp : p ∣ (a^2 + b^2)) :
    p ∣ (d - c) ∨ p ∣ (d + c) := by
  exact hp_prime.dvd_or_dvd ( by convert hp using 1; linarith )


theorem sq_mod4 (n : ℤ) : n ^ 2 % 4 = 0 ∨ n ^ 2 % 4 = 1 := by
  rcases Int.even_or_odd' n with ⟨ k, rfl | rfl ⟩ <;> ring_nf <;> norm_num


/-- **Mod 8 Structure**: When all components are even, 8 divides d²-a²-b²-c². -/
theorem quad_mod8_even (a b c d : ℤ)
    (h : a^2 + b^2 + c^2 = d^2)
    (ha : 2 ∣ a) (hb : 2 ∣ b) (hc : 2 ∣ c) (hd : 2 ∣ d) :
    8 ∣ (d^2 - a^2 - b^2 - c^2) := by
  omega

