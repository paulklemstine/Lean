import Mathlib
import Catalog.Shared.QuatNorm

/-! # CatalogBuild.Speculative.HurwitzQuaternions

Unified from HurwitzQuaternions, HurwitzQuaternions_2, and HurwitzQuaternions_3.
Quaternion norms, the four-square identity, and factoring via Hurwitz quaternions.
-/}

-- ---------------------------------------------------------------------------
-- Four-square identity and multiplicative closure
-- ---------------------------------------------------------------------------

/-- Euler's four-square identity: the product of two sums of four squares
is itself a sum of four squares. This is the multiplicativity of quaternion norms. -/
theorem euler_four_square_identity (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    quatNorm a₁ b₁ c₁ d₁ * quatNorm a₂ b₂ c₂ d₂ =
    quatNorm
      (a₁ * a₂ - b₁ * b₂ - c₁ * c₂ - d₁ * d₂)
      (a₁ * b₂ + b₁ * a₂ + c₁ * d₂ - d₁ * c₂)
      (a₁ * c₂ - b₁ * d₂ + c₁ * a₂ + d₁ * b₂)
      (a₁ * d₂ + b₁ * c₂ - c₁ * b₂ + d₁ * a₂) := by
  unfold quatNorm; ring

/-- Closure of four-square representability under multiplication. -/
theorem four_square_mul_closure (n₁ n₂ : ℤ)
    (h₁ : ∃ a b c d : ℤ, quatNorm a b c d = n₁)
    (h₂ : ∃ a b c d : ℤ, quatNorm a b c d = n₂) :
    ∃ a b c d : ℤ, quatNorm a b c d = n₁ * n₂ := by
  obtain ⟨a₁, b₁, c₁, d₁, rfl⟩ := h₁
  obtain ⟨a₂, b₂, c₂, d₂, rfl⟩ := h₂
  exact ⟨_, _, _, _, (euler_four_square_identity a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂).symm

-- ---------------------------------------------------------------------------
-- Quaternion units and representations
-- ---------------------------------------------------------------------------

/-- The quaternion units have norm 1. -/
theorem quaternion_unit_norms :
    quatNorm 1 0 0 0 = 1 ∧
    quatNorm 0 1 0 0 = 1 ∧
    quatNorm 0 0 1 0 = 1 ∧
    quatNorm 0 0 0 1 = 1 := by
  unfold quatNorm; norm_num

/-- Every positive integer has a four-square representation (Lagrange). -/
theorem four_square_rep_exists (N : ℕ) :
    ∃ a b c d : ℕ, a^2 + b^2 + c^2 + d^2 = N :=
  Nat.sum_four_squares N

/-- Every prime has a four-square representation. -/
theorem prime_four_square_rep (p : ℕ) (hp : Nat.Prime p) :
    ∃ a b c d : ℕ, a^2 + b^2 + c^2 + d^2 = p :=
  Nat.sum_four_squares p

-- ---------------------------------------------------------------------------
-- Euclidean division and factoring structure
-- ---------------------------------------------------------------------------

/-- Integer remainder is bounded. -/
theorem int_remainder_bound (a b : ℤ) (hb : 0 < b) :
    a % b < b :=
  Int.emod_lt_of_pos a hb

/-- Euclidean division for integers. -/
theorem int_euclidean_division (a b : ℤ) (hb : 0 < b) :
    ∃ q r : ℤ, a = b * q + r ∧ r < b := by
  exact ⟨a / b, a % b, by linarith [Int.mul_ediv_add_emod a b], Int.emod_lt_of_pos a hb⟩

/-- If g is a nontrivial divisor of N, we get a factorization. -/
theorem quaternion_gcd_factor (N g : ℕ) (hg : g ∣ N) (hg1 : 1 < g) (hg2 : g < N) :
    ∃ k, N = g * k ∧ 1 < k := by
  obtain ⟨k, hk⟩ := hg
  exact ⟨k, hk, by nlinarith⟩

/-- Any composite N = pq has a nontrivial divisor. -/
theorem composite_has_nontrivial_divisor (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) :
    ∃ d, d ∣ (p * q) ∧ 1 < d ∧ d < p * q := by
  exact ⟨p, dvd_mul_right p q, hp.one_lt, by nlinarith [hp.one_lt, hq.one_lt]⟩

/-- Composite numbers have a two-factor decomposition. -/
theorem composite_gcd_structure (N : ℕ) (hN : 1 < N) (hc : ¬Nat.Prime N) :
    ∃ a b : ℕ, 1 < a ∧ 1 < b ∧ N = a * b := by
  rcases Nat.exists_dvd_of_not_prime2 hN hc with ⟨a, ha₁, ha₂⟩
  exact ⟨a, N / a, by nlinarith [Nat.div_mul_cancel ha₁],
    by nlinarith [Nat.div_mul_cancel ha₁],
    by rw [Nat.mul_div_cancel' ha₁]⟩
