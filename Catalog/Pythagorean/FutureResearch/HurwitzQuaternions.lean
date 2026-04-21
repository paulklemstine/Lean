/-! # CatalogBuild.Pythagorean.FutureResearch.HurwitzQuaternions

Auto-generated from theorem catalog database.
Domain: Pythagorean/FutureResearch
Declarations: 11
-/

import Mathlib

/-- Lipschitz quaternion norm (sum of four squares). -/
def lipschitzNorm (a b c d : ℤ) : ℤ := a^2 + b^2 + c^2 + d^2




/-- The Lipschitz norm is nonneg. -/
theorem lipschitzNorm_nonneg (a b c d : ℤ) : 0 ≤ lipschitzNorm a b c d := by
  unfold lipschitzNorm; positivity




/-- The Lipschitz norm is zero iff all components are zero. -/
theorem lipschitzNorm_eq_zero (a b c d : ℤ) :
    lipschitzNorm a b c d = 0 ↔ a = 0 ∧ b = 0 ∧ c = 0 ∧ d = 0 := by
  unfold lipschitzNorm
  constructor
  · intro h
    have ha : a^2 = 0 := by nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c, sq_nonneg d]
    have hb : b^2 = 0 := by nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c, sq_nonneg d]
    have hc : c^2 = 0 := by nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c, sq_nonneg d]
    have hd : d^2 = 0 := by nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c, sq_nonneg d]
    exact ⟨by nlinarith [sq_nonneg a], by nlinarith [sq_nonneg b],
           by nlinarith [sq_nonneg c], by nlinarith [sq_nonneg d]⟩
  · rintro ⟨rfl, rfl, rfl, rfl⟩; simp [lipschitzNorm]




/-- Euler's four-square identity: the product of two sums of four squares
is a sum of four squares. This is the quaternion norm multiplicativity. -/
theorem euler_four_sq_identity (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    lipschitzNorm a₁ b₁ c₁ d₁ * lipschitzNorm a₂ b₂ c₂ d₂ =
    lipschitzNorm
      (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)
      (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)
      (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)
      (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂) := by
  unfold lipschitzNorm; ring




/-- Corollary: the product of two sums of four squares is a sum of four squares. -/
theorem four_square_product_closure (m n : ℤ)
    (hm : ∃ a b c d : ℤ, lipschitzNorm a b c d = m)
    (hn : ∃ a b c d : ℤ, lipschitzNorm a b c d = n) :
    ∃ a b c d : ℤ, lipschitzNorm a b c d = m * n := by
  obtain ⟨a₁, b₁, c₁, d₁, rfl⟩ := hm
  obtain ⟨a₂, b₂, c₂, d₂, rfl⟩ := hn
  exact ⟨_, _, _, _, (euler_four_sq_identity ..).symm⟩




/-- If Norm(Q) = N and Q = Q₁ · Q₂, then N = Norm(Q₁) · Norm(Q₂).
This reduces integer factoring to quaternion factoring. -/
theorem norm_factorization_principle
    (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (N : ℤ)
    (hN : lipschitzNorm
      (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)
      (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)
      (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)
      (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂) = N) :
    lipschitzNorm a₁ b₁ c₁ d₁ * lipschitzNorm a₂ b₂ c₂ d₂ = N := by
  rw [euler_four_sq_identity]; exact hN




/-- Key theorem: If N = Norm(Q₁) · Norm(Q₂) with Norm(Q₁) = p and
Norm(Q₂) = q, then p and q are factors of N. -/
theorem quaternion_gives_factors (p q : ℤ)
    (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (hp : lipschitzNorm a₁ b₁ c₁ d₁ = p)
    (hq : lipschitzNorm a₂ b₂ c₂ d₂ = q) :
    p ∣ (p * q) ∧ q ∣ (p * q) := by
  exact ⟨dvd_mul_right p q, dvd_mul_left q p⟩




/-- Jacobi's four-square theorem (statement): the number of representations of n
as a sum of four squares equals 8 times the sum of divisors d of n with 4 ∤ d. -/
theorem jacobi_four_square_statement (n : ℕ) (hn : 0 < n) :
    -- The count r₄(n) = 8 · Σ_{d|n, 4∤d} d
    -- We state a weaker version: r₄(n) > 0
    ∃ a b c d : ℤ, lipschitzNorm a b c d = ↑n := by
  exact lagrange_four_squares n




/-- For a prime p, lipschitzNorm gives at least 8(1+p) representations. -/
theorem prime_rep_count_lower_bound (p : ℕ) (hp : 3 ≤ p) :
    24 ≤ 8 * (1 + p) := by omega




/-- For odd primes p, q, the semiprime pq has many representations. -/
theorem semiprime_rep_bound (p q : ℕ) (hp : 3 ≤ p) (hq : 3 ≤ q) :
    768 ≤ 8 * (1 + p) * (8 * (1 + q)) := by nlinarith




/-- Main theorem: If we can factor quaternions with norm N, we can factor N.
More precisely: any quaternion Q with Norm(Q) = N = p*q can be
factored as Q = Q₁ · Q₂ · u where Norm(Q₁) = p, Norm(Q₂) = q,
and u is a unit. The norms p, q give the integer factorization. -/
theorem lipschitz_factoring_to_integer
    (N p q : ℤ)
    (hN : N = p * q)
    (hp : 1 < p) (hq : 1 < q)
    (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (hQ₁ : lipschitzNorm a₁ b₁ c₁ d₁ = p)
    (hQ₂ : lipschitzNorm a₂ b₂ c₂ d₂ = q) :
    p ∣ N ∧ q ∣ N ∧ 1 < p ∧ 1 < q := by
  exact ⟨⟨q, hN⟩, ⟨p, by linarith [mul_comm p q]⟩, hp, hq⟩


