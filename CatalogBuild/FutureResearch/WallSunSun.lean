/-! # CatalogBuild.FutureResearch.WallSunSun

Auto-generated from theorem catalog database.
Domain: FutureResearch
Declarations: 13
-/

import Mathlib

/-- [Section: ### Wieferich Primes] -/
def IsWieferichPrime (p : ℕ) : Prop :=
  Nat.Prime p ∧ 2 ^ (p - 1) % (p ^ 2) = 1


theorem wieferich_1093 : IsWieferichPrime 1093 := ⟨by native_decide, by native_decide⟩

theorem wieferich_3511 : IsWieferichPrime 3511 := ⟨by native_decide, by native_decide⟩


/-- [Section: ### Fibonacci Properties] -/
theorem fib_dvd_fib_mul' (m n : ℕ) : Nat.fib m ∣ Nat.fib (m * n) :=
  Nat.fib_dvd _ _ (dvd_mul_right m n)


theorem fib_gcd_eq (m n : ℕ) :
    Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n) :=
  (Nat.fib_gcd m n).symm


/-- [Section: ### Wall-Sun-Sun Conjecture] -/
def WallSunSunConjecture : Prop :=
  ∀ p, Nat.Prime p → 7 ≤ p →
    ¬(p ^ 2 ∣ Nat.fib (p - 1) * Nat.fib (p + 1))


theorem wss_check_7 : ¬(7 ^ 2 ∣ Nat.fib 6 * Nat.fib 8) := by native_decide

theorem wss_check_11 : ¬(11 ^ 2 ∣ Nat.fib 10 * Nat.fib 12) := by native_decide

theorem wss_check_13 : ¬(13 ^ 2 ∣ Nat.fib 12 * Nat.fib 14) := by native_decide

theorem wss_check_17 : ¬(17 ^ 2 ∣ Nat.fib 16 * Nat.fib 18) := by native_decide

theorem wss_check_19 : ¬(19 ^ 2 ∣ Nat.fib 18 * Nat.fib 20) := by native_decide

theorem wss_check_23 : ¬(23 ^ 2 ∣ Nat.fib 22 * Nat.fib 24) := by native_decide

theorem wss_check_29 : ¬(29 ^ 2 ∣ Nat.fib 28 * Nat.fib 30) := by native_decide

