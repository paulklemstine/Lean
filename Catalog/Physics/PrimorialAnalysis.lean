import Mathlib

/-! # CatalogBuild.Physics.PrimorialAnalysis

Auto-generated from theorem catalog database.
Domain: Physics
Declarations: 10
-/

/-- Primorial: product of all primes ≤ n. -/
def myPrimorial (n : ℕ) : ℕ :=
  ((Finset.Icc 1 n).filter Nat.Prime).prod id

/-- Primorial values for small inputs. -/
theorem primorial_values :
    myPrimorial 2 = 2 ∧
    myPrimorial 3 = 6 ∧
    myPrimorial 5 = 30 ∧
    myPrimorial 7 = 210 ∧
    myPrimorial 11 = 2310 ∧
    myPrimorial 13 = 30030 := by
  unfold myPrimorial; refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> native_decide

/-- 2# + 1 = 3 is prime. -/
theorem primorial_plus1_2 : Nat.Prime (myPrimorial 2 + 1) := by
  unfold myPrimorial; native_decide

/-- 3# + 1 = 7 is prime. -/
theorem primorial_plus1_3 : Nat.Prime (myPrimorial 3 + 1) := by
  unfold myPrimorial; native_decide

/-- 5# + 1 = 31 is prime. -/
theorem primorial_plus1_5 : Nat.Prime (myPrimorial 5 + 1) := by
  unfold myPrimorial; native_decide

/-- 7# + 1 = 211 is prime. -/
theorem primorial_plus1_7 : Nat.Prime (myPrimorial 7 + 1) := by
  unfold myPrimorial; native_decide

/-- 11# + 1 = 2311 is prime. -/
theorem primorial_plus1_11 : Nat.Prime (myPrimorial 11 + 1) := by
  unfold myPrimorial; native_decide

/-- 13# + 1 = 30031 is composite: 30031 = 59 × 509. -/
theorem primorial_plus1_13_composite :
    ¬Nat.Prime (myPrimorial 13 + 1) ∧ myPrimorial 13 + 1 = 59 * 509 := by
  unfold myPrimorial; constructor <;> native_decide

/-- The smallest prime factor of 30031 is 59, which is > 13. -/
theorem primorial_plus1_13_smallest_factor :
    Nat.Prime 59 ∧ 59 ∣ (myPrimorial 13 + 1) ∧ 59 > 13 := by
  unfold myPrimorial
  refine ⟨?_, ?_, ?_⟩
  · decide
  · native_decide
  · omega

/-- No prime ≤ 13 divides 13# + 1 = 30031. -/
theorem primorial_13_coprime :
    ∀ p ∈ (Finset.Icc 2 13).filter Nat.Prime,
      ¬(p ∣ (myPrimorial 13 + 1)) := by
  unfold myPrimorial; native_decide

