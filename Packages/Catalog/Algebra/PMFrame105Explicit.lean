/-
# The explicit ternary frame `Φ₁₀₅` and the sharpness of Bang's bound at `105`

`105 = 3 · 5 · 7` is the smallest order with three distinct odd prime factors.  Here we determine
`Φ₁₀₅` completely — as the explicit degree-48 integer polynomial obtained from the Möbius identity
of `Algebra/PMFrameTernaryBoundary.lean` by cancellation — and read off:

* every coefficient of `Φ₁₀₅` lies in `{-2,-1,0,1,2}` (Bang's bound `p - 1 = 2` for `p = 3`),
* the value `-2` is attained (at `X^7` and at `X^41`),

so that the height of `Φ₁₀₅` is exactly `2`: the flat class stops, but only just.
-/
import Mathlib
import Shared.PMFrameTwoParameter
import Algebra.PMFrameTernaryBoundary

namespace PMFrame105

open Polynomial Finset PMFrame

/-- The coefficient list of `Φ₁₀₅`, indices `0 … 48`. -/
def c105 : List ℤ :=
  [1, 1, 1, 0, 0, -1, -1, -2, -1, -1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, -1, 0, -1, 0, -1, 0, -1, 0,
   -1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, -1, -1, -2, -1, -1, 0, 0, 1, 1, 1]

/-- The candidate polynomial, in coefficient form. -/
noncomputable def P105 : ℤ[X] := ∑ i ∈ Finset.range 49, C (c105.getD i 0) * X ^ i

theorem length_c105 : c105.length = 49 := by decide

theorem coeff_P105 (k : ℕ) : P105.coeff k = c105.getD k 0 := by
  rw [P105, Polynomial.finset_sum_coeff]
  simp only [Polynomial.coeff_C_mul, Polynomial.coeff_X_pow, mul_ite, mul_one, mul_zero]
  rw [Finset.sum_ite_eq (Finset.range 49) k fun i => c105.getD i 0]
  split
  · rfl
  · rename_i hk
    rw [Finset.mem_range, Nat.not_lt] at hk
    exact (List.getD_eq_default c105 0 (by rw [length_c105]; exact hk)).symm

/-- The candidate polynomial, in expanded form. -/
theorem P105_expand :
    P105 = X ^ 48 + X ^ 47 + X ^ 46 - X ^ 43 - X ^ 42 - 2 * X ^ 41 - X ^ 40 - X ^ 39 + X ^ 36 +
      X ^ 35 + X ^ 34 + X ^ 33 + X ^ 32 + X ^ 31 - X ^ 28 - X ^ 26 - X ^ 24 - X ^ 22 - X ^ 20 +
      X ^ 17 + X ^ 16 + X ^ 15 + X ^ 14 + X ^ 13 + X ^ 12 - X ^ 9 - X ^ 8 - 2 * X ^ 7 - X ^ 6 -
      X ^ 5 + X ^ 2 + X + 1 := by
  rw [P105]
  simp only [c105, Finset.sum_range_succ, Finset.sum_range_zero, List.getD_cons_zero,
    List.getD_cons_succ, map_one, map_zero, map_neg, map_ofNat, pow_zero, pow_one]
  ring

set_option maxHeartbeats 2000000 in
/-- The Möbius identity, verified for the explicit candidate. -/
theorem P105_moebius :
    P105 * ((X - 1) * (X ^ 15 - 1) * (X ^ 21 - 1) * (X ^ 35 - 1))
      = (X ^ 3 - 1) * (X ^ 5 - 1) * (X ^ 7 - 1) * (X ^ 105 - 1) := by
  rw [P105_expand]
  ring

theorem moebius_factor_ne_zero :
    ((X : ℤ[X]) - 1) * (X ^ 15 - 1) * (X ^ 21 - 1) * (X ^ 35 - 1) ≠ 0 := by
  have key : ∀ m : ℕ, 0 < m → (X ^ m - 1 : ℤ[X]) ≠ 0 := by
    intro m hm h
    have := congrArg (Polynomial.eval (0 : ℤ)) h
    simp [zero_pow hm.ne'] at this
  have h1 : (X : ℤ[X]) - 1 ≠ 0 := by
    have h := key 1 (by norm_num)
    rwa [pow_one] at h
  exact mul_ne_zero (mul_ne_zero (mul_ne_zero h1 (key 15 (by norm_num))) (key 21 (by norm_num)))
    (key 35 (by norm_num))

/-- **The explicit ternary frame.**  `Φ₁₀₅` equals the explicit degree-`48` polynomial `P₁₀₅`. -/
theorem pmFrame_105_eq : pmFrame 105 = P105 := by
  show cyclotomic 105 ℤ = P105
  have h := PMFrameTernary.cyclotomic_105_moebius
  have h2 : cyclotomic 105 ℤ * ((X - 1) * (X ^ 15 - 1) * (X ^ 21 - 1) * (X ^ 35 - 1))
      = P105 * ((X - 1) * (X ^ 15 - 1) * (X ^ 21 - 1) * (X ^ 35 - 1)) := by
    rw [h, P105_moebius]
  exact mul_right_cancel₀ moebius_factor_ne_zero h2

/-- Every coefficient of `Φ₁₀₅` lies in `{-2,…,2}`: Bang's bound `|a| ≤ p - 1` with `p = 3`. -/
theorem abs_coeff_pmFrame_105_le_two (k : ℕ) : |(pmFrame 105).coeff k| ≤ 2 := by
  rw [pmFrame_105_eq, coeff_P105]
  rcases lt_or_ge k c105.length with hk | hk
  · have hmem : c105.getD k 0 ∈ c105 := by
      rw [List.getD_eq_getElem c105 0 hk]
      exact List.getElem_mem hk
    have hall : ∀ x ∈ c105, |x| ≤ 2 := by decide
    exact hall _ hmem
  · rw [List.getD_eq_default c105 0 hk]
    norm_num

/-- The bound `2` is attained twice, at `X^7` and at `X^41`. -/
theorem coeff_pmFrame_105_eq_neg_two :
    (pmFrame 105).coeff 7 = -2 ∧ (pmFrame 105).coeff 41 = -2 := by
  rw [pmFrame_105_eq, coeff_P105, coeff_P105]
  exact ⟨by decide, by decide⟩

/-- **The height of `Φ₁₀₅` is exactly `2`.**  `2` is the least common bound for the absolute
values of the coefficients. -/
theorem isLeast_height_pmFrame_105 :
    IsLeast {B : ℤ | ∀ k : ℕ, |(pmFrame 105).coeff k| ≤ B} 2 := by
  constructor
  · exact abs_coeff_pmFrame_105_le_two
  · intro B hB
    have h7 := hB 7
    rw [coeff_pmFrame_105_eq_neg_two.1] at h7
    simpa using h7

/-- The degree of `Φ₁₀₅` is `48 = φ(105)`, recovered from the explicit form. -/
theorem natDegree_pmFrame_105 : (pmFrame 105).natDegree = 48 := by
  unfold pmFrame
  rw [Polynomial.natDegree_cyclotomic]
  decide

end PMFrame105