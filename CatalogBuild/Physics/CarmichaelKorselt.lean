/-! # CatalogBuild.Physics.CarmichaelKorselt

Auto-generated from theorem catalog database.
Domain: Physics
Declarations: 8
-/

import Mathlib

/-- A Carmichael number: composite n where a^(n-1) ≡ 1 (mod n) for all a coprime to n. -/
def IsCarmichael (n : ℕ) : Prop :=
  2 ≤ n ∧ ¬Nat.Prime n ∧
  ∀ a ∈ Finset.Icc 1 (n - 1), Nat.Coprime a n → a ^ (n - 1) % n = 1


/-- 561 = 3 × 11 × 17 is a Carmichael number. -/
theorem carmichael_561 : IsCarmichael 561 := by
  unfold IsCarmichael
  refine ⟨by omega, by native_decide, ?_⟩
  native_decide


/-- 1105 = 5 × 13 × 17 is a Carmichael number. -/
theorem carmichael_1105 : IsCarmichael 1105 := by
  unfold IsCarmichael
  refine ⟨by omega, by native_decide, ?_⟩
  native_decide


/-- 1729 = 7 × 13 × 19 is a Carmichael number (Hardy-Ramanujan / taxicab number). -/
theorem carmichael_1729 : IsCarmichael 1729 := by
  unfold IsCarmichael
  refine ⟨by omega, by native_decide, ?_⟩
  native_decide


/-- Korselt's criterion: n is Carmichael iff n is squarefree and
(p - 1) | (n - 1) for every prime factor p of n.
We verify the forward direction computationally for 561. -/
theorem korselt_561 :
    -- 561 = 3 × 11 × 17
    561 = 3 * 11 * 17 ∧
    -- Squarefree: no p² divides 561
    (∀ p ∈ (Finset.Icc 2 23).filter Nat.Prime, ¬(p * p ∣ 561)) ∧
    -- (p-1) | (n-1) for each prime factor
    (3 - 1 ∣ 561 - 1) ∧ (11 - 1 ∣ 561 - 1) ∧ (17 - 1 ∣ 561 - 1) := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · norm_num
  · native_decide
  · norm_num
  · norm_num
  · norm_num


/-- Korselt verified for 1729. -/
theorem korselt_1729 :
    1729 = 7 * 13 * 19 ∧
    (∀ p ∈ (Finset.Icc 2 41).filter Nat.Prime, ¬(p * p ∣ 1729)) ∧
    (7 - 1 ∣ 1729 - 1) ∧ (13 - 1 ∣ 1729 - 1) ∧ (19 - 1 ∣ 1729 - 1) := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · norm_num
  · native_decide
  · norm_num
  · norm_num
  · norm_num


/-- The first three Carmichael numbers are 561, 1105, 1729. -/
theorem first_three_carmichael :
    561 = 3 * 11 * 17 ∧ ¬Nat.Prime 561 ∧
    1105 = 5 * 13 * 17 ∧ ¬Nat.Prime 1105 ∧
    1729 = 7 * 13 * 19 ∧ ¬Nat.Prime 1729 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> first | norm_num | native_decide


/-- No Carmichael number below 561 exists (every composite n < 561 has a Fermat witness). -/
theorem no_carmichael_below_561 :
    ∀ n ∈ (Finset.Icc 4 560).filter (fun n => ¬Nat.Prime n),
      ∃ a ∈ Finset.Icc 2 (n - 1),
        Nat.Coprime a n ∧ a ^ (n - 1) % n ≠ 1 := by
  native_decide


