/-
# Rogers–Szegő polynomials and their three-term ladder

Fifth cycle (Future Direction 1, closed).  The Rogers–Szegő polynomial

`H_n(x) = ∑_{k ≤ n} ⟦n,k⟧_q x^k`

is the generating function of a row of the Gaussian triangle.  Its `x = 1`
specialisation is the Galois number `G_n` of
`Applications.QBinomialGaussProduct`, and the Goldman–Rota recurrence proved
there is the `x = 1` slice of the three-term ladder

`H_{n+2}(x) = (1+x) H_{n+1}(x) + (q^{n+1} - 1) x H_n(x)`

proved here.  The proof is the one-parameter deformation of the Galois argument:
the auxiliary weighted sum `W_n(x) = ∑_k q^k ⟦n,k⟧_q x^k` satisfies the coupled
system `H_{n+1} = x H_n + W_n`, `W_{n+1} = q^{n+1} x H_n + W_n`, obtained from the
two q-Pascal recurrences respectively.
-/

import Applications.QBinomialGaussProduct

namespace Catalog.Applications.QBinomial

open Finset

variable {R : Type*} [CommRing R]

/-- The Rogers–Szegő polynomial `H_n(x) = ∑_{k ≤ n} ⟦n,k⟧_q x^k`. -/
def qRS (q x : R) (n : ℕ) : R := ∑ k ∈ range (n + 1), qBinom q n k * x ^ k

/-- The `q`-weighted Rogers–Szegő polynomial `W_n(x) = ∑_{k ≤ n} q^k ⟦n,k⟧_q x^k`. -/
def qRSW (q x : R) (n : ℕ) : R := ∑ k ∈ range (n + 1), q ^ k * qBinom q n k * x ^ k

@[simp] lemma qRS_one (q : R) (n : ℕ) : qRS q 1 n = qGalois q n := by
  simp [qRS, qGalois]

lemma qRSW_shift (q x : R) (n : ℕ) :
    ∑ j ∈ range (n + 1), q ^ (j + 1) * qBinom q n (j + 1) * x ^ (j + 1) = qRSW q x n - 1 := by
  have h1 : ∑ k ∈ range (n + 1 + 1), q ^ k * qBinom q n k * x ^ k
      = (∑ j ∈ range (n + 1), q ^ (j + 1) * qBinom q n (j + 1) * x ^ (j + 1))
        + q ^ 0 * qBinom q n 0 * x ^ 0 := Finset.sum_range_succ' _ (n + 1)
  have h2 : ∑ k ∈ range (n + 1 + 1), q ^ k * qBinom q n k * x ^ k
      = qRSW q x n + q ^ (n + 1) * qBinom q n (n + 1) * x ^ (n + 1) :=
    Finset.sum_range_succ _ (n + 1)
  rw [qBinom_eq_zero_of_lt q (by omega : n < n + 1)] at h2
  rw [qBinom_zero_right, pow_zero] at h1
  linear_combination h2 - h1

/-- First half of the coupled system: `H_{n+1}(x) = x H_n(x) + W_n(x)`,
coming from the first q-Pascal recurrence. -/
lemma qRS_succ (q x : R) (n : ℕ) : qRS q x (n + 1) = x * qRS q x n + qRSW q x n := by
  have h1 : qRS q x (n + 1)
      = (∑ j ∈ range (n + 1), qBinom q (n + 1) (j + 1) * x ^ (j + 1))
        + qBinom q (n + 1) 0 * x ^ 0 := Finset.sum_range_succ' _ (n + 1)
  have h2 : ∀ j ∈ range (n + 1), qBinom q (n + 1) (j + 1) * x ^ (j + 1)
      = qBinom q n j * x ^ j * x + q ^ (j + 1) * qBinom q n (j + 1) * x ^ (j + 1) := by
    intro j _
    rw [qBinom_succ_succ q n j]
    ring
  rw [h1, Finset.sum_congr rfl h2, Finset.sum_add_distrib, qRSW_shift, qBinom_zero_right,
    ← Finset.sum_mul]
  simp only [qRS]
  ring

/-- Second half of the coupled system: `W_{n+1}(x) = q^{n+1} x H_n(x) + W_n(x)`,
coming from the second q-Pascal recurrence. -/
lemma qRSW_succ (q x : R) (n : ℕ) :
    qRSW q x (n + 1) = q ^ (n + 1) * x * qRS q x n + qRSW q x n := by
  have h1 : qRSW q x (n + 1)
      = (∑ j ∈ range (n + 1), q ^ (j + 1) * qBinom q (n + 1) (j + 1) * x ^ (j + 1))
        + q ^ 0 * qBinom q (n + 1) 0 * x ^ 0 := Finset.sum_range_succ' _ (n + 1)
  have h2 : ∀ j ∈ range (n + 1), q ^ (j + 1) * qBinom q (n + 1) (j + 1) * x ^ (j + 1)
      = q ^ (n + 1) * (qBinom q n j * x ^ j) * x
        + q ^ (j + 1) * qBinom q n (j + 1) * x ^ (j + 1) := by
    intro j hj
    simp only [Finset.mem_range] at hj
    have he : q ^ (j + 1) * q ^ (n - j) = q ^ (n + 1) := by
      rw [← pow_add]; congr 1; omega
    rw [qBinom_succ_succ' q n j]
    linear_combination qBinom q n j * x ^ (j + 1) * he
  rw [h1, Finset.sum_congr rfl h2, Finset.sum_add_distrib, qRSW_shift, qBinom_zero_right,
    ← Finset.sum_mul, ← Finset.mul_sum]
  simp only [qRS]
  ring

/-- **The Rogers–Szegő three-term ladder**:
`H_{n+2}(x) = (1+x) H_{n+1}(x) + (q^{n+1} - 1) x H_n(x)`. -/
theorem qRS_rec (q x : R) (n : ℕ) :
    qRS q x (n + 2) = (1 + x) * qRS q x (n + 1) + (q ^ (n + 1) - 1) * x * qRS q x n := by
  have h1 := qRS_succ q x (n + 1)
  have h2 := qRSW_succ q x n
  have h3 := qRS_succ q x n
  linear_combination h1 + h2 - h3

@[simp] lemma qRS_zero (q x : R) : qRS q x 0 = 1 := by simp [qRS]

@[simp] lemma qRS_one_index (q x : R) : qRS q x 1 = 1 + x := by
  simp [qRS, Finset.sum_range_succ]

/-- At `x = -1` the ladder degenerates to a two-step recursion: Gauss' evaluation
`H_{2m+1}(-1) = 0`. -/
theorem qRS_neg_one_odd (q : R) (m : ℕ) : qRS q (-1) (2 * m + 1) = 0 := by
  induction m with
  | zero => simp
  | succ m ih =>
      have h := qRS_rec q (-1 : R) (2 * m + 1)
      rw [show 2 * (m + 1) + 1 = 2 * m + 1 + 2 by ring, h, ih]
      ring

/-- Gauss' evaluation of the even Rogers–Szegő polynomials at `x = -1`:
`H_{2m}(-1) = ∏_{i<m} (1 - q^{2i+1})`. -/
theorem qRS_neg_one_even (q : R) (m : ℕ) :
    qRS q (-1) (2 * m) = ∏ i ∈ range m, (1 - q ^ (2 * i + 1)) := by
  induction m with
  | zero => simp
  | succ m ih =>
      have h := qRS_rec q (-1 : R) (2 * m)
      rw [show 2 * (m + 1) = 2 * m + 2 by ring, h, qRS_neg_one_odd, ih,
        Finset.prod_range_succ]
      ring

/-- The Goldman–Rota recurrence is the `x = 1` slice of the Rogers–Szegő ladder. -/
theorem qGalois_rec_of_qRS (q : R) (n : ℕ) :
    qGalois q (n + 2) = 2 * qGalois q (n + 1) + (q ^ (n + 1) - 1) * qGalois q n := by
  have h := qRS_rec q (1 : R) n
  simp only [qRS_one, mul_one] at h
  rw [h]
  ring

end Catalog.Applications.QBinomial