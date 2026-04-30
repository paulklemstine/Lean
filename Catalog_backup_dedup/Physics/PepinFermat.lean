import Mathlib

/-! # CatalogBuild.Physics.PepinFermat

Auto-generated from theorem catalog database.
Domain: Physics
Declarations: 12
-/

/-- The n-th Fermat number F_n = 2^(2^n) + 1. -/
def FermatNum (n : ℕ) : ℕ := 2 ^ (2 ^ n) + 1

/-- Fermat number values. -/
theorem fermat_values :
    FermatNum 0 = 3 ∧
    FermatNum 1 = 5 ∧
    FermatNum 2 = 17 ∧
    FermatNum 3 = 257 ∧
    FermatNum 4 = 65537 := by
  unfold FermatNum; omega

/-- F₀ through F₄ are all prime. -/
theorem fermat_primes_0_to_4 :
    Nat.Prime (FermatNum 0) ∧
    Nat.Prime (FermatNum 1) ∧
    Nat.Prime (FermatNum 2) ∧
    Nat.Prime (FermatNum 3) ∧
    Nat.Prime (FermatNum 4) := by
  unfold FermatNum; refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> native_decide

/-- F₅ = 4294967297 = 641 × 6700417 is composite (Euler, 1732). -/
theorem fermat_5_composite :
    FermatNum 5 = 641 * 6700417 := by
  unfold FermatNum; norm_num

/-- 641 divides F₅, and 641 = 5 × 2^7 + 1, confirming the divisor form k·2^(n+2) + 1. -/
theorem fermat_5_divisor_form :
    641 ∣ FermatNum 5 ∧ 641 = 5 * 2 ^ 7 + 1 := by
  unfold FermatNum
  constructor
  · exact ⟨6700417, by norm_num⟩
  · norm_num

/-- Pépin's test: F_n is prime iff 3^((F_n - 1)/2) ≡ -1 (mod F_n).
We verify this computationally for F₁ = 5. -/
theorem pepin_test_F1 :
    3 ^ ((FermatNum 1 - 1) / 2) % FermatNum 1 = FermatNum 1 - 1 := by
  unfold FermatNum; native_decide

/-- Pépin's test for F₂ = 17. -/
theorem pepin_test_F2 :
    3 ^ ((FermatNum 2 - 1) / 2) % FermatNum 2 = FermatNum 2 - 1 := by
  unfold FermatNum; native_decide

/-- Pépin's test for F₃ = 257. -/
theorem pepin_test_F3 :
    3 ^ ((FermatNum 3 - 1) / 2) % FermatNum 3 = FermatNum 3 - 1 := by
  unfold FermatNum; native_decide

/-- Pépin's test for F₄ = 65537. -/
theorem pepin_test_F4 :
    3 ^ ((FermatNum 4 - 1) / 2) % FermatNum 4 = FermatNum 4 - 1 := by
  unfold FermatNum; native_decide

/-- Fermat numbers > 1 for all n. -/
theorem fermat_num_gt_one (n : ℕ) : 1 < FermatNum n := by
  unfold FermatNum
  have : 1 ≤ 2 ^ (2 ^ n) := Nat.one_le_pow _ _ (by omega)
  omega

/-- Consecutive Fermat numbers are coprime (verified for small cases). -/
theorem fermat_coprime_small :
    Nat.Coprime (FermatNum 0) (FermatNum 1) ∧
    Nat.Coprime (FermatNum 1) (FermatNum 2) ∧
    Nat.Coprime (FermatNum 2) (FermatNum 3) ∧
    Nat.Coprime (FermatNum 3) (FermatNum 4) := by
  unfold FermatNum; refine ⟨?_, ?_, ?_, ?_⟩ <;> native_decide

/-- All pairs of distinct Fermat numbers among F₀,...,F₄ are coprime. -/
theorem fermat_pairwise_coprime_small :
    ∀ i ∈ Finset.range 5, ∀ j ∈ Finset.range 5,
      i ≠ j → Nat.Coprime (FermatNum i) (FermatNum j) := by
  unfold FermatNum; native_decide

