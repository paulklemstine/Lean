import Mathlib

/-!
# Báez–Duarte floor polynomials and divisor transforms

This file formalizes the algebraic core of Proposition 2.10 of Alexandre
Pyvovarov, *A few remarks on the Báez-Duarte Criterion* (arXiv:2607.12084).
The result is stated for an arbitrary integer-valued arithmetic function.  It
therefore isolates a bridge between two different constructions:

* floor-weighted generating polynomials (discrete approximation), and
* divisor-sum polynomials (multiplicative number theory).

The paper's Möbius polynomials are obtained by specializing the coefficient
function to `ArithmeticFunction.moebius`.
-/

namespace BaezDuarte

open scoped BigOperators

/-- The floor-weighted polynomial attached to an arithmetic function.
Its coefficient of `X^n` is `a n * ⌊k/n⌋`. -/
noncomputable def floorPolynomial (a : ℕ → ℤ) (k : ℕ) : Polynomial ℤ :=
  ∑ n ∈ Finset.Icc 1 k, Polynomial.monomial n (a n * (k / n : ℕ))

/-- The divisor-transform polynomial attached to an arithmetic function.
Its coefficient of `X^n` is `a n` exactly when `n ∣ k`. -/
noncomputable def divisorPolynomial (a : ℕ → ℤ) (k : ℕ) : Polynomial ℤ :=
  ∑ n ∈ Finset.Icc 1 k with n ∣ k, Polynomial.monomial n (a n)

/-
Crossing the integer `k+1` makes the floor `⌊k/n⌋` jump precisely when
`n` divides `k+1`.  This is the coefficientwise engine of Proposition 2.10.
-/
lemma floor_div_increment (k n : ℕ) :
    (k + 1) / n = k / n + (if n ∣ k + 1 then 1 else 0) := by
  split_ifs <;> simp_all +decide [ Nat.succ_div ]

/-
**Floor/divisor connector.** The discrete derivative of a floor-weighted
polynomial is its divisor-transform polynomial.
-/
theorem floorPolynomial_succ_sub (a : ℕ → ℤ) (k : ℕ) :
    floorPolynomial a (k + 1) - floorPolynomial a k =
      divisorPolynomial a (k + 1) := by
  ext n;
  by_cases hn : n ≤ k <;> by_cases hn' : n ≤ k + 1 <;> simp_all +decide;
  · unfold floorPolynomial divisorPolynomial; simp +decide [ Polynomial.coeff_monomial, Nat.succ_div, hn, hn' ] ;
    grind +qlia;
  · grind;
  · cases hn'.eq_or_lt <;> first | linarith | simp_all +decide [ floorPolynomial, divisorPolynomial, Polynomial.coeff_monomial ] ;
    rw [ Int.ediv_self ( by linarith ), mul_one ];
  · unfold floorPolynomial divisorPolynomial; simp +decide [ Polynomial.coeff_monomial, Finset.sum_Ioc_succ_top, (Nat.succ_eq_succ ▸ Finset.Icc_succ_left_eq_Ioc) ] ;
    grind +splitIndPred

/-
Equivalently, the floor-weighted polynomial is the cumulative sum of its
divisor-transform polynomials.  This is the exact finite/Cesàro identity behind
`Q_k = (1/k) ∑_{m≤k} R_m` in Proposition 2.10.
-/
theorem floorPolynomial_eq_sum_divisorPolynomial (a : ℕ → ℤ) (k : ℕ) :
    floorPolynomial a k = ∑ m ∈ Finset.Icc 1 k, divisorPolynomial a m := by
  induction' k with k ih;
  · unfold floorPolynomial; aesop;
  · convert congr_arg ( fun x : Polynomial ℤ => x + divisorPolynomial a ( k + 1 ) ) ih using 1;
    · rw [ ← floorPolynomial_succ_sub, add_sub_cancel ];
    · exact Finset.sum_Ioc_succ_top ( by norm_num ) _

/-- The Möbius specialization appearing in the paper. -/
noncomputable def moebiusFloorPolynomial (k : ℕ) : Polynomial ℤ :=
  floorPolynomial ArithmeticFunction.moebius k

/-- The paper's divisor polynomial `R_k(x) = ∑_{n∣k} μ(n)x^n`. -/
noncomputable def moebiusDivisorPolynomial (k : ℕ) : Polynomial ℤ :=
  divisorPolynomial ArithmeticFunction.moebius k

/-- Möbius-polynomial form of Proposition 2.10: a floor-weighted Möbius
polynomial is exactly the cumulative divisor-polynomial sum. -/
theorem moebius_polynomial_connector (k : ℕ) :
    moebiusFloorPolynomial k =
      ∑ m ∈ Finset.Icc 1 k, moebiusDivisorPolynomial m := by
  simpa [moebiusFloorPolynomial, moebiusDivisorPolynomial] using
    floorPolynomial_eq_sum_divisorPolynomial ArithmeticFunction.moebius k

end BaezDuarte