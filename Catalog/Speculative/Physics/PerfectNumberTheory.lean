import Mathlib

/-! # CatalogBuild.Physics.PerfectNumberTheory

Auto-generated from theorem catalog database.
Domain: Physics
Declarations: 11
-/

/-- The divisor sum function σ(n). -/
def divisorSum' (n : ℕ) : ℕ :=
  ((Finset.Icc 1 n).filter (fun d => d ∣ n)).sum id

/-- A number is perfect if σ(n) = 2n. -/
def IsPerfect' (n : ℕ) : Prop := divisorSum' n = 2 * n

/-- 6 is perfect: divisors are 1, 2, 3, 6 and 1+2+3+6 = 12 = 2×6. -/
theorem perfect_6' : IsPerfect' 6 := by
  unfold IsPerfect' divisorSum'; native_decide

/-- 28 is perfect: divisors are 1, 2, 4, 7, 14, 28 and sum = 56 = 2×28. -/
theorem perfect_28' : IsPerfect' 28 := by
  unfold IsPerfect' divisorSum'; native_decide

/-- 496 is perfect. -/
theorem perfect_496' : IsPerfect' 496 := by
  unfold IsPerfect' divisorSum'; native_decide

/-- 8128 is perfect. -/
theorem perfect_8128' : IsPerfect' 8128 := by
  unfold IsPerfect' divisorSum'; native_decide

/-- No other number below 100 is perfect besides 6 and 28. -/
theorem perfect_numbers_below_100' :
    ∀ n ∈ Finset.Icc 1 99,
      divisorSum' n = 2 * n ↔ n ∈ ({6, 28} : Finset ℕ) := by
  native_decide

/-- The abundancy index: σ(n)/n. For perfect numbers this equals 2. -/
theorem abundancy_perfect' :
    divisorSum' 6 = 2 * 6 ∧
    divisorSum' 28 = 2 * 28 ∧
    divisorSum' 496 = 2 * 496 ∧
    divisorSum' 8128 = 2 * 8128 := by
  unfold divisorSum'; native_decide

/-- Abundant numbers: σ(n) > 2n. First few: 12, 18, 20, 24, 30. -/
theorem abundant_numbers_small' :
    divisorSum' 12 > 2 * 12 ∧
    divisorSum' 18 > 2 * 18 ∧
    divisorSum' 20 > 2 * 20 ∧
    divisorSum' 24 > 2 * 24 ∧
    divisorSum' 30 > 2 * 30 := by
  unfold divisorSum'; native_decide

/-- Deficient primes: σ(p) = p + 1 < 2p for all primes p. Verified for primes ≤ 50. -/
theorem prime_deficient' :
    ∀ p ∈ (Finset.Icc 2 50).filter Nat.Prime,
      divisorSum' p = p + 1 := by
  native_decide

/-- Euclid's perfect number form: 2^(p-1) * (2^p - 1) for Mersenne primes.
Verified for p = 2, 3, 5, 7 (giving 6, 28, 496, 8128). -/
theorem euclid_perfect_numbers' :
    -- p=2: 2^1 * (2^2 - 1) = 2 * 3 = 6
    (2 ^ 1 * (2 ^ 2 - 1) = 6 ∧ IsPerfect' 6) ∧
    -- p=3: 2^2 * (2^3 - 1) = 4 * 7 = 28
    (2 ^ 2 * (2 ^ 3 - 1) = 28 ∧ IsPerfect' 28) ∧
    -- p=5: 2^4 * (2^5 - 1) = 16 * 31 = 496
    (2 ^ 4 * (2 ^ 5 - 1) = 496 ∧ IsPerfect' 496) ∧
    -- p=7: 2^6 * (2^7 - 1) = 64 * 127 = 8128
    (2 ^ 6 * (2 ^ 7 - 1) = 8128 ∧ IsPerfect' 8128) := by
  unfold IsPerfect' divisorSum'
  refine ⟨⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩⟩ <;> native_decide

