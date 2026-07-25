import Mathlib

/-! # CatalogBuild.Physics.PrimeCountingBounds

Auto-generated from theorem catalog database.
Domain: Physics
Declarations: 16
-/

/-- The prime-counting function π(x) = |{p ≤ x : p is prime}|. -/
def primeCount (x : ℕ) : ℕ :=
  ((Finset.range (x + 1)).filter Nat.Prime).card

/-- π(2) = 1. -/
theorem prime_count_2 : primeCount 2 = 1 := by native_decide

/-- π(3) = 2. -/
theorem prime_count_3 : primeCount 3 = 2 := by native_decide

/-- π(5) = 3. -/
theorem prime_count_5 : primeCount 5 = 3 := by native_decide

/-- π(10) = 4. -/
theorem prime_count_10 : primeCount 10 = 4 := by native_decide

/-- π(20) = 8. -/
theorem prime_count_20 : primeCount 20 = 8 := by native_decide

/-- π(30) = 10. -/
theorem prime_count_30 : primeCount 30 = 10 := by native_decide

/-- π(100) = 25. -/
theorem prime_count_100 : primeCount 100 = 25 := by native_decide

/-- π(1000) = 168. -/
theorem prime_count_1000 : primeCount 1000 = 168 := by native_decide

/-- π is monotone: if a ≤ b then π(a) ≤ π(b). -/
theorem prime_count_monotone : Monotone primeCount := by
  intro a b hab
  unfold primeCount
  apply Finset.card_le_card
  apply Finset.filter_subset_filter
  exact Finset.range_mono (by omega)

/-- There is at least one prime ≤ x for x ≥ 2. -/
theorem prime_count_pos (x : ℕ) (hx : 2 ≤ x) : 0 < primeCount x := by
  have h2 : primeCount 2 = 1 := prime_count_2
  have h0 : 0 < primeCount 2 := by omega
  exact Nat.lt_of_lt_of_le h0 (prime_count_monotone hx)

/-- Bertrand's postulate for n = 1: there exists a prime between 1 and 2. -/
theorem bertrand_1 : ∃ p, Nat.Prime p ∧ 1 < p ∧ p ≤ 2 :=
  ⟨2, by decide, by omega, by omega⟩

/-- Bertrand's postulate for n = 2: there exists a prime between 2 and 4. -/
theorem bertrand_2 : ∃ p, Nat.Prime p ∧ 2 < p ∧ p ≤ 4 :=
  ⟨3, by decide, by omega, by omega⟩

/-- Bertrand's postulate for n = 3: there exists a prime between 3 and 6. -/
theorem bertrand_3 : ∃ p, Nat.Prime p ∧ 3 < p ∧ p ≤ 6 :=
  ⟨5, by decide, by omega, by omega⟩

/-- Bertrand's postulate for n = 10: there exists a prime between 10 and 20. -/
theorem bertrand_10 : ∃ p, Nat.Prime p ∧ 10 < p ∧ p ≤ 20 :=
  ⟨11, by decide, by omega, by omega⟩

/-- Bertrand's postulate for n = 50: there exists a prime between 50 and 100. -/
theorem bertrand_50 : ∃ p, Nat.Prime p ∧ 50 < p ∧ p ≤ 100 :=
  ⟨53, by decide, by omega, by omega⟩

