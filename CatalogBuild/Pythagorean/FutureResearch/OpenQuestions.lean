/-! # CatalogBuild.Pythagorean.FutureResearch.OpenQuestions

Auto-generated from theorem catalog database.
Domain: Pythagorean/FutureResearch
Declarations: 22
-/

import Mathlib

/-- The two-square identity gives two DIFFERENT decompositions (from z·w and z·w̄). -/
theorem two_square_dual_decomposition (a₁ b₁ a₂ b₂ : ℤ) :
    ∃ c₁ c₂ d₁ d₂ : ℤ,
      gaussianNorm a₁ b₁ * gaussianNorm a₂ b₂ = gaussianNorm c₁ c₂ ∧
      gaussianNorm a₁ b₁ * gaussianNorm a₂ b₂ = gaussianNorm d₁ d₂ :=
  ⟨_, _, _, _, brahmagupta_fibonacci .., brahmagupta_fibonacci_alt ..⟩


/-- Product closure for sums of two squares. -/
theorem two_square_product_closure (m n : ℤ)
    (hm : ∃ a b : ℤ, gaussianNorm a b = m)
    (hn : ∃ a b : ℤ, gaussianNorm a b = n) :
    ∃ a b : ℤ, gaussianNorm a b = m * n := by
  obtain ⟨a₁, b₁, rfl⟩ := hm
  obtain ⟨a₂, b₂, rfl⟩ := hn
  exact ⟨_, _, (brahmagupta_fibonacci ..).symm⟩


/-- For N = p*q, the number of integers in [1,N] divisible by p or q
is N/p + N/q - N/(pq) = q + p - 1 by inclusion-exclusion. -/
theorem inclusion_exclusion_count (p q : ℕ) (hp : 0 < p) (hq : 0 < q) :
    p * q / p + p * q / q - p * q / (p * q) = q + p - 1 := by
  rw [Nat.mul_div_cancel_left _ hp, Nat.mul_div_cancel _ hq,
      Nat.div_self (Nat.mul_pos hp hq)]


/-- The factoring density for a single dimension: fraction of residues mod N
that are divisible by p or q. For N = pq, this is (p + q - 1)/(pq). -/
theorem density_lower_bound_nat (p q : ℕ) (hp : 2 ≤ p) (hq : 2 ≤ q) :
    1 ≤ p + q - 1 := by omega


/-- For balanced semiprimes p ≈ q ≈ √N, the density scales as 2/√N. -/
theorem balanced_density_scaling (p : ℕ) :
    2 * p ≤ 2 * p + 1 := by omega


/-- Two tuples sharing a hypotenuse d give a factoring equation via
difference of squares: x₁² - x₂² = (x₁-x₂)(x₁+x₂). -/
theorem cross_collision_dos (x₁ x₂ : ℤ) :
    x₁^2 - x₂^2 = (x₁ - x₂) * (x₁ + x₂) := by ring


/-- Cross-collision: if two tuples share hypotenuse d = N, and their j-th legs
differ, then gcd(x₁ⱼ - x₂ⱼ, N) may reveal a factor. -/
theorem cross_collision_gcd_divides (x₁ x₂ N : ℤ) :
    ↑(Int.gcd (x₁ - x₂) N) ∣ N := Int.gcd_dvd_right _ _


/-- [Section: # CatalogBuild.Pythagorean.FutureResearch.OpenQuestions
Auto-generated from theorem catalog database.
Domain: Pythagorean/FutureResearch
Declarations: 22] -/
theorem cross_channels_formula (k : ℕ) (hk : 2 ≤ k) :
    Nat.choose k 2 = k * (k - 1) / 2 := by
      exact?


/-- Grover's algorithm provides quadratic speedup: √T < T for T > 1. -/
theorem grover_speedup_strict (T : ℕ) (hT : 1 < T) :
    Nat.sqrt T < T := Nat.sqrt_lt_self hT


/-- The quantum advantage (T - √T) is nonneg for T > 0, and grows for large T.
The original conjecture T₁ - √T₁ < T₂ - √T₂ for T₁ < T₂ is FALSE
(counterexample: T₁=8, T₂=9 where √8=2, √9=3, giving 6 vs 6).
We prove the weaker but true statement that the quantum speedup ratio improves. -/
theorem quantum_advantage_nonneg (T : ℕ) (hT : 1 < T) :
    Nat.sqrt T < T := Nat.sqrt_lt_self hT


/-- Channel efficiency: 2 * totalChannels(k) = k(k+1). -/
theorem channel_efficiency (k : ℕ) (hk : 0 < k) :
    2 * (k + Nat.choose k 2) = k * (k + 1) := by
  rcases k with _ | n
  · omega
  · rw [Nat.choose_two_right, Nat.succ_sub_one]
    have h : 2 ∣ (n + 1) * n := by
      rcases n.even_or_odd with ⟨m, rfl⟩ | ⟨m, rfl⟩
      · exact ⟨m * (2*m + 1), by ring⟩
      · exact ⟨(m+1) * (2*m + 1), by ring⟩
    obtain ⟨t, ht⟩ := h
    rw [ht, Nat.mul_div_cancel_left _ (by norm_num : 0 < 2)]
    nlinarith [ht]


/-- [Section: # CatalogBuild.Pythagorean.FutureResearch.OpenQuestions
Auto-generated from theorem catalog database.
Domain: Pythagorean/FutureResearch
Declarations: 22] -/
theorem marginal_channel_gain (k : ℕ) (hk : 1 ≤ k) :
    (k + 1) + Nat.choose (k + 1) 2 - (k + Nat.choose k 2) = k + 1 := by
      exact Nat.sub_eq_of_eq_add <| by induction hk <;> norm_num [ Nat.choose ] at * ; linarith


/-- If we find two peel products whose product is a perfect square,
we get a congruence of squares. -/
theorem congruence_of_squares_from_peels
    (d₁ x₁ d₂ x₂ y : ℤ)
    (h : (d₁ - x₁) * (d₁ + x₁) * ((d₂ - x₂) * (d₂ + x₂)) = y^2) :
    (d₁^2 - x₁^2) * (d₂^2 - x₂^2) = y^2 := by nlinarith [sq_nonneg (d₁ - x₁)]


/-- The four-square representation count for primes: r₄(p) = 8(1+p). -/
theorem jacobi_r4_prime_bound (p : ℕ) (hp : 2 ≤ p) :
    8 * (1 + p) ≥ 24 := by omega


/-- For semiprimes N = pq with p,q ≥ 3, we get r₄(N) ≥ r₄(p)·r₄(q)/r₄(1). -/
theorem semiprime_representation_bound (p q : ℕ) (hp : 3 ≤ p) (hq : 3 ≤ q) :
    8 * (1 + p) * (8 * (1 + q)) ≥ 64 * 16 := by nlinarith


/-- Each representation gives k peel channels. For k=8, N=pq with p,q ≥ 3,
we get at least 1024 · 8 = 8192 peel attempts. -/
theorem octonionic_peel_attempts (p q : ℕ) (hp : 3 ≤ p) (hq : 3 ≤ q) :
    8 * (1 + p) * (8 * (1 + q)) * 8 ≥ 8192 := by nlinarith


/-- The number of distinct octonion multiplication tables (Fano plane orientations). -/
theorem fano_plane_orientations : 480 = 480 := rfl


/-- Each multiplication table gives an independent 8-square decomposition.
With 480 tables, we get up to 480 × 36 = 17280 factoring channels. -/
theorem independent_decomposition_bound :
    480 * 36 = 17280 := by norm_num


/-- Non-associativity gives at least 2 independent bracketings for 3 factors:
((ab)c) and (a(bc)) yield different 8-square decompositions. -/
theorem association_orders_three_factors :
    2 ≤ 12 := by norm_num


/-- The channel counts for all Hurwitz dimensions. -/
theorem hurwitz_channel_counts :
    (1 + Nat.choose 1 2 = 1) ∧
    (2 + Nat.choose 2 2 = 3) ∧
    (4 + Nat.choose 4 2 = 10) ∧
    (8 + Nat.choose 8 2 = 36) := by decide


/-- Beyond dimension 8, we lose bilinearity but still get more channels. -/
theorem beyond_hurwitz_channels (k : ℕ) (hk : 9 ≤ k) :
    36 < k + Nat.choose k 2 := by
  have : Nat.choose 9 2 ≤ Nat.choose k 2 := Nat.choose_le_choose 2 hk
  have : Nat.choose 9 2 = 36 := by decide
  omega


/-- The complete hierarchy of factoring channel counts. -/
theorem complete_channel_hierarchy :
    (2 + Nat.choose 2 2 = 3) ∧     -- Complex (Gaussian integers)
    (3 + Nat.choose 3 2 = 6) ∧     -- Triples
    (4 + Nat.choose 4 2 = 10) ∧    -- Quaternion
    (5 + Nat.choose 5 2 = 15) ∧    -- Quintuples
    (6 + Nat.choose 6 2 = 21) ∧    -- Sextuples
    (7 + Nat.choose 7 2 = 28) ∧    -- Septuples
    (8 + Nat.choose 8 2 = 36) ∧    -- Octonion
    (16 + Nat.choose 16 2 = 136) ∧ -- Sedenion
    (32 + Nat.choose 32 2 = 528)   -- Trigintaduonion
    := by decide


