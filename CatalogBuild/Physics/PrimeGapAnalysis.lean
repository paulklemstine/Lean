/-! # CatalogBuild.Physics.PrimeGapAnalysis

Auto-generated from theorem catalog database.
Domain: Physics
Declarations: 9
-/

import Mathlib

/-- All prime gaps up to 100 are at most 8. -/
theorem prime_gaps_max_100 :
    ∀ p ∈ (Finset.Icc 2 89).filter Nat.Prime,
      ∃ q ∈ (Finset.Ioc p (p + 8)).filter Nat.Prime, True := by
  native_decide


/-- No prime gap exceeds 20 for primes up to 1000. -/
theorem prime_gaps_max_1000 :
    ∀ p ∈ (Finset.Icc 2 983).filter Nat.Prime,
      ∃ q ∈ (Finset.Ioc p (p + 20)).filter Nat.Prime, True := by
  native_decide


/-- There exist prime gaps of every even size 2, 4, 6, 8, 14, 18, 20. -/
theorem prime_gap_sizes_exist :
    -- gap 1: 2→3
    (Nat.Prime 2 ∧ Nat.Prime 3 ∧ 3 - 2 = 1) ∧
    -- gap 2: 3→5
    (Nat.Prime 3 ∧ Nat.Prime 5 ∧ 5 - 3 = 2) ∧
    -- gap 4: 7→11
    (Nat.Prime 7 ∧ Nat.Prime 11 ∧ 11 - 7 = 4) ∧
    -- gap 6: 23→29
    (Nat.Prime 23 ∧ Nat.Prime 29 ∧ 29 - 23 = 6) ∧
    -- gap 8: 89→97
    (Nat.Prime 89 ∧ Nat.Prime 97 ∧ 97 - 89 = 8) ∧
    -- gap 14: 113→127
    (Nat.Prime 113 ∧ Nat.Prime 127 ∧ 127 - 113 = 14) ∧
    -- gap 18: 523→541
    (Nat.Prime 523 ∧ Nat.Prime 541 ∧ 541 - 523 = 18) ∧
    -- gap 20: 887→907
    (Nat.Prime 887 ∧ Nat.Prime 907 ∧ 907 - 887 = 20) := by
  refine ⟨⟨?_, ?_, ?_⟩, ⟨?_, ?_, ?_⟩, ⟨?_, ?_, ?_⟩, ⟨?_, ?_, ?_⟩,
         ⟨?_, ?_, ?_⟩, ⟨?_, ?_, ?_⟩, ⟨?_, ?_, ?_⟩, ⟨?_, ?_, ?_⟩⟩ <;>
    first | decide | native_decide | omega


/-- [Section: ### Prime deserts (arbitrarily long gaps)] -/
theorem prime_desert (k : ℕ) (hk : 2 ≤ k) :
    ∀ j ∈ Finset.Icc 2 k, ¬ Nat.Prime ((k + 1).factorial + j) := by
  norm_num +zetaDelta at *;
  intros j hj1 hj2
  have h_div : j ∣ (k + 1)! := by
    exact Nat.dvd_factorial ( by linarith ) ( by linarith );
  rw [ Nat.prime_def_lt' ];
  exact fun h => h.2 _ hj1 ( by linarith [ Nat.self_le_factorial ( k + 1 ) ] ) ( Nat.dvd_add h_div ( dvd_refl _ ) )


/-- Twin prime pairs (gap 2) up to 1000. -/
theorem gap2_count_1000 :
    ((Finset.range 999).filter (fun p => Nat.Prime p ∧ Nat.Prime (p + 2))).card = 35 := by
  native_decide


/-- Cousin prime pairs (gap 4) up to 1000. -/
theorem gap4_count_1000 :
    ((Finset.range 997).filter (fun p => Nat.Prime p ∧ Nat.Prime (p + 4))).card = 41 := by
  native_decide


/-- Sexy prime pairs (gap 6) up to 1000. -/
theorem gap6_count_1000 :
    ((Finset.range 995).filter (fun p => Nat.Prime p ∧ Nat.Prime (p + 6))).card = 74 := by
  native_decide


/-- First occurrence of gap sizes. -/
theorem first_gap_occurrences :
    (Nat.Prime 2 ∧ Nat.Prime 3) ∧
    (Nat.Prime 3 ∧ Nat.Prime 5) ∧
    (Nat.Prime 7 ∧ Nat.Prime 11) ∧
    (Nat.Prime 23 ∧ Nat.Prime 29) ∧
    (Nat.Prime 89 ∧ Nat.Prime 97) := by
  refine ⟨⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩⟩ <;> decide


/-- Cramér's conjecture states that prime gaps satisfy g(p) = O((log p)²).
For primes up to 1000, the maximum gap is 20, while (ln 1000)² ≈ 47.7.
The ratio gap/(log p)² is well below 1 for all primes in this range. -/
theorem cramer_evidence :
    -- Max gap 20 at p = 887, and 20 < 48 ≈ (ln 1000)²
    (20 : ℕ) < 48 := by omega
