/-! # CatalogBuild.Physics.BertrandPostulate

Auto-generated from theorem catalog database.
Domain: Physics
Declarations: 12
-/

import Mathlib

/-- Bertrand's postulate: for every n ≥ 1, ∃ prime p with n < p ≤ 2n. -/
theorem bertrand_postulate (n : ℕ) (hn : 1 ≤ n) :
    ∃ p, Nat.Prime p ∧ n < p ∧ p ≤ 2 * n :=
  Nat.bertrand n (by omega)


/-- Infinitely many primes (Euclid's theorem). -/
theorem infinitely_many_primes : ∀ N : ℕ, ∃ p, N ≤ p ∧ Nat.Prime p :=
  Nat.exists_infinite_primes


/-- Primes are unbounded. -/
theorem primes_unbounded (N : ℕ) : ∃ p, N < p ∧ Nat.Prime p := by
  obtain ⟨p, hp1, hp2⟩ := Nat.exists_infinite_primes (N + 1)
  exact ⟨p, by omega, hp2⟩


/-- Prime gap: the gap after any prime p is at most p (from Bertrand). -/
theorem prime_gap_le (p : ℕ) (hp : Nat.Prime p) :
    ∃ q, Nat.Prime q ∧ p < q ∧ q ≤ 2 * p := by
  rcases eq_or_lt_of_le hp.two_le with rfl | h
  · exact ⟨3, by decide, by omega, by omega⟩
  · exact bertrand_postulate p (by omega)


/-- Relative prime gap: the next prime after p is within distance p. -/
theorem relative_prime_gap (p : ℕ) (hp : Nat.Prime p) :
    ∃ q, Nat.Prime q ∧ p < q ∧ q - p ≤ p := by
  obtain ⟨q, hq1, hq2, hq3⟩ := prime_gap_le p hp
  exact ⟨q, hq1, hq2, by omega⟩


/-- Legendre's conjecture verified for all n from 1 to 50:
there exists a prime between n² and (n+1)². -/
theorem legendre_verified_to_50 :
    ∀ n ∈ Finset.Icc 1 50,
      ∃ p ∈ Finset.Ioc (n ^ 2) ((n + 1) ^ 2), Nat.Prime p := by
  native_decide


/-- Legendre's conjecture verified for all n from 1 to 100. -/
theorem legendre_verified_to_100 :
    ∀ n ∈ Finset.Icc 1 100,
      ∃ p ∈ Finset.Ioc (n ^ 2) ((n + 1) ^ 2), Nat.Prime p := by
  native_decide


/-- Specific witnesses for Legendre's conjecture. -/
theorem legendre_witnesses :
    (Nat.Prime 2 ∧ 1 < 2 ∧ 2 ≤ 4) ∧      -- n = 1
    (Nat.Prime 5 ∧ 4 < 5 ∧ 5 ≤ 9) ∧      -- n = 2
    (Nat.Prime 11 ∧ 9 < 11 ∧ 11 ≤ 16) ∧   -- n = 3
    (Nat.Prime 17 ∧ 16 < 17 ∧ 17 ≤ 25) ∧  -- n = 4
    (Nat.Prime 29 ∧ 25 < 29 ∧ 29 ≤ 36) ∧  -- n = 5
    (Nat.Prime 101 ∧ 100 < 101 ∧ 101 ≤ 121) := by -- n = 10
  refine ⟨⟨?_, ?_, ?_⟩, ⟨?_, ?_, ?_⟩, ⟨?_, ?_, ?_⟩, ⟨?_, ?_, ?_⟩, ⟨?_, ?_, ?_⟩, ⟨?_, ?_, ?_⟩⟩
  all_goals first | decide | omega


/-- The prime counting function. -/
def primeCountBP (x : ℕ) : ℕ :=
  ((Finset.range (x + 1)).filter Nat.Prime).card


/-- π(2^k) ≥ k for k = 1..10 (consequence of iterated Bertrand). -/
theorem prime_count_pow2_ge_small :
    primeCountBP (2^1) ≥ 1 ∧
    primeCountBP (2^2) ≥ 2 ∧
    primeCountBP (2^3) ≥ 3 ∧
    primeCountBP (2^4) ≥ 4 ∧
    primeCountBP (2^5) ≥ 5 ∧
    primeCountBP (2^6) ≥ 6 ∧
    primeCountBP (2^7) ≥ 7 ∧
    primeCountBP (2^8) ≥ 8 ∧
    primeCountBP (2^9) ≥ 9 ∧
    primeCountBP (2^10) ≥ 10 := by
  unfold primeCountBP
  native_decide


/-- The number of primes up to n for several key values. -/
theorem prime_counting_values :
    primeCountBP 10 = 4 ∧
    primeCountBP 100 = 25 ∧
    primeCountBP 1000 = 168 := by
  unfold primeCountBP
  native_decide


/-- π(n)/n approximation: the prime density decreases.
π(10)/10 > π(100)/100 > π(1000)/1000, matching PNT prediction. -/
theorem prime_density_decreasing :
    -- π(10) * 100 > π(100) * 10 (i.e., 4/10 > 25/100 → 400 > 250)
    primeCountBP 10 * 100 > primeCountBP 100 * 10 ∧
    -- π(100) * 1000 > π(1000) * 100 (i.e., 25/100 > 168/1000 → 25000 > 16800)
    primeCountBP 100 * 1000 > primeCountBP 1000 * 100 := by
  unfold primeCountBP
  native_decide


