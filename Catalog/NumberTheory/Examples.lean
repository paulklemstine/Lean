/-
# Worked instances of the `q`-analogue of Kummer's theorem

This file tests the general theorems of `Catalog/NumberTheory/QKummer/Valuation.lean` and
`Catalog/NumberTheory/QKummer/TwoAdic.lean` against explicit numerical data.  The headline
instance is the one singled out as the falsifiable test of the conjecture:

`binom(6,3)_2 = 1395 = 3² · 5 · 31`, with `ord_5(2) = 4` and `ord_3(2) = 2`.

* `qBinom_two_six_three` : `binom(6,3)_2 = 1395` and its factorisation;
* `padicValNat_five_qBinom_two_six_three` : the `5`-adic valuation is `1`, *derived from the
  general theorem*, and matching the direct computation `v_5(1395) = 1`;
* `padicValNat_three_qBinom_two_six_three` : the `3`-adic valuation is `2`, again derived from
  the general theorem (here the classical Kummer term contributes `1` and the base-`d` carry
  contributes `e = 1`), matching `v_3(1395) = 2`;
* `qKummer_naive_two_adic_prediction_fails` : at `ℓ = 2` the naive prediction is off, while
* `padicValNat_two_qBinom_three_two_one` : the repaired `ℓ = 2` datum (period = order of `q`
  modulo `4`) gives the right answer.
-/
import Catalog.NumberTheory.QKummer.TwoAdic

namespace QKummer

/-- `binom(6,3)_2 = 1395 = 3² · 5 · 31`. -/
theorem qBinom_two_six_three : qBinom 2 6 3 = 1395 ∧ (1395 : ℕ) = 3 ^ 2 * 5 * 31 :=
  ⟨rfl, by norm_num⟩

theorem orderOf_two_zmod_five : orderOf ((2 : ℕ) : ZMod 5) = 4 := by
  haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  have h1 : ((2 : ℕ) : ZMod 5) ^ (2 ^ 1) ≠ 1 := by decide
  have h2 : ((2 : ℕ) : ZMod 5) ^ (2 ^ (1 + 1)) = 1 := by decide
  simpa using orderOf_eq_prime_pow h1 h2

theorem orderOf_two_zmod_three : orderOf ((2 : ℕ) : ZMod 3) = 2 := by
  haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  exact orderOf_eq_prime (by decide) (by decide)

/-- Direct computation: `v_5(1395) = 1`. -/
theorem padicValNat_five_1395 : padicValNat 5 1395 = 1 := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  have h : (1395 : ℕ) = 5 * 279 := by norm_num
  rw [h, padicValNat.mul (by norm_num) (by norm_num), padicValNat.self (by norm_num),
    padicValNat.eq_zero_of_not_dvd (by norm_num)]

/-- Direct computation: `v_3(1395) = 2`. -/
theorem padicValNat_three_1395 : padicValNat 3 1395 = 2 := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  have h : (1395 : ℕ) = 3 ^ 2 * 155 := by norm_num
  rw [h, padicValNat.mul (by norm_num) (by norm_num), padicValNat.prime_pow,
    padicValNat.eq_zero_of_not_dvd (by norm_num)]

/-- **The falsifiable instance, `ℓ = 5`.**  Here `d = ord_5(2) = 4`, `e = v_5([4]_2) = v_5(15) = 1`,
and adding `k = 3` and `n - k = 3` in base `4` carries, so the `q`-Kummer formula predicts
`v_5(binom(6,3)_2) = e · 1 = 1`.  The prediction is derived from the general theorem and agrees
with the direct computation `v_5(1395) = 1`. -/
theorem padicValNat_five_qBinom_two_six_three :
    padicValNat 5 (qBinom 2 6 3) = 1 ∧ padicValNat 5 (qBinom 2 6 3) = padicValNat 5 1395 := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  have key := qBinom_padicValNat_orderOf (q := 2) (ℓ := 5) (by decide) (le_refl 2) (by decide)
    (show (3 : ℕ) ≤ 6 by norm_num)
  rw [orderOf_two_zmod_five] at key
  have h15 : qNat 2 4 = 15 := rfl
  have hv15 : padicValNat 5 15 = 1 := by
    have h : (15 : ℕ) = 5 * 3 := by norm_num
    rw [h, padicValNat.mul (by norm_num) (by norm_num), padicValNat.self (by norm_num),
      padicValNat.eq_zero_of_not_dvd (by norm_num)]
  rw [h15, hv15] at key
  norm_num at key
  exact ⟨key, by rw [key, padicValNat_five_1395]⟩

/-- **The falsifiable instance, `ℓ = 3`.**  Here `d = ord_3(2) = 2` and `e = v_3([2]_2) = 1`;
the base-`2` addition `3 + 3` carries, `⌊6/2⌋ = 3`, `⌊3/2⌋ = 1`, and the classical Kummer term
`v_3(binom(3,1)) = 1` contributes as well, predicting `v_3(binom(6,3)_2) = 1 + 1 = 2`. -/
theorem padicValNat_three_qBinom_two_six_three :
    padicValNat 3 (qBinom 2 6 3) = 2 ∧ padicValNat 3 (qBinom 2 6 3) = padicValNat 3 1395 := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  have key := qBinom_padicValNat_orderOf (q := 2) (ℓ := 3) (by decide) (le_refl 2) (by decide)
    (show (3 : ℕ) ≤ 6 by norm_num)
  rw [orderOf_two_zmod_three] at key
  have h3 : qNat 2 2 = 3 := rfl
  have hv3 : padicValNat 3 3 = 1 := padicValNat.self (by norm_num)
  have hchoose : (3 : ℕ).choose 1 = 3 := by norm_num
  have hv2 : padicValNat 3 2 = 0 := padicValNat.eq_zero_of_not_dvd (by norm_num)
  rw [h3, hv3] at key
  norm_num [hchoose, hv3, hv2] at key
  exact ⟨key, by rw [key, padicValNat_three_1395]⟩

/-- **The naive `ℓ = 2` prediction is wrong.**  With `d = ord_2(3) = 1` and `e = v_2([1]_3) = 0`
the recipe would predict `v_2(binom(2,1)_3) = v_2(binom(2,1)) = 1`, but `binom(2,1)_3 = 4` has
`2`-adic valuation `2`. -/
theorem qKummer_naive_two_adic_prediction_fails :
    padicValNat 2 (qBinom 3 2 1) = 2 ∧ padicValNat 2 (Nat.choose 2 1) = 1 ∧
      padicValNat 2 (qBinom 3 2 1) ≠ padicValNat 2 (Nat.choose 2 1) := by
  have h4 : qBinom 3 2 1 = 2 ^ 2 := rfl
  have hval : padicValNat 2 (qBinom 3 2 1) = 2 := by rw [h4, padicValNat.prime_pow]
  have hchoose : padicValNat 2 (Nat.choose 2 1) = 1 := by
    have h : Nat.choose 2 1 = 2 := by norm_num
    rw [h, padicValNat.self (by norm_num)]
  exact ⟨hval, hchoose, by rw [hval, hchoose]; norm_num⟩

/-- **The repaired `ℓ = 2` formula is right.**  Using the order of `q = 3` modulo `4`, namely
`d = 2`, and `e = v_2([2]_3) = v_2(4) = 2`, the `q`-Kummer formula predicts
`v_2(binom(2,1)_3) = e · 1 = 2`, which is correct. -/
theorem padicValNat_two_qBinom_three_two_one :
    padicValNat 2 (qBinom 3 2 1) = 2 := by
  have key := qBinom_padicValNat (isQRegular_two_of_three_mod_four (q := 3) (by norm_num))
    (show (1 : ℕ) ≤ 2 by norm_num)
  have h4 : qNat 3 2 = 2 ^ 2 := rfl
  rw [h4, padicValNat.prime_pow] at key
  norm_num at key
  exact key

end QKummer