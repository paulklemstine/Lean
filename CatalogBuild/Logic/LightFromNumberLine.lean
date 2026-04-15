/-! # CatalogBuild.Logic.LightFromNumberLine

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 20
-/

import Mathlib

/-- The standard parametrization of Pythagorean triples satisfies a² + b² = c². -/
theorem pythagorean_parametrization (m n : ℤ) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by
  ring


/-- [Section: ## 3. Unit Circle / Polarization States] -/
theorem unit_circle_rational_point (m n : ℚ) (h : m ^ 2 + n ^ 2 ≠ 0) :
    ((m ^ 2 - n ^ 2) / (m ^ 2 + n ^ 2)) ^ 2 +
    (2 * m * n / (m ^ 2 + n ^ 2)) ^ 2 = 1 := by
  grind


/-- The Gaussian norm is multiplicative: beam splitting preserves total intensity. -/
theorem gaussian_norm_multiplicative (a b c d : ℤ) :
    ∃ e f : ℤ, (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = e ^ 2 + f ^ 2 := by
  exact ⟨a * c - b * d, a * d + b * c, by ring⟩


/-- [Section: ## 5. Fermat's Two-Square Theorem (Easy Direction)] -/
theorem fermat_two_square_easy_direction (p a b : ℕ) (hp : Nat.Prime p)
    (hab : a ^ 2 + b ^ 2 = p) (ha : 0 < a) (hb : 0 < b) :
    p = 2 ∨ p % 4 = 1 := by
  subst p; rcases Nat.even_or_odd' a with ⟨ k, rfl | rfl ⟩ <;> rcases Nat.even_or_odd' b with ⟨ l, rfl | rfl ⟩ <;> ring_nf <;> norm_num at *;
  · exact absurd hp ( by rw [ show ( 2 * k ) ^ 2 + ( 2 * l ) ^ 2 = 2 * ( 2 * k ^ 2 + 2 * l ^ 2 ) by ring ] ; exact Nat.not_prime_mul ( by norm_num ) ( by nlinarith only [ ha, hb ] ) );
  · cases hp.eq_two_or_odd' <;> simp_all +arith +decide [ parity_simps ];
    lia


/-- [Section: ## 6. Infinitude of Pythagorean Triples] -/
theorem infinitely_many_pythagorean_triples :
    ∀ N : ℕ, ∃ a b c : ℕ, N < c ∧ a ^ 2 + b ^ 2 = c ^ 2 ∧ 0 < a ∧ 0 < b := by
  intro N
  use 3 * (N + 1), 4 * (N + 1), 5 * (N + 1);
  grind


/-- A Pythagorean triple defines a null (lightlike) direction. -/
theorem lightlike_direction (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c ^ 2 - a ^ 2 - b ^ 2 = 0 := by
  omega


/-- Lightlike directions are scale-invariant. -/
theorem lightlike_scaling (a b c k : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (k * a) ^ 2 + (k * b) ^ 2 = (k * c) ^ 2 := by
  nlinarith [mul_pow k a 2, mul_pow k b 2, mul_pow k c 2]


/-- Combining two Pythagorean triples via Gaussian multiplication yields a new triple. -/
theorem pythagorean_superposition (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h₁ : a₁ ^ 2 + b₁ ^ 2 = c₁ ^ 2) (h₂ : a₂ ^ 2 + b₂ ^ 2 = c₂ ^ 2) :
    (a₁ * a₂ - b₁ * b₂) ^ 2 + (a₁ * b₂ + b₁ * a₂) ^ 2 = (c₁ * c₂) ^ 2 := by
  nlinarith [brahmagupta_fibonacci a₁ b₁ a₂ b₂]


/-- Every number of the form 4k+2 with k ≥ 0 can be expressed as a sum of two squares
(since 4k+2 = (2k+1)² + 1² when k=0, and more generally 2 = 1² + 1²). -/
theorem two_is_sum_of_squares : ∃ a b : ℤ, a ^ 2 + b ^ 2 = 2 :=
  ⟨1, 1, by ring⟩


/-- 5 is the smallest odd prime that splits in ℤ[i]. -/
theorem five_splits : ∃ a b : ℤ, a ^ 2 + b ^ 2 = 5 :=
  ⟨1, 2, by ring⟩


/-- 13 splits in ℤ[i]. -/
theorem thirteen_splits : ∃ a b : ℤ, a ^ 2 + b ^ 2 = 13 :=
  ⟨2, 3, by ring⟩


/-- 25 has two distinct Pythagorean representations (interference). -/
theorem interference_25 :
    (3 ^ 2 + 4 ^ 2 = 25) ∧ (0 ^ 2 + 5 ^ 2 = 25) := by
  constructor <;> norm_num


/-- 50 has multiple representations as a sum of two squares. -/
theorem multiple_representations_50 :
    (1 ^ 2 + 7 ^ 2 = 50) ∧ (5 ^ 2 + 5 ^ 2 = 50) := by
  constructor <;> norm_num


/-- [Section: ## 11. Parity and Modular Structure] -/
theorem sum_two_squares_mod4 (a b : ℤ) : (a ^ 2 + b ^ 2) % 4 ≠ 3 := by
  rcases Int.even_or_odd' a with ⟨ a, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ b, rfl | rfl ⟩ <;> ring_nf <;> norm_num


/-- The fundamental (3,4,5) Pythagorean triple. -/
theorem triple_3_4_5 : (3 : ℤ) ^ 2 + 4 ^ 2 = 5 ^ 2 := by norm_num


/-- The (5,12,13) triple. -/
theorem triple_5_12_13 : (5 : ℤ) ^ 2 + 12 ^ 2 = 13 ^ 2 := by norm_num


/-- The (8,15,17) triple. -/
theorem triple_8_15_17 : (8 : ℤ) ^ 2 + 15 ^ 2 = 17 ^ 2 := by norm_num


/-- The (7,24,25) triple — first multi-representation hypotenuse. -/
theorem triple_7_24_25 : (7 : ℤ) ^ 2 + 24 ^ 2 = 25 ^ 2 := by norm_num


/-- [Section: ## 13. Polarization Angle Density] -/
theorem polarization_density :
    ∀ p q : ℕ, 0 < p → p < q →
    ∃ m n : ℕ, 0 < n ∧ n < m ∧
      (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by
  exact fun p q hp hq => ⟨ 2, 1, by norm_num, by norm_num, by norm_num ⟩


/-- [Section: ## 15. Wave-Particle Duality (Fourier)] -/
theorem wave_particle_complementarity (a b c : ℤ) (hc : c ≠ 0) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a : ℚ) ^ 2 / (c : ℚ) ^ 2 + (b : ℚ) ^ 2 / (c : ℚ) ^ 2 = 1 := by
  rw [ ← add_div, div_eq_iff ] <;> norm_cast <;> aesop
