/-
# Cauchy's q-binomial theorem (the "negative" q-binomial theorem)

Fourth cycle.  Rothe's theorem expands the *finite* product `∏_{i<n}(1 + q^i x)`.
Its companion expands the *reciprocal* product

`1 / ∏_{i<n}(1 - q^i x) = ∑_{k ≥ 0} ⟦n+k-1, k⟧_q x^k`,

which is a genuine identity of formal power series (Cauchy's q-binomial
theorem).  Since division is unavailable in a general ring, we state it in the
equivalent product form

`(∏_{i<n} (1 - q^i X)) * (∑_{k ≥ 0} ⟦n+k-1,k⟧_q X^k) = 1`   in `R⟦X⟧`,

which simultaneously proves that the polynomial `∏_{i<n}(1 - q^i X)` is a unit of
the power series ring with an explicitly Gaussian-binomial inverse.

The engine of the proof is the *second* form of the q-Pascal recurrence
`⟦m+1,k+1⟧ = q^{m-k} ⟦m,k⟧ + ⟦m,k+1⟧` from `Applications.QVandermondeQBinomial`,
which is exactly the statement that multiplying the series by `1 - q^n X` peels
off one factor.
-/

import Applications.QVandermondeQBinomial

namespace Catalog.Applications.QBinomial

open Finset PowerSeries

variable {R : Type*} [CommRing R]

/-- The `q`-analogue of the negative-binomial series:
`∑_{k ≥ 0} ⟦n+k-1, k⟧_q X^k`.  (For `n = 0` all terms with `k ≥ 1` vanish, so the
series is `1`, matching the empty product.) -/
noncomputable def qNegSeries (q : R) (n : ℕ) : R⟦X⟧ :=
  PowerSeries.mk fun k => qBinom q (n + k - 1) k

@[simp] lemma coeff_qNegSeries (q : R) (n k : ℕ) :
    (coeff k) (qNegSeries q n) = qBinom q (n + k - 1) k :=
  PowerSeries.coeff_mk k _

/-- Peeling off one factor: `(1 - q^n X) · ∑_k ⟦n+k, k⟧ X^k = ∑_k ⟦n+k-1, k⟧ X^k`.
This is the second q-Pascal recurrence in disguise. -/
lemma one_sub_mul_qNegSeries (q : R) (n : ℕ) :
    (1 - PowerSeries.C (q ^ n) * PowerSeries.X) * qNegSeries q (n + 1) = qNegSeries q n := by
  refine PowerSeries.ext fun k => ?_
  have hexp : (1 - PowerSeries.C (q ^ n) * PowerSeries.X) * qNegSeries q (n + 1)
      = qNegSeries q (n + 1) - PowerSeries.C (q ^ n) * (PowerSeries.X * qNegSeries q (n + 1)) := by
    ring
  rw [hexp, map_sub, PowerSeries.coeff_C_mul, coeff_qNegSeries]
  match k with
  | 0 =>
      rw [PowerSeries.coeff_zero_X_mul, coeff_qNegSeries]
      simp
  | (j + 1) =>
      rw [PowerSeries.coeff_succ_X_mul, coeff_qNegSeries, coeff_qNegSeries]
      have e1 : n + 1 + (j + 1) - 1 = (n + j) + 1 := by omega
      have e2 : n + 1 + j - 1 = n + j := by omega
      have e3 : n + (j + 1) - 1 = n + j := by omega
      rw [e1, e2, e3, qBinom_succ_succ' q (n + j) j, show n + j - j = n by omega]
      ring

/-- **Cauchy's q-binomial theorem** (power-series form): the polynomial
`∏_{i<n} (1 - q^i X)` is invertible in `R⟦X⟧` with inverse the Gaussian series
`∑_{k ≥ 0} ⟦n+k-1, k⟧_q X^k`. -/
theorem qBinom_cauchy (q : R) (n : ℕ) :
    (∏ i ∈ range n, (1 - PowerSeries.C (q ^ i) * PowerSeries.X)) * qNegSeries q n = 1 := by
  induction n with
  | zero =>
      simp only [Finset.range_zero, Finset.prod_empty, one_mul]
      refine PowerSeries.ext fun k => ?_
      rw [coeff_qNegSeries, PowerSeries.coeff_one]
      match k with
      | 0 => simp
      | (j + 1) =>
          rw [if_neg (by omega), qBinom_eq_zero_of_lt q (by omega)]
  | succ n ih =>
      rw [Finset.prod_range_succ, mul_assoc, one_sub_mul_qNegSeries q n, ih]

/-- The product `∏_{i<n}(1 - q^i X)` is a unit of the power series ring. -/
theorem isUnit_prod_one_sub (q : R) (n : ℕ) :
    IsUnit (∏ i ∈ range n, (1 - PowerSeries.C (q ^ i) * PowerSeries.X)) :=
  IsUnit.of_mul_eq_one _ (qBinom_cauchy q n)

/-- The classical specialisation `q = 1`: `(1 - X)^n · ∑_k C(n+k-1,k) X^k = 1`. -/
theorem cauchy_one (n : ℕ) :
    ((1 : ℤ⟦X⟧) - PowerSeries.X) ^ n
        * PowerSeries.mk (fun k => ((n + k - 1).choose k : ℤ)) = 1 := by
  have h := qBinom_cauchy (1 : ℤ) n
  simp only [one_pow, map_one, one_mul, Finset.prod_const, Finset.card_range] at h
  have hs : qNegSeries (1 : ℤ) n = PowerSeries.mk (fun k => ((n + k - 1).choose k : ℤ)) := by
    refine PowerSeries.ext fun k => ?_
    rw [coeff_qNegSeries, PowerSeries.coeff_mk, qBinom_one_eq_choose]
  rw [hs] at h
  exact h

end Catalog.Applications.QBinomial