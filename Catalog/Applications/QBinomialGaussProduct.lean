/-
# Gauss product formula, symmetry, Gauss' alternating sum, and Galois numbers

A second cycle of results built directly on `Applications.QVandermondeQBinomial`.

* `qBinom_mul_qPoch` — the **division-free product formula**
  `⟦n,k⟧_q · (q;q)_k · (q;q)_{n-k} = (q;q)_n`, where `(q;q)_m = ∏_{i<m}(1-q^{i+1})`
  is the `q`-Pochhammer symbol.  This identifies the recursively defined
  `qBinom` with the classical closed form `(q;q)_n / ((q;q)_k (q;q)_{n-k})`
  wherever the denominators are invertible, but is stated so that it holds in
  *every* commutative ring.
* `qBinom_symm` — the symmetry `⟦n,k⟧_q = ⟦n,n-k⟧_q`, deduced from the product
  formula by cancelling in the universal integral domain `ℤ[X]` and then
  specialising.
* `qBinom_alternating_sum` — **Gauss' alternating sum identity**
  `∑_k (-1)^k q^{k(k-1)/2} ⟦n,k⟧_q = 0` for `n ≥ 1`, a degenerate value of
  Rothe's theorem at `x = -1`.
* `qGalois_rec` — the **Goldman–Rota recurrence** for the Galois numbers
  `G_n = ∑_k ⟦n,k⟧_q` (the number of subspaces of `𝔽_q^n` when `q` is a prime
  power): `G_{n+2} = 2 G_{n+1} + (q^{n+1} - 1) G_n`.
* `qBinom_vandermonde'` — the reflected form of the q-Vandermonde convolution.
-/

import Applications.QVandermondeQBinomial

namespace Catalog.Applications.QBinomial

open Finset Polynomial

/-! ## The q-Pochhammer symbol and the product formula -/

variable {R : Type*} [CommRing R]

/-- The `q`-Pochhammer symbol `(q;q)_m = ∏_{i<m} (1 - q^{i+1})`. -/
def qPoch (q : R) (m : ℕ) : R := ∏ i ∈ range m, (1 - q ^ (i + 1))

@[simp] lemma qPoch_zero (q : R) : qPoch q 0 = 1 := by simp [qPoch]

lemma qPoch_succ (q : R) (m : ℕ) : qPoch q (m + 1) = qPoch q m * (1 - q ^ (m + 1)) := by
  rw [qPoch, qPoch, Finset.prod_range_succ]

/-- **The division-free Gauss product formula.**  For `k ≤ n`,
`⟦n,k⟧_q · (q;q)_k · (q;q)_{n-k} = (q;q)_n`. -/
theorem qBinom_mul_qPoch (q : R) : ∀ {n k : ℕ}, k ≤ n →
    qBinom q n k * qPoch q k * qPoch q (n - k) = qPoch q n := by
  intro n
  induction n with
  | zero =>
      intro k hk
      obtain rfl : k = 0 := by omega
      simp
  | succ n ih =>
      intro k hk
      match k with
      | 0 => simp
      | (k + 1) =>
          rcases Nat.lt_or_ge n (k + 1) with h | h
          · obtain rfl : k = n := by omega
            simp
          · have h1 := ih (show k ≤ n by omega)
            have h2 := ih (show k + 1 ≤ n by omega)
            have e1 : qPoch q (k + 1) = qPoch q k * (1 - q ^ (k + 1)) := qPoch_succ q k
            have e2 : qPoch q (n - k) = qPoch q (n - (k + 1)) * (1 - q ^ (n - k)) := by
              rw [show n - k = (n - (k + 1)) + 1 by omega, qPoch_succ]
            have e4 : q ^ (k + 1) * q ^ (n - k) = q ^ (n + 1) := by
              rw [← pow_add]; congr 1; omega
            rw [e2] at h1
            rw [e1] at h2
            rw [show n + 1 - (k + 1) = n - k by omega, qBinom_succ_succ, qPoch_succ q n, e1, e2]
            linear_combination (1 - q ^ (k + 1)) * h1 + q ^ (k + 1) * (1 - q ^ (n - k)) * h2
              - qPoch q n * e4

/-! ## Symmetry, via cancellation in the universal ring `ℤ[X]` -/

lemma qPoch_int_ne_zero (m : ℕ) : qPoch (X : ℤ[X]) m ≠ 0 := by
  rw [qPoch]
  refine Finset.prod_ne_zero_iff.mpr fun i _ h => ?_
  have := congrArg (fun p : ℤ[X] => p.coeff 0) h
  simp [Polynomial.coeff_X_pow] at this

lemma qBinom_symm_int {n k : ℕ} (h : k ≤ n) :
    qBinom (X : ℤ[X]) n k = qBinom (X : ℤ[X]) n (n - k) := by
  have h1 := qBinom_mul_qPoch (X : ℤ[X]) h
  have h2 := qBinom_mul_qPoch (X : ℤ[X]) (show n - k ≤ n by omega)
  rw [show n - (n - k) = k by omega] at h2
  have hne : qPoch (X : ℤ[X]) k * qPoch (X : ℤ[X]) (n - k) ≠ 0 :=
    mul_ne_zero (qPoch_int_ne_zero k) (qPoch_int_ne_zero (n - k))
  refine mul_right_cancel₀ hne ?_
  linear_combination h1 - h2

/-- **Symmetry of Gaussian binomial coefficients**: `⟦n,k⟧_q = ⟦n,n-k⟧_q` for `k ≤ n`. -/
theorem qBinom_symm (q : R) {n k : ℕ} (h : k ≤ n) : qBinom q n k = qBinom q n (n - k) := by
  have hmap := congrArg (fun p : ℤ[X] => Polynomial.aeval q p) (qBinom_symm_int h)
  simpa [aeval_qBinom] using hmap

/-! ## Gauss' alternating sum identity -/

/-- **Gauss' alternating sum**: for `n ≥ 1`,
`∑_{k ≤ n} (-1)^k q^{k(k-1)/2} ⟦n,k⟧_q = 0`.
This is Rothe's theorem evaluated at the "annihilating" point `x = -1`, where the
`i = 0` factor of the product vanishes. -/
theorem qBinom_alternating_sum (q : R) {n : ℕ} (hn : 0 < n) :
    ∑ k ∈ range (n + 1), (-1 : R) ^ k * q ^ (k.choose 2) * qBinom q n k = 0 := by
  have h := qBinom_rothe q (-1 : R) n
  have hz : ∏ i ∈ range n, (1 + q ^ i * (-1 : R)) = 0 :=
    Finset.prod_eq_zero (Finset.mem_range.mpr hn) (by simp)
  rw [hz] at h
  refine Eq.trans (Finset.sum_congr rfl fun k _ => ?_) h.symm
  ring

/-! ## Galois numbers and the Goldman–Rota recurrence -/

/-- The `q`-Galois number `G_n = ∑_{k ≤ n} ⟦n,k⟧_q`.  For a prime power `q` this
counts all subspaces of `𝔽_q^n`. -/
def qGalois (q : R) (n : ℕ) : R := ∑ k ∈ range (n + 1), qBinom q n k

/-- The `q`-weighted Galois number `W_n = ∑_{k ≤ n} q^k ⟦n,k⟧_q`. -/
def qGaloisW (q : R) (n : ℕ) : R := ∑ k ∈ range (n + 1), q ^ k * qBinom q n k

lemma qGaloisW_shift (q : R) (n : ℕ) :
    ∑ j ∈ range (n + 1), q ^ (j + 1) * qBinom q n (j + 1) = qGaloisW q n - 1 := by
  have h1 : ∑ k ∈ range (n + 1 + 1), q ^ k * qBinom q n k
      = (∑ j ∈ range (n + 1), q ^ (j + 1) * qBinom q n (j + 1)) + q ^ 0 * qBinom q n 0 :=
    Finset.sum_range_succ' _ (n + 1)
  have h2 : ∑ k ∈ range (n + 1 + 1), q ^ k * qBinom q n k
      = qGaloisW q n + q ^ (n + 1) * qBinom q n (n + 1) := Finset.sum_range_succ _ (n + 1)
  rw [qBinom_eq_zero_of_lt q (by omega : n < n + 1)] at h2
  rw [qBinom_zero_right, pow_zero] at h1
  linear_combination h2 - h1

lemma qGalois_succ (q : R) (n : ℕ) : qGalois q (n + 1) = qGalois q n + qGaloisW q n := by
  have h1 : qGalois q (n + 1)
      = (∑ j ∈ range (n + 1), qBinom q (n + 1) (j + 1)) + qBinom q (n + 1) 0 :=
    Finset.sum_range_succ' _ (n + 1)
  have h2 : ∀ j ∈ range (n + 1),
      qBinom q (n + 1) (j + 1) = qBinom q n j + q ^ (j + 1) * qBinom q n (j + 1) :=
    fun j _ => qBinom_succ_succ q n j
  rw [h1, Finset.sum_congr rfl h2, Finset.sum_add_distrib, qGaloisW_shift, qBinom_zero_right]
  show qGalois q n + (qGaloisW q n - 1) + 1 = _
  ring

lemma qGaloisW_succ (q : R) (n : ℕ) :
    qGaloisW q (n + 1) = q ^ (n + 1) * qGalois q n + qGaloisW q n := by
  have h1 : qGaloisW q (n + 1)
      = (∑ j ∈ range (n + 1), q ^ (j + 1) * qBinom q (n + 1) (j + 1))
        + q ^ 0 * qBinom q (n + 1) 0 := Finset.sum_range_succ' _ (n + 1)
  have h2 : ∀ j ∈ range (n + 1), q ^ (j + 1) * qBinom q (n + 1) (j + 1)
      = q ^ (n + 1) * qBinom q n j + q ^ (j + 1) * qBinom q n (j + 1) := by
    intro j hj
    simp only [Finset.mem_range] at hj
    have he : q ^ (j + 1) * q ^ (n - j) = q ^ (n + 1) := by
      rw [← pow_add]; congr 1; omega
    rw [qBinom_succ_succ' q n j]
    linear_combination qBinom q n j * he
  rw [h1, Finset.sum_congr rfl h2, Finset.sum_add_distrib, qGaloisW_shift, ← Finset.mul_sum,
    qBinom_zero_right, pow_zero]
  simp only [qGalois]
  ring

/-- **The Goldman–Rota recurrence for Galois numbers**:
`G_{n+2} = 2 G_{n+1} + (q^{n+1} - 1) G_n`.  For a prime power `q` this is the
recurrence satisfied by the total number of subspaces of `𝔽_q^n`. -/
theorem qGalois_rec (q : R) (n : ℕ) :
    qGalois q (n + 2) = 2 * qGalois q (n + 1) + (q ^ (n + 1) - 1) * qGalois q n := by
  have h1 := qGalois_succ q (n + 1)
  have h2 := qGaloisW_succ q n
  have h3 := qGalois_succ q n
  linear_combination h1 + h2 - h3

/-- At `q = 1` the Galois numbers degenerate to `2^n`, and the Goldman–Rota
recurrence degenerates to `2^{n+2} = 2·2^{n+1}`. -/
theorem qGalois_one (n : ℕ) : qGalois (1 : ℤ) n = 2 ^ n := by
  have : qGalois (1 : ℤ) n = ∑ k ∈ range (n + 1), (n.choose k : ℤ) := by
    simp [qGalois, qBinom_one_eq_choose]
  rw [this, ← Nat.cast_sum, Nat.sum_range_choose]
  push_cast
  ring

/-! ## The reflected q-Vandermonde convolution -/

/-- The reflected form of the q-Vandermonde convolution:
`⟦m+n,k⟧_q = ∑_{j ≤ k} q^{j(n-(k-j))} ⟦m,j⟧_q ⟦n,k-j⟧_q`. -/
theorem qBinom_vandermonde' (q : R) (m n k : ℕ) :
    qBinom q (m + n) k =
      ∑ j ∈ range (k + 1), q ^ (j * (n - (k - j))) * qBinom q m j * qBinom q n (k - j) := by
  rw [add_comm m n, qBinom_vandermonde q n m k, ← Finset.sum_range_reflect]
  refine Finset.sum_congr rfl fun j hj => ?_
  simp only [Finset.mem_range, Nat.add_sub_cancel] at hj ⊢
  rw [show k - (k - j) = j by omega, Nat.mul_comm]
  ring

end Catalog.Applications.QBinomial