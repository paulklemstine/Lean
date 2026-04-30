import Mathlib

/-! # CatalogBuild.Physics.GoldbachVerification

Auto-generated from theorem catalog database.
Domain: Physics
Declarations: 13
-/

/-- Goldbach's conjecture verified for all even n with 4 ≤ n ≤ 100. -/
theorem goldbach_verified_to_100 :
    ∀ n ∈ (Finset.Icc 4 100).filter (fun n => Even n),
      ∃ p ∈ Finset.range (n + 1), ∃ q ∈ Finset.range (n + 1),
        Nat.Prime p ∧ Nat.Prime q ∧ n = p + q := by
  native_decide

/-- Goldbach's conjecture verified for all even n with 4 ≤ n ≤ 500. -/
theorem goldbach_verified_to_500 :
    ∀ n ∈ (Finset.Icc 4 500).filter (fun n => Even n),
      ∃ p ∈ Finset.range (n + 1), ∃ q ∈ Finset.range (n + 1),
        Nat.Prime p ∧ Nat.Prime q ∧ n = p + q := by
  native_decide

/-- Goldbach's conjecture verified for all even n with 4 ≤ n ≤ 1000. -/
theorem goldbach_verified_to_1000 :
    ∀ n ∈ (Finset.Icc 4 1000).filter (fun n => Even n),
      ∃ p ∈ Finset.range (n + 1), ∃ q ∈ Finset.range (n + 1),
        Nat.Prime p ∧ Nat.Prime q ∧ n = p + q := by
  native_decide

/-- Explicit Goldbach witnesses for notable numbers. -/
theorem goldbach_explicit_witnesses :
    (4 = 2 + 2 ∧ Nat.Prime 2) ∧
    (6 = 3 + 3 ∧ Nat.Prime 3) ∧
    (100 = 3 + 97 ∧ Nat.Prime 3 ∧ Nat.Prime 97) ∧
    (1000 = 3 + 997 ∧ Nat.Prime 3 ∧ Nat.Prime 997) := by
  refine ⟨⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_, ?_⟩, ⟨?_, ?_, ?_⟩⟩ <;> first | norm_num | decide

/-- Weak Goldbach: every odd n ≥ 7 is sum of three primes, verified to 100. -/
theorem weak_goldbach_verified_to_100 :
    ∀ n ∈ (Finset.Icc 7 100).filter (fun n => ¬ Even n),
      ∃ p ∈ Finset.range (n + 1), ∃ q ∈ Finset.range (n + 1),
        ∃ r ∈ Finset.range (n + 1),
          Nat.Prime p ∧ Nat.Prime q ∧ Nat.Prime r ∧ n = p + q + r := by
  native_decide

/-- Weak Goldbach verified to 500. -/
theorem weak_goldbach_verified_to_500 :
    ∀ n ∈ (Finset.Icc 7 500).filter (fun n => ¬ Even n),
      ∃ p ∈ Finset.range (n + 1), ∃ q ∈ Finset.range (n + 1),
        ∃ r ∈ Finset.range (n + 1),
          Nat.Prime p ∧ Nat.Prime q ∧ Nat.Prime r ∧ n = p + q + r := by
  native_decide

/-- Count of twin prime pairs (p, p+2) with both prime, p ≤ 98. -/
theorem twin_prime_count_100 :
    ((Finset.range 99).filter (fun p => Nat.Prime p ∧ Nat.Prime (p + 2))).card = 8 := by
  native_decide

/-- Count of twin prime pairs up to 1000. -/
theorem twin_prime_count_1000 :
    ((Finset.range 999).filter (fun p => Nat.Prime p ∧ Nat.Prime (p + 2))).card = 35 := by
  native_decide

/-- The 8 twin prime pairs up to 100. -/
theorem twin_primes_list :
    (Nat.Prime 3 ∧ Nat.Prime 5) ∧
    (Nat.Prime 5 ∧ Nat.Prime 7) ∧
    (Nat.Prime 11 ∧ Nat.Prime 13) ∧
    (Nat.Prime 17 ∧ Nat.Prime 19) ∧
    (Nat.Prime 29 ∧ Nat.Prime 31) ∧
    (Nat.Prime 41 ∧ Nat.Prime 43) ∧
    (Nat.Prime 59 ∧ Nat.Prime 61) ∧
    (Nat.Prime 71 ∧ Nat.Prime 73) := by
  refine ⟨⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩⟩ <;> decide

/-- Count of cousin prime pairs up to 100. -/
theorem cousin_prime_count_100 :
    ((Finset.range 97).filter (fun p => Nat.Prime p ∧ Nat.Prime (p + 4))).card = 8 := by
  native_decide

/-- Count of sexy prime pairs up to 100. -/
theorem sexy_prime_count_100 :
    ((Finset.range 95).filter (fun p => Nat.Prime p ∧ Nat.Prime (p + 6))).card = 15 := by
  native_decide

/-- Sophie Germain primes: p is a Sophie Germain prime if both p and 2p+1 are prime. -/
theorem sophie_germain_count_100 :
    ((Finset.range 100).filter (fun p => Nat.Prime p ∧ Nat.Prime (2 * p + 1))).card = 10 := by
  native_decide

/-- Some Sophie Germain primes. -/
theorem sophie_germain_examples :
    (Nat.Prime 2 ∧ Nat.Prime 5) ∧
    (Nat.Prime 3 ∧ Nat.Prime 7) ∧
    (Nat.Prime 5 ∧ Nat.Prime 11) ∧
    (Nat.Prime 11 ∧ Nat.Prime 23) ∧
    (Nat.Prime 23 ∧ Nat.Prime 47) ∧
    (Nat.Prime 29 ∧ Nat.Prime 59) ∧
    (Nat.Prime 41 ∧ Nat.Prime 83) ∧
    (Nat.Prime 53 ∧ Nat.Prime 107) ∧
    (Nat.Prime 83 ∧ Nat.Prime 167) ∧
    (Nat.Prime 89 ∧ Nat.Prime 179) := by
  refine ⟨⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩,
         ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩⟩ <;> native_decide

