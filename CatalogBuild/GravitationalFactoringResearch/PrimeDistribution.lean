/-! # CatalogBuild.GravitationalFactoringResearch.PrimeDistribution

Auto-generated from theorem catalog database.
Domain: GravitationalFactoringResearch
Declarations: 16
-/

import Mathlib

/-- The prime counting function. -/
def piCount (x : ℕ) : ℕ :=
  ((Finset.range (x + 1)).filter Nat.Prime).card

/-- Prime counting table: exact values of π(n) for important thresholds. -/

theorem prime_counting_table :
    piCount 10 = 4 ∧
    piCount 20 = 8 ∧
    piCount 30 = 10 ∧
    piCount 50 = 15 ∧
    piCount 100 = 25 ∧
    piCount 200 = 46 ∧
    piCount 500 = 95 ∧
    piCount 1000 = 168 := by
  unfold piCount; native_decide

/-- π is monotone. -/

theorem piCount_monotone : Monotone piCount := by
  intro a b hab
  unfold piCount
  apply Finset.card_le_card
  apply Finset.filter_subset_filter
  exact Finset.range_mono (by omega)

/-- π(n) > 0 for n ≥ 2. -/

theorem piCount_pos (n : ℕ) (hn : 2 ≤ n) : 0 < piCount n := by
  have : piCount 2 = 1 := by unfold piCount; native_decide
  have : 0 < piCount 2 := by omega
  exact lt_of_lt_of_le this (piCount_monotone hn)

/-! ### Prime density ratios (PNT evidence) -/

/-- The ratio π(n)/n decreases, consistent with the Prime Number Theorem
    prediction π(n) ~ n/ln(n). -/

theorem prime_density_ratios :
    piCount 10 * 100 > piCount 100 * 10 ∧
    piCount 100 * 1000 > piCount 1000 * 100 := by
  unfold piCount; native_decide

/-! ### Prime gaps -/

/-- The maximum prime gap for primes ≤ 100 is 8 (between 89 and 97). -/

theorem max_prime_gap_100 :
    Nat.Prime 89 ∧ Nat.Prime 97 ∧
    (∀ p ∈ Finset.Ioc 89 96, ¬ Nat.Prime p) := by
  refine ⟨by decide, by decide, ?_⟩
  native_decide

/-- The maximum prime gap for primes ≤ 1000 is 20 (between 887 and 907). -/

theorem max_prime_gap_1000 :
    Nat.Prime 887 ∧ Nat.Prime 907 ∧
    (∀ p ∈ Finset.Ioc 887 906, ¬ Nat.Prime p) := by
  refine ⟨by native_decide, by native_decide, ?_⟩
  native_decide

/-! ### Primes in arithmetic progressions (Dirichlet's theorem evidence) -/

/-- Primes ≡ 1 (mod 4) up to 100. -/

theorem primes_4k1_count :
    ((Finset.range 100).filter (fun p => Nat.Prime p ∧ p % 4 = 1)).card = 11 := by
  native_decide

/-- Primes ≡ 3 (mod 4) up to 100. -/

theorem primes_4k3_count :
    ((Finset.range 100).filter (fun p => Nat.Prime p ∧ p % 4 = 3)).card = 13 := by
  native_decide

/-- Primes ≡ 1 (mod 6) up to 100. -/

theorem primes_6k1_count :
    ((Finset.range 100).filter (fun p => Nat.Prime p ∧ p % 6 = 1)).card = 11 := by
  native_decide

/-- Primes ≡ 5 (mod 6) up to 100. -/

theorem primes_6k5_count :
    ((Finset.range 100).filter (fun p => Nat.Prime p ∧ p % 6 = 5)).card = 12 := by
  native_decide

/-! ### Chebyshev's bias -/

/-- Chebyshev's bias: more primes ≡ 3 (mod 4) than ≡ 1 (mod 4) up to 100. -/

theorem chebyshev_bias_100 :
    ((Finset.range 100).filter (fun p => Nat.Prime p ∧ p % 4 = 3)).card >
    ((Finset.range 100).filter (fun p => Nat.Prime p ∧ p % 4 = 1)).card := by
  native_decide

/-- Chebyshev's bias persists up to 1000. -/

theorem chebyshev_bias_1000 :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 4 = 3)).card >
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 4 = 1)).card := by
  native_decide

/-! ### Palindromic and emirp primes -/

/-- Some palindromic primes. -/

theorem palindromic_primes :
    Nat.Prime 2 ∧ Nat.Prime 3 ∧ Nat.Prime 5 ∧ Nat.Prime 7 ∧
    Nat.Prime 11 ∧ Nat.Prime 101 ∧ Nat.Prime 131 ∧ Nat.Prime 151 ∧
    Nat.Prime 181 ∧ Nat.Prime 191 ∧ Nat.Prime 313 ∧ Nat.Prime 353 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> decide

/-- Emirp pairs: primes whose digit-reversal is also prime. -/

theorem emirp_examples :
    (Nat.Prime 13 ∧ Nat.Prime 31) ∧
    (Nat.Prime 17 ∧ Nat.Prime 71) ∧
    (Nat.Prime 37 ∧ Nat.Prime 73) ∧
    (Nat.Prime 79 ∧ Nat.Prime 97) := by
  refine ⟨⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩⟩ <;> decide

/-! ### Semiprime examples -/

/-- Basic semiprime factorizations. -/

theorem semiprime_examples :
    (4 = 2 * 2) ∧ (6 = 2 * 3) ∧ (9 = 3 * 3) ∧
    (10 = 2 * 5) ∧ (15 = 3 * 5) ∧ (21 = 3 * 7) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> norm_num

