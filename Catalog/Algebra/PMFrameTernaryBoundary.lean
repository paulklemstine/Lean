/-
# The ternary boundary of flatness: `Φ₁₀₅` has a coefficient equal to `-2`
-/
import Mathlib
import Shared.PMFrameTwoParameter

namespace PMFrameTernary

open Polynomial Finset PMFrame

/-- `(X³-1)(X⁵-1)(X⁷-1)`, expanded. -/
noncomputable def W105 : ℤ[X] := X ^ 15 - X ^ 12 - X ^ 10 - X ^ 8 + X ^ 7 + X ^ 5 + X ^ 3 - 1

/-- The cofactor `R` in `(X¹⁵-1)(X²¹-1)(X³⁵-1) = -1 + X¹⁵ · R`. -/
noncomputable def R105 : ℤ[X] :=
  X ^ 56 - X ^ 41 - X ^ 35 - X ^ 21 + X ^ 20 + X ^ 6 + 1

theorem prod_cyclotomic_105 :
    cyclotomic 1 ℤ * cyclotomic 3 ℤ * cyclotomic 5 ℤ * cyclotomic 7 ℤ * cyclotomic 15 ℤ *
      cyclotomic 21 ℤ * cyclotomic 35 ℤ * cyclotomic 105 ℤ = X ^ 105 - 1 := by
  have h := prod_cyclotomic_eq_X_pow_sub_one (n := 105) (by norm_num) ℤ
  rw [show Nat.divisors 105 = ({1, 3, 5, 7, 15, 21, 35, 105} : Finset ℕ) from by decide,
    Finset.prod_insert (by decide), Finset.prod_insert (by decide),
    Finset.prod_insert (by decide), Finset.prod_insert (by decide),
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

theorem prod_cyclotomic_21 :
    cyclotomic 1 ℤ * cyclotomic 3 ℤ * cyclotomic 7 ℤ * cyclotomic 21 ℤ = X ^ 21 - 1 := by
  have h := prod_cyclotomic_eq_X_pow_sub_one (n := 21) (by norm_num) ℤ
  rw [show Nat.divisors 21 = ({1, 3, 7, 21} : Finset ℕ) from by decide,
    Finset.prod_insert (by decide), Finset.prod_insert (by decide),
    Finset.prod_insert (by decide), Finset.prod_singleton] at h
  linear_combination h

theorem prod_cyclotomic_15 :
    cyclotomic 1 ℤ * cyclotomic 3 ℤ * cyclotomic 5 ℤ * cyclotomic 15 ℤ = X ^ 15 - 1 := by
  have h := prod_cyclotomic_eq_X_pow_sub_one (n := 15) (by norm_num) ℤ
  rw [show Nat.divisors 15 = ({1, 3, 5, 15} : Finset ℕ) from by decide,
    Finset.prod_insert (by decide), Finset.prod_insert (by decide),
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

theorem prod_cyclotomic_3 : cyclotomic 1 ℤ * cyclotomic 3 ℤ = X ^ 3 - 1 := by
  have h := prod_cyclotomic_eq_X_pow_sub_one (n := 3) (by norm_num) ℤ
  rw [show Nat.divisors 3 = ({1, 3} : Finset ℕ) from by decide,
    Finset.prod_insert (by decide), Finset.prod_singleton] at h
  linear_combination h

/-- **Möbius identity for the order `105`.** -/
theorem cyclotomic_105_moebius :
    cyclotomic 105 ℤ * ((X - 1) * (X ^ 15 - 1) * (X ^ 21 - 1) * (X ^ 35 - 1))
      = (X ^ 3 - 1) * (X ^ 5 - 1) * (X ^ 7 - 1) * (X ^ 105 - 1) := by
  have e1 : (X : ℤ[X]) - 1 = cyclotomic 1 ℤ := by rw [Polynomial.cyclotomic_one]
  rw [← prod_cyclotomic_105, ← prod_cyclotomic_35, ← prod_cyclotomic_21, ← prod_cyclotomic_15,
    ← prod_cyclotomic_7, ← prod_cyclotomic_5, ← prod_cyclotomic_3, e1]
  ring

/-- Splitting off the part of the Möbius identity that is invisible below degree `15`. -/
theorem cyclotomic_105_low_identity :
    cyclotomic 105 ℤ * (X - 1)
      = W105 + (cyclotomic 105 ℤ * (X - 1) * R105 - X ^ 90 * W105) * X ^ 15 := by
  have h := cyclotomic_105_moebius
  simp only [W105, R105]
  linear_combination -h

/-- Below degree `15`, the coefficients of `Φ₁₀₅ · (X-1)` are those of `(X³-1)(X⁵-1)(X⁷-1)`. -/
theorem coeff_cyclotomic_105_low {k : ℕ} (hk : k < 15) :
    (cyclotomic 105 ℤ * (X - 1)).coeff k = W105.coeff k := by
  have h := congrArg (fun f : ℤ[X] => f.coeff k) cyclotomic_105_low_identity
  simpa [Polynomial.coeff_mul_X_pow', show ¬ (15 ≤ k) from by omega] using h

theorem W105_coeff_values :
    W105.coeff 0 = -1 ∧ W105.coeff 1 = 0 ∧ W105.coeff 2 = 0 ∧ W105.coeff 3 = 1 ∧
      W105.coeff 4 = 0 ∧ W105.coeff 5 = 1 ∧ W105.coeff 6 = 0 ∧ W105.coeff 7 = 1 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    simp [W105, Polynomial.coeff_X_pow, Polynomial.coeff_one]

/-- The head of the recursion: the constant term of `Φ₁₀₅` is `1`. -/
theorem coeff_cyclotomic_105_zero : (cyclotomic 105 ℤ).coeff 0 = 1 := by
  have h := coeff_cyclotomic_105_low (k := 0) (by norm_num)
  rw [mul_sub, mul_one, Polynomial.coeff_sub, Polynomial.coeff_mul_X_zero,
    W105_coeff_values.1] at h
  linarith

/-- The recursion: `c_k - c_{k+1}` is the `(k+1)`-st coefficient of `(X³-1)(X⁵-1)(X⁷-1)`. -/
theorem coeff_cyclotomic_105_step {k : ℕ} (hk : k + 1 < 15) :
    (cyclotomic 105 ℤ).coeff k - (cyclotomic 105 ℤ).coeff (k + 1) = W105.coeff (k + 1) := by
  have h := coeff_cyclotomic_105_low (k := k + 1) hk
  rw [mul_sub, mul_one, Polynomial.coeff_sub, Polynomial.coeff_mul_X] at h
  linarith

/-- **The ternary boundary.**  `Φ₁₀₅` — the smallest cyclotomic polynomial with three distinct
odd prime factors — has a coefficient equal to `-2`.  Hence the flat bound `|c| ≤ 1`, valid for
all orders with at most two prime factors, fails at three parameters. -/
theorem coeff_pmFrame_105_seven : (pmFrame 105).coeff 7 = -2 := by
  obtain ⟨w0, w1, w2, w3, w4, w5, w6, w7⟩ := W105_coeff_values
  have h0 := coeff_cyclotomic_105_zero
  have s0 := coeff_cyclotomic_105_step (k := 0) (by norm_num)
  have s1 := coeff_cyclotomic_105_step (k := 1) (by norm_num)
  have s2 := coeff_cyclotomic_105_step (k := 2) (by norm_num)
  have s3 := coeff_cyclotomic_105_step (k := 3) (by norm_num)
  have s4 := coeff_cyclotomic_105_step (k := 4) (by norm_num)
  have s5 := coeff_cyclotomic_105_step (k := 5) (by norm_num)
  have s6 := coeff_cyclotomic_105_step (k := 6) (by norm_num)
  rw [w1] at s0
  rw [w2] at s1
  rw [w3] at s2
  rw [w4] at s3
  rw [w5] at s4
  rw [w6] at s5
  rw [w7] at s6
  show (cyclotomic 105 ℤ).coeff 7 = -2
  linarith

/-- The first eight coefficients of `Φ₁₀₅`. -/
theorem coeff_pmFrame_105_initial :
    (pmFrame 105).coeff 0 = 1 ∧ (pmFrame 105).coeff 1 = 1 ∧ (pmFrame 105).coeff 2 = 1 ∧
      (pmFrame 105).coeff 3 = 0 ∧ (pmFrame 105).coeff 4 = 0 ∧ (pmFrame 105).coeff 5 = -1 ∧
      (pmFrame 105).coeff 6 = -1 ∧ (pmFrame 105).coeff 7 = -2 := by
  obtain ⟨w0, w1, w2, w3, w4, w5, w6, w7⟩ := W105_coeff_values
  have h0 := coeff_cyclotomic_105_zero
  have s0 := coeff_cyclotomic_105_step (k := 0) (by norm_num)
  have s1 := coeff_cyclotomic_105_step (k := 1) (by norm_num)
  have s2 := coeff_cyclotomic_105_step (k := 2) (by norm_num)
  have s3 := coeff_cyclotomic_105_step (k := 3) (by norm_num)
  have s4 := coeff_cyclotomic_105_step (k := 4) (by norm_num)
  have s5 := coeff_cyclotomic_105_step (k := 5) (by norm_num)
  have s6 := coeff_cyclotomic_105_step (k := 6) (by norm_num)
  rw [w1] at s0
  rw [w2] at s1
  rw [w3] at s2
  rw [w4] at s3
  rw [w5] at s4
  rw [w6] at s5
  rw [w7] at s6
  show (cyclotomic 105 ℤ).coeff 0 = 1 ∧ (cyclotomic 105 ℤ).coeff 1 = 1 ∧
    (cyclotomic 105 ℤ).coeff 2 = 1 ∧ (cyclotomic 105 ℤ).coeff 3 = 0 ∧
    (cyclotomic 105 ℤ).coeff 4 = 0 ∧ (cyclotomic 105 ℤ).coeff 5 = -1 ∧
    (cyclotomic 105 ℤ).coeff 6 = -1 ∧ (cyclotomic 105 ℤ).coeff 7 = -2
  refine ⟨h0, by linarith, by linarith, by linarith, by linarith, by linarith, by linarith,
    by linarith⟩

end PMFrameTernary