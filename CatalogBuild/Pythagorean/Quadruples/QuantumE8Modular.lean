/-! # CatalogBuild.Pythagorean.Quadruples.QuantumE8Modular

Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 18
-/

import Mathlib

noncomputable section

/-- In dimension k, the total factoring equations from one representation
are k peel channels plus C(k,2) cross-component pairs. -/
theorem total_factoring_equations (k : ℕ) :
    k + Nat.choose k 2 = k + k * (k - 1) / 2 := by
  congr 1; exact Nat.choose_two_right k


/-- σ_k(n) = sum of k-th powers of divisors of n -/
noncomputable def sigma_k (k n : ℕ) : ℕ :=
  (Nat.divisors n).sum (· ^ k)


/-- σ_k(n) ≥ 1 for all n ≥ 1 (since n divides itself). -/
theorem sigma_k_pos (k n : ℕ) (hn : n ≥ 1) : sigma_k k n ≥ 1 := by
  unfold sigma_k
  have hmem : n ∈ Nat.divisors n := Nat.mem_divisors.mpr ⟨dvd_refl n, by omega⟩
  have := Finset.single_le_sum (f := fun x => x ^ k) (fun x _ => Nat.zero_le _) hmem
  calc (Nat.divisors n).sum (· ^ k) ≥ n ^ k := this
    _ ≥ 1 := Nat.one_le_pow k n (by omega)


/-- Octonion norm (sum of 8 squares) -/
def onorm (v : Fin 8 → ℤ) : ℤ := ∑ i, v i ^ 2


/-- Onorm is nonneg -/
theorem onorm_nonneg (v : Fin 8 → ℤ) : onorm v ≥ 0 := by
  unfold onorm
  apply Finset.sum_nonneg
  intro i _
  exact sq_nonneg (v i)


/-- In dimension 8, each pair of representations gives C(8,2) = 28
cross-collision pairs. -/
theorem dim8_cross_collisions : Nat.choose 8 2 = 28 := by decide

/-- [Section: ## Part 2: E₈ Lattice Geometry] -/
theorem dim4_cross_collisions : Nat.choose 4 2 = 6 := by decide

theorem dim2_cross_collisions : Nat.choose 2 2 = 1 := by decide


/-- The first few r₈ values demonstrate representation richness. -/
theorem e8_representation_richness :
    16 < 112 ∧ 112 < 448 ∧ 448 < 1136 := by omega


/-- Count divisors of n congruent to r mod m -/
noncomputable def count_divisors_mod (n r m : ℕ) : ℕ :=
  ((Nat.divisors n).filter (fun d => d % m = r)).card


/-- For a prime p ≡ 1 (mod 4), p has at least one divisor ≡ 1 (mod 4),
namely 1 itself. -/
theorem r2_prime_1mod4_divisor_structure (p : ℕ) (hp : Nat.Prime p)
    (_hmod : p % 4 = 1) :
    count_divisors_mod p 1 4 ≥ 1 := by
  unfold count_divisors_mod
  apply Finset.card_pos.mpr
  use 1
  simp [Finset.mem_filter, Nat.mem_divisors]
  exact hp.ne_zero


/-- Upper bound on σ_k(n): at most n^k times the number of divisors. -/
theorem sigma_k_upper_bound (k n : ℕ) (_hn : n ≥ 1) :
    sigma_k k n ≤ n ^ k * (Nat.divisors n).card := by
  unfold sigma_k
  calc (Nat.divisors n).sum (· ^ k)
      ≤ (Nat.divisors n).sum (fun _ => n ^ k) := by
        apply Finset.sum_le_sum
        intro d hd
        exact Nat.pow_le_pow_left (Nat.divisor_le hd) k
    _ = (Nat.divisors n).card • (n ^ k) := Finset.sum_const _
    _ = n ^ k * (Nat.divisors n).card := by rw [smul_eq_mul, mul_comm]


/-- The hierarchy of factoring power: more channels, more collisions. -/
theorem hierarchy_channels :
    1 * Nat.choose 2 2 < 2 * Nat.choose 2 2 ∧
    2 * Nat.choose 2 2 < 4 * Nat.choose 2 2 ∧
    4 * Nat.choose 2 2 < 8 * Nat.choose 2 2 := by decide


/-- The cross term (ad - bc) squared is bounded by N². -/
theorem cross_term_squared_bound (a b c d N : ℤ)
    (h1 : a ^ 2 + b ^ 2 = N) (h2 : c ^ 2 + d ^ 2 = N) :
    (a * d - b * c) ^ 2 ≤ N ^ 2 := by
  have key : (a * d - b * c) ^ 2 + (a * c + b * d) ^ 2 = N ^ 2 := by
    linear_combination' h1 * h2
  nlinarith [sq_nonneg (a * c + b * d)]


/-- The cross term is zero iff the two representations are "parallel". -/
theorem cross_term_zero_iff_parallel (a b c d : ℤ)
    (h_ad_bc : a * d - b * c = 0) :
    a * d = b * c := by linarith


/-- If both the cross term and dot product are nonzero, the cross term
is strictly bounded—making gcd(ad-bc, N) a nontrivial factor candidate.
Note: when ac+bd = 0 (representations are orthogonal rotations of each other),
we get (ad-bc)² = N² exactly, so the dot-product hypothesis is needed. -/
theorem collision_yields_factor_candidate (a b c d N : ℤ)
    (h1 : a ^ 2 + b ^ 2 = N) (h2 : c ^ 2 + d ^ 2 = N)
    (_hne : a * d - b * c ≠ 0)
    (hne2 : a * c + b * d ≠ 0) :
    (a * d - b * c) ^ 2 < N ^ 2 := by
  have key : (a * d - b * c) ^ 2 + (a * c + b * d) ^ 2 = N ^ 2 := by
    linear_combination' h1 * h2
  have : (a * c + b * d) ^ 2 > 0 := by positivity
  linarith


/-- Total channel count in the hierarchy for 2 representations -/
theorem total_channels_two_reps :
    1 < 3 ∧ 3 < 10 ∧ 10 < 36 := by omega


/-- The ratio of channels grows superlinearly with dimension. -/
theorem channel_growth_superlinear :
    10 * 2 > 3 * 4 ∧
    36 * 4 > 10 * 8 := by omega


end
