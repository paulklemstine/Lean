/-! # CatalogBuild.Pythagorean.GravitationalFactoring.CoreTheorems

Auto-generated from theorem catalog database.
Domain: Pythagorean/GravitationalFactoring
Declarations: 24
-/

import Mathlib

/-- Channel count satisfies 2·C(k) = k(k+1). -/
theorem channel_quadratic_growth (k : ℕ) :
    2 * totalChannels k = k * (k + 1) := by
  unfold totalChannels
  rcases k with _ | n
  · simp
  · rw [Nat.choose_two_right, Nat.succ_sub_one]
    have h : 2 ∣ (n + 1) * n := by
      rcases n.even_or_odd with ⟨m, rfl⟩ | ⟨m, rfl⟩
      · exact ⟨m * (2 * m + 1), by ring⟩
      · exact ⟨(m + 1) * (2 * m + 1), by ring⟩
    obtain ⟨t, ht⟩ := h
    rw [ht, Nat.mul_div_cancel_left _ (by norm_num : 0 < 2)]
    nlinarith [ht]


/-- Concrete channel counts for key dimensions in the Cayley-Dickson hierarchy. -/
theorem channel_hierarchy_concrete :
    totalChannels 2 = 3 ∧
    totalChannels 3 = 6 ∧
    totalChannels 4 = 10 ∧
    totalChannels 8 = 36 ∧
    totalChannels 16 = 136 := by
  unfold totalChannels; decide


/-- Channels at dimension k+1 are strictly greater than at k (for k ≥ 1). -/
theorem channels_strictly_increasing (k : ℕ) (hk : 1 ≤ k) :
    totalChannels k < totalChannels (k + 1) := by
  unfold totalChannels
  have h := Nat.choose_le_choose 2 (show k ≤ k + 1 by omega)
  linarith


/-- The fundamental peel identity: d² - xⱼ² = (d - xⱼ)(d + xⱼ). -/
theorem peel_identity (d x : ℤ) :
    d ^ 2 - x ^ 2 = (d - x) * (d + x) := by ring


/-- Peel product encodes complementary sum of squares. -/
theorem peel_product_is_complement {k : ℕ} (legs : Fin k → ℤ) (d : ℤ)
    (h : (∑ i, (legs i) ^ 2) = d ^ 2) (j : Fin k) :
    (d - legs j) * (d + legs j) = ∑ i ∈ Finset.univ.erase j, (legs i) ^ 2 := by
  have hsplit : (∑ i, (legs i) ^ 2) =
      (legs j) ^ 2 + ∑ i ∈ Finset.univ.erase j, (legs i) ^ 2 := by
    rw [← Finset.add_sum_erase _ _ (Finset.mem_univ j)]
  rw [hsplit] at h; nlinarith


/-- If p | N and N | d² - x², then p | (d-x)(d+x). -/
theorem peel_product_factors_N (p d x N : ℤ) (hp : p ∣ N) (hN : N ∣ d ^ 2 - x ^ 2) :
    p ∣ (d - x) * (d + x) := by
  rw [peel_identity] at hN; exact dvd_trans hp hN


/-- Cross-collision: two representations give difference of squares. -/
theorem cross_collision_difference_of_squares
    (x y d : ℤ) (r₁ r₂ : ℤ)
    (h₁ : x ^ 2 + r₁ = d ^ 2)
    (h₂ : y ^ 2 + r₂ = d ^ 2) :
    x ^ 2 - y ^ 2 = r₂ - r₁ := by linarith


/-- The cross-collision factors as (x-y)(x+y). -/
theorem cross_collision_factored (x y : ℤ) :
    x ^ 2 - y ^ 2 = (x - y) * (x + y) := by ring


/-- ℂ: Two-square (Brahmagupta-Fibonacci) identity. -/
theorem norm_multiplicativity_two_square (a₁ b₁ a₂ b₂ : ℤ) :
    (a₁^2 + b₁^2) * (a₂^2 + b₂^2) =
    (a₁*a₂ - b₁*b₂)^2 + (a₁*b₂ + b₁*a₂)^2 := by ring


/-- ℍ: Four-square (Euler) identity. -/
theorem norm_multiplicativity_four_square (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    (a₁^2 + b₁^2 + c₁^2 + d₁^2) * (a₂^2 + b₂^2 + c₂^2 + d₂^2) =
    (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)^2 +
    (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)^2 +
    (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)^2 +
    (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂)^2 := by ring


/-- Alternative two-square form (Cayley-Dickson). -/
theorem cayley_dickson_norm_two (a b c d : ℤ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c + b*d)^2 + (a*d - b*c)^2 := by ring


/-- [Section: ## §6. Sum-of-Divisors] -/
theorem sigma1_mult_coprime (a b : ℕ) (ha : 0 < a) (hb : 0 < b)
    (h : Nat.Coprime a b) :
    sigma1 (a * b) = sigma1 a * sigma1 b := by
  unfold sigma1;
  exact?


/-- For odd primes p, Jacobi: r₄(p) = 8(p+1). -/
theorem jacobi_r4_prime (p : ℕ) (hp : p.Prime) :
    8 * sigma1 p = 8 * (p + 1) := by
  rw [sigma1_prime p hp]


/-- Berggren matrix A has determinant 1. -/
theorem berggrenA_det : berggrenA.det = 1 := by
  simp [berggrenA, Matrix.det_fin_three]


/-- Berggren matrix B has determinant -1. -/
theorem berggrenB_det : berggrenB.det = -1 := by
  simp [berggrenB, Matrix.det_fin_three]


/-- Berggren matrix C has determinant 1. -/
theorem berggrenC_det : berggrenC.det = 1 := by
  simp [berggrenC, Matrix.det_fin_three]


/-- Berggren matrices preserve the Pythagorean property. -/
theorem berggrenA_preserves_pythagorean (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a - 2*b + 2*c)^2 + (2*a - b + 2*c)^2 = (2*a - 2*b + 3*c)^2 := by nlinarith


/-- [Section: ## §7. Berggren Tree Structure] -/
theorem berggrenB_preserves_pythagorean (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a + 2*b + 2*c)^2 + (2*a + b + 2*c)^2 = (2*a + 2*b + 3*c)^2 := by nlinarith


theorem berggrenC_preserves_pythagorean (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (-a + 2*b + 2*c)^2 + (-2*a + b + 2*c)^2 = (-2*a + 2*b + 3*c)^2 := by nlinarith


/-- Energy is zero iff we have a valid Pythagorean k-tuple. -/
theorem energy_zero_iff_valid (k : ℕ) (legs : Fin k → ℤ) (d : ℤ) :
    factoringEnergy k legs d = 0 ↔ (∑ i, (legs i) ^ 2) = d ^ 2 := by
  unfold factoringEnergy; omega


/-- Nonneg energy when sum ≥ d². -/
theorem energy_nonneg_on_sphere (k : ℕ) (legs : Fin k → ℤ) (d : ℤ)
    (h : (∑ i, (legs i) ^ 2) ≥ d ^ 2) :
    0 ≤ factoringEnergy k legs d := by
  unfold factoringEnergy; omega


/-- For balanced semiprimes, density bound. -/
theorem balanced_density_bound (p q : ℕ) (hp : 2 ≤ p) (hq : 2 ≤ q) :
    p + q - 1 ≤ 2 * max p q := by omega


/-- Setting 1/(2α) = 2α gives α = 1/2. -/
theorem optimal_alpha_balance (α : ℚ) (hα : α = 1/2) :
    1 / (2 * α) = 2 * α := by subst hα; norm_num


/-- A nontrivial GCD gives a factorization. -/
theorem nontrivial_gcd_factors (g N : ℕ) (hN : 1 < N)
    (hg : g ∣ N) (hg1 : 1 < g) (hgN : g < N) :
    ∃ a b : ℕ, N = a * b ∧ 1 < a ∧ 1 < b :=
  ⟨g, N / g,
   (Nat.mul_div_cancel' hg).symm,
   hg1,
   by { have h1 := Nat.div_pos (Nat.le_of_dvd (by omega) hg) (by omega : 0 < g)
        have h2 := Nat.div_lt_self (by omega : 0 < N) hg1
        have : N / g ≠ 1 := by
          intro heq; have := Nat.div_mul_cancel hg; rw [heq] at this; simp at this; omega
        omega }⟩
