/-! # CatalogBuild.Physics.ArithmeticProgressions

Auto-generated from theorem catalog database.
Domain: Physics
Declarations: 13
-/

import Mathlib

/-- Primes ≡ 1 (mod 3) up to 1000. -/
theorem primes_mod3_1_count :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 3 = 1)).card = 80 := by
  native_decide



/-- Primes ≡ 2 (mod 3) up to 1000. -/
theorem primes_mod3_2_count :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 3 = 2)).card = 87 := by
  native_decide



/-- Chebyshev bias mod 3: more primes ≡ 2 (mod 3) than ≡ 1 (mod 3). -/
theorem chebyshev_bias_mod3 :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 3 = 2)).card >
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 3 = 1)).card := by
  native_decide



/-- Primes ending in 1 up to 1000. -/
theorem primes_ending_1 :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 10 = 1)).card = 40 := by
  native_decide



/-- Primes ending in 3 up to 1000. -/
theorem primes_ending_3 :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 10 = 3)).card = 42 := by
  native_decide



/-- Primes ending in 7 up to 1000. -/
theorem primes_ending_7 :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 10 = 7)).card = 46 := by
  native_decide



/-- Primes ending in 9 up to 1000. -/
theorem primes_ending_9 :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 10 = 9)).card = 38 := by
  native_decide



/-- A 3-term AP of primes: 3, 5, 7. -/
theorem green_tao_3 : Nat.Prime 3 ∧ Nat.Prime 5 ∧ Nat.Prime 7 ∧
    5 - 3 = 7 - 5 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> decide



/-- A 5-term AP of primes: 5, 11, 17, 23, 29 (common difference 6). -/
theorem green_tao_5 :
    Nat.Prime 5 ∧ Nat.Prime 11 ∧ Nat.Prime 17 ∧ Nat.Prime 23 ∧ Nat.Prime 29 ∧
    11 - 5 = 6 ∧ 17 - 11 = 6 ∧ 23 - 17 = 6 ∧ 29 - 23 = 6 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> first | decide | omega



/-- A 6-term AP of primes: 7, 37, 67, 97, 127, 157 (common difference 30). -/
theorem green_tao_6 :
    Nat.Prime 7 ∧ Nat.Prime 37 ∧ Nat.Prime 67 ∧
    Nat.Prime 97 ∧ Nat.Prime 127 ∧ Nat.Prime 157 ∧
    37 - 7 = 30 ∧ 67 - 37 = 30 ∧ 97 - 67 = 30 ∧
    127 - 97 = 30 ∧ 157 - 127 = 30 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> first | decide | omega



/-- A 7-term AP of primes: 7, 157, 307, 457, 607, 757, 907 (common difference 150). -/
theorem green_tao_7 :
    Nat.Prime 7 ∧ Nat.Prime 157 ∧ Nat.Prime 307 ∧ Nat.Prime 457 ∧
    Nat.Prime 607 ∧ Nat.Prime 757 ∧ Nat.Prime 907 ∧
    157 - 7 = 150 ∧ 307 - 157 = 150 ∧ 457 - 307 = 150 ∧
    607 - 457 = 150 ∧ 757 - 607 = 150 ∧ 907 - 757 = 150 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    first | decide | native_decide | omega



/-- Evidence for Dirichlet: every valid residue class mod 12 contains large primes. -/
theorem dirichlet_mod12_evidence :
    (∃ p, Nat.Prime p ∧ p % 12 = 1 ∧ p > 100) ∧
    (∃ p, Nat.Prime p ∧ p % 12 = 5 ∧ p > 100) ∧
    (∃ p, Nat.Prime p ∧ p % 12 = 7 ∧ p > 100) ∧
    (∃ p, Nat.Prime p ∧ p % 12 = 11 ∧ p > 100) := by
  exact ⟨⟨109, by decide, by native_decide, by omega⟩,
         ⟨101, by decide, by native_decide, by omega⟩,
         ⟨103, by decide, by native_decide, by omega⟩,
         ⟨107, by decide, by native_decide, by omega⟩⟩



/-- Linnik's theorem: the smallest prime in each residue class mod q is O(q^L).
We verify that all classes mod 7 contain primes ≤ 49 = 7². -/
theorem linnik_evidence_mod_7 :
    (∃ p, Nat.Prime p ∧ p % 7 = 1 ∧ p ≤ 49) ∧
    (∃ p, Nat.Prime p ∧ p % 7 = 2 ∧ p ≤ 49) ∧
    (∃ p, Nat.Prime p ∧ p % 7 = 3 ∧ p ≤ 49) ∧
    (∃ p, Nat.Prime p ∧ p % 7 = 4 ∧ p ≤ 49) ∧
    (∃ p, Nat.Prime p ∧ p % 7 = 5 ∧ p ≤ 49) ∧
    (∃ p, Nat.Prime p ∧ p % 7 = 6 ∧ p ≤ 49) := by
  exact ⟨⟨29, by decide, by native_decide, by omega⟩,
         ⟨2, by decide, by native_decide, by omega⟩,
         ⟨3, by decide, by native_decide, by omega⟩,
         ⟨11, by decide, by native_decide, by omega⟩,
         ⟨5, by decide, by native_decide, by omega⟩,
         ⟨13, by decide, by native_decide, by omega⟩⟩


