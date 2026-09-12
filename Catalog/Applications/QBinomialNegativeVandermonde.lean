/-
# The negative (Cauchy) q-Vandermonde convolution

Fifth cycle.  `Applications.QVandermondeQBinomial` proves the *finite*
q-Vandermonde convolution by extracting coefficients from the factorisation of
the Rothe product `∏_{i<m+n}(1 + q^i X)`.  `Applications.QBinomialCauchy`
exhibits the Gaussian series `∑_k ⟦n+k-1,k⟧_q X^k` as the inverse of
`∏_{i<n}(1 - q^i X)` in `R⟦X⟧`.

This file runs the coefficient-extraction argument on the *reciprocal* product,
using that inverses are multiplicative: from

`∏_{i<m+n}(1 - q^i X) = (∏_{i<m}(1 - q^i X)) · (∏_{i<n}(1 - q^{m+i} X))`

and the fact that the second factor is inverted by the rescaled Gaussian series
`∑_j q^{mj} ⟦n+j-1,j⟧_q X^j`, one obtains the **negative q-Vandermonde
convolution**

`⟦m+n+k-1, k⟧_q = ∑_{j ≤ k} q^{m(k-j)} ⟦m+j-1, j⟧_q ⟦n+k-j-1, k-j⟧_q`,

whose `q = 1` slice is the classical negative-index Vandermonde identity
`C(m+n+k-1,k) = ∑_{j≤k} C(m+j-1,j) C(n+k-j-1,k-j)`.

This closes Direction 5 of the previous cycle's `FUTURE_DIRECTIONS.md`, and
pins the unknown exponent there down to the linear weight `m·(k-j)`.
-/

import Applications.QBinomialCauchy

namespace Catalog.Applications.QBinomial

open Finset PowerSeries

variable {R : Type*} [CommRing R]

/-- The Gaussian series of `Applications.QBinomialCauchy` rescaled by `X ↦ q^m X`:
`∑_j q^{mj} ⟦n+j-1, j⟧_q X^j`.  It is the inverse of the *shifted* product
`∏_{i<n}(1 - q^{m+i} X)`. -/
noncomputable def qNegSeriesShift (q : R) (m n : ℕ) : R⟦X⟧ :=
  PowerSeries.mk fun j => q ^ (m * j) * qBinom q (n + j - 1) j

@[simp] lemma coeff_qNegSeriesShift (q : R) (m n j : ℕ) :
    (coeff j) (qNegSeriesShift q m n) = q ^ (m * j) * qBinom q (n + j - 1) j :=
  PowerSeries.coeff_mk j _

lemma qNegSeriesShift_zero (q : R) (n : ℕ) : qNegSeriesShift q 0 n = qNegSeries q n := by
  refine PowerSeries.ext fun j => ?_
  simp

/-- Peeling off one factor of the shifted reciprocal product; the rescaled version of
`one_sub_mul_qNegSeries`. -/
lemma one_sub_mul_qNegSeriesShift (q : R) (m n : ℕ) :
    (1 - PowerSeries.C (q ^ (m + n)) * PowerSeries.X) * qNegSeriesShift q m (n + 1)
      = qNegSeriesShift q m n := by
  refine PowerSeries.ext fun k => ?_
  have hexp : (1 - PowerSeries.C (q ^ (m + n)) * PowerSeries.X) * qNegSeriesShift q m (n + 1)
      = qNegSeriesShift q m (n + 1)
        - PowerSeries.C (q ^ (m + n)) * (PowerSeries.X * qNegSeriesShift q m (n + 1)) := by
    ring
  rw [hexp, map_sub, PowerSeries.coeff_C_mul, coeff_qNegSeriesShift]
  match k with
  | 0 =>
      rw [PowerSeries.coeff_zero_X_mul, coeff_qNegSeriesShift]
      simp
  | (j + 1) =>
      rw [PowerSeries.coeff_succ_X_mul, coeff_qNegSeriesShift, coeff_qNegSeriesShift]
      have e1 : n + 1 + (j + 1) - 1 = (n + j) + 1 := by omega
      have e2 : n + 1 + j - 1 = n + j := by omega
      have e3 : n + (j + 1) - 1 = n + j := by omega
      rw [e1, e2, e3, qBinom_succ_succ' q (n + j) j, show n + j - j = n by omega]
      have hpow : q ^ (m * (j + 1)) = q ^ (m * j) * q ^ m := by
        rw [← pow_add]; ring_nf
      rw [hpow, pow_add]
      ring

/-- Cauchy's q-binomial theorem for the shifted product: the rescaled Gaussian series
inverts `∏_{i<n}(1 - q^{m+i} X)`. -/
theorem qBinom_cauchy_shift (q : R) (m n : ℕ) :
    (∏ i ∈ range n, (1 - PowerSeries.C (q ^ (m + i)) * PowerSeries.X))
        * qNegSeriesShift q m n = 1 := by
  induction n with
  | zero =>
      simp only [Finset.range_zero, Finset.prod_empty, one_mul]
      refine PowerSeries.ext fun k => ?_
      rw [coeff_qNegSeriesShift, PowerSeries.coeff_one]
      match k with
      | 0 => simp
      | (j + 1) =>
          rw [if_neg (by omega), qBinom_eq_zero_of_lt q (by omega), mul_zero]
  | succ n ih =>
      rw [Finset.prod_range_succ, mul_assoc, one_sub_mul_qNegSeriesShift q m n, ih]

/-- The reciprocal Gaussian series is multiplicative under `n ↦ m + n`:
`∑_k ⟦m+n+k-1,k⟧ X^k = (∑_k ⟦m+k-1,k⟧ X^k) · (∑_j q^{mj} ⟦n+j-1,j⟧ X^j)`. -/
theorem qNegSeries_add (q : R) (m n : ℕ) :
    qNegSeries q (m + n) = qNegSeries q m * qNegSeriesShift q m n := by
  set P : R⟦X⟧ := ∏ i ∈ range (m + n), (1 - PowerSeries.C (q ^ i) * PowerSeries.X) with hP
  have hsplit : P = (∏ i ∈ range m, (1 - PowerSeries.C (q ^ i) * PowerSeries.X))
      * ∏ i ∈ range n, (1 - PowerSeries.C (q ^ (m + i)) * PowerSeries.X) := by
    rw [hP, Finset.prod_range_add]
  have h1 : P * qNegSeries q (m + n) = 1 := qBinom_cauchy q (m + n)
  have h2 : P * (qNegSeries q m * qNegSeriesShift q m n) = 1 := by
    rw [hsplit]
    calc (∏ i ∈ range m, (1 - PowerSeries.C (q ^ i) * PowerSeries.X))
            * (∏ i ∈ range n, (1 - PowerSeries.C (q ^ (m + i)) * PowerSeries.X))
            * (qNegSeries q m * qNegSeriesShift q m n)
        = ((∏ i ∈ range m, (1 - PowerSeries.C (q ^ i) * PowerSeries.X)) * qNegSeries q m)
            * ((∏ i ∈ range n, (1 - PowerSeries.C (q ^ (m + i)) * PowerSeries.X))
                * qNegSeriesShift q m n) := by ring
      _ = 1 := by rw [qBinom_cauchy q m, qBinom_cauchy_shift q m n, one_mul]
  calc qNegSeries q (m + n)
      = qNegSeries q (m + n) * (P * (qNegSeries q m * qNegSeriesShift q m n)) := by
        rw [h2, mul_one]
    _ = (P * qNegSeries q (m + n)) * (qNegSeries q m * qNegSeriesShift q m n) := by ring
    _ = qNegSeries q m * qNegSeriesShift q m n := by rw [h1, one_mul]

/-- **Negative (Cauchy) q-Vandermonde convolution.**
`⟦m+n+k-1, k⟧_q = ∑_{j ≤ k} q^{m(k-j)} ⟦m+j-1, j⟧_q ⟦n+(k-j)-1, k-j⟧_q`. -/
theorem qBinom_negative_vandermonde (q : R) (m n k : ℕ) :
    qBinom q (m + n + k - 1) k
      = ∑ j ∈ range (k + 1),
          q ^ (m * (k - j)) * (qBinom q (m + j - 1) j * qBinom q (n + (k - j) - 1) (k - j)) := by
  have h := congrArg (fun s : R⟦X⟧ => (coeff k) s) (qNegSeries_add q m n)
  simp only [coeff_qNegSeries] at h
  rw [PowerSeries.coeff_mul, Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk] at h
  rw [h]
  refine Finset.sum_congr rfl fun j hj => ?_
  simp only [coeff_qNegSeries, coeff_qNegSeriesShift]
  ring

/-- The `q = 1` slice: the classical negative-index Vandermonde convolution
`C(m+n+k-1, k) = ∑_{j ≤ k} C(m+j-1, j) · C(n+k-j-1, k-j)`. -/
theorem choose_negative_vandermonde (m n k : ℕ) :
    ((m + n + k - 1).choose k : ℤ)
      = ∑ j ∈ range (k + 1), ((m + j - 1).choose j : ℤ) * ((n + (k - j) - 1).choose (k - j) : ℤ) := by
  have h := qBinom_negative_vandermonde (1 : ℤ) m n k
  simp only [one_pow, one_mul, qBinom_one_eq_choose] at h
  exact h

end Catalog.Applications.QBinomial