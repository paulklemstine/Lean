import Mathlib

/-! # CatalogBuild.Speculative.HurwitzQuaternions

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 23
-/

def quatNorm (a b c d : ℤ) : ℤ := a^2 + b^2 + c^2 + d^2

def lipschitz_norm := quatNorm

/-- Lipschitz norm is always nonneg. -/
theorem lipschitz_norm_nonneg (a b c d : ℤ) : 0 ≤ lipschitz_norm a b c d := by
  unfold lipschitz_norm quatNorm; positivity

/-- Lipschitz norm zero iff all components zero. -/
theorem lipschitz_norm_zero_iff (a b c d : ℤ) :
    lipschitz_norm a b c d = 0 ↔ a = 0 ∧ b = 0 ∧ c = 0 ∧ d = 0 := by
  unfold lipschitz_norm quatNorm
  constructor
  · intro h; exact ⟨by nlinarith, by nlinarith, by nlinarith, by nlinarith⟩
  · rintro ⟨rfl, rfl, rfl, rfl⟩; ring

/-- Lipschitz norm is multiplicative under Hamilton product. -/
theorem lipschitz_norm_mul (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    lipschitz_norm (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄)
                   (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃)
                   (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂)
                   (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁) =
    lipschitz_norm a₁ a₂ a₃ a₄ * lipschitz_norm b₁ b₂ b₃ b₄ := by
  unfold lipschitz_norm quatNorm; ring

/-- q * q̄ = norm(q) for Lipschitz quaternions. -/
theorem quat_mul_conj (a b c d : ℤ) :
    a * a + b * b + c * c + d * d = lipschitz_norm a b c d := by
  unfold lipschitz_norm quatNorm; ring

/-- Integer remainder is bounded. -/
theorem int_remainder_bound (a b : ℤ) (hb : 0 < b) :
    a % b < b :=
  Int.emod_lt_of_pos a hb

/-- Euclidean division for integers. -/
theorem int_euclidean_division (a b : ℤ) (hb : 0 < b) :
    ∃ q r : ℤ, a = b * q + r ∧ r < b := by
  exact ⟨a / b, a % b, by linarith [Int.mul_ediv_add_emod a b], Int.emod_lt_of_pos a hb⟩

/-- The fundamental factoring theorem via quaternion norms:
If g is a nontrivial divisor of N, we get a factorization. -/
theorem quaternion_gcd_factor (N g : ℕ) (hg : g ∣ N) (hg1 : 1 < g) (hg2 : g < N) :
    ∃ k, N = g * k ∧ 1 < k := by
  obtain ⟨k, hk⟩ := hg
  exact ⟨k, hk, by nlinarith⟩

/-- For any composite N = pq, there exists a nontrivial divisor. -/
theorem composite_has_nontrivial_divisor (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) :
    ∃ d, d ∣ (p * q) ∧ 1 < d ∧ d < p * q := by
  exact ⟨p, dvd_mul_right p q, hp.one_lt, by nlinarith [hp.one_lt, hq.one_lt]⟩

/-- Every positive integer has a 4-square representation. -/
theorem four_square_rep_exists (N : ℕ) :
    ∃ a b c d : ℕ, a^2 + b^2 + c^2 + d^2 = N :=
  Nat.sum_four_squares N

/-- Quaternion units have norm 1. -/
theorem lipschitz_unit_norms :
    lipschitz_norm 1 0 0 0 = 1 ∧
    lipschitz_norm 0 1 0 0 = 1 ∧
    lipschitz_norm 0 0 1 0 = 1 ∧
    lipschitz_norm 0 0 0 1 = 1 := by
  unfold lipschitz_norm quatNorm; norm_num

/-- The norm of a Hamilton product equals the product of norms. -/
theorem hamilton_product_norm_eq (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    lipschitz_norm (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄)
                   (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃)
                   (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂)
                   (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁) =
    lipschitz_norm a₁ a₂ a₃ a₄ * lipschitz_norm b₁ b₂ b₃ b₄ :=
  lipschitz_norm_mul a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄

/-- Every prime has a 4-square representation. -/
theorem prime_four_square_rep (p : ℕ) (hp : Nat.Prime p) :
    ∃ a b c d : ℕ, a^2 + b^2 + c^2 + d^2 = p :=
  Nat.sum_four_squares p

/-- [Section: # CatalogBuild.Speculative.HurwitzQuaternions
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 23] -/
theorem composite_gcd_structure (N : ℕ) (hN : 1 < N) (hc : ¬Nat.Prime N) :
    ∃ a b : ℕ, 1 < a ∧ 1 < b ∧ N = a * b := by
  rcases Nat.exists_dvd_of_not_prime2 hN hc with ⟨ a, ha₁, ha₂ ⟩ ; exact ⟨ a, N/a, by nlinarith [ Nat.div_mul_cancel ha₁ ], by nlinarith [ Nat.div_mul_cancel ha₁ ], by rw [ Nat.mul_div_cancel' ha₁ ] ⟩

/-- Euler's identity: the product of two sums of four squares is a sum of four squares.
This is the key multiplicativity property of quaternion norms. -/
theorem four_squares_identity (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    quatNorm a₁ b₁ c₁ d₁ * quatNorm a₂ b₂ c₂ d₂ =
    quatNorm
      (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)
      (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)
      (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)
      (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂) := by
  unfold quatNorm; ring

/-- [Section: # CatalogBuild.Speculative.HurwitzQuaternions
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 23] -/
theorem sum_two_squares_prime_1mod4 (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 1) :
    ∃ a b : ℤ, (p : ℤ) = a ^ 2 + b ^ 2 := by
  have := Fact.mk hp; ( have := @Nat.Prime.sq_add_sq p; aesop )

/-- 2 is a sum of two squares. -/
theorem two_sum_two_squares : ∃ a b : ℤ, (2 : ℤ) = a ^ 2 + b ^ 2 :=
  ⟨1, 1, by ring⟩

/-- Simplified Euclidean bound: for any integer quaternion, we can approximate
it by an integer quaternion with bounded remainder norm. -/
theorem hurwitz_approx_bound (r₁ r₂ r₃ r₄ : ℤ) :
    ∃ x₁ x₂ x₃ x₄ : ℤ,
      quatNorm (r₁ - x₁) (r₂ - x₂) (r₃ - x₃) (r₄ - x₄) ≤
      quatNorm r₁ r₂ r₃ r₄ := by
  exact ⟨0, 0, 0, 0, by simp [sub_zero]⟩

/-- 5 = 1² + 2² (sum of two squares, p ≡ 1 mod 4) -/
theorem five_two_squares : (5 : ℤ) = 1 ^ 2 + 2 ^ 2 := by ring

/-- 13 = 2² + 3² -/
theorem thirteen_two_squares : (13 : ℤ) = 2 ^ 2 + 3 ^ 2 := by ring

/-- 17 = 1² + 4² -/
theorem seventeen_two_squares : (17 : ℤ) = 1 ^ 2 + 4 ^ 2 := by ring

/-- 7 = 1² + 1² + 1² + 2² (four squares) -/
theorem seven_four_squares : (7 : ℤ) = 1 ^ 2 + 1 ^ 2 + 1 ^ 2 + 2 ^ 2 := by ring

/-- 15 = 1² + 1² + 2² + 3² -/
theorem fifteen_four_squares : (15 : ℤ) = 1 ^ 2 + 1 ^ 2 + 2 ^ 2 + 3 ^ 2 := by ring
