import Mathlib
import Shared.Ispythquadruple.IsPythQuadruple
import Shared.HigherPythagorean.LorentzCore
import Physics.HigherPythagoreanTrees.GrowthExponent

/-!
# The sharp growth constant is never attained on the integral tree

The catalog proves that in dimension three the growth constant `2 + √3` is *attained* on the
real null cone (`HigherPythagorean.quad_growth_bound_sharp`, with the point
`(1/√3, 1/√3, 1/√3; 1)`).  That extremal point is irrational, and this file shows the
phenomenon is systematic:

> for an **integral** Pythagorean quadruple every reflection move increases the height by a
> factor *strictly* less than `2 + √3`.

The obstruction is the irrationality of `√3`: equality in `a + b + c ≤ √3 · d` forces
`a = b = c` and hence `3a² = d²`.

Main results.

* `three_mul_sq_ne_sq` : `3a² = d²` has no solution with `a ≠ 0`.
* `space_sum_lt_sqrt_three_height` : `a + b + c < √3 · d` for every integral quadruple with
  non-negative coordinates and positive height.
* `quad_move_height_lt_growth` : every reflection move satisfies `d' < (2+√3) · d`, so the
  sharp real constant `HigherPythagoreanGrowth.growth 3` is an unattained supremum on the
  integral tree.
-/

namespace HigherPythagoreanIntegral

open HigherPythagoreanGrowth

/-- `3a² = d²` is impossible for a nonzero integer `a`: this is the irrationality of `√3`. -/
theorem three_mul_sq_ne_sq {a d : ℤ} (ha : a ≠ 0) : 3 * a ^ 2 ≠ d ^ 2 := by
  intro h
  have hirr : Irrational (Real.sqrt 3) := by
    simpa using (Nat.prime_three).irrational_sqrt
  have ha' : (a : ℝ) ≠ 0 := Int.cast_ne_zero.mpr ha
  have hq : Real.sqrt 3 = |(d : ℝ)| / |(a : ℝ)| := by
    have h3 : ((d : ℝ) / (a : ℝ)) ^ 2 = 3 := by
      field_simp
      have : (3 : ℝ) * (a : ℝ) ^ 2 = (d : ℝ) ^ 2 := by exact_mod_cast h
      linarith
    rw [show |(d : ℝ)| / |(a : ℝ)| = |(d : ℝ) / (a : ℝ)| by rw [abs_div]]
    rw [← Real.sqrt_sq_eq_abs, h3]
  rw [hq] at hirr
  exact hirr ⟨|(d : ℚ)| / |(a : ℚ)|, by push_cast; simp⟩

/-- **Strict Cauchy–Schwarz on the integral null cone.**  The sum of the space coordinates of
an integral Pythagorean quadruple is strictly below `√3` times the height. -/
theorem space_sum_lt_sqrt_three_height {a b c d : ℤ} (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c)
    (hd : 0 < d) (h : IsPythQuadruple a b c d) :
    ((a : ℝ) + (b : ℝ) + (c : ℝ)) < Real.sqrt 3 * (d : ℝ) := by
  have h3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have h3pos : 0 < Real.sqrt 3 := by positivity
  have hd' : (0 : ℝ) < (d : ℝ) := by exact_mod_cast hd
  unfold IsPythQuadruple at h
  -- the integral Cauchy–Schwarz gap: equality would force `a = b = c`
  have hgap : (a + b + c) ^ 2 < 3 * d ^ 2 := by
    rcases lt_or_eq_of_le (by nlinarith [sq_nonneg (a - b), sq_nonneg (b - c), sq_nonneg (a - c)]
      : (a + b + c) ^ 2 ≤ 3 * d ^ 2) with hlt | heq
    · exact hlt
    · exfalso
      have hab : a = b := by nlinarith [sq_nonneg (a - b), sq_nonneg (b - c), sq_nonneg (a - c)]
      have hbc : b = c := by nlinarith [sq_nonneg (a - b), sq_nonneg (b - c), sq_nonneg (a - c)]
      have hzero : a ≠ 0 := by
        intro h0
        rw [h0] at hab
        rw [← hab] at hbc
        rw [h0, ← hab, ← hbc] at h
        simp at h
        nlinarith
      exact three_mul_sq_ne_sq hzero (by rw [hab, hbc] at h ⊢; linarith)
  have hgap' : ((a : ℝ) + (b : ℝ) + (c : ℝ)) ^ 2 < 3 * (d : ℝ) ^ 2 := by exact_mod_cast hgap
  have hS : (0 : ℝ) ≤ (a : ℝ) + (b : ℝ) + (c : ℝ) := by
    have ha' : (0 : ℝ) ≤ (a : ℝ) := by exact_mod_cast ha
    have hb' : (0 : ℝ) ≤ (b : ℝ) := by exact_mod_cast hb
    have hc' : (0 : ℝ) ≤ (c : ℝ) := by exact_mod_cast hc
    linarith
  have key : (Real.sqrt 3 * (d : ℝ)) ^ 2 = 3 * (d : ℝ) ^ 2 := by
    rw [mul_pow, h3]
  nlinarith [hgap', key, mul_pos h3pos hd', hS]

/-- **No integral node attains the growth constant.**  Every reflection move on an integral
Pythagorean quadruple multiplies the height by a factor strictly smaller than
`growth 3 = 2 + √3`. -/
theorem quad_move_height_lt_growth {a b c d e₁ e₂ e₃ : ℤ} (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c)
    (hd : 0 < d) (h : IsPythQuadruple a b c d)
    (h₁ : e₁ = 1 ∨ e₁ = -1) (h₂ : e₂ = 1 ∨ e₂ = -1) (h₃ : e₃ = 1 ∨ e₃ = -1) :
    ((2 * d - (e₁ * a + e₂ * b + e₃ * c) : ℤ) : ℝ) < growth 3 * (d : ℝ) := by
  have hsum := space_sum_lt_sqrt_three_height ha hb hc hd h
  have hlow : -((a : ℝ) + (b : ℝ) + (c : ℝ)) ≤
      ((e₁ * a + e₂ * b + e₃ * c : ℤ) : ℝ) := by
    have ha' : (0 : ℝ) ≤ (a : ℝ) := by exact_mod_cast ha
    have hb' : (0 : ℝ) ≤ (b : ℝ) := by exact_mod_cast hb
    have hc' : (0 : ℝ) ≤ (c : ℝ) := by exact_mod_cast hc
    push_cast
    rcases h₁ with rfl | rfl <;> rcases h₂ with rfl | rfl <;> rcases h₃ with rfl | rfl <;>
      push_cast <;> linarith
  rw [growth_three]
  push_cast
  push_cast at hlow
  linarith

end HigherPythagoreanIntegral