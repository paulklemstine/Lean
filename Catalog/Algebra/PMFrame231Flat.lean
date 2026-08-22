/-
# A flat ternary frame: `Φ₂₃₁`

The classification of `Algebra/PMFrameFlatClassification.lean` is *sufficient* but not *necessary*:
`231 = 3 · 7 · 11` has three odd prime divisors, yet `Φ₂₃₁` is flat.  We prove this by determining
`Φ₂₃₁` explicitly — again by cancellation in the Möbius identity — and reading off its coefficients.
Combined with height reduction this produces an infinite family of flat orders outside the
`ω_odd ≤ 2` class, namely all `n` whose odd radical is `231`.
-/
import Mathlib
import Shared.PMFrameTwoParameter
import Algebra.PMFrameFlatFamilies
import Algebra.PMFrameHeightReduction

namespace PMFrame231

open Polynomial Finset PMFrame PMFrameFlat PMFrameHeight

/-- The coefficient list of `Φ₂₃₁`, indices `0 … 120`. -/
def c231 : List ℤ :=
  [1, 1, 1, 0, 0, 0, 0, -1, -1, -1, 0, -1, -1, -1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, -1,
   -1, -1, 0, -1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -1, -1, 0, 0, -1, -1, 0, 1, 0, 0, 0, 1, 0,
   0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -1, -1, 0, 0, -1, -1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0,
   -1, 0, -1, -1, -1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, -1, -1, -1, 0, -1, -1, -1, 0, 0,
   0, 0, 1, 1, 1]

/-- The candidate polynomial in coefficient form. -/
noncomputable def P231 : ℤ[X] := ∑ i ∈ Finset.range 121, C (c231.getD i 0) * X ^ i

theorem length_c231 : c231.length = 121 := by decide

theorem coeff_P231 (k : ℕ) : P231.coeff k = c231.getD k 0 := by
  rw [P231, Polynomial.finset_sum_coeff]
  simp only [Polynomial.coeff_C_mul, Polynomial.coeff_X_pow, mul_ite, mul_one, mul_zero]
  rw [Finset.sum_ite_eq (Finset.range 121) k fun i => c231.getD i 0]
  split
  · rfl
  · rename_i hk
    rw [Finset.mem_range, Nat.not_lt] at hk
    exact (List.getD_eq_default c231 0 (by rw [length_c231]; exact hk)).symm

set_option maxHeartbeats 4000000 in
theorem P231_expand :
    P231 = 1 + X + X ^ 2 - X ^ 7 - X ^ 8 - X ^ 9 - X ^ 11 - X ^ 12 - X ^ 13 + X ^ 18 + X ^ 19 + X ^ 20
       + X ^ 21 + X ^ 22 + X ^ 23 - X ^ 28 - X ^ 29 - X ^ 30 - X ^ 32 + X ^ 35 + X ^ 39 + X ^ 43
       - X ^ 45 - X ^ 46 - X ^ 49 - X ^ 50 + X ^ 52 + X ^ 56 + X ^ 60 + X ^ 64 + X ^ 68 - X ^ 70
       - X ^ 71 - X ^ 74 - X ^ 75 + X ^ 77 + X ^ 81 + X ^ 85 - X ^ 88 - X ^ 90 - X ^ 91 - X ^ 92
       + X ^ 97 + X ^ 98 + X ^ 99 + X ^ 100 + X ^ 101 + X ^ 102 - X ^ 107 - X ^ 108 - X ^ 109
       - X ^ 111 - X ^ 112 - X ^ 113 + X ^ 118 + X ^ 119 + X ^ 120 := by
  rw [P231]
  simp only [c231, Finset.sum_range_succ, Finset.sum_range_zero, List.getD_cons_zero,
    List.getD_cons_succ, map_one, map_zero, map_neg, pow_zero, pow_one]
  ring

/-! ## The Möbius identity at `231 = 3 · 7 · 11` -/

theorem prod_cyclotomic_231 :
    cyclotomic 1 ℤ * cyclotomic 3 ℤ * cyclotomic 7 ℤ * cyclotomic 11 ℤ * cyclotomic 21 ℤ *
      cyclotomic 33 ℤ * cyclotomic 77 ℤ * cyclotomic 231 ℤ = X ^ 231 - 1 := by
  have h := prod_cyclotomic_eq_X_pow_sub_one (n := 231) (by norm_num) ℤ
  rw [show Nat.divisors 231 = ({1, 3, 7, 11, 21, 33, 77, 231} : Finset ℕ) from by decide,
    Finset.prod_insert (by decide), Finset.prod_insert (by decide),
    Finset.prod_insert (by decide), Finset.prod_insert (by decide),
    Finset.prod_insert (by decide), Finset.prod_insert (by decide),
    Finset.prod_insert (by decide), Finset.prod_singleton] at h
  linear_combination h

theorem prod_cyclotomic_77 :
    cyclotomic 1 ℤ * cyclotomic 7 ℤ * cyclotomic 11 ℤ * cyclotomic 77 ℤ = X ^ 77 - 1 := by
  have h := prod_cyclotomic_eq_X_pow_sub_one (n := 77) (by norm_num) ℤ
  rw [show Nat.divisors 77 = ({1, 7, 11, 77} : Finset ℕ) from by decide,
    Finset.prod_insert (by decide), Finset.prod_insert (by decide),
    Finset.prod_insert (by decide), Finset.prod_singleton] at h
  linear_combination h

theorem prod_cyclotomic_33 :
    cyclotomic 1 ℤ * cyclotomic 3 ℤ * cyclotomic 11 ℤ * cyclotomic 33 ℤ = X ^ 33 - 1 := by
  have h := prod_cyclotomic_eq_X_pow_sub_one (n := 33) (by norm_num) ℤ
  rw [show Nat.divisors 33 = ({1, 3, 11, 33} : Finset ℕ) from by decide,
    Finset.prod_insert (by decide), Finset.prod_insert (by decide),
    Finset.prod_insert (by decide), Finset.prod_singleton] at h
  linear_combination h

theorem prod_cyclotomic_21 :
    cyclotomic 1 ℤ * cyclotomic 3 ℤ * cyclotomic 7 ℤ * cyclotomic 21 ℤ = X ^ 21 - 1 := by
  have h := prod_cyclotomic_eq_X_pow_sub_one (n := 21) (by norm_num) ℤ
  rw [show Nat.divisors 21 = ({1, 3, 7, 21} : Finset ℕ) from by decide,
    Finset.prod_insert (by decide), Finset.prod_insert (by decide),
    Finset.prod_insert (by decide), Finset.prod_singleton] at h
  linear_combination h

theorem prod_cyclotomic_11 : cyclotomic 1 ℤ * cyclotomic 11 ℤ = X ^ 11 - 1 := by
  have h := prod_cyclotomic_eq_X_pow_sub_one (n := 11) (by norm_num) ℤ
  rw [show Nat.divisors 11 = ({1, 11} : Finset ℕ) from by decide,
    Finset.prod_insert (by decide), Finset.prod_singleton] at h
  linear_combination h

theorem prod_cyclotomic_7 : cyclotomic 1 ℤ * cyclotomic 7 ℤ = X ^ 7 - 1 := by
  have h := prod_cyclotomic_eq_X_pow_sub_one (n := 7) (by norm_num) ℤ
  rw [show Nat.divisors 7 = ({1, 7} : Finset ℕ) from by decide,
    Finset.prod_insert (by decide), Finset.prod_singleton] at h
  linear_combination h

theorem prod_cyclotomic_3 : cyclotomic 1 ℤ * cyclotomic 3 ℤ = X ^ 3 - 1 := by
  have h := prod_cyclotomic_eq_X_pow_sub_one (n := 3) (by norm_num) ℤ
  rw [show Nat.divisors 3 = ({1, 3} : Finset ℕ) from by decide,
    Finset.prod_insert (by decide), Finset.prod_singleton] at h
  linear_combination h

theorem cyclotomic_231_moebius :
    cyclotomic 231 ℤ * ((X - 1) * (X ^ 21 - 1) * (X ^ 33 - 1) * (X ^ 77 - 1))
      = (X ^ 3 - 1) * (X ^ 7 - 1) * (X ^ 11 - 1) * (X ^ 231 - 1) := by
  have e1 : (X : ℤ[X]) - 1 = cyclotomic 1 ℤ := by rw [Polynomial.cyclotomic_one]
  rw [← prod_cyclotomic_231, ← prod_cyclotomic_77, ← prod_cyclotomic_33, ← prod_cyclotomic_21,
    ← prod_cyclotomic_11, ← prod_cyclotomic_7, ← prod_cyclotomic_3, e1]
  ring

set_option maxHeartbeats 4000000 in
theorem P231_moebius :
    P231 * ((X - 1) * (X ^ 21 - 1) * (X ^ 33 - 1) * (X ^ 77 - 1))
      = (X ^ 3 - 1) * (X ^ 7 - 1) * (X ^ 11 - 1) * (X ^ 231 - 1) := by
  rw [P231_expand]
  ring

theorem moebius_factor_231_ne_zero :
    ((X : ℤ[X]) - 1) * (X ^ 21 - 1) * (X ^ 33 - 1) * (X ^ 77 - 1) ≠ 0 := by
  have key : ∀ m : ℕ, 0 < m → (X ^ m - 1 : ℤ[X]) ≠ 0 := by
    intro m hm h
    have := congrArg (Polynomial.eval (0 : ℤ)) h
    simp [zero_pow hm.ne'] at this
  have h1 : (X : ℤ[X]) - 1 ≠ 0 := by
    have h := key 1 (by norm_num)
    rwa [pow_one] at h
  exact mul_ne_zero (mul_ne_zero (mul_ne_zero h1 (key 21 (by norm_num))) (key 33 (by norm_num)))
    (key 77 (by norm_num))

/-- **The explicit frame `Φ₂₃₁`.** -/
theorem pmFrame_231_eq : pmFrame 231 = P231 := by
  show cyclotomic 231 ℤ = P231
  have h2 : cyclotomic 231 ℤ * ((X - 1) * (X ^ 21 - 1) * (X ^ 33 - 1) * (X ^ 77 - 1))
      = P231 * ((X - 1) * (X ^ 21 - 1) * (X ^ 33 - 1) * (X ^ 77 - 1)) := by
    rw [cyclotomic_231_moebius, P231_moebius]
  exact mul_right_cancel₀ moebius_factor_231_ne_zero h2

/-- **A flat ternary frame.**  `Φ₂₃₁` has all coefficients in `{-1,0,1}`, although `231` has three
distinct odd prime divisors. -/
theorem flatFrame_231 : FlatFrame 231 := by
  intro k
  rw [pmFrame_231_eq, coeff_P231]
  rcases lt_or_ge k c231.length with hk | hk
  · have hmem : c231.getD k 0 ∈ c231 := by
      rw [List.getD_eq_getElem c231 0 hk]
      exact List.getElem_mem hk
    have hall : ∀ x ∈ c231, |x| ≤ 1 := by decide
    exact hall _ hmem
  · rw [List.getD_eq_default c231 0 hk]
    norm_num

theorem primeFactors_231 : (231 : ℕ).primeFactors = {3, 7, 11} := by
  have h : (231 : ℕ) = 3 * (7 * 11) := by norm_num
  rw [h, Nat.primeFactors_mul (by norm_num) (by norm_num),
    Nat.primeFactors_mul (by norm_num) (by norm_num),
    Nat.Prime.primeFactors (by norm_num), Nat.Prime.primeFactors (by norm_num),
    Nat.Prime.primeFactors (by norm_num)]
  rfl

/-- **The classification is not an equivalence.**  `231` has three odd prime divisors and its
frame is nevertheless flat. -/
theorem flat_not_characterised_by_two_odd_primes :
    ∃ n : ℕ, n ≠ 0 ∧ 2 < (n.primeFactors.erase 2).card ∧ FlatFrame n := by
  refine ⟨231, by norm_num, ?_, flatFrame_231⟩
  rw [primeFactors_231]
  decide

theorem oddRad_231 : oddRad 231 = 231 := by
  rw [oddRad, primeFactors_231]
  decide

/-- **An infinite flat family outside the classification.**  Every `n` whose odd radical is `231`
— for instance `n = 2^a 3^b 7^c 11^d` with `b, c, d ≥ 1` — has a flat frame. -/
theorem flatFrame_of_oddRad_231 {n : ℕ} (hn : n ≠ 0) (h : oddRad n = 231) : FlatFrame n := by
  rw [flatFrame_iff_oddRad hn, h]
  exact flatFrame_231

end PMFrame231