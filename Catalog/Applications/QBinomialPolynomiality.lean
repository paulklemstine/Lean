/-
# Polynomiality of Gaussian binomial coefficients

Third cycle.  The universal Gaussian binomial coefficient `⟦n,k⟧_X ∈ ℤ[X]`
obtained by taking `q = X` is a genuine polynomial invariant, and this file
pins down its shape:

* `qBinom_int_monic` / `qBinom_int_natDegree` — for `k ≤ n` the polynomial
  `⟦n,k⟧_X` is **monic of degree `k(n-k)`** (the dimension of the Grassmannian
  cell decomposition);
* `qBinom_int_coeff_nonneg` — all its coefficients are **non-negative**, proved
  by factoring `⟦n,k⟧_X` through the semiring `ℕ[X]`;
* `qBinom_int_eval_one` — evaluating at `q = 1` returns `Nat.choose n k`, so the
  coefficients of `⟦n,k⟧_X` are a partition of the binomial coefficient (the
  Gaussian coefficient is a genuine `q`-analogue);
* `qBinom_sq_sum` — the `q`-analogue of `∑_j C(n,j)^2 = C(2n,n)`, namely
  `⟦2n,n⟧_q = ∑_j q^{(n-j)^2} ⟦n,j⟧_q^2`, obtained by combining the
  q-Vandermonde convolution with the symmetry `⟦n,j⟧ = ⟦n,n-j⟧`.
-/

import Applications.QBinomialGaussProduct

namespace Catalog.Applications.QBinomial

open Finset Polynomial

/-! ## Monicity and degree over `ℤ[X]` -/

/-- For `k ≤ n`, the universal Gaussian binomial `⟦n,k⟧_X ∈ ℤ[X]` is monic of
degree `k(n-k)`. -/
theorem qBinom_int_monic_natDegree : ∀ {n k : ℕ}, k ≤ n →
    (qBinom (X : ℤ[X]) n k).Monic ∧ (qBinom (X : ℤ[X]) n k).natDegree = k * (n - k) := by
  intro n
  induction n with
  | zero =>
      intro k hk
      obtain rfl : k = 0 := by omega
      simp [monic_one]
  | succ n ih =>
      intro k hk
      match k with
      | 0 => simp [monic_one]
      | (k + 1) =>
          rcases Nat.lt_or_ge n (k + 1) with h | h
          · obtain rfl : k = n := by omega
            simp [monic_one]
          · obtain ⟨hm1, hd1⟩ := ih (show k ≤ n by omega)
            obtain ⟨hm2, hd2⟩ := ih (show k + 1 ≤ n by omega)
            have hmul : ((X : ℤ[X]) ^ (k + 1) * qBinom (X : ℤ[X]) n (k + 1)).Monic :=
              (monic_X_pow (k + 1)).mul hm2
            have hdmul : ((X : ℤ[X]) ^ (k + 1) * qBinom (X : ℤ[X]) n (k + 1)).natDegree
                = (k + 1) * (n - k) := by
              rw [natDegree_mul (by exact (monic_X_pow (k + 1)).ne_zero) hm2.ne_zero,
                natDegree_X_pow, hd2]
              have : n - (k + 1) + 1 = n - k := by omega
              nlinarith [this]
            have hlt : (qBinom (X : ℤ[X]) n k).natDegree
                < ((X : ℤ[X]) ^ (k + 1) * qBinom (X : ℤ[X]) n (k + 1)).natDegree := by
              rw [hd1, hdmul]
              have hnk : 1 ≤ n - k := by omega
              nlinarith
            constructor
            · rw [qBinom_succ_succ]
              exact hmul.add_of_right (degree_lt_degree hlt)
            · rw [qBinom_succ_succ, natDegree_add_eq_right_of_natDegree_lt hlt, hdmul]
              congr 1
              omega

theorem qBinom_int_monic {n k : ℕ} (h : k ≤ n) : (qBinom (X : ℤ[X]) n k).Monic :=
  (qBinom_int_monic_natDegree h).1

theorem qBinom_int_natDegree {n k : ℕ} (h : k ≤ n) :
    (qBinom (X : ℤ[X]) n k).natDegree = k * (n - k) :=
  (qBinom_int_monic_natDegree h).2

/-! ## Non-negativity of the coefficients -/

/-- `⟦n,k⟧_X ∈ ℤ[X]` is the image of the corresponding element of the *semiring*
`ℕ[X]`; this is the structural reason its coefficients are non-negative. -/
lemma qBinom_int_eq_map_nat (n k : ℕ) :
    qBinom (X : ℤ[X]) n k = Polynomial.map (Nat.castRingHom ℤ) (qBinom (X : ℕ[X]) n k) := by
  have h := map_qBinom (Polynomial.mapRingHom (Nat.castRingHom ℤ)) (X : ℕ[X]) n k
  simpa [Polynomial.coe_mapRingHom, Polynomial.map_X] using h.symm

theorem qBinom_int_coeff_nonneg (n k i : ℕ) : 0 ≤ (qBinom (X : ℤ[X]) n k).coeff i := by
  rw [qBinom_int_eq_map_nat, Polynomial.coeff_map]
  exact Int.natCast_nonneg _

/-- Evaluating the universal Gaussian binomial at `q = 1` gives the ordinary
binomial coefficient. -/
theorem qBinom_int_eval_one (n k : ℕ) :
    (qBinom (X : ℤ[X]) n k).eval 1 = (n.choose k : ℤ) := by
  have h := aeval_qBinom (1 : ℤ) n k
  rw [qBinom_one_eq_choose] at h
  simpa [Polynomial.aeval_def, Polynomial.eval₂_eq_eval_map, Polynomial.eval_map] using h

/-! ## The q-analogue of `∑_j C(n,j)^2 = C(2n,n)` -/

variable {R : Type*} [CommRing R]

/-- `⟦2n,n⟧_q = ∑_{j ≤ n} q^{(n-j)^2} ⟦n,j⟧_q^2`: the q-analogue of the central
binomial identity, obtained from q-Vandermonde together with the symmetry
`⟦n,n-j⟧_q = ⟦n,j⟧_q`. -/
theorem qBinom_sq_sum (q : R) (n : ℕ) :
    qBinom q (n + n) n =
      ∑ j ∈ range (n + 1), q ^ ((n - j) * (n - j)) * qBinom q n j * qBinom q n j := by
  rw [qBinom_vandermonde q n n n]
  refine Finset.sum_congr rfl fun j hj => ?_
  simp only [Finset.mem_range] at hj
  rw [← qBinom_symm q (show j ≤ n by omega)]

end Catalog.Applications.QBinomial