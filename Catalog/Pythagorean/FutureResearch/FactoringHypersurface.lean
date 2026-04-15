import Mathlib

/-!
# The Factoring Hypersurface

## Overview

We study the geometry of the set of k-tuples whose peel channels reveal
factors of N.

## Main Results

- `semiprime_factoring_channels`: p ∣ (pq - x) ↔ p ∣ x
- `factoring_set_is_AP`: The factoring set is an arithmetic progression
- `remaining_sum_after_peel`: Fixing one variable constrains the rest
- `gcd_divides_N`: GCD from peel channel divides N
- `more_channels_more_chances`: Higher k gives more channels
-/

set_option maxHeartbeats 800000

open Finset BigOperators Int

/-! ## §1. The Factoring Condition -/

/-- A value x reveals a factor of N via peel channel iff gcd(N-x, N) > 1. -/
def revealsFactorVia (x N : ℤ) : Prop := 1 < Int.gcd (N - x) N

/-! ## §2. The Factoring Hyperplane Structure -/

/-- The factoring set for a single prime factor: { x : p ∣ N - x }
    is an arithmetic progression with common difference p. -/
theorem factoring_set_is_AP (p : ℤ) (hp : 0 < p) (N : ℤ) :
    ∀ x : ℤ, p ∣ (N - x) ↔ ∃ k : ℤ, x = N - k * p := by
  intro x
  constructor
  · rintro ⟨k, hk⟩; exact ⟨k, by linarith⟩
  · rintro ⟨k, rfl⟩; exact ⟨k, by ring⟩

/-- For N = p * q, the factoring channels are x ≡ 0 (mod p) or x ≡ 0 (mod q)
    (after shifting by N). -/
theorem semiprime_factoring_channels (p q x : ℤ) :
    p ∣ (p * q - x) ↔ p ∣ x := by
  constructor
  · intro h
    have : p ∣ p * q := dvd_mul_right p q
    have : p ∣ p * q - (p * q - x) := dvd_sub this h
    simpa using this
  · intro h
    have : p ∣ p * q := dvd_mul_right p q
    exact dvd_sub this h

/-! ## §3. Density Bounds -/

/-
For N = p*q with p, q odd primes, at least one value reveals a factor.
-/
theorem exists_revealing_value (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) :
    ∃ x : ℤ, revealsFactorVia x (↑(p * q)) := by
  -- Let's choose x = p. Then N - x = p*q - p = p*(q-1).
  use p
  simp [revealsFactorVia];
  exact hp.one_lt

/-! ## §4. GCD Properties -/

/-- The GCD of N-x and N divides N. -/
theorem gcd_divides_N' (x N : ℤ) : ↑(Int.gcd (N - x) N) ∣ N :=
  Int.gcd_dvd_right _ _

/-
If p ∣ x and p ∣ N, then p ∣ gcd(N-x, N).
-/
theorem prime_divides_gcd (p : ℤ) (x N : ℤ)
    (hp_div_x : p ∣ x) (hp_div_N : p ∣ N) :
    p ∣ ↑(Int.gcd (N - x) N) := by
  exact Int.dvd_coe_gcd ( dvd_sub hp_div_N hp_div_x ) hp_div_N

/-- A single nontrivial GCD reveals a complete factorization. -/
theorem single_gcd_suffices (N p : ℕ) (hp : Nat.Prime p) (hpN : p ∣ N) :
    N / p * p = N :=
  Nat.div_mul_cancel hpN

/-! ## §5. The Sphere-Hyperplane Intersection -/

/-- On the sphere Σxᵢ² = d², fixing xⱼ constrains the remaining variables. -/
theorem remaining_sum_after_peel {k : ℕ} (legs : Fin k → ℤ) (d : ℤ) (j : Fin k)
    (h : (∑ i, (legs i)^2) = d^2) :
    (∑ i ∈ Finset.univ.erase j, (legs i)^2) = d^2 - (legs j)^2 := by
  have : (∑ i, (legs i)^2) = (legs j)^2 + ∑ i ∈ Finset.univ.erase j, (legs i)^2 := by
    rw [← Finset.add_sum_erase _ _ (Finset.mem_univ j)]
  linarith

/-! ## §6. Multi-dimensional Factoring Probability -/

/-- Higher k gives strictly more factoring channels. -/
theorem more_channels_more_chances (k₁ k₂ : ℕ) (hk : k₁ < k₂) :
    k₁ + Nat.choose k₁ 2 < k₂ + Nat.choose k₂ 2 := by
  have : Nat.choose k₁ 2 ≤ Nat.choose k₂ 2 :=
    Nat.choose_le_choose 2 (le_of_lt hk)
  omega