/-! # CatalogBuild.Speculative.HurwitzQuaternions_2

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 14
-/

import Mathlib

/-- The Lipschitz quaternion norm (sum of squares of integer components). -/
def lipschitz_norm (a b c d : ℤ) : ℤ := a^2 + b^2 + c^2 + d^2




/-- Lipschitz norm is always nonneg. -/
theorem lipschitz_norm_nonneg (a b c d : ℤ) : 0 ≤ lipschitz_norm a b c d := by
  unfold lipschitz_norm; positivity




/-- Lipschitz norm zero iff all components zero. -/
theorem lipschitz_norm_zero_iff (a b c d : ℤ) :
    lipschitz_norm a b c d = 0 ↔ a = 0 ∧ b = 0 ∧ c = 0 ∧ d = 0 := by
  unfold lipschitz_norm
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
  unfold lipschitz_norm; ring




/-- q * q̄ = norm(q) for Lipschitz quaternions. -/
theorem quat_mul_conj (a b c d : ℤ) :
    a * a + b * b + c * c + d * d = lipschitz_norm a b c d := by
  unfold lipschitz_norm; ring




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
  unfold lipschitz_norm; norm_num




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




/-- [Section: # CatalogBuild.Speculative.HurwitzQuaternions_2
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 14] -/
theorem composite_gcd_structure (N : ℕ) (hN : 1 < N) (hc : ¬Nat.Prime N) :
    ∃ a b : ℕ, 1 < a ∧ 1 < b ∧ N = a * b := by
  rcases Nat.exists_dvd_of_not_prime2 hN hc with ⟨ a, ha₁, ha₂ ⟩ ; exact ⟨ a, N/a, by nlinarith [ Nat.div_mul_cancel ha₁ ], by nlinarith [ Nat.div_mul_cancel ha₁ ], by rw [ Nat.mul_div_cancel' ha₁ ] ⟩


