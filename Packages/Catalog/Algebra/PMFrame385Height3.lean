/-
# The height-three frame `Φ₃₈₅` and the third value of the height spectrum

`385 = 5 · 7 · 11` is the smallest order whose frame has a coefficient of absolute value `3`.
Following the method used for `Φ₁₀₅` in `Algebra/PMFrame105Explicit.lean`, we determine `Φ₃₈₅`
completely — as the explicit degree-`240` integer polynomial obtained by cancellation from the
Möbius identity

  `Φ₃₈₅ · (X-1)(X³⁵-1)(X⁵⁵-1)(X⁷⁷-1) = (X⁵-1)(X⁷-1)(X¹¹-1)(X³⁸⁵-1)` —

and read off that its height is exactly `3`, the value `-3` being attained at `X¹¹⁹`, `X¹²⁰`,
`X¹²¹`.  Combined with the height-reduction theorem of `Algebra/PMFrameHeightReduction.lean` this
produces a second infinite family, `2^a 5^{b+1} 7^{c+1} 11^{d+1}`, of frames of height exactly `3`,
and shows that the height spectrum of `±`-frames contains at least the three values `1, 2, 3`:
the flat class, the `Φ₁₀₅` class, and the `Φ₃₈₅` class are pairwise distinct.
-/
import Mathlib
import Shared.PMFrameTwoParameter
import Algebra.PMFrameFlatFamilies
import Algebra.PMFrameFlatClassification
import Algebra.PMFrame105Explicit
import Algebra.PMFrameHeightReduction
import Algebra.PMFrameHeightCapstone

namespace PMFrame385

open Polynomial Finset PMFrame PMFrameFlat PMFrameHeight

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

/-! ## 1. The explicit polynomial -/

/-- The coefficient list of `Φ₃₈₅`, indices `0 … 240`. -/
def c385 : List ℤ :=
  [1, 1, 1, 1, 1, 0, 0, -1, -1, -1, -1, -2, -1, -1, -1, -1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
   0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, -1, -1, -1, -1, -2, -1, -1, -1, -1, 0, 0, 1, 1, 2,
   2, 2, 1, 1, 0, 0, -1, -1, -1, -1, -2, -1, -1, -1, 0, 1, 1, 2, 2, 1, 1, 1, 0, 0, 0, -1, -1,
   -1, -2, -2, -1, -1, -1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, -1, -2, -1, -1, -1, 0, 1, 1, 2, 2,
   2, 2, 2, 1, 1, 0, -1, -2, -2, -3, -3, -3, -2, -2, -1, 0, 1, 1, 2, 2, 2, 2, 2, 1, 1, 0, -1,
   -1, -1, -2, -1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, -1, -1, -1, -2, -2, -1, -1, -1, 0, 0, 0, 1,
   1, 1, 2, 2, 1, 1, 0, -1, -1, -1, -2, -1, -1, -1, -1, 0, 0, 1, 1, 2, 2, 2, 1, 1, 0, 0, -1,
   -1, -1, -1, -2, -1, -1, -1, -1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
   1, 1, 1, 1, 0, 0, -1, -1, -1, -1, -2, -1, -1, -1, -1, 0, 0, 1, 1, 1, 1, 1]

/-- The candidate polynomial, in coefficient form. -/
noncomputable def P385 : ℤ[X] := ∑ i ∈ Finset.range 241, C (c385.getD i 0) * X ^ i

theorem length_c385 : c385.length = 241 := by decide

theorem coeff_P385 (k : ℕ) : P385.coeff k = c385.getD k 0 := by
  rw [P385, Polynomial.finset_sum_coeff]
  simp only [Polynomial.coeff_C_mul, Polynomial.coeff_X_pow, mul_ite, mul_one, mul_zero]
  rw [Finset.sum_ite_eq (Finset.range 241) k fun i => c385.getD i 0]
  split
  · rfl
  · rename_i hk
    rw [Finset.mem_range, Nat.not_lt] at hk
    exact (List.getD_eq_default c385 0 (by rw [length_c385]; exact hk)).symm

/-- The candidate polynomial, in expanded form. -/
theorem P385_expand :
    P385 =
    1 + X + X ^ 2 + X ^ 3 + X ^ 4 - X ^ 7 - X ^ 8 - X ^ 9 - X ^ 10 - 2 * X ^ 11 - X ^ 12 - X ^ 13
      - X ^ 14 - X ^ 15 + X ^ 18 + X ^ 19 + X ^ 20 + X ^ 21 + X ^ 22 + X ^ 35 + X ^ 36 + X ^ 37 +
      X ^ 38 + X ^ 39 - X ^ 42 - X ^ 43 - X ^ 44 - X ^ 45 - 2 * X ^ 46 - X ^ 47 - X ^ 48 - X ^ 49
      - X ^ 50 + X ^ 53 + X ^ 54 + 2 * X ^ 55 + 2 * X ^ 56 + 2 * X ^ 57 + X ^ 58 + X ^ 59 - X ^
      62 - X ^ 63 - X ^ 64 - X ^ 65 - 2 * X ^ 66 - X ^ 67 - X ^ 68 - X ^ 69 + X ^ 71 + X ^ 72 + 2
      * X ^ 73 + 2 * X ^ 74 + X ^ 75 + X ^ 76 + X ^ 77 - X ^ 81 - X ^ 82 - X ^ 83 - 2 * X ^ 84 -
      2 * X ^ 85 - X ^ 86 - X ^ 87 - X ^ 88 + X ^ 90 + X ^ 91 + X ^ 92 + X ^ 93 + X ^ 94 + X ^ 95
      + X ^ 96 - X ^ 100 - 2 * X ^ 101 - X ^ 102 - X ^ 103 - X ^ 104 + X ^ 106 + X ^ 107 + 2 * X
      ^ 108 + 2 * X ^ 109 + 2 * X ^ 110 + 2 * X ^ 111 + 2 * X ^ 112 + X ^ 113 + X ^ 114 - X ^ 116
      - 2 * X ^ 117 - 2 * X ^ 118 - 3 * X ^ 119 - 3 * X ^ 120 - 3 * X ^ 121 - 2 * X ^ 122 - 2 * X
      ^ 123 - X ^ 124 + X ^ 126 + X ^ 127 + 2 * X ^ 128 + 2 * X ^ 129 + 2 * X ^ 130 + 2 * X ^ 131
      + 2 * X ^ 132 + X ^ 133 + X ^ 134 - X ^ 136 - X ^ 137 - X ^ 138 - 2 * X ^ 139 - X ^ 140 + X
      ^ 144 + X ^ 145 + X ^ 146 + X ^ 147 + X ^ 148 + X ^ 149 + X ^ 150 - X ^ 152 - X ^ 153 - X ^
      154 - 2 * X ^ 155 - 2 * X ^ 156 - X ^ 157 - X ^ 158 - X ^ 159 + X ^ 163 + X ^ 164 + X ^ 165
      + 2 * X ^ 166 + 2 * X ^ 167 + X ^ 168 + X ^ 169 - X ^ 171 - X ^ 172 - X ^ 173 - 2 * X ^ 174
      - X ^ 175 - X ^ 176 - X ^ 177 - X ^ 178 + X ^ 181 + X ^ 182 + 2 * X ^ 183 + 2 * X ^ 184 + 2
      * X ^ 185 + X ^ 186 + X ^ 187 - X ^ 190 - X ^ 191 - X ^ 192 - X ^ 193 - 2 * X ^ 194 - X ^
      195 - X ^ 196 - X ^ 197 - X ^ 198 + X ^ 201 + X ^ 202 + X ^ 203 + X ^ 204 + X ^ 205 + X ^
      218 + X ^ 219 + X ^ 220 + X ^ 221 + X ^ 222 - X ^ 225 - X ^ 226 - X ^ 227 - X ^ 228 - 2 * X
      ^ 229 - X ^ 230 - X ^ 231 - X ^ 232 - X ^ 233 + X ^ 236 + X ^ 237 + X ^ 238 + X ^ 239 + X ^
      240 := by
  rw [P385]
  simp only [c385, Finset.sum_range_succ, Finset.sum_range_zero, List.getD_cons_zero,
    List.getD_cons_succ, map_one, map_zero, map_neg, map_ofNat, pow_zero, pow_one]
  ring

/-! ## 2. The Möbius identity at `385 = 5 · 7 · 11` -/

theorem prod_cyclotomic_385 :
    cyclotomic 1 ℤ * cyclotomic 5 ℤ * cyclotomic 7 ℤ * cyclotomic 11 ℤ * cyclotomic 35 ℤ *
      cyclotomic 55 ℤ * cyclotomic 77 ℤ * cyclotomic 385 ℤ = X ^ 385 - 1 := by
  have h := prod_cyclotomic_eq_X_pow_sub_one (n := 385) (by norm_num) ℤ
  rw [show Nat.divisors 385 = ({1, 5, 7, 11, 35, 55, 77, 385} : Finset ℕ) from by decide,
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

theorem prod_cyclotomic_55 :
    cyclotomic 1 ℤ * cyclotomic 5 ℤ * cyclotomic 11 ℤ * cyclotomic 55 ℤ = X ^ 55 - 1 := by
  have h := prod_cyclotomic_eq_X_pow_sub_one (n := 55) (by norm_num) ℤ
  rw [show Nat.divisors 55 = ({1, 5, 11, 55} : Finset ℕ) from by decide,
    Finset.prod_insert (by decide), Finset.prod_insert (by decide),
    Finset.prod_insert (by decide), Finset.prod_singleton] at h
  linear_combination h

theorem prod_cyclotomic_35 :
    cyclotomic 1 ℤ * cyclotomic 5 ℤ * cyclotomic 7 ℤ * cyclotomic 35 ℤ = X ^ 35 - 1 := by
  have h := prod_cyclotomic_eq_X_pow_sub_one (n := 35) (by norm_num) ℤ
  rw [show Nat.divisors 35 = ({1, 5, 7, 35} : Finset ℕ) from by decide,
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

theorem prod_cyclotomic_5 : cyclotomic 1 ℤ * cyclotomic 5 ℤ = X ^ 5 - 1 := by
  have h := prod_cyclotomic_eq_X_pow_sub_one (n := 5) (by norm_num) ℤ
  rw [show Nat.divisors 5 = ({1, 5} : Finset ℕ) from by decide,
    Finset.prod_insert (by decide), Finset.prod_singleton] at h
  linear_combination h

/-- **Möbius identity for the order `385`.** -/
theorem cyclotomic_385_moebius :
    cyclotomic 385 ℤ * ((X - 1) * (X ^ 35 - 1) * (X ^ 55 - 1) * (X ^ 77 - 1))
      = (X ^ 5 - 1) * (X ^ 7 - 1) * (X ^ 11 - 1) * (X ^ 385 - 1) := by
  have e1 : (X : ℤ[X]) - 1 = cyclotomic 1 ℤ := by rw [Polynomial.cyclotomic_one]
  rw [← prod_cyclotomic_385, ← prod_cyclotomic_77, ← prod_cyclotomic_55, ← prod_cyclotomic_35,
    ← prod_cyclotomic_11, ← prod_cyclotomic_7, ← prod_cyclotomic_5, e1]
  ring

/-- The same identity, verified for the explicit candidate `P₃₈₅`. -/
theorem P385_moebius :
    P385 * ((X - 1) * (X ^ 35 - 1) * (X ^ 55 - 1) * (X ^ 77 - 1))
      = (X ^ 5 - 1) * (X ^ 7 - 1) * (X ^ 11 - 1) * (X ^ 385 - 1) := by
  rw [P385_expand]
  ring

theorem moebius_factor_ne_zero :
    ((X : ℤ[X]) - 1) * (X ^ 35 - 1) * (X ^ 55 - 1) * (X ^ 77 - 1) ≠ 0 := by
  have key : ∀ m : ℕ, 0 < m → (X ^ m - 1 : ℤ[X]) ≠ 0 := by
    intro m hm h
    have := congrArg (Polynomial.eval (0 : ℤ)) h
    simp [zero_pow hm.ne'] at this
  have h1 : (X : ℤ[X]) - 1 ≠ 0 := by
    have h := key 1 (by norm_num)
    rwa [pow_one] at h
  exact mul_ne_zero (mul_ne_zero (mul_ne_zero h1 (key 35 (by norm_num))) (key 55 (by norm_num)))
    (key 77 (by norm_num))

/-- **The explicit height-three frame.**  `Φ₃₈₅` equals the explicit degree-`240` polynomial. -/
theorem pmFrame_385_eq : pmFrame 385 = P385 := by
  show cyclotomic 385 ℤ = P385
  have h2 : cyclotomic 385 ℤ * ((X - 1) * (X ^ 35 - 1) * (X ^ 55 - 1) * (X ^ 77 - 1))
      = P385 * ((X - 1) * (X ^ 35 - 1) * (X ^ 55 - 1) * (X ^ 77 - 1)) := by
    rw [cyclotomic_385_moebius, P385_moebius]
  exact mul_right_cancel₀ moebius_factor_ne_zero h2

/-! ## 3. The height of `Φ₃₈₅` is exactly three -/

/-- Every coefficient of `Φ₃₈₅` lies in `{-3,…,3}`: Bang's bound `|a| ≤ p - 1` is not attained
here (`p = 5`), the true height being `3`. -/
theorem abs_coeff_pmFrame_385_le_three (k : ℕ) : |(pmFrame 385).coeff k| ≤ 3 := by
  rw [pmFrame_385_eq, coeff_P385]
  rcases lt_or_ge k c385.length with hk | hk
  · have hmem : c385.getD k 0 ∈ c385 := by
      rw [List.getD_eq_getElem c385 0 hk]
      exact List.getElem_mem hk
    have hall : ∀ x ∈ c385, |x| ≤ 3 := by decide
    exact hall _ hmem
  · rw [List.getD_eq_default c385 0 hk]
    norm_num

/-- The bound `3` is attained three times in a row, at `X¹¹⁹`, `X¹²⁰` and `X¹²¹`. -/
theorem coeff_pmFrame_385_eq_neg_three :
    (pmFrame 385).coeff 119 = -3 ∧ (pmFrame 385).coeff 120 = -3 ∧
      (pmFrame 385).coeff 121 = -3 := by
  rw [pmFrame_385_eq, coeff_P385, coeff_P385, coeff_P385]
  exact ⟨by decide, by decide, by decide⟩

/-- **The height of `Φ₃₈₅` is exactly `3`.** -/
theorem isLeast_height_pmFrame_385 :
    IsLeast {B : ℤ | ∀ k : ℕ, |(pmFrame 385).coeff k| ≤ B} 3 := by
  constructor
  · exact abs_coeff_pmFrame_385_le_three
  · intro B hB
    have h := hB 119
    rw [coeff_pmFrame_385_eq_neg_three.1] at h
    simpa using h

/-- The degree of `Φ₃₈₅` is `240 = φ(385)`. -/
theorem natDegree_pmFrame_385 : (pmFrame 385).natDegree = 240 := by
  unfold pmFrame
  rw [Polynomial.natDegree_cyclotomic]
  decide

/-! ## 4. An infinite family of frames of height exactly three -/

theorem primeFactors_385 : (385 : ℕ).primeFactors = {5, 7, 11} := by
  have h : (385 : ℕ) = 5 * (7 * 11) := by norm_num
  rw [h, Nat.primeFactors_mul (by norm_num) (by norm_num),
    Nat.primeFactors_mul (by norm_num) (by norm_num),
    Nat.Prime.primeFactors (by norm_num), Nat.Prime.primeFactors (by norm_num),
    Nat.Prime.primeFactors (by norm_num)]
  decide

theorem oddRad_385 : oddRad 385 = 385 := by
  rw [oddRad, primeFactors_385]
  decide

/-- The odd radical of `2^a 5^{b+1} 7^{c+1} 11^{d+1}` is `385`. -/
theorem oddRad_family_385 (a b c d : ℕ) :
    oddRad (2 ^ a * (5 ^ (b + 1) * (7 ^ (c + 1) * 11 ^ (d + 1)))) = 385 := by
  have h385 : (385 : ℕ) ≠ 0 := by norm_num
  have h5 : ((385 : ℕ) * 5 ^ b) ≠ 0 := by positivity
  have h7 : ((385 : ℕ) * 5 ^ b * 7 ^ c) ≠ 0 := by positivity
  have hrw : 5 ^ (b + 1) * (7 ^ (c + 1) * 11 ^ (d + 1)) = 385 * 5 ^ b * 7 ^ c * 11 ^ d := by
    ring
  rw [hrw, oddRad_two_pow_mul (by positivity),
    oddRad_mul_prime_pow (p := 11) (by norm_num) ⟨35 * 5 ^ b * 7 ^ c, by ring⟩ h7,
    oddRad_mul_prime_pow (p := 7) (by norm_num) ⟨55 * 5 ^ b, by ring⟩ h5,
    oddRad_mul_prime_pow (p := 5) (by norm_num) ⟨77, by norm_num⟩ h385,
    oddRad_385]

/-- **Height three for a whole family.**  For all `a b c d`, the frame of the order
`2^a 5^{b+1} 7^{c+1} 11^{d+1}` has least coefficient bound `3`. -/
theorem isLeast_height_family_385 (a b c d : ℕ) :
    IsLeast {B : ℤ | FrameBoundedBy (2 ^ a * (5 ^ (b + 1) * (7 ^ (c + 1) * 11 ^ (d + 1)))) B} 3 := by
  have hn0 : (2 ^ a * (5 ^ (b + 1) * (7 ^ (c + 1) * 11 ^ (d + 1)))) ≠ 0 := by positivity
  have hiff := frameBoundedBy_iff_oddRad _ hn0
  constructor
  · rw [Set.mem_setOf_eq, hiff 3, oddRad_family_385 a b c d]
    exact abs_coeff_pmFrame_385_le_three
  · intro B hB
    rw [Set.mem_setOf_eq, hiff B, oddRad_family_385 a b c d] at hB
    have h := hB 119
    rw [coeff_pmFrame_385_eq_neg_three.1] at h
    simpa using h

/-! ## 5. Three distinct values in the height spectrum -/

theorem pmFrame_3_eq : pmFrame 3 = X ^ 2 + X + 1 := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  show cyclotomic 3 ℤ = _
  rw [Polynomial.cyclotomic_prime ℤ 3]
  simp [Finset.sum_range_succ]
  ring

/-- The height of `Φ₃` is exactly `1`. -/
theorem isLeast_height_pmFrame_3 : IsLeast {B : ℤ | FrameBoundedBy 3 B} 1 := by
  constructor
  · intro k
    rw [pmFrame_3_eq]
    rcases k with _ | _ | _ | k <;>
      simp [Polynomial.coeff_one, Polynomial.coeff_X, Polynomial.coeff_X_pow]
  · intro B hB
    have h := hB 0
    rw [pmFrame_3_eq] at h
    simpa [Polynomial.coeff_one, Polynomial.coeff_X, Polynomial.coeff_X_pow] using h

/-- **The height spectrum contains at least three values.**  There are orders whose frames have
height exactly `1`, exactly `2` and exactly `3`; so neither the flat class nor the flat class
together with the `Φ₁₀₅` class exhausts the possible coefficient heights. -/
theorem height_spectrum_contains_one_two_three :
    (∃ n : ℕ, IsLeast {B : ℤ | FrameBoundedBy n B} 1) ∧
      (∃ n : ℕ, IsLeast {B : ℤ | FrameBoundedBy n B} 2) ∧
      (∃ n : ℕ, IsLeast {B : ℤ | FrameBoundedBy n B} 3) :=
  ⟨⟨3, isLeast_height_pmFrame_3⟩, ⟨105, PMFrame105.isLeast_height_pmFrame_105⟩,
    ⟨385, isLeast_height_pmFrame_385⟩⟩

/-- `Φ₃₈₅` is not flat, and it is not even bounded by the height of `Φ₁₀₅`: the ternary orders
split into at least three genuinely different height classes. -/
theorem not_frameBoundedBy_two_385 : ¬ FrameBoundedBy 385 2 := by
  intro h
  have := isLeast_height_pmFrame_385.2 h
  norm_num at this

end PMFrame385