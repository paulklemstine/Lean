/-! # CatalogBuild.Speculative.SigmaPrimePower

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 11
-/

import Mathlib

/-- The divisors of p^n are exactly {1, p, p², ..., pⁿ}. Therefore
σ₁(pⁿ) = ∑ i in range (n+1), p^i. -/
theorem sigma1_prime_power (p n : ℕ) (hp : Nat.Prime p) :
    sigma1' (p ^ n) = ∑ i ∈ Finset.range (n + 1), p ^ i := by
  unfold sigma1'
  rw [Nat.divisors_prime_pow hp]
  simp [Finset.sum_map, Function.Embedding.coeFn_mk]



/-- Corollary: σ₁(p²) = p² + p + 1. -/
theorem sigma1_prime_sq' (p : ℕ) (hp : Nat.Prime p) :
    sigma1' (p ^ 2) = p ^ 2 + p + 1 := by
  rw [sigma1_prime_power p 2 hp]
  simp [Finset.sum_range_succ]; ring



/-- Corollary: σ₁(p³) = p³ + p² + p + 1. -/
theorem sigma1_prime_cube (p : ℕ) (hp : Nat.Prime p) :
    sigma1' (p ^ 3) = p ^ 3 + p ^ 2 + p + 1 := by
  rw [sigma1_prime_power p 3 hp]
  simp [Finset.sum_range_succ]; ring



/-- For odd primes, r₄(p) = 8·σ₁(p) = 8(p+1).
This is a consequence of Jacobi's four-square theorem. -/
theorem r4_prime_value (p : ℕ) (hp : Nat.Prime p) :
    8 * sigma1' p = 8 * (p + 1) := by
  rw [sigma1_prime' p hp]



/-- For prime powers, r₄(pⁿ) = 8·σ₁(pⁿ) = 8·∑ pⁱ. -/
theorem r4_prime_power_value (p n : ℕ) (hp : Nat.Prime p) :
    8 * sigma1' (p ^ n) = 8 * ∑ i ∈ Finset.range (n + 1), p ^ i := by
  rw [sigma1_prime_power p n hp]



/-- For any branching factor b ≥ 2, the total number of nodes in a
complete b-ary tree of depth d satisfies:
(b-1) · ∑_{i=0}^d b^i = b^{d+1} - 1. -/
theorem berggren_geometric_general (b d : ℕ) (hb : 2 ≤ b) :
    (b - 1) * ∑ i ∈ Finset.range (d + 1), b ^ i = b ^ (d + 1) - 1 := by
  have h := Nat.geomSum_eq hb (d + 1)
  rw [h]
  have hd : (b - 1) ∣ (b ^ (d + 1) - 1) := by
    have := Nat.sub_dvd_pow_sub_pow b 1 (d + 1)
    simp at this; exact this
  rw [mul_comm]
  exact Nat.div_mul_cancel hd



/-- Specialization: branching factor 3 (Berggren tree). -/
theorem berggren_tree_formula (d : ℕ) :
    2 * ∑ i ∈ Finset.range (d + 1), 3 ^ i = 3 ^ (d + 1) - 1 := by
  have := berggren_geometric_general 3 d (by omega)
  linarith



/-- Specialization: branching factor 2 (binary tree, Barning tree). -/
theorem binary_tree_formula (d : ℕ) :
    ∑ i ∈ Finset.range (d + 1), 2 ^ i = 2 ^ (d + 1) - 1 := by
  have := berggren_geometric_general 2 d (by omega)
  simpa using this



/-- σ₁ is multiplicative for coprime arguments. -/
theorem sigma1'_mult (m n : ℕ) (hcop : Nat.Coprime m n) :
    sigma1' (m * n) = sigma1' m * sigma1' n := by
  unfold sigma1'
  exact Coprime.sum_divisors_mul hcop



/-- For a semiprime N = p·q with p, q distinct primes,
σ₁(N) = (p+1)(q+1). -/
theorem sigma1_semiprime (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) :
    sigma1' (p * q) = (p + 1) * (q + 1) := by
  have hcop : Nat.Coprime p q :=
    hp.coprime_iff_not_dvd.mpr fun h =>
      hpq (hq.eq_one_or_self_of_dvd p h |>.resolve_left hp.one_lt.ne')
  rw [sigma1'_mult p q hcop, sigma1_prime' p hp, sigma1_prime' q hq]



/-- For N = p^a · q^b with p, q coprime primes,
σ₁(N) = σ₁(p^a) · σ₁(q^b). -/
theorem sigma1_two_prime_powers (p q a b : ℕ)
    (hp : Nat.Prime p) (hq : Nat.Prime q) (hpq : p ≠ q) :
    sigma1' (p ^ a * q ^ b) = sigma1' (p ^ a) * sigma1' (q ^ b) := by
  apply sigma1'_mult
  exact (hp.coprime_iff_not_dvd.mpr fun h =>
    hpq (hq.eq_one_or_self_of_dvd p h |>.resolve_left hp.one_lt.ne')).pow a b


